local Lsp = require "utils.lsp"
-- go install golang.org/x/tools/gopls@latest
return {
  cmd = { "gopls" },
  on_attach = Lsp.on_attach,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.sum", "go.mod", ".git" },
}
