#!/usr/bin/env python3
"""
SQL-to-Blueprint: Query a SQLite database and generate Blueprint Typst diagrams.

This script demonstrates a pipeline from relational data to hierarchical diagrams:
  1. Creates a complex SQLite schema (datacenters, racks, servers, NICs, storage, switches, links)
  2. Populates it with realistic sample data
  3. Queries the hierarchy and connections
  4. Generates Blueprint Typst code with relative positioning and Manhattan routing

Usage:
    python3 tools/sql_to_blueprint.py [--db PATH] [--output PATH] [--query SCOPE]

    --db       SQLite database path (default: tools/infra.db, created if missing)
    --output   Output .typ file path (default: stdout)
    --query    What to render: "all", "rack:NAME", "dc:NAME" (default: "all")
"""

import argparse
import sqlite3
import sys
import textwrap
from pathlib import Path

# ─── Schema ──────────────────────────────────────────────────────────────────

SCHEMA = """
CREATE TABLE IF NOT EXISTS datacenters (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    location    TEXT,
    tier        INTEGER DEFAULT 3
);

CREATE TABLE IF NOT EXISTS racks (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    dc_id       INTEGER NOT NULL REFERENCES datacenters(id),
    row_num     INTEGER DEFAULT 1,
    position    INTEGER DEFAULT 1,
    height_u    INTEGER DEFAULT 42
);

CREATE TABLE IF NOT EXISTS switches (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    rack_id     INTEGER NOT NULL REFERENCES racks(id),
    model       TEXT,
    port_count  INTEGER DEFAULT 48,
    speed_gbps  INTEGER DEFAULT 10,
    role        TEXT DEFAULT 'tor'  -- tor, spine, leaf
);

CREATE TABLE IF NOT EXISTS servers (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    rack_id     INTEGER NOT NULL REFERENCES racks(id),
    cpu_model   TEXT,
    cpu_cores   INTEGER DEFAULT 8,
    ram_gb      INTEGER DEFAULT 64,
    role        TEXT DEFAULT 'compute'  -- compute, storage, gpu
);

CREATE TABLE IF NOT EXISTS nics (
    id          INTEGER PRIMARY KEY,
    server_id   INTEGER NOT NULL REFERENCES servers(id),
    name        TEXT NOT NULL,
    speed_gbps  INTEGER DEFAULT 10,
    mac         TEXT
);

CREATE TABLE IF NOT EXISTS disks (
    id          INTEGER PRIMARY KEY,
    server_id   INTEGER NOT NULL REFERENCES servers(id),
    name        TEXT NOT NULL,
    type        TEXT DEFAULT 'ssd',  -- ssd, nvme, hdd
    capacity_tb REAL DEFAULT 1.0
);

CREATE TABLE IF NOT EXISTS links (
    id          INTEGER PRIMARY KEY,
    src_type    TEXT NOT NULL,  -- 'nic', 'switch_port'
    src_id      INTEGER NOT NULL,
    dst_type    TEXT NOT NULL,
    dst_id      INTEGER NOT NULL,
    speed_gbps  INTEGER DEFAULT 10,
    cable_type  TEXT DEFAULT 'copper'  -- copper, fiber, dac
);

CREATE TABLE IF NOT EXISTS vlans (
    id          INTEGER PRIMARY KEY,
    vlan_id     INTEGER NOT NULL,
    name        TEXT NOT NULL,
    subnet      TEXT
);

CREATE TABLE IF NOT EXISTS vlan_assignments (
    id          INTEGER PRIMARY KEY,
    vlan_id     INTEGER NOT NULL REFERENCES vlans(id),
    nic_id      INTEGER REFERENCES nics(id),
    switch_id   INTEGER REFERENCES switches(id)
);
"""

# ─── Sample data ─────────────────────────────────────────────────────────────

