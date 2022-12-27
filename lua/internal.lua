local M = {}

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
  [1] = { title = 'Telescope', command = 'Telescope' },
  [2] = { title = 'diagnostic_jump_next', command = 'Lspsaga diagnostic_jump_next', delay = true },
  [3] = { title = 'diagnostic_jump_prev', command = 'Lspsaga diagnostic_jump_prev', delay = true },
}

M.setup = function(opts)
  opts           = opts or {}
  M.listCommands = opts.listCommands or M.listCommands
  M.borders      = opts.borders or M.borders
end

return M
