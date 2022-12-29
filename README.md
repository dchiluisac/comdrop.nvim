# comdrop.nvim


## What Is ComDrop?

`comdrop.nvim` is a plugin allowing you to simple and fast access to commands set by 
you as well as commands defined by other plugins in neovim.
Just press a key and find the command you need.

![Preview](https://i.imgur.com/52NNvnD.gif)

![Preview](https://i.imgur.com/yTeM4jB.gif)

### Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'dchiluisac/comdrop.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('dchiluisac/comdrop.nvim')
```
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'dchiluisac/comdrop.nvim' }
```

## Usage

Try the command `:ComDrop<cr>`
  to see if `comdrop.nvim` is installed correctly.

Using Lua:

```lua
require('comdrop').setup()
```

## Customization

This section should help you explore available options to configure and
customize your `comdrop.nvim`.

### ComDrop setup structure

```lua
local comdrop = require('comdrop')

local listCommands = {
  { title = 'Telescope', command = 'Telescope' },
  { title = 'diagnostic_jump_next', command = 'Lspsaga diagnostic_jump_next'},
  { title = 'diagnostic_jump_prev', command = 'Lspsaga diagnostic_jump_prev'},
  { title = 'Commits', command = 'Telescope git_commits' },
  { title = 'Git Diff', command = 'DiffviewOpen' },
  { title = 'Git close', command = 'DiffviewClose'},
}

comdrop.setup {
  listCommands = listCommands,
  systemCommands = false -- default true
}
```
