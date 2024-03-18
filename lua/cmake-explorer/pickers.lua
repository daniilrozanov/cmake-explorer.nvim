local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local cmake_make_entry = require("cmake-explorer.make_entry")

local M = {}

M.build_dirs = function(opts)
	pickers.new(opts, {
		prompt_title = "Builds",
		finder = finders.new_table({
			results = cmake.project.fileapis,
			-- entry_maker = cmake_make_entry.gen_from_fileapi(opts),
			sorter = conf.generic_sorter(opts),
		}),
	})
end

return M