SAMPLE_DATA = """
-- Datacenters
INSERT OR IGNORE INTO datacenters (id, name, location, tier) VALUES
    (1, 'DC-East', 'Virginia, US', 4),
    (2, 'DC-West', 'Oregon, US', 3);

-- Racks in DC-East
INSERT OR IGNORE INTO racks (id, name, dc_id, row_num, position) VALUES
    (1, 'Rack-A1', 1, 1, 1),
    (2, 'Rack-A2', 1, 1, 2),
    (3, 'Rack-B1', 1, 2, 1);

-- Racks in DC-West
INSERT OR IGNORE INTO racks (id, name, dc_id, row_num, position) VALUES
    (4, 'Rack-W1', 2, 1, 1);

-- Switches
INSERT OR IGNORE INTO switches (id, name, rack_id, model, port_count, speed_gbps, role) VALUES
    (1, 'ToR-A1',   1, 'Arista 7050X', 48, 10, 'tor'),
    (2, 'ToR-A2',   2, 'Arista 7050X', 48, 10, 'tor'),
    (3, 'Spine-B1', 3, 'Arista 7500R', 32, 40, 'spine'),
    (4, 'ToR-W1',   4, 'Cisco 9336C',  36, 25, 'tor');

-- Servers in Rack-A1
INSERT OR IGNORE INTO servers (id, name, rack_id, cpu_model, cpu_cores, ram_gb, role) VALUES
    (1, 'web-01',   1, 'Xeon 8380', 32, 256, 'compute'),
    (2, 'web-02',   1, 'Xeon 8380', 32, 256, 'compute'),
    (3, 'db-01',    1, 'Xeon 8380', 64, 512, 'compute');

-- Servers in Rack-A2
INSERT OR IGNORE INTO servers (id, name, rack_id, cpu_model, cpu_cores, ram_gb, role) VALUES
    (4, 'stor-01',  2, 'EPYC 7763', 32, 128, 'storage'),
    (5, 'stor-02',  2, 'EPYC 7763', 32, 128, 'storage');

-- Servers in Rack-B1 (spine has servers too)
INSERT OR IGNORE INTO servers (id, name, rack_id, cpu_model, cpu_cores, ram_gb, role) VALUES
    (6, 'mgmt-01',  3, 'Xeon 4314',  16, 64,  'compute');

-- Servers in DC-West
INSERT OR IGNORE INTO servers (id, name, rack_id, cpu_model, cpu_cores, ram_gb, role) VALUES
    (7, 'gpu-01',   4, 'EPYC 9654', 96, 1024, 'gpu'),
    (8, 'gpu-02',   4, 'EPYC 9654', 96, 1024, 'gpu');

-- NICs
INSERT OR IGNORE INTO nics (id, server_id, name, speed_gbps) VALUES
    (1,  1, 'eth0', 10),  (2,  1, 'eth1', 10),
    (3,  2, 'eth0', 10),  (4,  2, 'eth1', 10),
    (5,  3, 'eth0', 10),  (6,  3, 'eth1', 25),
    (7,  4, 'eth0', 25),  (8,  4, 'eth1', 25),
    (9,  5, 'eth0', 25),  (10, 5, 'eth1', 25),
    (11, 6, 'eth0', 10),
    (12, 7, 'eth0', 100), (13, 7, 'eth1', 100),
    (14, 8, 'eth0', 100), (15, 8, 'eth1', 100);

-- Disks
INSERT OR IGNORE INTO disks (id, server_id, name, type, capacity_tb) VALUES
    (1,  1, 'sda', 'ssd',  0.5),
    (2,  2, 'sda', 'ssd',  0.5),
    (3,  3, 'sda', 'nvme', 2.0),  (4, 3, 'sdb', 'nvme', 2.0),
    (5,  4, 'sda', 'hdd',  16.0), (6, 4, 'sdb', 'hdd', 16.0),
    (7,  4, 'sdc', 'hdd',  16.0), (8, 4, 'sdd', 'hdd', 16.0),
    (9,  5, 'sda', 'hdd',  16.0), (10, 5, 'sdb', 'hdd', 16.0),
    (11, 5, 'sdc', 'hdd',  16.0), (12, 5, 'sdd', 'hdd', 16.0),
    (13, 7, 'nvme0', 'nvme', 4.0), (14, 7, 'nvme1', 'nvme', 4.0),
    (15, 8, 'nvme0', 'nvme', 4.0), (16, 8, 'nvme1', 'nvme', 4.0);

-- Links: NIC to ToR switch
INSERT OR IGNORE INTO links (id, src_type, src_id, dst_type, dst_id, speed_gbps, cable_type) VALUES
    -- Rack-A1 servers → ToR-A1
    (1,  'nic', 1,  'switch_port', 1, 10, 'copper'),
    (2,  'nic', 3,  'switch_port', 1, 10, 'copper'),
    (3,  'nic', 5,  'switch_port', 1, 10, 'copper'),
    -- Rack-A2 servers → ToR-A2
    (4,  'nic', 7,  'switch_port', 2, 25, 'dac'),
    (5,  'nic', 9,  'switch_port', 2, 25, 'dac'),
    -- ToR uplinks to spine
    (6,  'switch_port', 1, 'switch_port', 3, 40, 'fiber'),
    (7,  'switch_port', 2, 'switch_port', 3, 40, 'fiber'),
    -- Rack-B1
    (8,  'nic', 11, 'switch_port', 3, 10, 'copper'),
    -- DC-West
    (9,  'nic', 12, 'switch_port', 4, 100, 'fiber'),
    (10, 'nic', 14, 'switch_port', 4, 100, 'fiber');

-- VLANs
INSERT OR IGNORE INTO vlans (id, vlan_id, name, subnet) VALUES
    (1, 100, 'management', '10.0.0.0/24'),
    (2, 200, 'production', '10.1.0.0/16'),
    (3, 300, 'storage',    '10.2.0.0/16'),
    (4, 400, 'gpu-fabric', '10.3.0.0/16');
"""

