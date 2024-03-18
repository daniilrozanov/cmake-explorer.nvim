local make_entry = require("telescope.make_entry")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

M.gen_from_fileapi = function(opts)
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { remaining = true },
      { width = 15 },
    },
  })

  local make_display = function(entry)
    return displayer({
      -- { entry.value, "TelescopeResultsIdentifier" },
      entry.ordinal,
    })
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      value = entry,
      ordinal = entry.codemodel.paths.build,
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
