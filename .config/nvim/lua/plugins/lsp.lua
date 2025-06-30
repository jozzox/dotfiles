return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neodev.nvim", opts = {} },
      "mason.nvim",
      "mason-lspconfig.nvim",
    },
    config = function()
      -- Ensure the LSP is set up after the plugin is loaded
      require("neodev").setup()

      -- Initialize all LSP configurations
      require("lsp").setup()
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        },
        install_root_dir = vim.fn.stdpath("data") .. "/mason",
      })

      -- Ensure packages are installed
      local registry = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs({ "bash-language-server" }) do
          if not registry.is_installed(tool) then
            vim.notify("Installing " .. tool, vim.log.levels.INFO)
            registry.get_package(tool):install()
          end
        end
      end

      if registry.refresh then
        registry.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "bashls" },
        automatic_installation = true,
      })
    end,
  },
}
