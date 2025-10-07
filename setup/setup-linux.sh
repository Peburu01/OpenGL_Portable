#!/bin/bash

# setup-linux.sh
# Automated setup script for Linux development environment

echo "====================================="
echo "OpenGL Project - Linux Setup"
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

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    UPDATE_CMD="sudo apt-get update"
    INSTALL_CMD="sudo apt-get install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="sudo dnf check-update"
    INSTALL_CMD="sudo dnf install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    UPDATE_CMD="sudo pacman -Sy"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo "ERROR: No supported package manager found (apt/dnf/pacman)"
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"
echo ""

# Update package lists
echo "Updating package lists..."
$UPDATE_CMD

# Install build essentials
echo ""
echo "Installing build tools (this may take a few minutes)..."
if [ "$PKG_MANAGER" = "apt-get" ]; then
    $INSTALL_CMD build-essential git cmake ninja-build ccache \
        libgl1-mesa-dev libx11-dev libxrandr-dev libxi-dev \
        libxinerama-dev libxcursor-dev
elif [ "$PKG_MANAGER" = "dnf" ]; then
    $INSTALL_CMD gcc gcc-c++ git cmake ninja-build ccache \
        mesa-libGL-devel libX11-devel libXrandr-devel libXi-devel \
        libXinerama-devel libXcursor-devel
elif [ "$PKG_MANAGER" = "pacman" ]; then
    $INSTALL_CMD base-devel git cmake ninja ccache \
        mesa libx11 libxrandr libxi
fi

# Verify installations
echo ""
echo "====================================="
echo "Verifying installations..."
echo "====================================="

command -v git &> /dev/null && echo "[OK] $(git --version)" || echo "[FAIL] Git"
command -v cmake &> /dev/null && echo "[OK] $(cmake --version | head -n1)" || echo "[FAIL] CMake"
command -v ninja &> /dev/null && echo "[OK] Ninja $(ninja --version)" || echo "[FAIL] Ninja"
command -v gcc &> /dev/null && echo "[OK] $(gcc --version | head -n1)" || echo "[FAIL] GCC"
command -v g++ &> /dev/null && echo "[OK] $(g++ --version | head -n1)" || echo "[FAIL] G++"
command -v ccache &> /dev/null && echo "[OK] ccache $(ccache --version | head -n1)" || echo "[FAIL] ccache"

echo ""
echo "====================================="
echo "Setup Complete!"
echo "====================================="
echo ""
echo "Installed Tools:"
echo "  ✓ Git (version control)"
echo "  ✓ CMake (build system)"
echo "  ✓ Ninja (fast build tool)"
echo "  ✓ GCC/G++ (C++ compiler)"
echo "  ✓ ccache (30x faster rebuilds)"
echo ""
echo "Ready to build! Press Ctrl+Shift+B in VSCode"
