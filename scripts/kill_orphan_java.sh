#!/bin/bash
# =============================================================================
# NVIM JAVA CLEANUP SCRIPT
# =============================================================================
# This script kills orphaned Java LSP processes that may remain after closing Neovim
# Run this if you notice high memory usage from old Java processes
#
# Usage: ./kill_orphan_java.sh
# =============================================================================

echo "🔍 Looking for orphaned Java LSP processes..."

# Find and kill JDTLS processes
jdtls_pids=$(pgrep -f 'java.*jdtls' 2>/dev/null)
nvim_java_pids=$(pgrep -f 'nvim-java' 2>/dev/null)
eclipse_jdt_pids=$(pgrep -f 'org.eclipse.jdt.ls' 2>/dev/null)

killed=0

if [ -n "$jdtls_pids" ]; then
    echo "☕ Found JDTLS processes: $jdtls_pids"
    for pid in $jdtls_pids; do
        # Check if process parent is alive (Neovim instance)
        parent=$(ps -o ppid= -p $pid 2>/dev/null | tr -d ' ')
        if [ -n "$parent" ] && ! ps -p $parent >/dev/null 2>&1; then
            echo "  ⚡ Killing orphaned JDTLS process: $pid"
            kill -9 $pid 2>/dev/null && ((killed++))
        else
            # Check if parent is init (orphaned)
            if [ "$parent" = "1" ]; then
                echo "  ⚡ Killing orphaned JDTLS process: $pid (parent is init)"
                kill -9 $pid 2>/dev/null && ((killed++))
            else
                echo "  ℹ️  JDTLS process $pid has active parent $parent - skipping"
            fi
        fi
    done
fi

if [ -n "$nvim_java_pids" ]; then
    echo "☕ Found nvim-java processes: $nvim_java_pids"
    for pid in $nvim_java_pids; do
        parent=$(ps -o ppid= -p $pid 2>/dev/null | tr -d ' ')
        if [ "$parent" = "1" ] || ([ -n "$parent" ] && ! ps -p $parent >/dev/null 2>&1); then
            echo "  ⚡ Killing orphaned nvim-java process: $pid"
            kill -9 $pid 2>/dev/null && ((killed++))
        fi
    done
fi

if [ -n "$eclipse_jdt_pids" ]; then
    echo "☕ Found Eclipse JDT processes: $eclipse_jdt_pids"
    for pid in $eclipse_jdt_pids; do
        parent=$(ps -o ppid= -p $pid 2>/dev/null | tr -d ' ')
        if [ "$parent" = "1" ] || ([ -n "$parent" ] && ! ps -p $parent >/dev/null 2>&1); then
            echo "  ⚡ Killing orphaned Eclipse JDT process: $pid"
            kill -9 $pid 2>/dev/null && ((killed++))
        fi
    done
fi

if [ $killed -eq 0 ]; then
    echo "✅ No orphaned Java processes found!"
else
    echo "✅ Killed $killed orphaned Java process(es)"
fi

# Show remaining Java memory usage
echo ""
echo "📊 Current Java process memory usage:"
ps aux --sort=-%mem | grep -E 'java|jdtls' | grep -v grep | head -5 || echo "No Java processes running"
