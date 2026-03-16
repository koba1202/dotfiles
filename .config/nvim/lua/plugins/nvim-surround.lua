return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = { "BufNewFile", "BufReadPre" },
    config = function()
      require("plugins.nvim-surround")
    end,
  },
}
