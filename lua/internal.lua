local M = {}

M.highlights = {
  ComdropSelection = { default = true, link = "Visual" },
  ComdropTitle = { default = true, link = "ComdropTitle" },
}

for k, v in pairs(M.highlights) do
  vim.api.nvim_set_hl(0, k, v)
end

M.borders = {
  top_left = "╭",
  top_mid = "─",
  top_right = "╮",
  mid = "│",
  bottom_left = "╰",
  bottom_right = "╯"
};

M.nameSpace = 'comdrop-list-name-space'

M.listCommands = {
  { title = 'New tab', command = 'tabnew' },
  { title = 'diagnostic_jump_next', command = 'Lspsaga diagnostic_jump_next', delay = true },
  { title = 'diagnostic_jump_prev', command = 'Lspsaga diagnostic_jump_prev', delay = true },
}

local function getCommandsNvim()
  local scripts = vim.api.nvim_command_output("command")
  local dd = vim.split(scripts, '\n')
  for _, value in pairs(dd) do
    local line = string.gsub(value, "%s+", "")
    line = string.gsub(line, "0", "-split-")
    line = string.gsub(line, "*", "-split-")
    line = string.gsub(line, "?", "-split-")
    line = string.gsub(line, "+", "-split-")
    line = string.gsub(line, "1", "-split-")
    local command = vim.split(line, '-split-')[1]
    table.insert(M.listCommands, {
      title = command,
      command = command,
    })
  end
end

function M.concatCommands(commands)
  getCommandsNvim()
  if commands ~= nil then
    local newCommands = M.listCommands
    for _, value in ipairs(commands) do
      table.insert(newCommands, value)
    end
    return newCommands
  end
  return M.listCommands
end

M.setup = function(opts)
  opts           = opts or {}
  M.listCommands = M.concatCommands(opts.listCommands)
  M.borders      = opts.borders or M.borders
end

return M
