if !has('nvim-0.5.0')
  echohl Error
  echom 'This plugin only works with Neovim >= v0.5.0'
  echohl clear
  finish
endif

if exists('g:loaded_comdrop') | finish | endif " prevent loading file twice
let s:save_cpo = &cpo 
set cpo&vim

command! ComDrop lua require'comdrop'.init()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_comdrop = 1