# ─── Database setup ──────────────────────────────────────────────────────────

def init_db(db_path: str) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.executescript(SCHEMA)
    conn.executescript(SAMPLE_DATA)
    conn.commit()
    return conn


# ─── Queries ─────────────────────────────────────────────────────────────────

def query_dc_hierarchy(conn: sqlite3.Connection, dc_name: str = None):
    """Query full datacenter hierarchy: DC → racks → (switches, servers → (nics, disks))"""
    dc_filter = "WHERE d.name = ?" if dc_name else ""
    params = (dc_name,) if dc_name else ()

    dcs = conn.execute(
        f"SELECT * FROM datacenters d {dc_filter} ORDER BY d.name", params
    ).fetchall()

    result = []
    for dc in dcs:
        racks = conn.execute(
            "SELECT * FROM racks WHERE dc_id = ? ORDER BY row_num, position",
            (dc["id"],)
        ).fetchall()

        rack_list = []
        for rack in racks:
            switches = conn.execute(
                "SELECT * FROM switches WHERE rack_id = ? ORDER BY name",
                (rack["id"],)
            ).fetchall()

            servers = conn.execute(
                "SELECT * FROM servers WHERE rack_id = ? ORDER BY name",
                (rack["id"],)
            ).fetchall()

            srv_list = []
            for srv in servers:
                nics = conn.execute(
                    "SELECT * FROM nics WHERE server_id = ? ORDER BY name",
                    (srv["id"],)
                ).fetchall()
                disks = conn.execute(
                    "SELECT * FROM disks WHERE server_id = ? ORDER BY name",
                    (srv["id"],)
                ).fetchall()
                srv_list.append({"server": srv, "nics": nics, "disks": disks})

            rack_list.append({
                "rack": rack,
                "switches": [dict(s) for s in switches],
                "servers": srv_list,
            })

        result.append({"dc": dc, "racks": rack_list})
    return result


def query_links_for_rack(conn: sqlite3.Connection, rack_id: int):
    """Get all network links involving NICs/switches in a given rack."""
    return conn.execute("""
        SELECT l.*,
               sn.name as src_nic_name, sn.server_id as src_server_id,
               dn.name as dst_nic_name, dn.server_id as dst_server_id
        FROM links l
        LEFT JOIN nics sn ON l.src_type = 'nic' AND l.src_id = sn.id
        LEFT JOIN nics dn ON l.dst_type = 'nic' AND l.dst_id = dn.id
        WHERE (l.src_type = 'nic' AND sn.server_id IN (SELECT id FROM servers WHERE rack_id = ?))
           OR (l.dst_type = 'nic' AND dn.server_id IN (SELECT id FROM servers WHERE rack_id = ?))
           OR (l.src_type = 'switch_port' AND l.src_id IN (SELECT id FROM switches WHERE rack_id = ?))
           OR (l.dst_type = 'switch_port' AND l.dst_id IN (SELECT id FROM switches WHERE rack_id = ?))
    """, (rack_id, rack_id, rack_id, rack_id)).fetchall()


def query_inter_rack_links(conn: sqlite3.Connection, dc_id: int):
    """Get links between switches in different racks within a DC."""
    return conn.execute("""
        SELECT l.*,
               s1.name as src_switch_name, s1.rack_id as src_rack_id,
               s2.name as dst_switch_name, s2.rack_id as dst_rack_id
        FROM links l
        JOIN switches s1 ON l.src_type = 'switch_port' AND l.src_id = s1.id
        JOIN switches s2 ON l.dst_type = 'switch_port' AND l.dst_id = s2.id
        WHERE s1.rack_id != s2.rack_id
          AND s1.rack_id IN (SELECT id FROM racks WHERE dc_id = ?)
    """, (dc_id,)).fetchall()


