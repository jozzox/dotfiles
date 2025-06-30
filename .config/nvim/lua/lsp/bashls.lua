local util = require("lspconfig.util")

local function get_root_dir(fname)
  -- Ensure fname is a string and convert to string if needed
  fname = tostring(fname or "")

  -- Find the root directory
  local root = util.find_git_ancestor(fname)
  if not root then
    -- Fallback to the directory containing the file
    root = vim.fn.expand(fname .. ":p:h")
  end
  return root
end

return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  single_file_support = true,
  root_dir = get_root_dir,
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)"
    }
  }
}
