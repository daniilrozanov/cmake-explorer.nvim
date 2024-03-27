local default_config = {
	cmake_path = "cmake",
	environment = {},
	configure_environment = {},
	build_directory = "${workspaceFolder}/build-${buildType}",
	build_environment = {},
	build_args = {},
	build_tool_args = {},
	generator = nil,
	default_variants = {},
	parallel_jobs = nil,
	save_before_build = true,
	source_directory = "${workspaceFolder}",
}

local M = vim.deepcopy(default_config)

M.setup = function(opts)
	local newconf = vim.tbl_deep_extend("force", default_config, opts or {})

	for k, v in pairs(newconf) do
		M[k] = v
	end
end

return M
