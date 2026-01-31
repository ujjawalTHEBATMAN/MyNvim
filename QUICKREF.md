# Neovim Configuration - Quick Reference Guide

## 🎯 Overview

This is a **performance-optimized** Neovim configuration focused on:
- **Java development** (JDTLS, nvim-java, custom runners)
- **High WPM typing** (optimized completion, reduced lag)
- **Modern UI** (Catppuccin, 20+ themes, beautiful dashboard)
- **IDE-like features** (LSP, DAP, Telescope, etc.)

## ⚡ Performance Stats

| Metric | Value |
|--------|-------|
| Startup Time | ~100-150ms |
| Plugin Count | ~110 (optimized from 127) |
| LSP Servers | lua_ls, jdtls, jsonls, yamlls |

---

## 🔑 Essential Keymaps

### Leader Key: `<Space>`

### 📁 File Navigation
| Key | Action |
|-----|--------|
| `<leader>ff` | Find Files (Telescope) |
| `<leader>fg` | Live Grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent Files |
| `<leader>fp` | Find Projects |
| `-` | Open parent directory (Oil) |
| `<leader>E` | Toggle NvimTree |
| `<leader>e` | Focus NvimTree |

### ⚓ Harpoon (Quick File Access)
| Key | Action |
|-----|--------|
| `<leader>a` | Add file to Harpoon |
| `<C-e>` | Toggle Harpoon menu |
| `<M-1>` to `<M-4>` | Jump to Harpoon file 1-4 |

### 🔍 Search & Replace
| Key | Action |
|-----|--------|
| `<leader>sr` | Spectre (Search & Replace) |
| `<leader>sw` | Spectre word under cursor |
| `<leader>st` | Search Todos |
| `n/N` | Next/Prev search (centered) |

### 💻 Code Actions
| Key | Action |
|-----|--------|
| `gd` | Go to Definition |
| `gD` | Go to Declaration |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover Documentation |
| `<leader>rn` | Rename |
| `<leader>ca` | Code Action |
| `<leader>lf` | Format |
| `<leader>o` | Toggle Outline |

### ☕ Java Specific
| Key | Action |
|-----|--------|
| `<F5>` | Run Java |
| `<leader>jr` | Run Java |
| `<leader>jb` | Compile Java |
| `<leader>jx` | Clean output |
| `<leader>ji` | Project info |
| `<leader>jv` | Switch Java version |
| `<leader>oi` | Organize imports |

### 🐛 Debugging
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle Breakpoint |
| `<leader>dB` | Conditional Breakpoint |
| `<leader>dc` | Continue/Start Debug |
| `<leader>do` | Step Over |
| `<leader>di` | Step Into |
| `<leader>du` | Step Out |
| `<leader>dt` | Terminate |

### 🎨 Themes
| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle Theme (cycle) |
| `<leader>ts` | Select Theme (Telescope) |
| `<leader>fc` | Colorschemes |

### 📜 Git
| Key | Action |
|-----|--------|
| `<leader>gg` | LazyGit |
| `<leader>gn` | Neogit |
| `<leader>gs` | Stage Hunk |
| `<leader>gr` | Reset Hunk |
| `<leader>gp` | Preview Hunk |
| `<leader>gb` | Blame Line |
| `<leader>gd` | Diff This |
| `<leader>gh` | File History |
| `]c` / `[c` | Next/Prev Hunk |

### 🪟 Windows & Buffers
| Key | Action |
|-----|--------|
| `<Tab>` | Next Buffer |
| `<S-Tab>` | Prev Buffer |
| `<leader>1-5` | Go to Buffer 1-5 |
| `<leader>bd` | Delete Buffer |
| `<leader>sv` | Split Vertical |
| `<leader>sh` | Split Horizontal |
| `<A-h/j/k/l>` | Navigate splits |
| `<A-S-h/j/k/l>` | Resize splits |
| `<C-w>z` | Maximize Window |

### 🔧 Utilities
| Key | Action |
|-----|--------|
| `<C-\`>` | Toggle Terminal |
| `<leader>u` | Undo Tree |
| `<leader>zz` | Zen Mode |
| `<leader>tw` | Twilight |
| `<leader>mp` | Markdown Preview |
| `<leader>D` | Toggle Database UI |

### 📝 Code Editing
| Key | Action |
|-----|--------|
| `gcc` | Comment line |
| `gc` | Comment (visual) |
| `ys{motion}{char}` | Surround add |
| `ds{char}` | Surround delete |
| `cs{old}{new}` | Surround change |
| `s` | Flash jump |
| `S` | Flash Treesitter |

### 🏆 Competitive Programming
| Key | Action |
|-----|--------|
| `<leader>Ll` | LeetCode Menu |
| `<leader>Lr` | Run Code |
| `<leader>Ls` | Submit Code |
| `<leader>Cp` | CompetiTest Receive Problem |
| `<leader>Cr` | CompetiTest Run |

---

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Bootstrap (loads core + lazy.nvim)
├── lua/
│   ├── core/
│   │   ├── options.lua      # Vim options
│   │   ├── keymaps.lua      # Global keymaps
│   │   └── autocmds.lua     # Autocommands
│   ├── plugins/
│   │   ├── coding.lua       # Surround, comment, autopairs, etc.
│   │   ├── completion.lua   # nvim-cmp, snippets
│   │   ├── competitive.lua  # LeetCode, CompetiTest
│   │   ├── dap.lua          # Debug Adapter Protocol
│   │   ├── editor.lua       # Telescope, Harpoon, NvimTree
│   │   ├── enhancements.lua # UFO, Neotest, Zen Mode
│   │   ├── git.lua          # Gitsigns, LazyGit, Neogit
│   │   ├── java.lua         # nvim-java, JDTLS config
│   │   ├── lsp.lua          # LSP, Mason, Trouble
│   │   ├── power.lua        # ToggleTerm, Project, Overseer
│   │   ├── themes.lua       # Color schemes
│   │   ├── treesitter.lua   # Treesitter config
│   │   └── ui.lua           # Lualine, Bufferline, Alpha
│   ├── java-runner.lua      # Custom Java runner (F5)
│   ├── java-runtime.lua     # Java version switcher
│   └── themes/
│       └── init.lua         # Theme switcher with 20+ themes
└── templates/               # Code templates
```

---

## 🛠️ Commands

| Command | Description |
|---------|-------------|
| `:Lazy` | Plugin manager |
| `:Mason` | LSP/DAP installer |
| `:LspInfo` | LSP status |
| `:checkhealth` | Health check |
| `:JavaRun` | Run current Java file |
| `:JavaCompile` | Compile Java |
| `:JavaClean` | Clean output |
| `:JavaInfo` | Show project info |
| `:Telescope` | Fuzzy finder |
| `:Trouble` | Diagnostics panel |
| `:OverseerRun` | Run tasks |

---

## 🔧 Troubleshooting

### If Neovim is slow:
1. Check `:checkhealth` for issues
2. Run `:Lazy profile` to see slow plugins
3. Ensure you're using lua-based alternatives for heavy plugins

### If LSP isn't working:
1. Check `:LspInfo` for attached servers
2. Run `:Mason` to install missing servers
3. Check `:messages` for errors

### If Java isn't working:
1. Ensure `$JAVA_HOME` is set
2. Check `:LspInfo` for jdtls status
3. Run `:JavaInfo` to see project detection

---

*Last updated: 2026-01-31*
