local M = {}

local function copy_to_clipboard(text, message)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  print(message .. text)
end

function M.setup()
  vim.api.nvim_create_user_command("CopyFilePath", function()
    local file = vim.fn.expand("%:.")
    copy_to_clipboard(file, "Copied file path: ")
  end, {})

  vim.api.nvim_create_user_command("CopyAbsoluteFilePath", function()
    local file = vim.fn.expand("%:p")
    copy_to_clipboard(file, "Copied absolute path: ")
  end, {})
end

return M
