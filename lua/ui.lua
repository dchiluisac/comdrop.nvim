local api = vim.api
local utils = require('utils')
local internal = require('internal')
local hi = internal.highlights
local M = {}

function M.createBuffer(dim, type)
  local buffer = api.nvim_create_buf(false, true)
  local borderBuffer = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(borderBuffer, 0, -1, false, dim.borderLines)
  local win = api.nvim_open_win(borderBuffer, true, dim.borderOpts)
  api.nvim_buf_set_option(buffer, 'buftype', type)
  return {
    buffer = buffer,
    win = win,
    borderBuffer = borderBuffer
  }
end

function M.createMain(width, height, setRow, setCol)
  local title = " Commands list "
  local dim = utils.getDimensionWin(width, height, setRow, setCol, title)
  local bufferInstance = M.createBuffer(dim, 'nofile')
  local buffer = bufferInstance.buffer
  local borderBuffer = bufferInstance.borderBuffer

  local opts = {
    style = "minimal",
    relative = "editor",
    width = dim.width,
    height = dim.height,
    row = dim.row,
    col = dim.col,
    zindex = 1400,
  }

  local firstLineBorder = api.nvim_buf_get_lines(borderBuffer, 0, 1, false)[1]
  local startPos, endPos = string.find(firstLineBorder, title)
  api.nvim_buf_add_highlight(borderBuffer, -1, hi.ComdropTitle.link, 0, startPos, endPos)
  local mainWin = api.nvim_open_win(buffer, true, opts)
  api.nvim_win_set_cursor(mainWin, { 1, 0 })
  return {
    win = mainWin,
    buffer = buffer,
    winBorder = bufferInstance.win,
    row = dim.row,
    col = dim.col,
    width = dim.width,
    height = dim.height
  }
end

function M.createPromp(width, height, setRow, setCol)
  local dim = utils.getDimensionWin(width, height, setRow, setCol)
  local bufferInstance = M.createBuffer(dim, 'prompt')
  local buffer = bufferInstance.buffer

  local opts = {
    style = "minimal",
    relative = "editor",
    width = dim.width,
    height = dim.height,
    row = dim.row,
    col = dim.col,
  }

  local entryMain = api.nvim_open_win(buffer, true, opts)
  vim.schedule(function()
    vim.cmd [[startinsert]]
    --vim.api.nvim_put({"xs","Cdc"}, "c", false, true)
  end)
  return {
    win = entryMain,
    buffer = buffer,
    winBorder = bufferInstance.win,
    row = dim.row,
    col = dim.col,
    width = dim.width,
    height = dim.height
  }
end

return M
