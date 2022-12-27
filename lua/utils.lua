local api = vim.api
local o = vim.o

local M = {}

M.borders = {
  top_left = "╭",
  top_mid = "─",
  top_right = "╮",
  mid = "│",
  bottom_left = "╰",
  bottom_right = "╯"
};

function M.getDimensions(width, height)
  local widthWindow = api.nvim_get_option("columns")
  local heightWindow = api.nvim_get_option("lines")
  local win_width = math.ceil(widthWindow * width)
  local win_height = math.ceil(heightWindow * height)
  local row = math.ceil((heightWindow - win_height) / 2)
  local col = math.ceil((widthWindow - win_width) / 2)
  return {
    width = win_width,
    height = win_height,
    row = row,
    col = col
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

function M.getDimensionWin(width, height, setRow, setCol)
  local row = setRow or 0
  local col = setCol or 0
  local dimensions = M.getDimensions(width, height)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = dimensions.width + 2,
    height = dimensions.height + 2,
    row = dimensions.row - 1 + row,
    col = dimensions.col - 1 + col,
  }
  local borders = M.borders;
  local borderLines = {
    borders.top_left ..
        string.rep(borders.top_mid, dimensions.width) ..
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

function M.center(str)
  local width = api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
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