# ─── Color palettes ─────────────────────────────────────────────────────────

ROLE_COLORS = {
    "tor":     ("#e8f5e9", "#2e7d32"),
    "spine":   ("#e1f5fe", "#01579b"),
    "leaf":    ("#e8f5e9", "#33691e"),
    "compute": ("#e3f2fd", "#1565c0"),
    "storage": ("#fff3e0", "#e65100"),
    "gpu":     ("#fce4ec", "#880e4f"),
}

CABLE_COLORS = {
    "copper": "#66bb6a",
    "dac":    "#ff9800",
    "fiber":  "#e53935",
}


def color_for(role: str):
    fill, stroke = ROLE_COLORS.get(role, ("#fafafa", "#333333"))
    return fill, stroke


# ─── Typst code generation ───────────────────────────────────────────────────

def sanitize(name: str) -> str:
    """Make a name safe for Typst variable identifiers."""
    return name.replace("-", "-").replace(" ", "-").replace(".", "-").lower()


def gen_server_factory(srv, nics, disks):
    """Generate a make-server function call for a specific server."""
    sid = sanitize(srv["name"])
    fill, stroke = color_for(srv["role"])

    # Build primitive rects for internals
    prims = []
    x = 0.2  # cm offset inside component

    def fmt_x(v):
        """Format cm value cleanly."""
        return f"{v:.1f}".rstrip('0').rstrip('.')

    # CPU
    cpu_label = f'{srv["cpu_cores"]}c'
    prims.append(
        f'    blueprint.primitive-rect(({fmt_x(x)}cm, 0.15cm), (0.7cm, 0.4cm), '
        f'fill: rgb("{fill}"), stroke: 0.8pt + rgb("{stroke}"), radius: 1pt, '
        f'label: "{cpu_label}")'
    )
    x += 0.9

    # RAM
    ram_label = f'{srv["ram_gb"]}G'
    prims.append(
        f'    blueprint.primitive-rect(({fmt_x(x)}cm, 0.15cm), (0.6cm, 0.4cm), '
        f'fill: rgb("{fill}"), stroke: 0.8pt + rgb("{stroke}"), radius: 1pt, '
        f'label: "{ram_label}")'
    )
    x += 0.8

    # NICs
    for nic in nics:
        nic_label = f'{nic["speed_gbps"]}G'
        prims.append(
            f'    blueprint.primitive-rect(({fmt_x(x)}cm, 0.15cm), (0.5cm, 0.4cm), '
            f'fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, '
            f'label: "{nic_label}")'
        )
        x += 0.65

    # Disks (if few enough to show)
    if len(disks) <= 4:
        for d in disks:
            d_label = f'{d["type"]}'
            prims.append(
                f'    blueprint.primitive-rect(({fmt_x(x)}cm, 0.15cm), (0.5cm, 0.4cm), '
                f'fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, '
                f'label: "{d_label}")'
            )
            x += 0.65
    elif disks:
        d_label = f'{len(disks)}x{disks[0]["type"]}'
        prims.append(
            f'    blueprint.primitive-rect(({fmt_x(x)}cm, 0.15cm), (0.7cm, 0.4cm), '
            f'fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, '
            f'label: "{d_label}")'
        )
        x += 0.85

    prims_str = ",\n".join(prims)

    # Connectors: one eth connector on top per NIC
    conns = []
    n_nics = len(nics)
    for i, nic in enumerate(nics):
        offset = (i + 1) / (n_nics + 1)
        conns.append(
            f'    blueprint.connector("{nic["name"]}", (0pt, 0pt), '
            f'side: "top", offset: {offset:.2f}, style: conn-eth)'
        )
    conns_str = ",\n".join(conns)

    return f"""\
#let {sid} = blueprint.component(
  "{srv['name']} ({srv['role']})",
  (
{prims_str},
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("{fill}"), stroke: 1.5pt + rgb("{stroke}"), radius: 2pt),
  connectors: (
{conns_str},
  ),
)"""


