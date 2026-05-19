vim.api.nvim_create_user_command("DjangoTestFile", function()
  local file = vim.fn.expand("%:.")
  file = file:match("apps[/\\].*") or file
  local label = file:gsub("/", "."):gsub("\\", "."):gsub("%.py$", "")

  local cmd = "python manage.py test " .. label

  vim.fn.setreg("+", cmd)
  vim.fn.setreg('"', cmd)

  print("Copied Django test import path: " .. cmd)
end, {})
