local M = {}

local function scan_directory(directory)
  local files = {}
  local handle = io.popen(string.format("ls -1 %s/*.lua 2>/dev/null", directory))
  if handle then
    for file in handle:lines() do
      local name = file:match "([^/]+)%.lua$"
      if name then
        table.insert(files, name)
      end
    end
    handle:close()
  end
  return files
end

local function get_available_plugins()
  local plugins_dir = vim.fn.stdpath "config" .. "/lua/plugins/extra"
  return scan_directory(plugins_dir)
end

local function get_available_lsp()
  local lsp_dir = vim.fn.stdpath "config" .. "/lsp"
  return scan_directory(lsp_dir)
end

local available_plugins = get_available_plugins()
local available_lsp = get_available_lsp()

local function show_help()
  local help_text = [[
Setup plugins and LSP servers for project-specific settings.

Available options:
1. Plugins:
]]

  -- Add plugins to help text
  for _, plugin in ipairs(available_plugins) do
    help_text = help_text .. string.format("   - %s\n", plugin)
  end

  help_text = help_text .. [[

2. LSP Servers:
]]

  -- Add LSP servers to help text
  for _, lsp in ipairs(available_lsp) do
    help_text = help_text .. string.format("   - %s\n", lsp)
  end

  help_text = help_text
    .. [[

  Please create .nvim-config.lua in the current directory with the following example:

```lua
-- Project-specific Neovim configuration

-- Set TypeScript LSP server
vim.g.lsp_typescript_server = "ts_ls" -- or "vtsls"

-- Enable additional LSP servers
vim.g.lsp_on_demands = {
    "eslint",
}

-- Enable extra plugins
vim.g.enable_extra_plugins = {
    "no-neck-pain",
}

-- Add any other project-specific settings below
-- vim.opt.tabstop = 2
-- vim.opt.shiftwidth = 2
```

]]

  Snacks.win {
    text = help_text,
    width = 0.6,
    height = 0.6,
    wo = {
      spell = false,
      wrap = false,
      signcolumn = "yes",
      statuscolumn = " ",
      conceallevel = 3,
    },
  }
end

local function create_nvim_config()
  -- Get plugin selection
  vim.ui.input({
    prompt = "Enter plugins to enable (comma-separated): ",
    default = "no-neck-pain",
  }, function(plugin_input)
    local selected_plugins = {}
    if plugin_input and plugin_input ~= "" then
      for item in plugin_input:gmatch "([^,]+)" do
        item = item:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
        table.insert(selected_plugins, item)
      end
    end
    vim.g.enable_extra_plugins = selected_plugins

    -- Get LSP selection
    vim.ui.input({
      prompt = "Enter LSP servers to enable (comma-separated): ",
      default = "eslint",
    }, function(lsp_input)
      local selected_lsp = {}
      if lsp_input and lsp_input ~= "" then
        for item in lsp_input:gmatch "([^,]+)" do
          item = item:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
          table.insert(selected_lsp, item)
        end
      end
      vim.g.lsp_on_demands = selected_lsp

      -- Create the config file
      local config = [[
-- Project-specific Neovim configuration

-- Set TypeScript LSP server
vim.g.lsp_typescript_server = "ts_ls" -- or "vtsls"

-- Enable additional LSP servers
vim.g.lsp_on_demands = {
]]

      -- Add selected LSP servers
      if vim.g.lsp_on_demands then
        for _, lsp in ipairs(vim.g.lsp_on_demands) do
          config = config .. string.format('    "%s",\n', lsp)
        end
      end

      config = config .. [[
}

-- Enable extra plugins
vim.g.enable_extra_plugins = {
]]

      -- Add selected plugins
      if vim.g.enable_extra_plugins then
        for _, plugin in ipairs(vim.g.enable_extra_plugins) do
          config = config .. string.format('    "%s",\n', plugin)
        end
      end

      config = config
        .. [[
}

-- Add any other project-specific settings below
-- vim.opt.tabstop = 2
-- vim.opt.shiftwidth = 2
]]

      local file = io.open(".nvim-config.lua", "w")
      if file then
        file:write(config)
        file:close()
        vim.notify("Created .nvim-config.lua with selected settings", vim.log.levels.INFO)
      else
        vim.notify("Failed to create .nvim-config.lua", vim.log.levels.ERROR)
      end
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("ProjectSettings", create_nvim_config, {
    desc = "Create .nvim-config.lua with interactive plugin and LSP selection",
  })

  vim.api.nvim_create_user_command("ProjectSettingsHelp", show_help, {
    desc = "Show available plugins and LSP servers for project settings",
  })
end

return M
