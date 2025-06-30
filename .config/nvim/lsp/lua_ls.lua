local Lsp = require "utils.lsp"
-- NOTE: mise use -g lua-language-server
-- Credit to https://lsp-zero.netlify.app/blog/lsp-config-overview.html
return {
  cmd = { "lua-language-server" },
  on_attach = Lsp.on_attach,
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc" },
}
