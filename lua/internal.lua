local Path = require "plenary.path"
local M = {}

M.systemCommands = true
M.loadedSetup = false

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

M.listCommands = {}

local function getCommandsNvim()
  local global_commands = vim.api.nvim_get_commands {}
  local buf_commands = vim.api.nvim_buf_get_commands(0, {})
  local commands = vim.tbl_extend("force", {}, global_commands, buf_commands)
  for key, value in pairs(commands) do
    if type(value) == "table" then
      table.insert(M.listCommands, {
        title = key,
        command = value.name
      })
    end
  end
end

function M.isSystemCommands(systemCommands)
  if systemCommands ~= nil then
    return systemCommands
  end
  return M.systemCommands
end

function M.concatCommands(commands, systemCommands)
  local enableSystemCommands = M.isSystemCommands(systemCommands)
  if enableSystemCommands then
    getCommandsNvim()
  end
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
  M.listCommands = M.concatCommands(opts.listCommands, opts.systemCommands)
  M.borders      = opts.borders or M.borders
  M.loadedSetup  = true
end

return M
