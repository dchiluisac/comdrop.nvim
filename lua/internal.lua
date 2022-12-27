local Path = require "plenary.path"
local M = {}

M.systemCommands = true

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
}

local function getCommandsNvim()
  local files = {}
  local help_files = {}
  local all_files = vim.api.nvim_get_runtime_file("doc/*", true)
  for _, fullpath in ipairs(all_files) do
    local file = require('utils').path_tail(fullpath)
    if file == "tags" then
      table.insert(files, fullpath)
    else
      help_files[file] = fullpath
    end
  end

  local tags = {}
  local tags_map = {}
  local delimiter = string.char(9)
  for _, file in ipairs(files or {}) do
    local lines = vim.split(Path:new(file):read(), "\n", true)
    for _, line in ipairs(lines) do
      if not line:match "^!_TAG_" then
        local fields = vim.split(line, delimiter, true)
        if #fields == 3 and not tags_map[fields[1]] then
          if fields[1] ~= "help-tags" or fields[2] ~= "tags" then
            table.insert(tags, {
              name = fields[1],
              filename = help_files[fields[2]],
              cmd = fields[3],
            })
            tags_map[fields[1]] = true
          end
        end
      end
    end
  end
  for _, value in ipairs(tags) do
    table.insert(M.listCommands, {
      title = string.gsub(value.name, ':', ''),
      command = value.name,
    })

  end
end

function M.isSystemCommands(systemCommands)
  print(systemCommands)
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
end

return M
