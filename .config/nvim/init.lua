-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })
