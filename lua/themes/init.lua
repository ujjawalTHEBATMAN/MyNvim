-- lua/themes/init.lua
-- Dynamic Theme Switcher with 25+ Themes

local M = {}

-- Theme configurations with setup functions
M.themes = {
	-- ============================================
	-- TIER 1: Premium Dark Themes
	-- ============================================
	{
		name = "catppuccin",
		label = "☕ Catppuccin Mocha",
		setup = function()
			local ok, catppuccin = pcall(require, "catppuccin")
			if ok then
				catppuccin.setup({
					flavour = "mocha",
					transparent_background = true,
					term_colors = true,
					dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
					styles = { comments = { "italic" }, functions = { "bold" }, keywords = { "italic" } },
					integrations = { cmp = true, gitsigns = true, nvimtree = true, treesitter = true, bufferline = true, mason = true, which_key = true, telescope = { enabled = true }, dap = true, dap_ui = true },
				})
				vim.cmd.colorscheme("catppuccin")
			end
		end,
	},
	{
		name = "catppuccin-frappe",
		label = "☕ Catppuccin Frappé",
		setup = function()
			require("catppuccin").setup({ flavour = "frappe", transparent_background = true })
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		name = "catppuccin-macchiato",
		label = "☕ Catppuccin Macchiato",
		setup = function()
			require("catppuccin").setup({ flavour = "macchiato", transparent_background = true })
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		name = "catppuccin-latte",
		label = "☕ Catppuccin Latte (Light)",
		setup = function()
			require("catppuccin").setup({ flavour = "latte", transparent_background = false })
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		name = "tokyonight",
		label = "🌃 Tokyo Night",
		setup = function()
			require("tokyonight").setup({ style = "night", transparent = true, terminal_colors = true })
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		name = "tokyonight-storm",
		label = "⛈️ Tokyo Night Storm",
		setup = function()
			require("tokyonight").setup({ style = "storm", transparent = true })
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		name = "tokyonight-moon",
		label = "🌙 Tokyo Night Moon",
		setup = function()
			require("tokyonight").setup({ style = "moon", transparent = true })
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		name = "tokyonight-day",
		label = "☀️ Tokyo Night Day (Light)",
		setup = function()
			require("tokyonight").setup({ style = "day", transparent = false })
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		name = "rose-pine",
		label = "🌸 Rosé Pine",
		setup = function()
			require("rose-pine").setup({ variant = "main", dim_nc_background = true, disable_background = true })
			vim.cmd.colorscheme("rose-pine")
		end,
	},
	{
		name = "rose-pine-moon",
		label = "🌙 Rosé Pine Moon",
		setup = function()
			require("rose-pine").setup({ variant = "moon", disable_background = true })
			vim.cmd.colorscheme("rose-pine")
		end,
	},
	{
		name = "rose-pine-dawn",
		label = "🌅 Rosé Pine Dawn (Light)",
		setup = function()
			require("rose-pine").setup({ variant = "dawn", disable_background = false })
			vim.cmd.colorscheme("rose-pine")
		end,
	},
	{
		name = "kanagawa",
		label = "🌊 Kanagawa Wave",
		setup = function()
			require("kanagawa").setup({ transparent = true, dimInactive = true, theme = "wave" })
			vim.cmd.colorscheme("kanagawa")
		end,
	},
	{
		name = "kanagawa-dragon",
		label = "🐉 Kanagawa Dragon",
		setup = function()
			require("kanagawa").setup({ transparent = true, theme = "dragon" })
			vim.cmd.colorscheme("kanagawa-dragon")
		end,
	},
	{
		name = "kanagawa-lotus",
		label = "🪷 Kanagawa Lotus (Light)",
		setup = function()
			require("kanagawa").setup({ transparent = false, theme = "lotus" })
			vim.cmd.colorscheme("kanagawa-lotus")
		end,
	},
	-- ============================================
	-- TIER 2: Classic & Retro
	-- ============================================
	{
		name = "gruvbox",
		label = "🍂 Gruvbox Dark",
		setup = function()
			require("gruvbox").setup({ transparent_mode = true, contrast = "hard" })
			vim.o.background = "dark"
			vim.cmd.colorscheme("gruvbox")
		end,
	},
	{
		name = "gruvbox-light",
		label = "🌻 Gruvbox Light",
		setup = function()
			require("gruvbox").setup({ transparent_mode = false, contrast = "soft" })
			vim.o.background = "light"
			vim.cmd.colorscheme("gruvbox")
		end,
	},
	{
		name = "everforest",
		label = "🌲 Everforest Dark",
		setup = function()
			vim.g.everforest_background = "hard"
			vim.g.everforest_transparent_background = 1
			vim.o.background = "dark"
			vim.cmd.colorscheme("everforest")
		end,
	},
	{
		name = "everforest-light",
		label = "🌿 Everforest Light",
		setup = function()
			vim.g.everforest_background = "soft"
			vim.o.background = "light"
			vim.cmd.colorscheme("everforest")
		end,
	},
	{
		name = "sonokai",
		label = "🎨 Sonokai",
		setup = function()
			vim.g.sonokai_style = "default"
			vim.g.sonokai_transparent_background = 1
			vim.cmd.colorscheme("sonokai")
		end,
	},
	{
		name = "sonokai-atlantis",
		label = "🌊 Sonokai Atlantis",
		setup = function()
			vim.g.sonokai_style = "atlantis"
			vim.g.sonokai_transparent_background = 1
			vim.cmd.colorscheme("sonokai")
		end,
	},
	{
		name = "edge",
		label = "⚡ Edge Dark",
		setup = function()
			vim.g.edge_style = "neon"
			vim.g.edge_transparent_background = 1
			vim.cmd.colorscheme("edge")
		end,
	},
	-- ============================================
	-- TIER 3: Modern & Trendy
	-- ============================================
	{
		name = "onedark",
		label = "🌑 One Dark",
		setup = function()
			require("onedark").setup({ style = "dark", transparent = true })
			require("onedark").load()
		end,
	},
	{
		name = "onedark-deep",
		label = "🌌 One Dark Deep",
		setup = function()
			require("onedark").setup({ style = "deep", transparent = true })
			require("onedark").load()
		end,
	},
	{
		name = "onedark-warmer",
		label = "🔥 One Dark Warmer",
		setup = function()
			require("onedark").setup({ style = "warmer", transparent = true })
			require("onedark").load()
		end,
	},
	{
		name = "nord",
		label = "❄️ Nord",
		setup = function()
			vim.g.nord_disable_background = true
			require("nord").set()
		end,
	},
	{
		name = "dracula",
		label = "🧛 Dracula",
		setup = function()
			require("dracula").setup({ transparent_bg = true })
			vim.cmd.colorscheme("dracula")
		end,
	},
	{
		name = "nightfox",
		label = "🦊 Nightfox",
		setup = function()
			require("nightfox").setup({ options = { transparent = true } })
			vim.cmd.colorscheme("nightfox")
		end,
	},
	{
		name = "duskfox",
		label = "🌆 Duskfox",
		setup = function()
			require("nightfox").setup({ options = { transparent = true } })
			vim.cmd.colorscheme("duskfox")
		end,
	},
	{
		name = "carbonfox",
		label = "⚫ Carbonfox",
		setup = function()
			require("nightfox").setup({ options = { transparent = true } })
			vim.cmd.colorscheme("carbonfox")
		end,
	},
	{
		name = "terafox",
		label = "🌲 Terafox",
		setup = function()
			require("nightfox").setup({ options = { transparent = true } })
			vim.cmd.colorscheme("terafox")
		end,
	},
	{
		name = "nordfox",
		label = "🐺 Nordfox",
		setup = function()
			require("nightfox").setup({ options = { transparent = true } })
			vim.cmd.colorscheme("nordfox")
		end,
	},
	{
		name = "dayfox",
		label = "🌞 Dayfox (Light)",
		setup = function()
			require("nightfox").setup({ options = { transparent = false } })
			vim.cmd.colorscheme("dayfox")
		end,
	},
	{
		name = "dawnfox",
		label = "🌅 Dawnfox (Light)",
		setup = function()
			require("nightfox").setup({ options = { transparent = false } })
			vim.cmd.colorscheme("dawnfox")
		end,
	},
	-- ============================================
	-- TIER 4: Material & Professional
	-- ============================================
	{
		name = "material-deep-ocean",
		label = "🌊 Material Deep Ocean",
		setup = function()
			require("material").setup({ disable = { background = true } })
			vim.g.material_style = "deep ocean"
			vim.cmd.colorscheme("material")
		end,
	},
	{
		name = "material-palenight",
		label = "🌃 Material Palenight",
		setup = function()
			require("material").setup({ disable = { background = true } })
			vim.g.material_style = "palenight"
			vim.cmd.colorscheme("material")
		end,
	},
	{
		name = "material-oceanic",
		label = "🌏 Material Oceanic",
		setup = function()
			vim.g.material_style = "oceanic"
			vim.cmd.colorscheme("material")
		end,
	},
	{
		name = "github-dark",
		label = "🐙 GitHub Dark",
		setup = function()
			require("github-theme").setup({ options = { transparent = true } })
			vim.cmd.colorscheme("github_dark")
		end,
	},
	{
		name = "github-dimmed",
		label = "🐙 GitHub Dimmed",
		setup = function()
			require("github-theme").setup({ options = { transparent = true } })
			vim.cmd.colorscheme("github_dark_dimmed")
		end,
	},
	{
		name = "github-light",
		label = "🐙 GitHub Light",
		setup = function()
			require("github-theme").setup({})
			vim.cmd.colorscheme("github_light")
		end,
	},
	{
		name = "vscode-dark",
		label = "💜 VSCode Dark+",
		setup = function()
			require("vscode").setup({ transparent = true, italic_comments = true })
			vim.cmd.colorscheme("vscode")
		end,
	},
	-- ============================================
	-- TIER 5: Unique & Aesthetic
	-- ============================================
	{
		name = "nightfly",
		label = "✈️ Nightfly",
		setup = function()
			vim.g.nightflyTransparent = true
			vim.cmd.colorscheme("nightfly")
		end,
	},
	{
		name = "moonfly",
		label = "🌙 Moonfly",
		setup = function()
			vim.g.moonflyTransparent = true
			vim.cmd.colorscheme("moonfly")
		end,
	},
	{
		name = "oxocarbon",
		label = "⬛ Oxocarbon",
		setup = function()
			vim.opt.background = "dark"
			vim.cmd.colorscheme("oxocarbon")
		end,
	},
	{
		name = "ayu-dark",
		label = "🌌 Ayu Dark",
		setup = function()
			require("ayu").setup({ mirage = false, overrides = {} })
			vim.cmd.colorscheme("ayu-dark")
		end,
	},
	{
		name = "ayu-mirage",
		label = "🌆 Ayu Mirage",
		setup = function()
			require("ayu").setup({ mirage = true })
			vim.cmd.colorscheme("ayu-mirage")
		end,
	},
	{
		name = "ayu-light",
		label = "☀️ Ayu Light",
		setup = function()
			require("ayu").setup({ mirage = false })
			vim.cmd.colorscheme("ayu-light")
		end,
	},
	{
		name = "monokai-pro",
		label = "🎨 Monokai Pro",
		setup = function()
			require("monokai-pro").setup({ transparent_background = true, filter = "pro" })
			vim.cmd.colorscheme("monokai-pro")
		end,
	},
	{
		name = "monokai-spectrum",
		label = "🌈 Monokai Spectrum",
		setup = function()
			require("monokai-pro").setup({ transparent_background = true, filter = "spectrum" })
			vim.cmd.colorscheme("monokai-pro")
		end,
	},
	{
		name = "monokai-octagon",
		label = "⬡ Monokai Octagon",
		setup = function()
			require("monokai-pro").setup({ transparent_background = true, filter = "octagon" })
			vim.cmd.colorscheme("monokai-pro")
		end,
	},
	{
		name = "cyberdream",
		label = "💾 Cyberdream",
		setup = function()
			require("cyberdream").setup({ transparent = true, italic_comments = true })
			vim.cmd.colorscheme("cyberdream")
		end,
	},
	{
		name = "fluoromachine",
		label = "🎆 Fluoromachine",
		setup = function()
			require("fluoromachine").setup({ glow = true, theme = "fluoromachine", transparent = true })
			vim.cmd.colorscheme("fluoromachine")
		end,
	},
	{
		name = "fluoromachine-retro",
		label = "📼 Fluoromachine Retro",
		setup = function()
			require("fluoromachine").setup({ glow = true, theme = "retrowave", transparent = true })
			vim.cmd.colorscheme("fluoromachine")
		end,
	},
	{
		name = "poimandres",
		label = "🔮 Poimandres",
		setup = function()
			require("poimandres").setup({ disable_background = true })
			vim.cmd.colorscheme("poimandres")
		end,
	},
	{
		name = "melange",
		label = "🍯 Melange Dark",
		setup = function()
			vim.o.background = "dark"
			vim.cmd.colorscheme("melange")
		end,
	},
	{
		name = "bamboo",
		label = "🎋 Bamboo",
		setup = function()
			require("bamboo").setup({ transparent = true })
			require("bamboo").load()
		end,
	},
	{
		name = "solarized",
		label = "☀️ Solarized Dark",
		setup = function()
			require("solarized").setup({ transparent = true })
			vim.o.background = "dark"
			vim.cmd.colorscheme("solarized")
		end,
	},
	{
		name = "modus-vivendi",
		label = "⚫ Modus Vivendi",
		setup = function()
			vim.cmd.colorscheme("modus_vivendi")
		end,
	},
	{
		name = "modus-operandi",
		label = "⚪ Modus Operandi (Light)",
		setup = function()
			vim.cmd.colorscheme("modus_operandi")
		end,
	},
}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

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
		name = name:gsub("%s+", "")
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
	local previewers = require("telescope.previewers")

	pickers.new({}, {
		prompt_title = "🎨 Select Theme (" .. #M.themes .. " themes)",
		finder = finders.new_table({
			results = M.themes,
			entry_maker = function(entry)
				return { value = entry, display = entry.label, ordinal = entry.name .. " " .. entry.label }
			end,
		}),
		sorter = conf.generic_sorter({}),
		previewer = previewers.new_buffer_previewer({
			title = "Theme Preview",
			define_preview = function(self, entry)
				local lines = {
					"Theme: " .. entry.value.label,
					"",
					"Name: " .. entry.value.name,
					"",
					"Press <Enter> to apply this theme",
				}
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
			end,
		}),
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