def gen_switch_factory(sw):
    """Generate a switch component."""
    sid = sanitize(sw["name"])
    fill, stroke = color_for(sw["role"])
    speed = sw["speed_gbps"]
    ports = sw["port_count"]

    return f"""\
#let {sid} = blueprint.component(
  "{sw['name']} ({sw['model']})",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (2.5cm, 0.5cm),
      fill: rgb("{fill}"), stroke: 0.8pt + rgb("{stroke}"), radius: 2pt,
      label: "{ports}x {speed}GbE"),
  ),
  border: true, border-shape: "rect", margin: 2mm,
  style: (fill: rgb("{fill}"), stroke: 2pt + rgb("{stroke}"), radius: 3pt),
  connectors: (
    blueprint.connector("uplink", (0pt, 0pt), side: "top", offset: 0.5, style: conn-uplink),
    blueprint.connector("dl-1", (0pt, 0pt), side: "bottom", offset: 0.2, style: conn-eth),
    blueprint.connector("dl-2", (0pt, 0pt), side: "bottom", offset: 0.4, style: conn-eth),
    blueprint.connector("dl-3", (0pt, 0pt), side: "bottom", offset: 0.6, style: conn-eth),
    blueprint.connector("dl-4", (0pt, 0pt), side: "bottom", offset: 0.8, style: conn-eth),
  ),
)"""


def gen_rack_assembly(rack_data):
    """Generate placement + assembly for a rack."""
    rack = rack_data["rack"]
    rack_sid = sanitize(rack["name"])
    switches = rack_data["switches"]
    servers = rack_data["servers"]

    lines = []
    lines.append(f"// ── {rack['name']} assembly (using stack combinator) ──")

    # Collect component names: servers bottom-to-top, then switches on top
    comp_names = []
    placed_names = []

    for srv_data in reversed(servers):
        sid = sanitize(srv_data["server"]["name"])
        comp_names.append(sid)
        placed_names.append(f"{rack_sid}-items.at({len(comp_names) - 1})")

    for sw in switches:
        swid = sanitize(sw["name"])
        comp_names.append(swid)
        placed_names.append(f"{rack_sid}-items.at({len(comp_names) - 1})")

    if not comp_names:
        return ""

    # Use stack() combinator for the whole rack
    items_list = ", ".join(comp_names)
    lines.append(
        f"#let {rack_sid}-items = blueprint.stack(\n"
        f"  ({items_list},),\n"
        f"  start: (0.3cm, 0.3cm), direction: \"up\", gap: 4mm,\n"
        f")"
    )

    # Create named variables for edge connection lookups
    for i, srv_data in enumerate(reversed(servers)):
        sid = sanitize(srv_data["server"]["name"])
        lines.append(f"#let {rack_sid}-{sid} = {rack_sid}-items.at({i})")

    for j, sw in enumerate(switches):
        swid = sanitize(sw["name"])
        idx = len(servers) + j
        lines.append(f"#let {rack_sid}-{swid} = {rack_sid}-items.at({idx})")

    # Assemble rack
    items_str = f"..{rack_sid}-items"
    lines.append(f"""
#let {rack_sid} = blueprint.component(
  "{rack['name']}",
  ({items_str},),
  border: true, border-shape: "rect", margin: 3mm,
  style: (fill: rgb("#fafafa"), stroke: 2pt + black, radius: 4pt),
)""")

    return "\n".join(lines)


def gen_rack_edges(rack_data, conn):
    """Generate edge connections within a rack (NIC → switch downlink)."""
    rack = rack_data["rack"]
    rack_sid = sanitize(rack["name"])
    switches = rack_data["switches"]
    servers = rack_data["servers"]

    links = query_links_for_rack(conn, rack["id"])

    lines = []
    lines.append(f"  // Edges for {rack['name']}")

    dl_counter = {}  # switch_id → next downlink index

    for link in links:
        if link["src_type"] == "nic" and link["dst_type"] == "switch_port":
            # NIC → switch
            src_srv = None
            src_nic_name = link["src_nic_name"]
            for sd in servers:
                if sd["server"]["id"] == link["src_server_id"]:
                    src_srv = sd["server"]
                    break

            dst_sw = None
            for sw in switches:
                if sw["id"] == link["dst_id"]:
                    dst_sw = sw
                    break

            if not src_srv or not dst_sw:
                continue

            srv_var = f"{rack_sid}-{sanitize(src_srv['name'])}"
            sw_var = f"{rack_sid}-{sanitize(dst_sw['name'])}"

            # Assign downlink port
            sw_id = dst_sw["id"]
            if sw_id not in dl_counter:
                dl_counter[sw_id] = 1
            else:
                dl_counter[sw_id] += 1
            dl_idx = min(dl_counter[sw_id], 4)

            cable = link["cable_type"] if link["cable_type"] else "copper"
            color = CABLE_COLORS.get(cable, "#333333")
            speed = link["speed_gbps"]

            speed_label = f"{speed}G"
            lines.append(
                f"  blueprint.connect-points("
                f"conn-abs({sw_var}, \"dl-{dl_idx}\"), "
                f"conn-abs({srv_var}, \"{src_nic_name}\"), "
                f"style: blueprint.edge-style(\"\", stroke: 1pt + rgb(\"{color}\"), marks: \"->\", label: \"{speed_label}\"), "
                f"routing: \"manhattan\", from-side: \"bottom\", to-side: \"top\")"
            )

    return "\n".join(lines)


def generate_typst(hierarchy, conn: sqlite3.Connection, scope: str = "all"):
    """Generate complete Blueprint Typst file from DB hierarchy."""
    out = []

    out.append("""\
/// Auto-generated from SQLite database by sql_to_blueprint.py
#import "/src/exports.typ" as blueprint

#set page(width: 22cm, height: 32cm, margin: 0.5cm)

// ── Connector styles ──────────────────────────────────────────────

#let conn-eth = (size: 2.5pt, shape: "square", fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"))
#let conn-uplink = (size: 3pt, shape: "square", fill: rgb("#bbdefb"), stroke: 0.8pt + rgb("#1565c0"))

// ── Helper ────────────────────────────────────────────────────────

#let conn-abs(child, conn-name) = {
  let pos = child.position
  let (px, py) = if type(pos) == array { pos } else { (0pt, 0pt) }
  let c = blueprint.get-connector(child, conn-name)
  let (cx, cy) = if type(c.position) == array { c.position } else { (0pt, 0pt) }
  (px + cx, py + cy)
}
""")

    # Generate all component factories
    out.append("// ── Component definitions (from DB) ──────────────────────────────\n")

    for dc_data in hierarchy:
        for rack_data in dc_data["racks"]:
            for sw in rack_data["switches"]:
                out.append(gen_switch_factory(sw))
                out.append("")

            for srv_data in rack_data["servers"]:
                out.append(gen_server_factory(
                    srv_data["server"], srv_data["nics"], srv_data["disks"]
                ))
                out.append("")

    # Generate rack assemblies
    out.append("// ── Rack assemblies (relative positioning) ───────────────────────\n")

    for dc_data in hierarchy:
        for rack_data in dc_data["racks"]:
            out.append(gen_rack_assembly(rack_data))
            out.append("")

    # Render each rack with edges
    for dc_data in hierarchy:
        dc = dc_data["dc"]
        out.append(f"// ── {dc['name']} ({dc['location']}) ── Detailed views ──────\n")

        for rack_data in dc_data["racks"]:
            rack = rack_data["rack"]
            rack_sid = sanitize(rack["name"])

            out.append(f"// {rack['name']} — detailed with edges")
            out.append("#{")
            out.append(f"  blueprint.cetz.canvas({{")
            out.append(f"    blueprint.draw-content({rack_sid})")
            out.append(gen_rack_edges(rack_data, conn))
            out.append(f"  }})")
            out.append("}")
            out.append("")

    # Collapsed views
    out.append("// ── Collapsed views ──────────────────────────────────────────────\n")
    for dc_data in hierarchy:
        for rack_data in dc_data["racks"]:
            rack_sid = sanitize(rack_data["rack"]["name"])
            out.append(f'#blueprint.render({rack_sid}, mode: "collapsed")')
    out.append("")

    return "\n".join(out)


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Generate Blueprint Typst diagrams from SQLite")
    parser.add_argument("--db", default="tools/infra.db", help="SQLite database path")
    parser.add_argument("--output", default=None, help="Output .typ file (default: stdout)")
    parser.add_argument("--query", default="all", help="Scope: all, dc:NAME, rack:NAME")
    args = parser.parse_args()

    db_path = Path(args.db)
    conn = init_db(str(db_path))

    dc_name = None
    if args.query.startswith("dc:"):
        dc_name = args.query[3:]

    hierarchy = query_dc_hierarchy(conn, dc_name)

    if not hierarchy:
        print(f"No data found for query: {args.query}", file=sys.stderr)
        sys.exit(1)

    typst_code = generate_typst(hierarchy, conn, args.query)

    if args.output:
        Path(args.output).write_text(typst_code)
        print(f"Generated {args.output}", file=sys.stderr)
    else:
        print(typst_code)

    conn.close()


if __name__ == "__main__":
    main()
