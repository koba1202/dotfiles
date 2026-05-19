return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    keys = {
      { "<leader>gB", "<cmd>BlameToggle<cr>", desc = "Toggle Git Blame" },
    },
    opts = {
      date_format = "%Y/%m/%d",
      blame_options = { '-w' },
    }
  }
}
