-- Monochrome LazyVim
--
-- Uses tokyonight as the highlight engine (so every LazyVim plugin keeps its
-- integrations and contrast hierarchy), but flattens the entire palette to
-- neutral grey. The base neutrals are tuned to the same #0D0D0D → #F0F0F0
-- ramp used by i3 / Polybar / Ghostty / Alacritty.
--
-- Set `transparent = false` below if you prefer an opaque #0D0D0D background.

local transparent = true

---Convert a `#rrggbb` color to its perceived (Rec. 709 luma) grey value.
---Grey stays grey, so values coming from blends are safe to re-run.
---@param hex string
---@return string
local function grayscale(hex)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  if not (r and g and b) then
    return hex
  end

  local y = math.floor(0.2126 * r + 0.7152 * g + 0.0722 * b + 0.5)
  return string.format("#%02x%02x%02x", y, y, y)
end

---Recursively flatten every hex string in a palette table.
---@param tbl table
local function flatten(tbl)
  for key, value in pairs(tbl) do
    if type(value) == "table" then
      flatten(value)
    elseif type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
      tbl[key] = grayscale(value)
    end
  end
end

return {
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      opts.style = "night"
      opts.transparent = transparent
      opts.styles = vim.tbl_deep_extend("force", opts.styles or {}, {
        sidebars = "transparent",
        floats = "dark",
      })

      opts.on_colors = function(colors)
        -- Remove every hue first, keeping only the light/dark relationships.
        flatten(colors)

        -- Anchor the neutrals to the desktop palette.
        colors.bg = "#0d0d0d"
        colors.bg_dark = "#141414"
        colors.bg_dark1 = "#0d0d0d"
        colors.bg_highlight = "#1a1a1a"
        colors.bg_popup = "#141414"
        colors.bg_float = "#141414"
        colors.bg_statusline = "#141414"
        colors.fg = "#e6e6e6"
        colors.fg_dark = "#c8c8c8"
        colors.fg_float = "#e6e6e6"
        colors.fg_sidebar = "#9a9a9a"
        colors.fg_gutter = "#4a4a4a"
        colors.comment = "#6e6e6e"
        colors.dark3 = "#4a4a4a"
        colors.dark5 = "#6e6e6e"
        colors.border = "#2a2a2a"
        colors.border_highlight = "#8a8a8a"

        -- Diagnostics get a deliberate brightness ramp: errors are the
        -- brightest, hints the dimmest. Undercurls/signs still carry meaning.
        colors.error = "#f0f0f0"
        colors.warning = "#c8c8c8"
        colors.info = "#9a9a9a"
        colors.hint = "#6e6e6e"
        colors.todo = "#c8c8c8"

        -- Keep blends performed while building highlights on the new base.
        local Util = require("tokyonight.util")
        Util.bg = colors.bg
        Util.fg = colors.fg
      end

      opts.on_highlights = function(hl)
        local bg = transparent and "NONE" or "#0d0d0d"

        -- Base UI
        hl.Normal = { fg = "#e6e6e6", bg = bg }
        hl.NormalNC = { fg = "#c8c8c8", bg = bg }
        hl.NormalFloat = { fg = "#e6e6e6", bg = "#141414" }
        hl.FloatBorder = { fg = "#3a3a3a", bg = "#141414" }
        hl.FloatTitle = { fg = "#f0f0f0", bg = "#141414", bold = true }
        hl.WinSeparator = { fg = "#2a2a2a" }
        hl.VertSplit = { link = "WinSeparator" }
        hl.WinBar = { fg = "#c8c8c8", bg = "#141414", bold = true }
        hl.WinBarNC = { fg = "#6e6e6e", bg = "#141414" }

        -- Cursor / selections
        hl.Cursor = { fg = "#0d0d0d", bg = "#f0f0f0" }
        hl.CursorIM = { link = "Cursor" }
        hl.TermCursor = { link = "Cursor" }
        hl.CursorLine = { bg = "#1a1a1a" }
        hl.CursorColumn = { bg = "#1a1a1a" }
        hl.ColorColumn = { bg = "#1a1a1a" }
        hl.CursorLineNr = { fg = "#f0f0f0", bold = true }
        hl.Visual = { bg = "#3a3a3a", fg = "#f2f2f2" }
        hl.VisualNOS = { link = "Visual" }

        -- Search
        hl.Search = { bg = "#8a8a8a", fg = "#0d0d0d" }
        hl.IncSearch = { bg = "#f0f0f0", fg = "#0d0d0d", bold = true }
        hl.CurSearch = { link = "IncSearch" }

        -- Popups / menus
        hl.Pmenu = { bg = "#141414", fg = "#e6e6e6" }
        hl.PmenuSel = { bg = "#3a3a3a", fg = "#ffffff", bold = true }
        hl.PmenuSbar = { bg = "#242424" }
        hl.PmenuThumb = { bg = "#4a4a4a" }

        -- Statusline / tabs / gutters
        hl.StatusLine = { bg = "#1a1a1a", fg = "#e6e6e6" }
        hl.StatusLineNC = { bg = "#141414", fg = "#6e6e6e" }
        hl.TabLine = { bg = "#141414", fg = "#9a9a9a" }
        hl.TabLineSel = { bg = "#0d0d0d", fg = "#e6e6e6", bold = true }
        hl.TabLineFill = { bg = "#141414" }
        hl.LineNr = { fg = "#4a4a4a" }
        hl.SignColumn = { bg = bg }
        hl.FoldColumn = { bg = bg, fg = "#3a3a3a" }

        -- Syntax chrome
        hl.Comment = { fg = "#6e6e6e", italic = true }
        hl.NonText = { fg = "#3a3a3a" }
        hl.Whitespace = { fg = "#2a2a2a" }
        hl.EndOfBuffer = { fg = "#1a1a1a" }
        hl.Directory = { fg = "#c8c8c8" }
        hl.Title = { fg = "#f0f0f0", bold = true }
        hl.MatchParen = { bg = "#3a3a3a", fg = "#ffffff", bold = true }

        -- Neovim built-ins that bypass the colorscheme palette entirely.
        local merge = function(name, attrs)
          hl[name] = vim.tbl_extend("force", hl[name] or {}, attrs)
        end
        hl.Added = { fg = "#b9b9b9" }
        hl.Changed = { fg = "#a6a6a6" }
        hl.Removed = { fg = "#9a9a9a" }
        hl.OkMsg = { fg = "#c8c8c8" }
        merge("DiagnosticDeprecated", { sp = "#8a8a8a" })
        merge("DiagnosticUnderlineOk", { sp = "#a6a6a6" })
        hl.FloatShadow = { bg = "#4a4a4a" }
        hl.FloatShadowThrough = { bg = "#4a4a4a" }
        hl.RedrawDebugClear = { bg = "#6b6b6b" }
        hl.RedrawDebugComposed = { bg = "#3a3a3a" }
        hl.RedrawDebugRecompose = { bg = "#2a2a2a" }
      end
    end,
  },

  -- Make the choice explicit (this is also LazyVim's default).
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },
}
