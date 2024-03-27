local config = require("cmake-explorer.config")
local Path = require("plenary.path")
local utils = require("cmake-explorer.utils")
local FileApi = require("cmake-explorer.file_api")
local Project = {}

local VariantConfig = {
  __index = function() end,
}

local variant_subs = {
  ["${workspaceFolder}"] = vim.loop.cwd(),
  ["${userHome}"] = vim.loop.os_homedir(),
}

function VariantConfig:new(obj)
  setmetatable(obj, self)
  obj.subs = obj:subs()
  obj.build_directory = obj:_build_directory()
  obj.configure_args = obj:_configure_args()
  obj.configure_command = obj:_configure_command()
  obj.build_args = obj:_build_args()
  obj.build_command = obj:_build_command()

  return obj
end

function VariantConfig:_subs()
  return vim.tbl_deep_extend("keep", variant_subs, { ["${buildType}"] = self.buildType })
end

function VariantConfig:_build_directory()
  return utils.substitude(config.build_directory, self.subs)
end

function VariantConfig:_configure_args()
  local args = {}
  if self.generator then
    table.insert(args, "-G " .. '"' .. self.generator .. '"')
  end
  if self.buildType then
    table.insert(args, "-DCMAKE_BUILD_TYPE=" .. self.buildType)
  end
  if string.lower(self.linkage) == "static" then
    table.insert(args, "-DCMAKE_BUILD_SHARED_LIBS=OFF")
  elseif string.lower(self.linkage) == "shared" then
    table.insert(args, "-DCMAKE_BUILD_SHARED_LIBS=ON")
  end
  for k, v in pairs(self.settings or {}) do
    table.insert(args, "-D" .. k .. "=" .. v)
  end
  table.insert(args, "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
  table.insert(
    args,
    "-B" .. Path:new(self:build_directory()):make_relative(utils.substitude(config.source_directory, self.subs))
  )
  return args
end

function VariantConfig:_configure_command()
  local ret = {}
  ret.cmd = config.cmake_path
  ret.args = self.configure_args
  ret.cwd = variant_subs["${workspaceFolder}"]
  ret.env = vim.tbl_deep_extend("keep", self.env, config.configure_environment, config.environment)
  return ret
end

function VariantConfig:_build_args()
  local args = { "--build" }
  table.insert(
    args,
    Path:new(self.build_directory):make_relative(utils.substitude(config.source_directory, self.subs))
  )
  table.insert(args, self.buildArgs or config.build_args)
  if self.buildToolArgs or config.build_tool_args then
    table.insert(args, "--")
    table.insert(args, self.buildToolArgs or config.build_tool_args)
  end
end

function VariantConfig:_build_command()
  local ret = {}
  ret.cmd = config.cmake_path
  ret.args = self.configure_args
  ret.cwd = variant_subs["${workspaceFolder}"]
  ret.env = vim.tbl_deep_extend("keep", self.env, config.configure_environment, config.environment)
  return ret
end

function Project.__index() end

local function cartesian_product(sets)
  local function collapse_result(res)
    local ret = {
      short = {},
      long = {},
      buildType = nil,
      linkage = nil,
      generator = nil,
      buildArgs = {},
      buildToolArgs = {},
      settings = {},
      env = {},
    }
    local is_default = true
    for _, v in ipairs(res) do
      ret.short[#ret.short + 1] = v.short
      ret.long[#ret.long + 1] = v.long
      ret.buildType = v.buildType or ret.buildType
      ret.linkage = v.linkage or ret.linkage
      ret.generator = v.generator or ret.generator
      ret.buildArgs = v.buildArgs or ret.buildArgs
      ret.buildToolArgs = v.buildToolArgs or ret.buildToolArgs
      for sname, sval in pairs(v.settings or {}) do
        ret.settings[sname] = sval
      end
      for ename, eres in pairs(v.env or {}) do
        ret.env[ename] = eres
      end
    end
    ret.default = is_default or nil
    return ret
  end
  local result = {}
  local set_count = #sets
  local function descend(depth)
    if depth == set_count then
      for k, v in pairs(sets[depth].choices) do
        if sets[depth].default ~= k then
          result.default = false
        end
        result[depth] = v
        result[depth].default = k == sets[depth].default
        coroutine.yield(collapse_result(result))
        result.default = true
      end
    else
      for k, v in pairs(sets[depth].choices) do
        if sets[depth].default ~= k then
          result.default = false
        end
        result[depth] = v
        result[depth].default = k == sets[depth].default
        descend(depth + 1)
      end
    end
  end
  return coroutine.wrap(function()
    descend(1)
  end)
end

function Project:from_variants(variants)
  local obj = { headers = {}, configs = {}, current_config = nil, fileapis = {} }
  local ivariants = {}
  for _, v in pairs(variants) do
    table.insert(obj.headers, v.description or "")
    table.insert(ivariants, v)
  end

  for _, v in cartesian_product(ivariants) do
    v = VariantConfig:new(v)
    table.insert(obj.configs, v)
    if v.default then
      obj.current_config = #obj.configs
    end
    if not obj.fileapis[v.build_directory] then
      obj.fileapis[v.build_directory] = FileApi:new(v.build_directory)
    end
  end
  return setmetatable(obj, self)
end

function Project:from_presets(presets)
  local obj = { { 1, 3, ddf = "" } }
  return setmetatable(obj, self)
end

function Project:set_current_config() end

function Project:set_current_build() end

function Project:conf_args() end

function Project:build_args() end

function Project:build_dir() end

function Project:list_configs() end

function Project:list_builds() end

return Project
