" vim-wscli - Vim interface to wscli websocket client
" Vim license. See ':help license'
" Copyright 2022 Jason Stewart <support@eggplantsd.com>

" Reload guard and 'compatible' handling
if exists("loaded_vim_wscli") | finish | endif

let loaded_vim_wscli = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists('*term_start')
  echoerr 'vim-wscli disabled: term_start() function not found'
  finish
endif

command! WscliToggle call wscli#Toggle()

" visual mode
xnoremap <leader>ws :<C-u>call wscli#SendVisual()<CR>

" normal mode
nnoremap <leader>ws :call wscli#SendParagraph()<CR>

" Cleanup and modelines {{{1
let &cpo = s:save_cpo
