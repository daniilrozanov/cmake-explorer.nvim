local make_entry = require("telescope.make_entry")
local entry_display = require("telescope.pickers.entry_display")
local config = require("cmake-explorer.config")

local M = {}

M.gen_from_configure = function(opts)
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 30 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    vim.print(entry)
    return displayer({
      { table.concat(entry.value.short, config.variants_display.short_sep), "TelescopeResultsIdentifier" },
      { table.concat(entry.value.long, config.variants_display.long_sep),   "TelescopeResultsIdentifier" },
    })
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      value = entry,
      ordinal = table.concat(entry.short, config.variants_display.short_sep),
      display = make_display,

      -- bufnr = entry.bufnr,
      -- filename = filename,
      -- lnum = entry.lnum,
      -- col = entry.col,
      -- text = entry.text,
      -- start = entry.start,
      -- finish = entry.finish,
    }, opts)
  end
end

return M
