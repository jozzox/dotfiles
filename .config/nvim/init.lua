-- Add config root to runtime path for lua modules
package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/?.lua"

require "config.options"

-- Load project setting if available, e.g: .nvim-config.lua
-- This file is not tracked by git
-- It can be used to set project specific settings
local project_setting = vim.fn.getcwd() .. "/.nvim-config.lua"
-- Check if the file exists and load it
if vim.loop.fs_stat(project_setting) then
  -- Read the file and run it with pcall to catch any errors
  local ok, err = pcall(dofile, project_setting)
  if not ok then
    vim.notify("Error loading project setting: " .. err, vim.log.levels.ERROR)
  end
end

require "config.autocmds"
require "config.lazy"
require "config.keymaps"
require "config.project"

-- Only load the theme if not in VSCode
if vim.g.vscode then
  -- Trigger vscode keymap
  local pattern = "NvimIdeKeymaps"
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
else
  -- Load the theme
  -- require("tokyonight").load "dark" -- Alternative Theme-Ladezeile, falls später benötigt
  vim.cmd("colorscheme tokyonight")

  local ts_server = vim.g.lsp_typescript_server or "ts_ls" -- "ts_ls" or "vtsls" for TypeScript

  -- Configure bashls before enabling it
  vim.lsp.config('bashls', {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh" },
    root_dir = function(fname)
      -- fname kann Buffer-Nummer oder Pfad sein
      local path = fname
      if type(fname) == "number" then
        path = vim.api.nvim_buf_get_name(fname)
      end
      local util = vim.lsp.util or {}
      local find_git_ancestor = util.find_git_ancestor
      if not find_git_ancestor then
        -- Alternative mit vim.fs.find (Neovim >=0.9)
        local git_dir = vim.fs.find('.git', { upward = true, path = path })[1]
        if git_dir then
          return vim.fs.dirname(git_dir)
        end
        return vim.loop.os_homedir()
      end
      return find_git_ancestor(path) or vim.loop.os_homedir()
    end,
    settings = {
      bashIde = {
        globPattern = "*.*",
      },
    },
  })

  -- Enable LSP servers for Neovim 0.11+
  vim.lsp.enable {
    ts_server,
    "lua_ls", -- Lua
    "biome", -- Biome = Eslint + Prettier
    "json", -- JSON
    "pyright", -- Python
    "gopls", -- Go
    "tailwindcss", -- Tailwind CSS
    "bashls", -- Bash Language Server
  }

  -- Load Lsp on-demand, e.g: eslint is disable by default
  -- e.g: We could enable eslint by set vim.g.lsp_on_demands = {"eslint"}
  if vim.g.lsp_on_demands then
    vim.lsp.enable(vim.g.lsp_on_demands)
  end
end
