return {
  {
    "hirsaeki/winimectl",
    event = "VeryLazy",
    config = function()
      require("winimectl").setup()
    end,
  },
}
