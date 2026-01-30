# Neovim Java Config – Fixes Applied

## Summary of Fixes

### 1. TreeSitter (syntax highlighting)

**Cause:** `nvim-treesitter-textobjects` was listed as a *dependency* of `nvim-treesitter`. With lazy.nvim, dependencies load first, so textobjects was loaded before treesitter and failed when requiring `nvim-treesitter.configs`.

**Fix:**  
- Removed textobjects from nvim-treesitter’s `dependencies`.  
- Registered `nvim-treesitter-textobjects` as its own plugin with `dependencies = { "nvim-treesitter/nvim-treesitter" }`.  
- Treesitter now loads first; textobjects loads after and can require the configs module.

**Rebuild parsers (optional):**
```bash
nvim --headless "+TSUpdate" +qa
```
Or inside Neovim: `:TSUpdate`

---

### 2. nvim-dap config (Error at plugins.lua:725)

**Cause:** The code used `dap.listeners.after.attach.event_initialized` and `dap.listeners.after.launch.event_initialized`. In nvim-dap, `listeners.after` and `listeners.before` only have event names like `event_initialized`, `event_terminated`, `event_exited`. There are no `attach` or `launch` sub-tables, so indexing them led to a nil value.

**Fix:** Use the flat listener names:
- `dap.listeners.after.event_initialized["dapui_config"]` (covers both launch and attach)
- `dap.listeners.before.event_terminated["dapui_config"]`
- `dap.listeners.before.event_exited["dapui_config"]`

---

### 3. Buffer write error (java-config.lua:231)

**Cause:** `open_floating_terminal` used `nvim_buf_set_lines` in the `termopen` `on_exit` callback. After the terminal starts, the buffer is no longer modifiable, so that write raised “Buffer is not 'modifiable'”.

**Fix:** Before appending exit status lines:
- Check `vim.api.nvim_buf_is_valid(buf)` and `vim.bo[buf].modifiable`.
- Use `pcall(vim.api.nvim_buf_set_lines, ...)` so a failure does not throw.

---

### 4. Java run / `vscode.java.resolveMainClass` (RPC MethodNotFound)

**Cause:** `nvim-java` (or the run command you used) calls the JDTLS command `vscode.java.resolveMainClass`. That command is provided by the VS Code Java extension, not by plain JDTLS from Mason, so JDTLS returns “No delegateCommandHandler for vscode.java.resolveMainClass”.

**Workaround:** Use the config’s own run path, which does not rely on that RPC:

- **F5** or **\<leader>rr** → `emergency_java_run` in `init.lua` → `java-config.run_main_floating()`:
  - Simple Java: `javac` + `java` in a floating terminal
  - Maven/Gradle: `mvn` / `gradle` run

So for “run current/main class”, use **F5** or **\<leader>rr**; avoid the nvim-java run command that calls `resolveMainClass` until you use a JDTLS setup that supports it (e.g. with vscode-java extensions).

---

## Applying This Config

If your real config lives under `~/.config/nvim/`, copy the updated files from this worktree:

- `lua/plugins.lua`
- `lua/java-config.lua`

Then restart Neovim. Optionally run `:TSUpdate` and `:Lazy sync` once.
