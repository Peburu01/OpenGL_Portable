#!/bin/bash

# setup-macos.sh
# Automated setup script for macOS development environment

echo "====================================="
echo "OpenGL Project - macOS Setup"
echo "====================================="
echo ""

# Check for sudo access upfront
echo "This script requires administrator privileges."
echo "You may be prompted for your password."
echo ""

# Test sudo access
if ! sudo -v; then
    echo "ERROR: Failed to obtain administrator privileges"
    exit 1
fi

# Keep sudo alive in background
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check if Homebrew is installed
echo "Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    echo "[INSTALLED] Homebrew"
else
    echo "[OK] Homebrew is installed"
fi

# Check and install Git
echo ""
echo "Checking Git..."
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    brew install git
    echo "[INSTALLED] Git"
else
    echo "[OK] Git $(git --version)"
fi

# Check and install CMake
echo ""
echo "Checking CMake..."
if ! command -v cmake &> /dev/null; then
    echo "Installing CMake..."
    brew install cmake
    echo "[INSTALLED] CMake"
else
    echo "[OK] $(cmake --version | head -n1)"
fi

# Check and install Ninja
echo ""
echo "Checking Ninja..."
if ! command -v ninja &> /dev/null; then
    echo "Installing Ninja..."
    brew install ninja
    echo "[INSTALLED] Ninja"
else
    echo "[OK] Ninja $(ninja --version)"
fi

# Check Xcode Command Line Tools (includes clang/clang++)
echo ""
echo "Checking Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    echo "A dialog will appear - click Install and wait for completion."
    xcode-select --install
    
    # Wait for installation
    echo "Waiting for Xcode Command Line Tools installation..."
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    
    echo "[INSTALLED] Xcode Command Line Tools"
else
    echo "[OK] Xcode Command Line Tools installed"
fi

# Check compiler
echo ""
echo "Checking C++ Compiler..."
if command -v clang++ &> /dev/null; then
    echo "[OK] $(clang++ --version | head -n1)"
else
    echo "[WARNING] No C++ compiler found"
fi

# Install ccache (build speedup)
echo ""
echo "Checking ccache (build speedup)..."
if ! command -v ccache &> /dev/null; then
    echo "Installing ccache..."
    brew install ccache
    echo "[INSTALLED] ccache - rebuilds will be 30x faster!"
else
    echo "[OK] ccache $(ccache --version | head -n1)"
fi

echo ""
echo "====================================="
echo "Setup Complete!"
echo "====================================="
echo ""
echo "Installed Tools:"
echo "  ✓ Git (version control)"
echo "  ✓ CMake (build system)"
echo "  ✓ Ninja (fast build tool)"
echo "  ✓ Xcode CLT (C++ compiler)"
echo "  ✓ ccache (30x faster rebuilds)"
echo ""
echo "Ready to build! Press Cmd+Shift+B in VSCode"
