return {
  "folke/tokyonight.nvim",
  lazy = true,
  opts = {
    style = "night", -- Mögliche Werte: 'storm', 'moon', 'night', 'day'
    transparent = true, -- Transparenter Hintergrund
    terminal_colors = true, -- Terminalfarben anpassen
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "dark", -- 'dark' oder 'transparent'
      floats = "dark", -- 'dark' oder 'transparent'
    },
    on_highlights = function(hl, c)
      -- Transparenter Hintergrund für Floating Windows
      hl.NormalFloat = { bg = "none" }
      hl.FloatBorder = { bg = "none" }
      hl.FloatTitle = { bg = "none" }
      -- Beispiel für Dashboard- und Notifier-Overrides
      hl.SnacksDashboardHeader = { fg = c.red }
      hl.SnacksDashboardFooter = { fg = c.comment }
      hl.SnacksDashboardDesc = { fg = c.cyan }
      hl.SnacksDashboardIcon = { fg = c.yellow }
      hl.SnacksDashboardKey = { fg = c.magenta }
      hl.SnacksDashboardSpecial = { fg = c.comment }
      hl.SnacksDashboardDir = { fg = c.cyan }
      hl.SnacksNotifierBorderError = { link = "DiagnosticError" }
      hl.SnacksNotifierBorderWarn = { link = "DiagnosticWarn" }
      hl.SnacksNotifierBorderInfo = { link = "DiagnosticInfo" }
      hl.SnacksNotifierBorderDebug = { link = "Debug" }
      hl.SnacksNotifierBorderTrace = { link = "Comment" }
      hl.SnacksNotifierIconError = { link = "DiagnosticError" }
      hl.SnacksNotifierIconWarn = { link = "DiagnosticWarn" }
      hl.SnacksNotifierIconInfo = { link = "DiagnosticInfo" }
      hl.SnacksNotifierIconDebug = { link = "Debug" }
      hl.SnacksNotifierIconTrace = { link = "Comment" }
      hl.SnacksNotifierTitleError = { link = "DiagnosticError" }
      hl.SnacksNotifierTitleWarn = { link = "DiagnosticWarn" }
      hl.SnacksNotifierTitleInfo = { link = "DiagnosticInfo" }
      hl.SnacksNotifierTitleDebug = { link = "Debug" }
      hl.SnacksNotifierTitleTrace = { link = "Comment" }
      hl.SnacksNotifierError = { link = "DiagnosticError" }
      hl.SnacksNotifierWarn = { link = "DiagnosticWarn" }
      hl.SnacksNotifierInfo = { link = "DiagnosticInfo" }
      hl.SnacksNotifierDebug = { link = "Debug" }
      hl.SnacksNotifierTrace = { link = "Comment" }
      hl.SnacksProfilerIconInfo = { bg = c.bg_search, fg = c.blue }
      hl.SnacksProfilerBadgeInfo = { bg = c.bg_visual, fg = c.blue }
      hl.SnacksScratchKey = { link = "SnacksProfilerIconInfo" }
      hl.SnacksScratchDesc = { link = "SnacksProfilerBadgeInfo" }
      hl.SnacksProfilerIconTrace = { bg = c.blue, fg = c.border }
      hl.SnacksProfilerBadgeTrace = { bg = c.blue, fg = c.border }
      hl.SnacksIndent = { fg = c.bg_highlight, nocombine = true }
      hl.SnacksIndentScope = { fg = c.bg_sidebar, nocombine = true }
      hl.SnacksZenIcon = { fg = c.purple }
      hl.SnacksInputIcon = { fg = c.bg_sidebar }
      hl.SnacksInputBorder = { fg = c.cyan }
      hl.SnacksInputTitle = { fg = c.cyan }
      hl.SnacksPickerInputBorder = { fg = c.orange }
      hl.SnacksPickerInputTitle = { fg = c.orange }
      hl.SnacksPickerBoxTitle = { fg = c.orange }
      hl.SnacksPickerSelected = { fg = c.yellow }
      hl.SnacksPickerToggle = { link = "SnacksProfilerBadgeInfo" }
      hl.SnacksPickerPickWinCurrent = { fg = c.fg, bg = c.yellow, bold = true }
      hl.SnacksPickerPickWin = { fg = c.fg, bg = c.bg_search, bold = true }
    end,
    -- Weitere Optionen siehe: https://github.com/folke/tokyonight.nvim#%EF%B8%8F-configuration
  },
}
