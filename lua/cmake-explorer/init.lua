local config = require("cmake-explorer.config")
local runner = require("cmake-explorer.runner")
local Project = require("cmake-explorer.project")
local capabilities = require("cmake-explorer.capabilities")
local utils = require("cmake-explorer.utils")
local Path = require("plenary.path")
-- local pickers = require("cmake-explorer.pickers")

local M = {}

M.project = nil

local format_build_dir = function()
	if Path:new(config.build_dir):is_absolute() then
		return function(v)
			return Path:new(v.path):make_relative(vim.env.HOME)
		end
	else
		return function(v)
			return Path:new(v.path):make_relative(M.project.path)
		end
	end
end

function M.configure()
	assert(M.project)
	local generators = capabilities.generators()
	table.insert(generators, 1, "Default")
	vim.ui.select(generators, { prompt = "Select generator" }, function(generator)
		if not generator then
			return
		end
		-- TODO: handle default generator from env (or from anywhere else)
		generator = utils.is_neq(generator, "Default")
		vim.ui.select(config.build_types, { prompt = "Select build type" }, function(build_type)
			if not build_type then
				return
			end
			vim.ui.input({ prompt = "Input additional args" }, function(args)
				if not build_type then
					return
				end
				local task = M.project:configure({ generator = generator, build_type = build_type, args = args })
				runner.start(task)
			end)
		end)
	end)
end

function M.configure_dir()
	assert(M.project)

	vim.ui.select(
		M.project:list_build_dirs(),
		{ prompt = "Select directory to build", format_item = format_build_dir() },
		function(dir)
			if not dir then
				return
			end
			local task = M.project:configure(dir.path)
			runner.start(task)
		end
	)
end

function M.configure_last()
	local task = M.project:configure_last()
	runner.start(task)
end

function M.setup(opts)
	opts = opts or {}

	config.setup(opts)
	capabilities.setup()

	M.project = Project:new(vim.loop.cwd())

	if not M.project then
		print("cmake-explorer: no CMakeLists.txt file found. Aborting setup")
		return
	end
	M.project:scan_build_dirs()
end

M.config = M.setup

return M
