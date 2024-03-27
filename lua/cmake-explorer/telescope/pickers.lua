local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local cmake_make_entry = require("cmake-explorer.make_entry")

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

M.profiles = function(opts)
	local cmake = require("cmake-explorer")
	pickers
			.new(opts, {
				prompt_title = "CMake Profiles",
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

return M
