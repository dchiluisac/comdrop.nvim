" in plugin/tags_help.vim
"if exists('g:loaded_tagsHelp') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

" command to run our plugin
command! TagsHelp lua require'tags-help'.init()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_tagsHelp = 1
