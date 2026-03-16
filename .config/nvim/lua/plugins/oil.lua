return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>t", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
  },

  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open Oil" },
      { "<leader>E", "<cmd>Oil --float<cr>", desc = "Open Oil (float)" },
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = "fast",
      },
      float = {
        padding = 2,
        max_width = 0.9,
        max_height = 0.9,
        border = "rounded",
      },
    },
  },
}
