-- LSP configurations manager
local M = {}

-- Initialize all LSP configurations
function M.setup()
  local lspconfig = require("lspconfig")

  -- Load individual LSP configurations
  local configs = {
    bashls = true,
    -- Add other LSPs here
  }

  for server, enabled in pairs(configs) do
    if enabled then
      local ok, config = pcall(require, "lsp." .. server)
      if ok then
        lspconfig[server].setup(config)
      else
        vim.notify(string.format("Failed to load %s LSP config: %s", server, config), vim.log.levels.WARN)
      end
    end
  end
end

return M
