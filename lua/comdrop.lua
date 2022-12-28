local api = vim.api
local utils = require('utils')
local ui = require('ui')
local internal = require('internal')
local listWin, listBuffer, listBorderWin
local entryWin, entryBuffer, entryBorderWin
local position = 0
local nameSpaceList = api.nvim_create_namespace(internal.nameSpace)
local hi = internal.highlights
local M = {}

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
    table.insert(listRender, '  ' .. value.title)
  end
  api.nvim_buf_set_option(listBuffer, 'modifiable', true)
  position = position + direction
  if position < 0 then position = 0 end
  api.nvim_buf_set_lines(listBuffer, 1, -1, false, listRender)
  local currentPosition = api.nvim_win_get_cursor(listWin)[1]
  api.nvim_win_set_cursor(listWin, { 1, 0 })
  if #listRender ~= 0 then
    api.nvim_buf_set_text(listBuffer, 1, 0, 1, 1, { '>' })
  end
  api.nvim_buf_add_highlight(listBuffer, nameSpaceList,
    hi.ComdropSelection.link, currentPosition
    , 0, -1)
  api.nvim_buf_set_option(listBuffer, 'modifiable', false)
end

function M.setMappingPrompt()
  local opts = { noremap = true, silent = true, nowait = true }
  api.nvim_buf_set_keymap(entryBuffer, 'i', '<esc>', [[<C-\><C-n>:lua require"comdrop".closeWindow()<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, 'i', '<Up>', [[<cmd> :lua require("comdrop").moveCursor("up")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, 'i', '<Down>', [[<cmd> :lua require("comdrop").moveCursor("down")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, 'i', '<cr>', [[<cmd> :lua require("comdrop").runCommand()<CR>]], opts)
end

function M.moveCursor(direction)
  local currentPosition = api.nvim_win_get_cursor(listWin)
  local row = currentPosition[1]
  local col = currentPosition[2]
  local maxHeight = api.nvim_buf_line_count(listBuffer)
  local newPosition = 0

  if direction == "up" then
    newPosition = math.max(1, row - 1)
  else if direction == "down" then
      newPosition = math.min(maxHeight - 1, row + 1)
    end
  end

  api.nvim_buf_clear_namespace(listBuffer, nameSpaceList, row, -1)
  api.nvim_buf_set_option(listBuffer, 'modifiable', true)
  api.nvim_buf_set_text(listBuffer, row, col, row, col + 1, { ' ' })
  api.nvim_buf_set_text(listBuffer, newPosition, col, newPosition, col + 1, { '>' })
  api.nvim_buf_set_option(listBuffer, 'modifiable', false)
  api.nvim_buf_add_highlight(listBuffer, nameSpaceList, hi.ComdropSelection.link, newPosition, 0, -1)
  api.nvim_win_set_cursor(listWin, { newPosition, 0 })
end

function M.runCommand()
  local currentPosition = api.nvim_win_get_cursor(listWin)[1]
  local str = api.nvim_buf_get_lines(listBuffer, currentPosition, currentPosition + 1, true)[1]
  M.closeWindow()
  local commandSelected = string.gsub(str, "%s+", "")
  commandSelected = string.gsub(commandSelected, ">", "")
  for _, value in ipairs(internal.listCommands) do
    local command = string.gsub(value.title, "%s+", "")
    if command == commandSelected then
      if value.delay ~= nil then
        utils.delay(value.command)
        break
      else
        vim.api.nvim_command(value.command)
        break
      end
    end
  end
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
  if not internal.loadedSetup then
    M.setup()
  end
  M.updateView(0, internal.listCommands)
  watchKeyboard()
end

function M.setup(opts)
  internal.setup(opts)
end

return M
