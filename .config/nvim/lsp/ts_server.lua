return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "javascript",
    "javascriptreact",
    "javascript.jsx",
  },
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)
  end,
  settings = {},
}
