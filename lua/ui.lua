local api = vim.api
local utils = require('utils')
local internal = require('internal')
local hi = internal.highlights
local M = {}

function M.createBuffer(dim, type)
  local buffer = api.nvim_create_buf(false, true)
  local border_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(border_buf, 0, -1, false, dim.borderLines)
  local win = api.nvim_open_win(border_buf, true, dim.borderOpts)
  api.nvim_buf_set_option(buffer, 'buftype', type)
  return {
    buffer = buffer,
    win = win
  }
end

function M.createMain(width, height, setRow, setCol)
  local row = setRow or 0
  local col = setCol or 0
  local dim = utils.getDimensionWin(width, height, row, col)
  local bufferInstance = M.createBuffer(dim, 'nofile')
  local buffer = bufferInstance.buffer

  local opts = {
    style = "minimal",
    relative = "editor",
    width = dim.width,
    height = dim.height,
    row = dim.row + row,
    col = dim.col + col,
    zindex = 1400,
  }

  api.nvim_buf_set_lines(buffer, 0, -1, false, { utils.center('Commands Drop'), '', '' })
  api.nvim_buf_add_highlight(buffer, -1, hi.ComdropTitle.link, 0, 0, -1)
  local mainWin = api.nvim_open_win(buffer, true, opts)
  api.nvim_win_set_cursor(mainWin, { 3, 0 })
  return {
    win = mainWin,
    buffer = buffer,
    winBorder = bufferInstance.win
  }
end

function M.createPromp(width, height, setRow, setCol)
  local row = setRow or 0
  local col = setCol or 0
  local adjust = utils.adjust(20)
  local dim = utils.getDimensionWin(width, height, row + adjust, col)
  local bufferInstance = M.createBuffer(dim, 'prompt')
  local buffer = bufferInstance.buffer

  local opts = {
    style = "minimal",
    relative = "editor",
    width = dim.width,
    height = dim.height,
    row = dim.row + row + adjust,
    col = dim.col + col,
  }

  local entryMain = api.nvim_open_win(buffer, true, opts)
  vim.schedule(function()
    vim.cmd [[startinsert]]
    --vim.api.nvim_put({"xs","Cdc"}, "c", false, true)
  end)
  return {
    win = entryMain,
    buffer = buffer,
    winBorder = bufferInstance.win
  }
end

return M
