-- lua/plugins.lua
-- COMPLETE PLUGIN SPEC - FIXED, ORGANIZED & ENHANCED

return {
	-- ============================================
	-- THEMES
	-- ============================================
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
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
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
					mason = true,
					which_key = true,
					telescope = { enabled = true, style = "nvchad" },
					harpoon = true,
					dap = true,
					dap_ui = true,
					indent_blankline = true,
				},
			})
			vim.cmd.colorscheme("catppuccin")
			
			-- Load theme switcher
			vim.defer_fn(function()
				local ok, themes = pcall(require, "themes")
				if ok then themes.setup() end
			end, 100)
		end,
	},

	{ "rose-pine/neovim", name = "rose-pine", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },

	-- ============================================
	-- DEPENDENCIES / UTILITIES
	-- ============================================
	{ "nvim-lua/plenary.nvim", priority = 999 },
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- ============================================
	-- UI ENHANCEMENTS
	-- ============================================
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		config = function()
			local function lsp_clients()
				local clients = vim.lsp.get_active_clients({ bufnr = 0 })
				if #clients == 0 then return "" end
				local names = {}
				for _, client in pairs(clients) do
					table.insert(names, client.name)
				end
				return "[" .. table.concat(names, ", ") .. "]"
			end

			local function java_version()
				if vim.bo.filetype == "java" then
					local ver = os.getenv("JAVA_HOME") or ""
					return ver:match("java%-(%d+)") or ver:match("jdk%-(%d+)") or ""
				end
				return ""
			end

			require("lualine").setup({
				options = {
					theme = "catppuccin",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { 
						{ "filename", path = 1 },
						{ lsp_clients, icon = "󰌘" },
					},
					lualine_x = { 
						{ java_version, icon = "☕", cond = function() return vim.bo.filetype == "java" end },
						"encoding", 
						"fileformat", 
						"filetype" 
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				extensions = { "nvim-tree", "trouble", "mason", "lazy" },
			})
		end,
	},

	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")
			
			dashboard.section.header.val = {
				"                                                     ",
				"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
				"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
				"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
				"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
				"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
				"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
				"                                                     ",
			}
			
			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
				dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
				dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
				dashboard.button("s", "  Restore Session", ":SessionRestore<CR>"),
				dashboard.button("l", "  Lazy", ":Lazy<CR>"),
				dashboard.button("q", "  Quit", ":qa<CR>"),
			}
			
			alpha.setup(dashboard.opts)
		end,
	},

	-- ============================================
	-- SMART SPLITS & NAVIGATION
	-- ============================================
	{
		"mrjones2014/smart-splits.nvim",
		event = "VeryLazy",
		config = function()
			local smart_splits = require("smart-splits")
			smart_splits.setup({
				ignored_filetypes = { "nofile", "quickfix", "prompt", "NvimTree" },
				ignored_buftypes = { "NvimTree" },
				default_amount = 3,
				at_edge = "wrap",
			})

			vim.keymap.set("n", "<C-h>", smart_splits.move_cursor_left, { desc = "Left Split" })
			vim.keymap.set("n", "<C-j>", smart_splits.move_cursor_down, { desc = "Down Split" })
			vim.keymap.set("n", "<C-k>", smart_splits.move_cursor_up, { desc = "Up Split" })
			vim.keymap.set("n", "<C-l>", smart_splits.move_cursor_right, { desc = "Right Split" })
			vim.keymap.set("n", "<A-h>", smart_splits.resize_left, { desc = "Resize Left" })
			vim.keymap.set("n", "<A-j>", smart_splits.resize_down, { desc = "Resize Down" })
			vim.keymap.set("n", "<A-k>", smart_splits.resize_up, { desc = "Resize Up" })
			vim.keymap.set("n", "<A-l>", smart_splits.resize_right, { desc = "Resize Right" })
		end,
	},

	-- ============================================
	-- BUFFER LINE
	-- ============================================
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		event = "VeryLazy",
		config = function()
			local highlights = {}
			local ok, catppuccin_hl = pcall(function()
				return require("catppuccin.groups.integrations.bufferline").get()
			end)
			if ok then highlights = catppuccin_hl end

			require("bufferline").setup({
				options = {
					mode = "buffers",
					numbers = "ordinal",
					close_command = "bdelete! %d",
					indicator = { icon = "▎", style = "underline" },
					buffer_close_icon = "",
					modified_icon = "●",
					close_icon = "",
					left_trunc_marker = "",
					right_trunc_marker = "",
					diagnostics = "nvim_lsp",
					diagnostics_indicator = function(count, level)
						local icon = level == "error" and " " or " "
						return " " .. icon .. count
					end,
					separator_style = "slant",
					offsets = {
						{ filetype = "NvimTree", text = "File Explorer", text_align = "center", separator = true },
					},
					show_buffer_close_icons = false,
					show_close_icon = false,
					enforce_regular_tabs = true,
					always_show_bufferline = true,
				},
				highlights = highlights,
			})

			vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
			vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
			vim.keymap.set("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", { desc = "Buffer 1" })
			vim.keymap.set("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", { desc = "Buffer 2" })
			vim.keymap.set("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", { desc = "Buffer 3" })
			vim.keymap.set("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", { desc = "Buffer 4" })
			vim.keymap.set("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", { desc = "Buffer 5" })
			vim.keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete Buffer" })
			vim.keymap.set("n", "<leader>bD", "<Cmd>bdelete!<CR>", { desc = "Force Delete Buffer" })
		end,
	},

	-- ============================================
	-- SNACKS (Utilities)
	-- ============================================
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("snacks").setup({
				bigfile = { enabled = true },
				notifier = { enabled = true, timeout = 3000 },
				quickfile = { enabled = true },
				statuscolumn = { enabled = true },
				words = { enabled = true, debounce = 200 },
			})
		end,
	},

	-- ============================================
	-- TELESCOPE (Fuzzy Finder)
	-- ============================================
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { 
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
			{ "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					prompt_prefix = "  ",
					selection_caret = " ",
					path_display = { "truncate" },
					file_ignore_patterns = { 
						"node_modules", ".git/", "target/", "build/", ".gradle", 
						"%.class", "%.jar" 
					},
					mappings = {
						i = {
							["<C-j>"] = require("telescope.actions").move_selection_next,
							["<C-k>"] = require("telescope.actions").move_selection_previous,
						},
					},
				},
				pickers = {
					find_files = { hidden = true, no_ignore = false },
					colorscheme = { enable_preview = true },
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})
			telescope.load_extension("fzf")
		end,
	},

	-- ============================================
	-- HARPOON ( Quick File Navigation)
	-- ============================================
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({
				settings = {
					save_on_toggle = true,
					sync_on_ui_close = true,
					key = function() return vim.loop.cwd() end,
				},
			})

			vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon Add" })
			vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })
			
			for i = 1, 4 do
				vim.keymap.set("n", string.format("<M-%d>", i), function() harpoon:list():select(i) end, 
					{ desc = "Harpoon " .. i })
			end

			-- Split navigation
			vim.keymap.set("n", "<leader>h1", function() vim.cmd("vsplit"); harpoon:list():select(1) end, { desc = "Harpoon 1 Vsplit" })
			vim.keymap.set("n", "<leader>h2", function() vim.cmd("vsplit"); harpoon:list():select(2) end, { desc = "Harpoon 2 Vsplit" })
		end,
	},

	-- ============================================
	-- TREESITTER (Syntax Highlighting)
	-- Treesitter loads at startup so nvim-treesitter.configs exists before
	-- nvim-treesitter-textobjects is ever sourced (fixes "module not found").
	-- ============================================
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		priority = 95,
		lazy = false,
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"java", "xml", "yaml", "json", "lua", "vim", "vimdoc",
					"markdown", "markdown_inline", "bash",
				},
				highlight = { enable = true, additional_vim_regex_highlighting = false },
				indent = { enable = true },
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
	},

	-- ============================================
	-- COMPLETION (CMP)
	-- ============================================
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip").filetype_extend("java", { "javadoc" })

			cmp.setup({
				snippet = {
					expand = function(args) luasnip.lsp_expand(args.body) end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
				}, {
					{ name = "buffer", priority = 500 },
					{ name = "path", priority = 250 },
				}),
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					fields = { "abbr", "kind", "menu" },
					format = function(entry, vim_item)
						local kind_icons = {
							Text = "", Method = "󰆧", Function = "󰊕", Constructor = "",
							Field = "󰜢", Variable = "", Class = "󰠱", Interface = "",
							Module = "", Property = "󰜢", Unit = "", Value = "",
							Enum = "", Keyword = "", Snippet = "", Color = "",
							File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
							Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "",
							TypeParameter = "",
						}
						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snip]",
							buffer = "[Buf]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})

			-- Use buffer source for `/` and `?`
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})

			-- Use cmdline & path source for ':'
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
	},

	-- ============================================
	-- LSP & MASON (Language Servers)
	-- ============================================
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
					border = "rounded",
				},
			})
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "jdtls", "lua_ls", "jsonls", "yamlls" },
				automatic_installation = true,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			
			-- Diagnostics signs
			local signs = { Error = "", Warn = "", Hint = "󰌵", Info = "" }
			for type, icon in pairs(signs) do
				vim.fn.sign_define("DiagnosticSign" .. type, { text = icon, texthl = "DiagnosticSign" .. type })
			end

			-- On attach function
			local on_attach = function(client, bufnr)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end

				map("gd", vim.lsp.buf.definition, "Go to Definition")
				map("gD", vim.lsp.buf.declaration, "Go to Declaration")
				map("gr", vim.lsp.buf.references, "Go to References")
				map("gi", vim.lsp.buf.implementation, "Go to Implementation")
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("<leader>k", vim.lsp.buf.signature_help, "Signature Help")
				map("<leader>rn", vim.lsp.buf.rename, "Rename")
				map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
				map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
				
				-- Inlay hints (if supported)
				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(bufnr, true)
				end
			end

			-- Lua LSP
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { 
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			-- JSON LSP
			lspconfig.jsonls.setup({ capabilities = capabilities, on_attach = on_attach })
			
			-- YAML LSP
			lspconfig.yamlls.setup({ 
				capabilities = capabilities, 
				on_attach = on_attach,
				settings = { yaml = { keyOrdering = false } }
			})
		end,
	},

	-- ============================================
	-- JAVA DEVELOPMENT (Enhanced)
	-- ============================================
	{
		"nvim-java/nvim-java",
		priority = 100,
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"mfussenegger/nvim-dap",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Load runtime switcher
			local ok_runtime, java_runtime = pcall(require, "java-runtime")
			local runtimes = {}
			local detected_ver = "21"

			if ok_runtime then
				runtimes, detected_ver = java_runtime.get_jdtls_runtimes()
				java_runtime.setup_autocmd()
			else
				runtimes = {{
					name = "JavaSE-21",
					path = "/usr/lib/jvm/java-21-openjdk",
					default = true,
				}}
			end

			require("java").setup({
				java = {
					configuration = { runtimes = runtimes },
					eclipse = { downloadSources = true },
					maven = { downloadSources = true, updateSnapshots = true },
					gradle = { enabled = true, wrapper = { enabled = true } },
					springboot = { enable = true },
					format = { enabled = true, settings = { profile = "GoogleStyle" } },
					completion = {
						favoriteStaticMembers = {
							"org.junit.Assert.*", "org.junit.Assume.*",
							"org.junit.jupiter.api.Assertions.*", "org.junit.jupiter.api.Assumptions.*",
							"org.junit.jupiter.api.DynamicContainer.*", "org.junit.jupiter.api.DynamicTest.*",
							"org.mockito.Mockito.*", "org.mockito.ArgumentMatchers.*", "org.mockito.Answers.*",
						},
					},
				},
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- JDTLS setup with enhanced configuration
			require("lspconfig").jdtls.setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					-- Load java-config for additional functionality
					vim.defer_fn(function()
						local ok, java_config = pcall(require, "java-config")
						if ok and java_config.on_attach then
							java_config.on_attach(client, bufnr)
						end
					end, 100)

					-- Show active Java version
					if ok_runtime then
						local current = java_runtime.get_current_java_version()
						if current then
							vim.notify("☕ Using Java " .. current, vim.log.levels.INFO)
						end
					end

					-- Standard LSP mappings
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
					end
					
					map("gd", vim.lsp.buf.definition, "Go to Definition")
					map("K", vim.lsp.buf.hover, "Hover")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("<leader>oi", function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end, "Organize Imports")
				end,
				settings = {
					java = {
						autobuild = { enabled = true },
						import = {
							gradle = { enabled = true, wrapper = { enabled = true } },
							maven = { enabled = true },
							exclusions = { "**/node_modules/**", "**/.git/**", "**/build/**", "**/target/**" },
						},
						contentProvider = { preferred = "fernflower" },
						saveActions = { organizeImports = true },
						referencesCodeLens = { enabled = true },
						implementationsCodeLens = { enabled = true },
						signatureHelp = { enabled = true, description = true },
						completion = { guessMethodArguments = true, overwrite = false },
						codeGeneration = {
							toString = {
								template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
							},
							useBlocks = true,
						},
					},
				},
			})
		end,
	},

	-- ============================================
	-- DEBUGGING (DAP)
	-- ============================================
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup({
				icons = { expanded = "", collapsed = "", current_frame = "" },
				controls = {
					icons = {
						pause = "",
						play = "",
						step_into = "",
						step_over = "",
						step_out = "",
						step_back = "",
						run_last = "",
						terminate = "",
					},
				},
			})

			require("nvim-dap-virtual-text").setup()

			-- Java adapter configuration is handled by nvim-java automatically
			-- dap.configurations.java = { ... } (Removed to prevent conflict)

			-- Auto open/close dapui (use flat listener names: after.event_*, before.event_*)
			dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
			dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
			dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

			-- Keymaps
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue/Start Debug" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
			vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "Step Out" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate Debug" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
			vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "Eval Expression" })
		end,
	},

	-- ============================================
	-- FORMATTING
	-- ============================================
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		dependencies = { "mason.nvim" },
		config = function()
			local conform = require("conform")
			conform.setup({
				formatters_by_ft = {
					java = { "google-java-format" },
					lua = { "stylua" },
					python = { "black" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
				},
				format_on_save = function(bufnr)
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 2000, lsp_fallback = true }
				end,
				formatters = {
					["google-java-format"] = {
						command = vim.fn.stdpath("data") .. "/mason/bin/google-java-format",
						args = { "--aosp", "-" },
					},
				},
			})

			vim.keymap.set("n", "<leader>f", function() conform.format({ async = true }) end, { desc = "Format" })
			vim.keymap.set("n", "<leader>tf", function() vim.b.disable_autoformat = not (vim.b.disable_autoformat or false); print("Autoformat: " .. tostring(not vim.b.disable_autoformat)) end, { desc = "Toggle Autoformat" })
		end,
	},

	-- ============================================
	-- FILE TREE
	-- ============================================
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "NvimTreeToggle", "NvimTreeFocus" },
		keys = {
			{ "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Tree Toggle" },
			{ "<leader>e", "<cmd>NvimTreeFocus<cr>", desc = "Explorer Focus" },
		},
		config = function()
			require("nvim-tree").setup({
				view = { width = 35, side = "left", relativenumber = true },
				renderer = {
					add_trailing = false,
					group_empty = true,
					icons = {
						git_placement = "after",
						glyphs = {
							folder = { arrow_closed = "▸", arrow_open = "▾", default = "📁", open = "📂", empty = "", empty_open = "" },
							default = "", symlink = "",
						},
					},
					special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "pom.xml", "build.gradle" },
				},
				filters = { custom = { "^.git$", "^node_modules$", "^target$", "^build$", "^.gradle$", "^.idea$" } },
				git = { enable = true, ignore = false },
				actions = {
					open_file = { quit_on_open = false, resize_window = true },
				},
				diagnostics = {
					enable = true,
					show_on_dirs = true,
					icons = { hint = "󰌵", info = "", warning = "", error = "" },
				},
			})
		end,
	},

	-- ============================================
	-- GIT INTEGRATION
	-- ============================================
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "┃" },
					change = { text = "┃" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				signcolumn = true,
				numhl = false,
				linehl = false,
				word_diff = false,
				current_line_blame = true,
				current_line_blame_opts = { virt_text = true, virt_text_pos = "eol", delay = 1000 },
				current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end
					
					map("n", "]c", function()
						if vim.wo.diff then return "]c" end
						vim.schedule(gs.next_hunk)
						return "<Ignore>"
					end, { expr = true, desc = "Next Hunk" })
					
					map("n", "[c", function()
						if vim.wo.diff then return "[c" end
						vim.schedule(gs.prev_hunk)
						return "<Ignore>"
					end, { expr = true, desc = "Prev Hunk" })
					
					map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage Hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Hunk" })
					map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage Hunk" })
					map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset Hunk" })
					map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage Buffer" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo Stage" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset Buffer" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Hunk" })
					map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame Line" })
					map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle Blame" })
					map("n", "<leader>gd", gs.diffthis, { desc = "Diff This" })
					map("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "Diff This ~" })
				end,
			})
		end,
	},

	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
		config = function()
			vim.g.lazygit_floating_window_winblend = 0
			vim.g.lazygit_floating_window_scaling_factor = 0.9
		end,
	},

	-- ============================================
	-- SESSION MANAGEMENT
	-- ============================================
	{
		"rmagatti/auto-session",
		lazy = false,
		config = function()
			require("auto-session").setup({
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/Downloads", "/", "/tmp" },
				auto_session_enable_last_session = false,
				auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
				auto_save_enabled = true,
				auto_restore_enabled = true,
				auto_session_use_git_branch = true,
			})
			
			vim.keymap.set("n", "<leader>Ss", "<cmd>SessionSave<cr>", { desc = "Save Session" })
			vim.keymap.set("n", "<leader>Sr", "<cmd>SessionRestore<cr>", { desc = "Restore Session" })
			vim.keymap.set("n", "<leader>Sd", "<cmd>SessionDelete<cr>", { desc = "Delete Session" })
		end,
	},

	-- ============================================
	-- ENHANCEMENTS
	-- ============================================
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("ibl").setup({
				indent = { char = "│", tab_char = "│" },
				scope = { enabled = true, show_start = true, show_end = true },
				exclude = { filetypes = { "help", "alpha", "dashboard", "Trouble", "lazy", "mason" } },
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "source" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
				enable_check_bracket_line = true,
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0,
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})
			
			-- Integration with cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
		end,
	},

	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup()
		end,
	},

	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("Comment").setup({
				toggler = { line = "gcc", block = "gbc" },
				opleader = { line = "gc", block = "gb" },
				extra = { above = "gcO", below = "gco", eol = "gcA" },
			})
		end,
	},

	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		config = function()
			require("neoscroll").setup({
				mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
				hide_cursor = true,
				stop_eof = true,
				respect_scrolloff = false,
				cursor_scrolls_alone = true,
			})
		end,
	},

	-- ============================================
	-- UI COMPONENTS
	-- ============================================
	{
		"SmiteshP/nvim-navic",
		lazy = true,
		dependencies = "neovim/nvim-lspconfig",
		config = function()
			require("nvim-navic").setup({ 
				highlight = true, 
				separator = " > ",
				depth_limit = 5,
			})
		end,
	},

	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		config = function()
			require("barbecue").setup({
				attach_navic = false,
				create_autocmd = false,
			})
			vim.api.nvim_create_autocmd({ "LspAttach", "BufWinEnter" }, {
				callback = function(args)
					local buffer = args.buf
					local window = vim.api.nvim_get_current_win()
					if args.event == "LspAttach" then
						local client = vim.lsp.get_client_by_id(args.data.client_id)
						if client and client.server_capabilities.documentSymbolProvider then
							require("nvim-navic").attach(client, buffer)
						end
					end
					require("barbecue.ui").update(window)
				end,
			})
		end,
	},

	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
			{ "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions" },
		},
		config = function()
			require("trouble").setup({
				position = "bottom",
				height = 12,
				icons = true,
				mode = "workspace_diagnostics",
				severity = nil,
				fold_open = "",
				fold_closed = "",
				group = true,
				padding = true,
				cycle_results = true,
			})
		end,
	},

	-- ============================================
	-- WHICH-KEY (Keymap helper)
	-- ============================================
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		priority = 50,
		config = function()
			local wk = require("which-key")
			wk.setup({
				preset = "modern",
				delay = 300,
				plugins = {
					marks = true,
					registers = true,
					spelling = { enabled = true, suggestions = 20 },
					presets = { operators = true, motions = true, text_objects = true, windows = true, nav = true, z = true, g = true },
				},
				win = { border = "rounded", padding = { 1, 2 }, wo = { winblend = 0 } },
				layout = { height = { min = 4, max = 25 }, width = { min = 20, max = 50 }, spacing = 3, align = "left" },
				icons = { breadcrumb = "", separator = "➜", group = "+" },
			})

			wk.add({
				{ "<leader>r", group = "Run", icon = { icon = "", color = "green" } },
				{ "<leader>rr", desc = "🔥 Run Java Main", icon = { icon = "", color = "red" } },
				{ "<leader>t", group = "Theme/Toggle", icon = { icon = "", color = "cyan" } },
				{ "<leader>h", group = "Harpoon", icon = { icon = "⚓", color = "blue" } },
				{ "<leader>g", group = "Git", icon = { icon = "", color = "orange" } },
				{ "<leader>S", group = "Session", icon = { icon = "", color = "yellow" } },
				{ "<leader>j", group = "Java", icon = { icon = "☕", color = "red" } },
				{ "<leader>d", group = "Debug", icon = { icon = "", color = "red" } },
				{ "<leader>e", group = "Explorer", icon = { icon = "", color = "blue" } },
				{ "<leader>x", group = "Diagnostics", icon = { icon = "", color = "red" } },
				{ "<leader>c", group = "Code", icon = { icon = "", color = "purple" } },
				{ "<leader>b", group = "Buffer", icon = { icon = "", color = "blue" } },
				{ "<leader>f", group = "Find", icon = { icon = "", color = "green" } },
				{ "<leader>s", group = "Split", icon = { icon = "", color = "blue" } },
				{ "<leader>l", group = "LSP", icon = { icon = "", color = "purple" } },
			})

			-- Theme keymaps (standalone)
			vim.keymap.set("n", "<leader>tt", function()
				local ok, themes = pcall(require, "themes")
				if ok then themes.toggle_theme() end
			end, { desc = "Toggle Theme" })
			
			vim.keymap.set("n", "<leader>ts", function()
				local ok, themes = pcall(require, "themes")
				if ok then themes.show_telescope_picker() end
			end, { desc = "Select Theme" })
		end,
	},

	-- ============================================
	-- MARKDOWN
	-- ============================================
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_theme = "dark"
			vim.g.mkdp_echo_preview_url = 1
		end,
		ft = { "markdown" },
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
		},
	},
	-- Previous plugin end was here, continuing list...

	-- ============================================
	-- PRIMEAGEN RECOMMENDED ENHANCEMENTS
	-- ============================================
	
	-- 1. NEOTEST (Testing)
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"rcasia/neotest-java",
		},
		keys = {
			{ "<leader>tn", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
			{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File Tests" },
			{ "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Test Summary" },
			{ "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show Test Output" },
			{ "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest Test" },
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-java")({
						-- Validates that junit is on the classpath
						ignore_wrapper = false,
					}),
				},
			})
		end,
	},

	-- 2. REFACTORING.NVIM
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{ "<leader>re", ":Refactor extract ", mode = "x", desc = "Extract Function" },
			{ "<leader>rf", ":Refactor extract_to_file ", mode = "x", desc = "Extract to File" },
			{ "<leader>rv", ":Refactor extract_var ", mode = "x", desc = "Extract Variable" },
			{ "<leader>ri", ":Refactor inline_var", mode = { "n", "x" }, desc = "Inline Variable" },
			{ "<leader>rb", ":Refactor extract_block", mode = "n", desc = "Extract Block" },
			{ "<leader>rbf", ":Refactor extract_block_to_file", mode = "n", desc = "Extract Block to File" },
		},
		config = function()
			require("refactoring").setup({})
		end,
	},

	-- 3. UNDOTREE
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Undo Tree" },
		},
	},

	-- 4. VIM-DADBOD (Database)
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
		keys = {
			{ "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
		},
	},
	-- Continuing list...

	-- ============================================
	-- LEVEL 2 ENHANCEMENTS (Productivity)
	-- ============================================

	-- 1. AI AUTOCOMPLETE (Codeium - Disabled by Default)
	{
		"Exafunction/codeium.vim",
		event = "BufEnter",
		config = function()
			-- Start DISABLED (User preference)
			vim.g.codeium_enabled = false
			-- Disable default bindings to avoid conflicts
			vim.g.codeium_disable_bindings = 1

			-- Accept keymap (only works when enabled)
			vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
			vim.keymap.set("i", "<C-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, silent = true })

			-- Toggle Keymap
			vim.keymap.set("n", "<leader>ai", function()
				vim.g.codeium_enabled = not vim.g.codeium_enabled
				if vim.g.codeium_enabled then
					vim.cmd("CodeiumEnable")
					vim.notify("🤖 AI Autocomplete ON", vim.log.levels.INFO)
				else
					vim.cmd("CodeiumDisable")
					vim.notify("🤖 AI Autocomplete OFF", vim.log.levels.WARN)
				end
			end, { desc = "Toggle AI" })
		end,
	},

	-- 2. SPECTRE (Search & Replace)
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>S", function() require("spectre").toggle() end, desc = "Spectre (Replace)" },
			{ "<leader>sw", function() require("spectre").open_visual({select_word=true}) end, desc = "Spectre (Word)" },
			{ "<leader>sf", function() require("spectre").open_file_search({select_word=true}) end, desc = "Spectre (File)" },
		},
	},

	-- 3. TODO COMMENTS
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("todo-comments").setup()
			vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo" })
			vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Prev Todo" })
			vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Search Todos" })
		end,
	},

	-- 4. NOICE (Modern UI)
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use Treesitter
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
			})
		end,
	},
}
