local utils = require "utils"
local ui = require 'ui'
local listBuffer, mainWin, listBorderWin
local entryBuffer, winEntry, entryBorderWin
local api = vim.api
local position = 0

local spaceTagsList = api.nvim_create_namespace('tags-help-list')



local function close_window()
  api.nvim_win_close(winEntry, true)
  api.nvim_win_close(mainWin, true)
  api.nvim_win_close(listBorderWin, true)
  api.nvim_win_close(entryBorderWin, true)
  utils.bufDelete(entryBuffer)
  utils.bufDelete(listBuffer)

  --  pcall(api.nvim_win_close, 0, true)
  --vim.api.nvim_create_autocmd("BufLeave", {
  --  buffer = entry,
  --  once = true,
  --  callback = function()
  --    pcall(vim.api.nvim_win_close, winEntry, true)
  --    print("rungifdsn")
  --    --pcall(vim.api.nvim_win_close, km_opts.border.win_id, true)
  --    buf_delete(entry)
  --  end,
  --})
end

local function update_view(direction, listActions)
  api.nvim_buf_set_option(listBuffer, 'modifiable', true)
  --api.nvim_buf_set_option(buf, 'modifiable', true)
  position = position + direction
  if position < 0 then position = 0 end
  --local cmd = 'ls -l'
  --local result = vim.fn.systemlist(cmd)
  --if #result == 0 then table.insert(result, '') end -- add  an empty line to preserve layout if there is no results
  --for k, v in pairs(result) do
  --  result[k] = '  ' .. result[k]
  --end

  --api.nvim_buf_set_lines(listBuffer, 1, 2, false, { utils.center('HEAD~' .. position) })
  api.nvim_buf_set_lines(listBuffer, 3, -1, false, listActions)
  api.nvim_buf_add_highlight(listBuffer, -1, 'DiagnosticSignError', 1, 0, -1)
  api.nvim_buf_set_option(listBuffer, 'modifiable', false)
  local currentPosition = api.nvim_win_get_cursor(mainWin)[1]
  api.nvim_buf_add_highlight(listBuffer, spaceTagsList, 'DiagnosticVirtualTextError', currentPosition, 0, -1)
end

local function setMappingPrompt()
  local mappings = {
    ['<esc>'] = 'close_window()',
    ['<cr>'] = 'run_command()',
  }
  local opts = { noremap = true, silent = true }

  api.nvim_buf_set_keymap(entryBuffer, '!', '<esc>', [[<C-\><C-n>:lua require"tags-help".close_window()<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<Up>', [[<cmd> :lua require("tags-help").move_cursor("up")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<Down>', [[<cmd> :lua require("tags-help").move_cursor("down")<CR>]], opts)
  api.nvim_buf_set_keymap(entryBuffer, '!', '<cr>', [[<cmd> :lua require("tags-help").run_command()<CR>]], opts)
  --api.nvim_buf_set_keymap(entryBuffer, 'i', '<Down>', [[<C-\>:lua require"tags-help".move_cursor("down", 2)<CR>]],
  --  opts)
  --for k, v in pairs(mappings) do
  --  api.nvim_buf_set_keymap(entry, 'n', k, ':lua require"tags-help".' .. v .. '<cr>', {
  --    nowait = true, noremap = true, silent = true
  --  })
  --end
end

local function set_mappings()
  local mappings = {
    ['['] = 'update_view(-1)',
    [']'] = 'update_view(1)',
    ['<cr>'] = 'run_command()',
    h = 'update_view(-1)',
    l = 'update_view(1)',
    q = 'close_window()',
    k = 'move_cursor("up")',
    ['.'] = 'move_cursor("down")'
  }

  for k, v in pairs(mappings) do
    api.nvim_buf_set_keymap(listBuffer, 'n', k, ':lua require"tags-help".' .. v .. '<cr>', {
      nowait = true, noremap = true, silent = true
    })
  end
  local other_chars = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  }
  for k, v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(listBuffer, 'n', v, '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(listBuffer, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
    api.nvim_buf_set_keymap(listBuffer, 'n', '<c-' .. v .. '>', '', { nowait = true, noremap = true, silent = true })
  end
end

local function move_cursor(direction)
  local currentPosition = api.nvim_win_get_cursor(mainWin)[1]
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
  api.nvim_win_set_cursor(mainWin, { newPosition, 0 })
end

local function run_command()
  local currentPosition = api.nvim_win_get_cursor(mainWin)[1]
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
  -- test

  local main = ui.createMain(0.6, 0.3, -10);
  mainWin = main.win
  listBuffer = main.buffer
  listBorderWin = main.winBorder
  local entry = ui.createPromp(0.6, 0.02)
  winEntry = entry.win
  entryBuffer = entry.buffer
  entryBorderWin = entry.winBorder

  set_mappings()
  setMappingPrompt()
  update_view(0, listActions)


  --vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'BufEnter', 'BufRead', 'BufWrite', 'CmdlineChanged',
  --  'InsertChange', 'TextChangedI' }, {
  --  buffer = entryBuffer,
  --  callback = function(n)
  --    print('gdsfs' .. math.random())
  --    local ll = {
  --      [1] = "  Telescope" .. math.random(),
  --      [2] = "  Lspsaga diagnostic_jump_next",
  --      [3] = "  Lspsaga diagnostic_jump_prev",
  --    }
  --    --api.nvim_win_set_cursor(mainWin, { 4, 0 })
  --    --api.nvim_win_set_option(mainWin, 'winhl', 'Normal:MyHighlight')
  --    --update_view(0, ll)

  --    --api.nvim_win_set_cursor(mainWin, { 6, 0 })
  --    --vim.api.nvim_set_option('cursorline', true)
  --    --nn = nn + 1
  --    local str = api.nvim_get_current_line() or ''
  --    local result = string.sub(str, -1)
  --    print(result .. '-')
  --    --move_cursor('up', nn)
  --    --run_command()
  --    --local currentPosition = api.nvim_win_get_cursor(mainWin)[1]
  --    --local li = api.nvim_buf_get_lines(listBuffer, currentPosition, currentPosition + 1, true)
  --    --print('cursoor' .. currentPosition .. li[1])
  --  end
  --})
end

return {
  tagsHelp = tagsHelp,
  close_window = close_window,
  setMappingPrompt = setMappingPrompt,
  move_cursor = move_cursor,
  update_view = update_view,
  run_command = run_command
}

--local borderchars = {
--  borders.top_mid, borders.mid,
--  borders.top_mid, borders.mid,
--  borders.top_left, borders.top_right,
--  borders.bottom_right, borders.bottom_left
--}
