-- lua/themes/init.lua
-- Dynamic Theme Switcher

local M = {}

M.themes = {
	{
		name = "catppuccin",
		label = "☕ Catppuccin Mocha",
		setup = function()
			local ok, catppuccin = pcall(require, "catppuccin")
			if ok then
				catppuccin.setup({
					flavour = "mocha",
					transparent_background = true,
					show_end_of_buffer = false,
					term_colors = true,
					dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
					styles = {
						comments = { "italic" },
						conditionals = { "italic" },
						functions = { "bold" },
						types = { "bold" },
						keywords = { "italic" },
					},
					integrations = {
						cmp = true,
						gitsigns = true,
						nvimtree = true,
						treesitter = true,
						bufferline = true,
						lualine = true,
						native_lsp = {
							enabled = true,
							virtual_text = { errors = { "italic" }, hints = { "italic" }, warnings = { "italic" }, information = { "italic" } },
							underlines = { errors = { "underline" }, hints = { "underline" }, warnings = { "underline" }, information = { "underline" } },
						},
						mason = true,
						which_key = true,
						telescope = { enabled = true, style = "nvchad" },
						harpoon = true,
						dap = true,
						dap_ui = true,
					},
				})
				vim.cmd.colorscheme("catppuccin")
			end
		end,
	},
	{
		name = "rose-pine",
		label = "🌸 Rosé Pine",
		setup = function()
			local ok, rose_pine = pcall(require, "rose-pine")
			if ok then
				rose_pine.setup({
					variant = "main",
					dark_variant = "main",
					dim_nc_background = true,
					disable_background = true,
					disable_float_background = true,
					styles = {
						bold = true,
						italic = true,
						transparency = true,
					},
					highlight_groups = {
						StatusLine = { fg = "love", bg = "love", blend = 10 },
						StatusLineNC = { fg = "subtle", bg = "surface" },
					},
				})
				vim.cmd.colorscheme("rose-pine")
			end
		end,
	},
	{
		name = "kanagawa",
		label = "🌊 Kanagawa",
		setup = function()
			local ok, kanagawa = pcall(require, "kanagawa")
			if ok then
				kanagawa.setup({
					compile = false,
					undercurl = true,
					commentStyle = { italic = true },
					functionStyle = { bold = true },
					keywordStyle = { italic = true },
					statementStyle = { bold = true },
					typeStyle = { bold = true },
					transparent = true,
					dimInactive = true,
					terminalColors = true,
					theme = "wave",
					background = { dark = "wave", light = "lotus" },
					overrides = function(colors)
						return {
							TelescopeTitle = { fg = colors.theme.ui.special, bold = true },
							TelescopeNormal = { bg = "none" },
							TelescopeBorder = { bg = "none" },
							TelescopePromptBorder = { bg = "none" },
							NormalFloat = { bg = "none" },
							FloatBorder = { bg = "none" },
							Pmenu = { bg = "none" },
							PmenuSel = { bg = colors.theme.ui.bg_p1 },
						}
					end,
				})
				vim.cmd.colorscheme("kanagawa")
			end
		end,
	},
}

function M.get_theme(name)
	for _, theme in ipairs(M.themes) do
		if theme.name == name then return theme end
	end
	return M.themes[1]
end

function M.get_random_theme()
	math.randomseed(os.time())
	return M.themes[math.random(1, #M.themes)]
end

function M.save_theme(name)
	local cache_dir = vim.fn.stdpath("cache")
	local cache_file = cache_dir .. "/last_theme.txt"
	vim.fn.mkdir(cache_dir, "p")
	local file = io.open(cache_file, "w")
	if file then
		file:write(name)
		file:close()
	end
end

function M.load_last_theme()
	local cache_file = vim.fn.stdpath("cache") .. "/last_theme.txt"
	local file = io.open(cache_file, "r")
	if file then
		local name = file:read("*l") or file:read("*a")
		file:close()
		name = name:gsub("%s+", "") -- trim whitespace
		if name ~= "" then return name end
	end
	return nil
end

function M.apply_theme(theme_name)
	local theme = M.get_theme(theme_name)
	
	-- Clear existing highlights
	pcall(vim.cmd, "highlight clear")
	pcall(vim.cmd, "syntax reset")

	local ok, err = pcall(theme.setup)
	if not ok then
		vim.notify("Failed to load theme " .. theme_name .. ": " .. tostring(err), vim.log.levels.ERROR)
		if theme_name ~= "catppuccin" then
			M.apply_theme("catppuccin")
		end
		return
	end

	M.save_theme(theme.name)
	vim.g.colors_name = theme.name
	vim.notify("🎨 Theme: " .. theme.label, vim.log.levels.INFO)
end

function M.apply_random()
	local theme = M.get_random_theme()
	M.apply_theme(theme.name)
end

function M.toggle_theme()
	local current = M.load_last_theme() or "catppuccin"
	local current_index = 1

	for i, theme in ipairs(M.themes) do
		if theme.name == current then
			current_index = i
			break
		end
	end

	local next_index = (current_index % #M.themes) + 1
	M.apply_theme(M.themes[next_index].name)
end

function M.show_telescope_picker()
	local has_telescope, pickers = pcall(require, "telescope.pickers")
	if not has_telescope then
		vim.notify("Telescope not found!", vim.log.levels.ERROR)
		return
	end

	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers.new({}, {
		prompt_title = "🎨 Select Theme",
		finder = finders.new_table({
			results = M.themes,
			entry_maker = function(entry)
				return { value = entry, display = entry.label, ordinal = entry.name }
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then M.apply_theme(selection.value.name) end
			end)
			return true
		end,
	}):find()
end

function M.setup()
	vim.defer_fn(function()
		local last_theme = M.load_last_theme()
		if last_theme then
			M.apply_theme(last_theme)
		else
			M.apply_theme("catppuccin")
		end
	end, 0)
end

return M
