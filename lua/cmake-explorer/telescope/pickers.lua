local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local cmake_make_entry = require("cmake-explorer.telescope.make_entry")
local notif = require("cmake-explorer.notification")

local M = {}

M.build_dirs = function(opts)
	local cmake = require("cmake-explorer")
	pickers
			.new(opts, {
				prompt_title = "CMake Builds",
				finder = finders.new_table({
					results = cmake.project.fileapis,
					-- entry_maker = cmake_make_entry.gen_from_fileapi(opts),
					entry_maker = function(entry)
						return {
							value = entry,
							display = entry.path,
							ordinal = entry.path,
						}
					end,
					sorter = conf.generic_sorter(opts),
					-- attach_mappings = function(prompt_bufnr, map)
					-- 	actions.select_default:replace(function() end)
					-- 	return true
					-- end,
				}),
			})
			:find()
end

M.configure = function(opts)
	local cmake = require("cmake-explorer")
	local runner = require("cmake-explorer.runner")
	pickers
			.new(opts, {
				prompt_title = "CMake Configure Options",
				finder = finders.new_table({
					results = cmake.project:list_configs(),
					entry_maker = cmake_make_entry.gen_from_configure(opts),
				}),
				sorter = conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						runner.start(selection.value.configure_command)
					end)
					return true
				end,
			})
			:find()
end

return M
