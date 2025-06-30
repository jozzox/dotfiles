require("config.options")

-- Load project setting if available, e.g: .nvim-config.lua
-- This file is not tracked by git
-- It can be used to set project specific settings
-- Ensure 'vim' global is available (for external Lua interpreters)
if vim == nil then
  vim = require('vim')
end
local project_setting = vim.fn.getcwd() .. "/.nvim-config.lua"
-- Check if the file exists and load it
if vim.loop.fs_stat(project_setting) then
  -- Read the file and run it with pcall to catch any errors
  local ok, err = pcall(dofile, project_setting)
  if not ok then
    vim.notify("Error loading project setting: " .. err, vim.log.levels.ERROR)
  end
end

require("config.lazy")
require("config.keymaps")
require("config.autocmds")
require("config.project")

--Theme
require("tokyonight").load({ style = "moon" })

-- LSP

local ts_server = vim.g.lsp_typescript_server or "ts_ls" -- "ts_ls" or "vtsls" for TypeScript

vim.lsp.enable {
  "ts_server",   -- TypeScript/JavaScript
  "lua_ls",      -- Lua
  "biome",       -- Biome
  "bashls",      -- Bash
  "jsonls",      -- JSON
  "pyright",     -- Python
  "gopls",       -- Go
  "tailwindcss", -- Tailwind CSS
}

if vim.g.lsp_on_demands then
  vim.lsp.enable(vim.g.lsp_on_demands)
end
