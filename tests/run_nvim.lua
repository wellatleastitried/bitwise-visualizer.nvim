--- Runs the Neovim integration suites.
---
---   nvim -l tests/run_nvim.lua
---
--- Requires the Tree-sitter parsers of the languages under test; suites for
--- missing parsers are skipped rather than failed.

vim.opt.runtimepath:prepend(vim.fn.getcwd())
package.path = table.concat({
  vim.fn.getcwd() .. "/lua/?.lua",
  vim.fn.getcwd() .. "/lua/?/init.lua",
  vim.fn.getcwd() .. "/tests/?.lua",
  package.path,
}, ";")

-- CI runners have no system clipboard tool (xclip, wl-copy, pbcopy, ...), so
-- the "+/"* registers would silently no-op without this. A fake in-memory
-- provider makes setreg/getreg("+") behave like a real register everywhere.
local fake_clipboard = {}
vim.g.clipboard = {
  name = "fake (test-only)",
  copy = {
    ["+"] = function(lines, regtype)
      fake_clipboard["+"] = { lines, regtype }
    end,
    ["*"] = function(lines, regtype)
      fake_clipboard["*"] = { lines, regtype }
    end,
  },
  paste = {
    ["+"] = function()
      return fake_clipboard["+"] or { {}, "v" }
    end,
    ["*"] = function()
      return fake_clipboard["*"] or { {}, "v" }
    end,
  },
}

local t = require("harness")

require("bitwise-visualizer").setup({})

require("nvim.parser_spec")
require("nvim.resolver_spec")
require("nvim.generic_spec")
require("nvim.integration_spec")

os.exit(t.summary())
