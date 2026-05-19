-- 前回選択したカラースキームを保存しているファイルから読み込む
-- ファイルが無い、または読めない場合はデフォルトの tokyonight にフォールバック
local function load_saved_colorscheme()
  local path = vim.fn.stdpath("data") .. "/last-colorscheme"
  local f = io.open(path, "r")
  if not f then
    return "tokyonight"
  end
  local name = f:read("*l")
  f:close()
  if not name or name == "" then
    return "tokyonight"
  end
  return name
end

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "rebelot/kanagawa.nvim",
    -- opts = {
    --   transparent = true,
    --   styles = {
    --     sidebars = "transparent",
    --     floats = "transparent",
    --   },
    -- },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = load_saved_colorscheme(),
    },
  },
}
