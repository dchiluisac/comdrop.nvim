local api = vim.api
local o = vim.o
local internal = require('internal')
local Path = require "plenary.path"

local M = {}

M.get_separator = function()
  return Path.path.sep
end

M.path_tail = (function()
  local os_sep = M.get_separator()
  return function(path)
    for i = #path, 1, -1 do
      if path:sub(i, i) == os_sep then
        return path:sub(i + 1, -1)
      end
    end
    return path
  end
end)()

function M.getDimensions(width, height, setRow, setCol)
  local widthWindow = api.nvim_get_option("columns")
  local heightWindow = api.nvim_get_option("lines")
  local win_width = math.ceil(widthWindow * width)
  local win_height = math.ceil(heightWindow * height)
  local row = math.ceil((heightWindow - win_height) / 2) - (0.2 * win_height)
  local col = math.ceil((widthWindow - win_width) / 2)
  return {
    width = win_width,
    height = win_height,
    row = setRow or row,
    col = setCol or col
  }
end

function M.adjust(value, width)
  if width == true then
    local widthWindow = api.nvim_get_option("columns")
    local x           = (value / 100) * widthWindow
    return math.ceil(x)
  end
  local heightWindow = api.nvim_get_option("lines")
  local x            = (value / 100) * heightWindow
  return math.ceil(x)

end

function M.getDimensionWin(width, height, setRow, setCol, title)
  local borders = internal.borders
  local dimensions = M.getDimensions(width, height, setRow, setCol)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = dimensions.width + 2,
    height = dimensions.height + 2,
    row = dimensions.row - 1,
    col = dimensions.col - 1,
  }

  local topMidLine = ''
  if title ~= nil then
    topMidLine = M.center(title, dimensions.width)
  else
    topMidLine = string.rep(borders.top_mid, dimensions.width)
  end

  local borderLines = {
    borders.top_left ..
        topMidLine ..
        borders.top_right
  }
  local middle_line = borders.mid .. string.rep(' ', dimensions.width) .. borders.mid
  for _ = 1, dimensions.height do
    table.insert(borderLines, middle_line)
  end
  table.insert(
    borderLines, borders.bottom_left ..
    string.rep(borders.top_mid, dimensions.width) ..
    borders.bottom_right
  )

  return {
    borderOpts = opts,
    borderLines = borderLines,
    width = dimensions.width,
    height = dimensions.height,
    row = dimensions.row,
    col = dimensions.col
  }
end

function M.center(str, width)
  local borders = internal.borders
  local borderMaxWidth = (width - string.len(str)) / 2
  local borderWidth = math.floor(borderMaxWidth)
  local diff = borderMaxWidth * 2 - math.floor(borderWidth * 2)
  return string.rep(borders.top_mid, borderWidth) .. str ..
      string.rep(borders.top_mid, borderWidth + diff)
end

function M.bufDelete(buf)
  if buf == nil then
    return
  end
  -- Suppress the buffer deleted message for those with &report<2
  local start_report = vim.o.report
  if start_report < 2 then
    o.report = 2
  end

  if api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
    api.nvim_buf_delete(buf, { force = true })
  end

  if start_report < 2 then
    o.report = start_report
  end
end

function M.delay(command, ms)
  local msDelay = ms or 10
  local timer = vim.loop.new_timer()
  timer:start(msDelay, 0, vim.schedule_wrap(function()
    api.nvim_command(command)
  end))
end

return M
