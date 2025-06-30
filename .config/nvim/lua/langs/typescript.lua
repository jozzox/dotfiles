return {
  {
    "dmmulroy/ts-error-translator.nvim",
    ft = "javascript,typescript,typescriptreact,svelte",
  },
  {
    "jellydn/typecheck.nvim",
    ft = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
    opts = {
      debug = true,
    },
    keys = {
      {
        "<leader>ck",
        "<cmd>Typecheck<cr>",
        desc = "Run Type Check",
      },
    },
  },
}
