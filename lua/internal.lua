local M = {}

M.nameSpace = 'tags-help-list-name-space'

M.listCommands = {
  [1] = { title = 'Telescope', command = 'Telescope' },
  [2] = { title = 'diagnostic_jump_next', command = 'Lspsaga diagnostic_jump_next', delay = true },
  [3] = { title = 'diagnostic_jump_prev', command = 'Lspsaga diagnostic_jump_prev', delay = true },
}

M.setup = function(opts)
  opts           = opts or {}
  M.listCommands = opts.listCommands or M.listCommands
end

return M
