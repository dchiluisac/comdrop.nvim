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
M.userListCommands = {}

local function isSystemCommands(systemCommands)
  if systemCommands ~= nil then
    return systemCommands
  end
  return true
end

M.setup = function(opts)
  opts               = opts or {}
  M.userListCommands = opts.listCommands or {}
  M.borders          = opts.borders or M.borders
  M.loadedSetup      = true
  M.systemCommands   = isSystemCommands(opts.systemCommands)
end

return M
