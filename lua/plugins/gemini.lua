return {
  -- Virtual plugin for Gemini Web Assistant
  "gemini-web-assistant",
  virtual = true, -- Not a real repo, just local config
  keys = {
    { "<leader>sa", mode = { "n", "v" }, desc = "Gemini: Smart Ask" },
    { "<leader>se", mode = { "n", "v" }, desc = "Gemini: Solve Error" },
  },
  config = function()
    -- Helpers
    local function get_visual_selection()
      local _, csrow, cscol, cerow, cecol
      local mode = vim.fn.mode()
      if mode == 'v' or mode == 'V' or mode == '' then
        -- if we are in visual mode use the current selection
        _, csrow, cscol, _ = unpack(vim.fn.getpos("."))
        _, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
        if mode == 'V' then
          -- visual line doesn't provide columns
          cscol, cecol = 0, 2147483647
        end
        -- swap if needed
        if csrow > cerow then csrow, cerow = cerow, csrow end
        if cscol > cecol then cscol, cecol = cecol, cscol end
        
        local lines = vim.fn.getline(csrow, cerow)
        if #lines == 0 then return "" end
        
        -- Special case for single line selection to handle columns
        if #lines == 1 then
           lines[1] = string.sub(lines[1], cscol, cecol)
        else
           lines[1] = string.sub(lines[1], cscol)
           lines[#lines] = string.sub(lines[#lines], 1, cecol)
        end
        return table.concat(lines, "\n")
      else
        -- Normal mode: yank the ENTIRE current buffer
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return table.concat(lines, "\n")
      end
    end

    local function open_gemini_and_paste(text)
      -- Copy to system clipboard
      vim.fn.setreg("+", text)
      vim.fn.setreg('"', text) -- also un-named register
      
      vim.notify("Copied to clipboard! Opening Gemini and auto-pasting...", "info")
      
      -- Open Brave
      local browser_cmd
      if vim.fn.executable("brave") == 1 then
        browser_cmd = "brave"
      elseif vim.fn.executable("brave-browser") == 1 then
        browser_cmd = "brave-browser"
      else
        vim.notify("Brave browser not found in PATH. Please open https://gemini.google.com manually.", "warn")
        browser_cmd = "xdg-open"
      end
      
      vim.fn.jobstart({ browser_cmd, "https://gemini.google.com" }, { detach = true })
      
      -- Auto-paste using xdotool after a delay (wait for browser to load)
      -- This simulates Ctrl+V in the focused window
      if vim.fn.executable("xdotool") == 1 then
        -- Wait 3 seconds for browser to load, then paste
        vim.fn.jobstart({ "bash", "-c", "sleep 3 && xdotool key --clearmodifiers ctrl+v" }, { detach = true })
      elseif vim.fn.executable("wtype") == 1 then
        -- Wayland alternative
        vim.fn.jobstart({ "bash", "-c", "sleep 3 && wtype -M ctrl -k v -m ctrl" }, { detach = true })
      else
        vim.notify("Install 'xdotool' (X11) or 'wtype' (Wayland) for auto-paste. Otherwise paste manually.", "warn")
      end
    end

    -- <leader>sa - Smart Ask (Just Paste)
    vim.keymap.set({ "n", "v" }, "<leader>sa", function()
      local text = get_visual_selection()
      if text == "" then
         vim.notify("No text selected!", "warn")
         return
      end
      -- Just the text
      open_gemini_and_paste(text)
    end, { desc = "Gemini: Smart Ask (Yank & Open)" })

    -- <leader>se - Solve Error (Prompt + Paste)
    vim.keymap.set({ "n", "v" }, "<leader>se", function()
      local text = get_visual_selection()
       if text == "" then
         vim.notify("No text selected!", "warn")
         return
      end
      -- Add Prompt
      local prompt = "Fix this error and explain the solution:\n\n" .. text
      open_gemini_and_paste(prompt)
    end, { desc = "Gemini: Solve Error (Yank w/ Prompt & Open)" })
    
  end
}
