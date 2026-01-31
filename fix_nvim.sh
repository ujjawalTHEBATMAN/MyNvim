#!/bin/bash
set -e

echo "============================================"
echo "   Fixing Neovim Configuration Issues       "
echo "============================================"

NVIM_DATA_DIR="$HOME/.local/share/nvim"
LAZY_DIR="$NVIM_DATA_DIR/lazy"

echo "[1/3] Cleaning potentially corrupt plugins..."

# Remove treesitter to force clean reinstall
if [ -d "$LAZY_DIR/nvim-treesitter" ]; then
    echo "  - Removing nvim-treesitter..."
    rm -rf "$LAZY_DIR/nvim-treesitter"
fi

# Remove nvim-java to force clean reinstall (fix DAP bundles)
if [ -d "$LAZY_DIR/nvim-java" ]; then
    echo "  - Removing nvim-java..."
    rm -rf "$LAZY_DIR/nvim-java"
fi

# Remove mason-managed java debug adapter if exists (to force re-download)
if [ -d "$NVIM_DATA_DIR/mason/packages/java-debug-adapter" ]; then
    echo "  - Removing java-debug-adapter..."
    rm -rf "$NVIM_DATA_DIR/mason/packages/java-debug-adapter"
fi

if [ -d "$NVIM_DATA_DIR/mason/packages/java-test" ]; then
    echo "  - Removing java-test..."
    rm -rf "$NVIM_DATA_DIR/mason/packages/java-test"
fi


echo "[3/3] Verifying dependencies..."
if command -v gcc &> /dev/null; then
    echo "  - GCC is installed."
else
    echo "  - WARNING: GCC is NOT installed. Treesitter requires a compiler."
    echo "  - Installing base-devel is recommended: sudo pacman -S base-devel"
fi

if command -v javac &> /dev/null; then
    echo "  - Java Compiler (javac) is installed."
else
    echo "  - WARNING: 'javac' NOT found! Competitive programming plugins need JDK."
fi

if command -v xclip &> /dev/null || command -v wl-copy &> /dev/null; then
    echo "  - Clipboard tool (xclip/wl-copy) is installed."
else
    echo "  - WARNING: No clipboard tool found! 'leetcode.nvim' needs 'xclip' or 'wl-copy'."
fi

echo "[3/3] Done!"
echo ""
echo "Please restart Neovim now. It will automatically reinstall the missing plugins."
echo "Wait for the installation to complete (check :Lazy status if needed)."
echo "Then, open a Java file and wait for 'jdtls' to initialize."
