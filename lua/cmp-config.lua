-- lua/cmp-config.lua
-- COMPLETE NVIM-CMP CONFIGURATION - NOTHING MISSING

local M = {}

function M.setup()
	local cmp = require("cmp")
	local luasnip = require("luasnip")

	-- Load snippets
	require("luasnip.loaders.from_vscode").lazy_load()
	luasnip.filetype_extend("java", { "javadoc" })
	luasnip.filetype_extend("javascript", { "jsdoc" })

	-- Check if we have snippets available
	local has_words_before = function()
		unpack = unpack or table.unpack
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			
			-- Accept currently selected item
			["<CR>"] = cmp.mapping.confirm({ 
				select = true,
				behavior = cmp.ConfirmBehavior.Replace 
			}),
			
			-- Tab completion with snippet support
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
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
			
			-- Alternative navigation
			["<C-j>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			
			["<C-k>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "i", "s" }),
		}),
		
		sources = cmp.config.sources({
			{ name = "nvim_lsp", priority = 1000 },
			{ name = "luasnip", priority = 750 },
			{ name = "buffer", priority = 500, keyword_length = 3 },
			{ name = "path", priority = 250 },
		}),
		
		formatting = {
			fields = { "kind", "abbr", "menu" },
			format = function(entry, vim_item)
				-- Kind icons
				local kind_icons = {
					Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
					Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
					Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
					Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
					File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
					Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
					TypeParameter = "",
				}
				
				-- Get the icon
				local icon = kind_icons[vim_item.kind] or ""
				vim_item.kind = string.format("%s %s", icon, vim_item.kind)
				
				-- Source info
				vim_item.menu = ({
					nvim_lsp = "[LSP]",
					luasnip = "[Snip]",
					buffer = "[Buf]",
					path = "[Path]",
					nvim_lua = "[Api]",
				})[entry.source.name]
				
				return vim_item
			end,
		},
		
		window = {
			completion = {
				border = "rounded",
				winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
				col_offset = -3,
				side_padding = 0,
			},
			documentation = {
				border = "rounded",
				winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
				max_width = 80,
				max_height = 20,
			},
		},
		
		experimental = {
			ghost_text = true,
			native_menu = false,
		},
		
		performance = {
			trigger_debounce_time = 50,
			throttle = 50,
			fetching_timeout = 500,
		},
	})

	-- Command line completion for `/` and `?`
	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" }
		}
	})

	-- Command line completion for `:`
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" }
		}, {
			{ name = "cmdline", option = { ignore_cmds = { "Man", "!" } } }
		})
	})

	-- Auto pairs integration (if installed)
	local ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
	if ok then
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end
end

-- Load LuaSnip extra configuration
function M.setup_luasnip()
	local luasnip = require("luasnip")
	
	luasnip.config.set_config({
		history = true,
		updateevents = "TextChanged,TextChangedI",
		enable_autosnippets = true,
		ext_opts = {
			[require("luasnip.util.types").choiceNode] = {
				active = {
					virt_text = { { "●", "GruvboxOrange" } }
				}
			}
		},
	})
	
	-- Snippet keymaps
	vim.keymap.set({ "i", "s" }, "<C-l>", function()
		if luasnip.choice_active() then
			luasnip.change_choice(1)
		end
	end, { silent = true })
	
	vim.keymap.set({ "i", "s" }, "<C-h>", function()
		if luasnip.choice_active() then
			luasnip.change_choice(-1)
		end
	end, { silent = true })
end

return M
