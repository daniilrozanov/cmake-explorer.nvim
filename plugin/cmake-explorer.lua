local cmd = vim.api.nvim_create_user_command

cmd("CMakeConfigure", function()
	require("cmake-explorer").configure()
end, {
	nargs = 0,
	bang = true,
	desc = "Configure with parameters",
})

cmd("CMakeConfigureLast", function()
	require("cmake-explorer").configure_last()
end, { nargs = 0, bang = true, desc = "Configure last if exists. Otherwise default" })

cmd("CMakeConfigureDir", function()
	require("cmake-explorer").configure_dir()
end, { nargs = 0, bang = true, desc = "Configure one of existings directories" })
