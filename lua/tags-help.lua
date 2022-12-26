local utils = require 'utils'
local ui = require 'ui'
local listWin, listBuffer, listBorderWin
local entryWin, entryBuffer, entryBorderWin
local api = vim.api
local position = 0

local spaceTagsList = api.nvim_create_namespace('tags-help-list')

local function closeWindow()
  api.nvim_win_close(entryWin, true)
  api.nvim_win_close(listWin, true)
  api.nvim_win_close(listBorderWin, true)
  api.nvim_win_close(entryBorderWin, true)
  utils.bufDelete(entryBuffer)
  utils.bufDelete(listBuffer)
end

local function updateView(direction, listActions)
  api.nvim_buf_set_option(listBuffer, 'modifiable', true)
  position = position + direction
  if position < 0 then position = 0 end
  api.nvim_buf_set_lines(listBuffer, 3, -1, false, listActions)
  api.nvim_buf_set_option(listBuffer, 'modifiable', false)
  local currentPosition = api.nvim_win_get_cursor(listWin)[1]
  api.nvim_buf_add_highlight(listBuffer, spaceTagsList, 'DiagnosticVirtualTextError', currentPosition, 0, -1)
end

local function setMappingPrompt()
  local opts = { noremap = true, silent = true }
  api.nvim_buf_set_keymap(entryBuffer, '!', '<esc>', [[<C-\><C-n>:lua require"tags-help".closeWindow()<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<Up>', [[<cmd> :lua require("tags-help").moveCursor("up")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<Down>', [[<cmd> :lua require("tags-help").moveCursor("down")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<cr>', [[<cmd> :lua require("tags-help").runCommand()<CR>]], opts)
end

local function set_mappings()
  local mappings = {
    ['['] = 'updateView(-1)',
    [']'] = 'updateView(1)',
    ['<cr>'] = 'runCommand()',
    h = 'updateView(-1)',
    l = 'updateView(1)',
    q = 'closeWindow()',
    k = 'moveCursor("up")',
    ['.'] = 'moveCursor("down")'
  }

  for k, v in pairs(mappings) do
    api.nvim_buf_set_keymap(listBuffer, 'n', k, ':lua require"tags-help".' .. v .. '<cr>', {
      nowait = true, noremap = true, silent = true
    })
  end
  local other_chars = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  }
  for _, v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(listBuffer, 'n', v, '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(listBuffer, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(listBuffer, 'n', '<c-' .. v .. '>', '', { nowait = true, noremap = true, silent = true })
  end
end

local function moveCursor(direction)
  local currentPosition = api.nvim_win_get_cursor(listWin)[1]
  local maxHeight = api.nvim_buf_line_count(listBuffer)
  local newPosition = 0

  if direction == "up" then
    newPosition = math.max(3, currentPosition - 1)
  else if direction == "down" then
      newPosition = math.min(maxHeight - 1, currentPosition + 1)
    end
  end

  api.nvim_buf_clear_namespace(listBuffer, spaceTagsList, currentPosition, -1) -- delete highlight
  api.nvim_buf_add_highlight(listBuffer, spaceTagsList, "DiagnosticVirtualTextError", newPosition, 0, -1)
  api.nvim_win_set_cursor(listWin, { newPosition, 0 })
end

local function runCommand()
  local currentPosition = api.nvim_win_get_cursor(listWin)[1]
  local str = api.nvim_buf_get_lines(listBuffer, currentPosition, currentPosition + 1, true)[1]
  print(str)
  if (string.find(str, ":")) then
    api.nvim_command(":" .. str)
  end
end

local listActions = {
  [1] = "  Telescope",
  [2] = "  Lspsaga diagnostic_jump_next",
  [3] = "  Lspsaga diagnostic_jump_prev",
}
local function tagsHelp()
  position = 0

  local main = ui.createMain(0.6, 0.3, -10);
  listWin = main.win
  listBuffer = main.buffer
  listBorderWin = main.winBorder
  local entry = ui.createPromp(0.6, 0.02)
  entryWin = entry.win
  entryBuffer = entry.buffer
  entryBorderWin = entry.winBorder

  set_mappings()
  setMappingPrompt()
  updateView(0, listActions)
end

return {
  tagsHelp = tagsHelp,
  closeWindow = closeWindow,
  setMappingPrompt = setMappingPrompt,
  moveCursor = moveCursor,
  updateView = updateView,
  runCommand = runCommand
}
