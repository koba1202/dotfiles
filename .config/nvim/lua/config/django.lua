vim.api.nvim_create_user_command("DjangoTestFile", function()
  local file = vim.fn.expand("%:.")
  local label = file:gsub("/", "."):gsub("\\", "."):gsub("%.py$", "")

  vim.fn.setreg("+", label)
  vim.fn.setreg('"', label)

  print("Copied Django test import path: " .. label)
end, {})
