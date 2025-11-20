# Blueprint - Task runner

# Default task: show available tasks
default:
    @just --list

# Install dependencies locally
install:
    #!/usr/bin/env bash
    set -e
    
    echo "Installing local dependencies..."
    
    # Check prerequisites
    typst --version || (echo "ERROR: Typst not found. Please install Typst first." && exit 1)
    cargo --version || (echo "ERROR: Cargo not found. Please install Rust first." && exit 1)
    
    # Install utpm if not available
    if ! command -v utpm &> /dev/null; then
        echo "Installing utpm..."
        cargo install --git https://github.com/Thumuss/utpm
    fi
    
    # Install Tytanic using cargo install
    # Version is managed in Cargo.toml
    echo "Installing Tytanic from Cargo.toml..."
    mkdir -p bin
    
    # Read version from Cargo.toml
    TYTANIC_VERSION=$(grep -A 2 'tytanic =' Cargo.toml | grep 'version' | sed 's/.*version = "\([^"]*\)".*/\1/' || echo "0.3.1")
    echo "Installing Tytanic version: $TYTANIC_VERSION"
    
    # Remove existing binary if it exists (to allow reinstall/update)
    if [ -f ".cargo/bin/tytanic" ]; then
        rm -f .cargo/bin/tytanic
    fi
    if [ -f ".cargo/bin/tt" ]; then
        rm -f .cargo/bin/tt
    fi
    
    # Use cargo install from crates.io with version from Cargo.toml
    # Install to local bin/ directory using --root and --force to overwrite
    cargo install --version "$TYTANIC_VERSION" --root . --force tytanic || {
        echo "Failed to install version $TYTANIC_VERSION, trying latest..."
        cargo install --root . --force tytanic
    }
    
    # Move binary to bin/tt (Tytanic binary is named 'tytanic' but we want 'tt')
    if [ -f ".cargo/bin/tytanic" ]; then
        cp .cargo/bin/tytanic bin/tt
        chmod +x bin/tt
        echo "Tytanic installed to bin/tt"
    elif [ -f "bin/tytanic" ]; then
        mv bin/tytanic bin/tt
        chmod +x bin/tt
        echo "Tytanic installed to bin/tt"
    else
        echo "Warning: Could not find installed Tytanic binary"
    fi
    
    # Tidy will be automatically downloaded when Typst compiles code that imports it
    # No manual installation needed - it will be cached in .typst/packages/ on first use
    echo "Tidy will be auto-downloaded on first use when compiling docs/manual.typ"
    
    echo ""
    echo "Installation complete!"
    echo "Local tools are in bin/ and .tools/"
    echo "The justfile tasks automatically use bin/tt - no PATH changes needed!"

# Run all tests using local Tytanic
test:
    #!/usr/bin/env bash
    if [ -f "bin/tt" ]; then
        ./bin/tt run
    else
        echo "ERROR: Tytanic not found. Run 'just install' first."
        exit 1
    fi

# Update test reference images
test-update:
    #!/usr/bin/env bash
    if [ -f "bin/tt" ]; then
        ./bin/tt update
    else
        echo "ERROR: Tytanic not found. Run 'just install' first."
        exit 1
    fi

# Run a specific test
test-single TEST:
    #!/usr/bin/env bash
    if [ -f "bin/tt" ]; then
        ./bin/tt run {{TEST}}
    else
        echo "ERROR: Tytanic not found. Run 'just install' first."
        exit 1
    fi

# Generate documentation
docs:
    typst compile docs/manual.typ

# Watch documentation for changes
docs-watch:
    typst watch --root . docs/manual.typ

# Compile examples
examples:
    #!/usr/bin/env bash
    for file in examples/*.typ; do
        if [ -f "$file" ]; then
            echo "Compiling $file..."
            typst compile "$file"
        fi
    done

# Check package for issues
check:
    #!/usr/bin/env bash
    echo "Checking package structure..."
    test -f typst.toml || echo "ERROR: typst.toml missing"
    test -f src/lib.typ || echo "ERROR: src/lib.typ missing"
    echo "Running Typst compile check..."
    typst compile --root . src/lib.typ --output /dev/null || echo "Compilation failed"

# Format code (if formatter available)
format:
    @echo "No formatter configured yet"

# Clean build artifacts
clean:
    #!/usr/bin/env bash
    rm -f *.pdf
    rm -f examples/*.pdf
    rm -f docs/*.pdf
    find . -name "*.pdf" -not -path "./.git/*" -delete
    echo "Cleaned build artifacts"

# Clean local tools (but keep .tools directory)
clean-tools:
    #!/usr/bin/env bash
    rm -rf bin/
    echo "Cleaned local binaries (source in .tools/ preserved)"

# Build everything
build: check test docs
    @echo "Build complete!"
