local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local cmake_make_entry = require("cmake-explorer.make_entry")
local cmake = require("cmake-explorer")

local numbers = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "numbers",
			finder = finders.new_table({
				results = {
					{ "one", 1 },
					{ "two", 2 },
					{ "three", 3 },
					{ "four", 4 },
				},
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[1],
						ordinal = entry[1],
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					vim.notify(vim.inspect(selection), vim.log.levels.INFO)
					-- vim.api.nvim_put({ selection[1] }, "", false, true)
				end)
				return true
			end,
		})
		:find()
end

-- our picker function: colors
local colors = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "colors",
			finder = finders.new_table({
				results = {
					{ "red", "#ff0000" },
					{ "green", "#00ff00" },
					{ "blue", "#0000ff" },
				},
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[1],
						ordinal = entry[1],
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					vim.notify(vim.inspect(selection), vim.log.levels.INFO)
					numbers(require("telescope.themes").get_dropdown({}))
					-- vim.api.nvim_put({ selection[1] }, "", false, true)
				end)
				return true
			end,
		})
		:find()
end

local super = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "pickers",
			finder = finders.new_table({
				results = {
					{ "colors", colors },
					{ "numbers", numbers },
				},
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[1],
						ordinal = entry[1],
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					vim.notify(vim.inspect(selection), vim.log.levels.INFO)
					selection.value[2](require("telescope.themes").get_dropdown({}))
					actions.open(prompt_bufnr)
					-- vim.api.nvim_put({ selection[1] }, "", false, true)
				end)
				return true
			end,
		})
		:find()
end

-- to execute the function
super()
