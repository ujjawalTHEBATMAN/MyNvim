# 🎓 Complete Beginner's Guide to This Neovim Configuration

## 📖 Table of Contents
1. [What is Neovim?](#what-is-neovim)
2. [Basic Concepts](#basic-concepts)
3. [How to Create New Files](#how-to-create-new-files) ⭐ **YOUR MAIN QUESTION**
4. [All Keyboard Shortcuts Explained](#all-keyboard-shortcuts-explained)
5. [Step-by-Step Workflow](#step-by-step-workflow)
6. [Common Tasks](#common-tasks)

---

## 🤔 What is Neovim?

Neovim is a **text editor** (like VS Code, but faster and works in terminal). Think of it as a super-powered notepad that you control with keyboard shortcuts instead of clicking with a mouse.

### Key Concepts:
- **Normal Mode**: Default mode for navigation and commands (you start here)
- **Insert Mode**: For typing text (like regular editors)
- **Leader Key**: A special key (Space bar in this config) that starts commands
- **Buffer**: An open file in Neovim
- **Split**: Dividing your screen into multiple sections

---

## 🆕 How to Create New Files (Your Main Question!)

There are **SEVERAL WAYS** to create a new file. Here they all are:

### Method 1: Using NvimTree (File Explorer) - RECOMMENDED FOR BEGINNERS

**Step-by-step:**
1. Press `<leader>E` (Space + Shift+E) to open the file tree on the left
2. Navigate using arrow keys or `j` (down) and `k` (up)
3. Move to the folder where you want to create the file
4. Press `a` to add a new file
5. Type the filename (e.g., `MyNewFile.java`)
6. Press Enter
7. The file is created and opened!

**NvimTree Keys:**
| Key | Action |
|-----|--------|
| `<leader>E` | Toggle file tree on/off |
| `<leader>e` | Focus on file tree |
| `a` | Create new file/folder |
| `d` | Delete file |
| `r` | Rename file |
| `Enter` | Open file |
| `o` | Open file in split |

---

### Method 2: Using Oil.nvim (Folder Navigation) - FASTEST!

**Step-by-step:**
1. Press `-` (minus/dash key)
2. You'll see a list of files in the current folder
3. Navigate to where you want
4. Press `o` to create a new file
5. Type the filename
6. Press Enter
7. Start editing!

**Oil.nvim Keys:**
| Key | Action |
|-----|--------|
| `-` | Open current directory |
| `o` | Create/open file |
| `Enter` | Open file |
| `-` (in Oil) | Go to parent directory |

---

### Method 3: Direct Command - SIMPLEST!

**Step-by-step:**
1. Press `:` (colon)
2. Type `e filename.java` (e = edit)
3. Press Enter
4. If the file doesn't exist, it will be created when you save
5. Type some content
6. Press `<leader>w` (Space+w) to save

**Examples:**
```
:e MyNewFile.java      → Creates/opens MyNewFile.java
:e src/Main.java       → Creates/opens src/Main.java
:e ../test.txt         → Creates file in parent folder
```

---

### Method 4: Using Telescope (Fuzzy Finder) - ADVANCED BUT POWERFUL

**Step-by-step:**
1. Press `<leader>ff` (Space+f, then f again)
2. Start typing part of the filename
3. If file exists, it will show up
4. To create new: type full filename and press Enter
5. Save with `<leader>w`

---

### Method 5: Using Mini.Files (Miller-style Explorer)

**Step-by-step:**
1. Press `<leader>fm` (for current file's directory)
   OR `<leader>fM` (for project root)
2. Navigate with arrow keys
3. Press `a` to create new file
4. Type filename and press Enter

---

## 🎹 All Keyboard Shortcuts Explained

### 🔑 THE LEADER KEY
In this config, **Space bar** is your leader key. Most commands start with Space!

---

### 📁 FILE NAVIGATION

| Keys | What It Does | When to Use |
|------|--------------|-------------|
| `<leader>ff` | Find any file in project | When you need to open an existing file |
| `<leader>fg` | Search text in all files | When looking for specific code |
| `<leader>fb` | See all open buffers | When switching between open files |
| `<leader>fr` | Recent files | Quick access to files you worked on |
| `<leader>E` | Toggle file tree | To see project structure |
| `-` | Open folder view | Navigate folders like Windows Explorer |
| `<leader>ha` | Add file to Harpoon | Mark frequently used files |
| `<C-e>` | Show Harpoon menu | Jump to marked files quickly |
| `<M-1>` to `<M-4>` | Jump to Harpoon file 1-4 | Super fast file switching |

---

### 💾 SAVING AND QUITTING

| Keys | What It Does |
|------|--------------|
| `<leader>w` | Save current file |
| `<leader>q` | Quit current file |
| `<leader>Q` | Quit everything (force) |

---

### 🪟 WINDOW MANAGEMENT (SPLITS)

| Keys | What It Does |
|------|--------------|
| `<leader>sv` | Split screen vertically (side by side) |
| `<leader>sh` | Split screen horizontally (top/bottom) |
| `<leader>se` | Make all splits equal size |
| `<leader>sx` | Close current split |
| `<A-h>` | Move cursor to left split |
| `<A-j>` | Move cursor to bottom split |
| `<A-k>` | Move cursor to top split |
| `<A-l>` | Move cursor to right split |
| `<A-S-h>` | Make left split smaller |
| `<A-S-j>` | Make bottom split smaller |
| `<A-S-k>` | Make top split smaller |
| `<A-S-l>` | Make right split smaller |

---

### 📝 CODE EDITING

| Keys | What It Does |
|------|--------------|
| `i` | Enter Insert mode (start typing) |
| `Esc` | Exit Insert mode (go back to Normal) |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `dd` | Delete entire line |
| `yy` | Copy entire line |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `gcc` | Comment/uncomment line |
| `gc` | Comment in visual mode |
| `s` | Flash jump (quick navigation) |
| `n` | Next search result |
| `N` | Previous search result |

---

### ☕ JAVA DEVELOPMENT

| Keys | What It Does |
|------|--------------|
| `<F5>` | Run Java program |
| `<leader>rr` | Run Java program (alternative) |
| `<leader>jb` | Compile Java |
| `<leader>jx` | Clean output window |
| `<leader>ji` | Show project info |
| `<leader>oi` | Organize imports |
| `gd` | Go to definition |
| `K` | Show documentation |
| `<leader>lf` | Format code |

---

### 🐛 DEBUGGING

| Keys | What It Does |
|------|--------------|
| `<leader>db` | Add/remove breakpoint |
| `<leader>dc` | Continue debugging |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>du` | Step out |

---

### 🔍 SEARCH AND REPLACE

| Keys | What It Does |
|------|--------------|
| `/` | Search forward |
| `?` | Search backward |
| `<leader>sr` | Search and replace in files |
| `<leader>sw` | Replace word under cursor |
| `<leader>st` | Find all TODO comments |

---

### 🎨 THEMES AND UI

| Keys | What It Does |
|------|--------------|
| `<leader>tt` | Switch to next theme |
| `<leader>ts` | Choose theme from list |
| `<leader>fc` | Colorschemes |
| `<Tab>` | Next buffer/tab |
| `<S-Tab>` | Previous buffer/tab |

---

### 📦 GIT INTEGRATION

| Keys | What It Does |
|------|--------------|
| `<leader>gg` | Open LazyGit (full Git UI) |
| `<leader>gs` | Stage changes |
| `<leader>gr` | Reset changes |
| `<leader>gb` | See who wrote this line |
| `[c` | Previous Git change |
| `]c` | Next Git change |

---

### 🤖 AI FEATURES

| Keys | What It Does |
|------|--------------|
| `<leader>a` | AI commands menu |
| `<leader>aa` | Ollama AI chat |

---

## 🚀 Step-by-Step Workflow for Beginners

### Scenario 1: Creating and Running a Java File

1. **Open Neovim** in your project folder
2. **Press `<leader>E`** to open file tree
3. **Navigate** to `src/` folder using `j/k` arrows
4. **Press `a`** to add new file
5. **Type** `HelloWorld.java`
6. **Press Enter** - file opens
7. **Press `i`** to enter insert mode
8. **Type your Java code**
9. **Press Esc** to exit insert mode
10. **Press `<leader>w`** to save
11. **Press `<F5>`** to run!

### Scenario 2: Opening Existing Project

1. **Open terminal**
2. **Navigate** to project: `cd /path/to/project`
3. **Type** `nvim .`
4. Dashboard appears!
5. **Press `f`** to find files
6. **Type** filename
7. **Press Enter** to open

### Scenario 3: Working with Multiple Files

1. **Open first file**: `<leader>ff`, type filename, Enter
2. **Split screen**: `<leader>sv` (vertical split)
3. **Open second file in split**: `<leader>ff`, type filename, Enter
4. **Switch between splits**: `<A-h>` and `<A-l>`
5. **Close split**: `<leader>sx`

---

## 💡 Pro Tips for Beginners

### Tip 1: Don't Remember Shortcuts?
Press **Space** and wait - a menu (Which-Key) shows all available commands!

### Tip 2: Stuck in Vim?
- Press `Esc` multiple times
- Type `:q!` and Enter to force quit

### Tip 3: Want to See All Commands?
- Press `<leader>fk` to see all keymaps
- Press `:` and type `Telescope keymaps`

### Tip 4: Need Help?
- Press `K` on any function to see documentation
- Type `:help` for general help

### Tip 5: Slow Performance?
- Close unused splits: `<leader>sx`
- Reload Neovim if needed

---

## 📋 Quick Reference Card

### MOST USED COMMANDS (Memorize These First!)

| Priority | Keys | Action |
|----------|------|--------|
| ⭐⭐⭐ | `<leader>E` | Open file tree |
| ⭐⭐⭐ | `<leader>ff` | Find file |
| ⭐⭐⭐ | `<leader>w` | Save file |
| ⭐⭐⭐ | `i` | Start typing |
| ⭐⭐⭐ | `Esc` | Stop typing |
| ⭐⭐ | `-` | Open folder |
| ⭐⭐ | `<F5>` | Run Java |
| ⭐⭐ | `<leader>sv` | Split screen |
| ⭐ | `<Tab>` | Next file |
| ⭐ | `<leader>q` | Quit |

---

## 🎯 Practice Exercises

### Day 1: Basic Navigation
1. Open Neovim
2. Create a file using `<leader>E` then `a`
3. Type something, save with `<leader>w`
4. Quit with `<leader>q`

### Day 2: File Management
1. Create 3 different files
2. Open them using `<leader>ff`
3. Switch between them with `<Tab>`

### Day 3: Splits
1. Open a file
2. Create vertical split: `<leader>sv`
3. Open another file in split
4. Navigate between splits with `<A-h/j/k/l>`

### Day 4: Java Development
1. Create `Test.java`
2. Write a simple Java program
3. Run it with `<F5>`
4. Fix errors if any

---

## ❓ Common Questions

### Q: How do I create a file named "something.java"?
**A:** Press `<leader>E`, then `a`, type `something.java`, press Enter!

### Q: Where are files saved?
**A:** In your current project folder. Use `<leader>E` to see the structure.

### Q: Can I create folders too?
**A:** Yes! In NvimTree, press `a` and type `foldername/` (with slash at end).

### Q: What if I make a mistake?
**A:** Press `u` to undo, `Ctrl+r` to redo.

### Q: How do I copy and paste?
**A:** 
- Visual mode: Select text with `v`, move cursor, press `y` to copy
- Paste: Press `p`
- Or use `<leader>y` to copy to system clipboard

---

## 🎉 You're Ready!

Start with these 5 commands:
1. `<leader>E` - See files
2. `a` (in tree) - Create file  
3. `i` - Type code
4. `<leader>w` - Save
5. `<F5>` - Run (for Java)

Everything else you'll learn naturally as you use it more!

**Remember:** Press **Space** anytime to see all available commands!

---

*Made with ❤️ for beginners | Your Neovim Journey Starts Here!*
