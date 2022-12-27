local api = vim.api
local utils = require('utils')
local ui = require('ui')
local internal = require('internal')
local listWin, listBuffer, listBorderWin
local entryWin, entryBuffer, entryBorderWin
local position = 0
local spaceTagsList = api.nvim_create_namespace(internal.nameSpace)
local M = {}
--function sorted_iter(t)
--  local i = {}
--  for k in next, t do
--    table.insert(i, k)
--  end
--  table.sort(i)
--  return function()
--    local k = table.remove(i)
--    if k ~= nil then
--      return k, t[k]
--    end
--  end
--end

function M.closeWindow()
  api.nvim_win_close(entryWin, true)
  api.nvim_win_close(listWin, true)
  api.nvim_win_close(listBorderWin, true)
  api.nvim_win_close(entryBorderWin, true)
  utils.bufDelete(entryBuffer)
  utils.bufDelete(listBuffer)
end

function M.updateView(direction, commands)
  local listRender = {}
  for _, value in ipairs(commands) do
    table.insert(listRender, '   ' .. value.title)
  end
  api.nvim_buf_set_option(listBuffer, 'modifiable', true)
  position = position + direction
  if position < 0 then position = 0 end
  api.nvim_buf_set_lines(listBuffer, 3, -1, false, listRender)
  api.nvim_buf_set_option(listBuffer, 'modifiable', false)
  local currentPosition = api.nvim_win_get_cursor(listWin)[1]
  api.nvim_buf_add_highlight(listBuffer, spaceTagsList, 'DiagnosticVirtualTextError', currentPosition, 0, -1)
  api.nvim_win_set_cursor(listWin, { 3, 0 })
end

function M.setMappingPrompt()
  local opts = { noremap = true, silent = true, nowait = true }
  api.nvim_buf_set_keymap(entryBuffer, '!', '<esc>', [[<C-\><C-n>:lua require"tags-help".closeWindow()<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<Up>', [[<cmd> :lua require("tags-help").moveCursor("up")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<Down>', [[<cmd> :lua require("tags-help").moveCursor("down")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<cr>', [[<cmd> :lua require("tags-help").runCommand()<CR>]], opts)
end

function M.moveCursor(direction)
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

function M.runCommand()
  local currentPosition = api.nvim_win_get_cursor(listWin)[1]
  local str = api.nvim_buf_get_lines(listBuffer, currentPosition, currentPosition + 1, true)[1]
  local commandSelected = string.gsub(str, "%s+", "")
  for _, value in ipairs(internal.listCommands) do
    local command = string.gsub(value.title, "%s+", "")
    if command == commandSelected then
      if value.delay ~= nil then
        utils.delay(value.command)
      else
        vim.api.nvim_command(value.command)
      end
    end
  end
  M.closeWindow()
end

local function filter_inplace(t, val)
  local tableFilter = {}
  for _, v in ipairs(t) do
    if string.find(string.lower(v.title), string.lower(val)) then
      table.insert(tableFilter, v)
    end
  end
  return tableFilter
end

local function watchKeyboard()
  api.nvim_create_autocmd({
    'InsertChange', 'TextChangedI'
  }, {
    buffer = entryBuffer,
    callback = function()
      local str = api.nvim_get_current_line() or ''
      local searchText = string.gsub(str, "%% ", "")
      local filterList = filter_inplace(internal.listCommands, searchText)
      M.updateView(0, filterList)
    end
  })
end

function M.init()
  position = 0
  local adjust = utils.adjust(-10)
  local main = ui.createMain(0.6, 0.3, adjust);
  listWin = main.win
  listBuffer = main.buffer
  listBorderWin = main.winBorder
  local entry = ui.createPromp(0.6, 0.02, adjust)
  entryWin = entry.win
  entryBuffer = entry.buffer
  entryBorderWin = entry.winBorder
  M.setMappingPrompt()
  M.updateView(0, internal.listCommands)
  watchKeyboard()
end

function M.setup(opts)
  internal.setup(opts)
end

return M
