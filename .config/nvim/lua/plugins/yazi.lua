return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",

  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },

  keys = {
    {
      "<leader>e",
      "<cmd>Yazi<cr>",
      desc = "Open Yazi",
    },
  },

  opts = {
    open_for_directories = true,
  },

  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}
