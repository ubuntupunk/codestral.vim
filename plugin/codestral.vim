" Title: Codestral.vim
" Description: A plugin for vim that allows you to chat with Codestral
" Last Change: 2024-01-11
" Maintainer: David Robert Lewis
" Email: ubuntupunk dot gmail dot com
" License: This program is free software. It comes without any warranty,
" to the extent permitted by applicable law. You can redistribute it 
" and/or modify it under the terms of the Do What The Fuck You Want To Public License,
" Version 2, as published by Sam Hocevar.
" See http://sam.zoy.org/wtfpl/COPYING for more details.



"Prevents the plugin from being loaded multiple times
if exists("g:loaded_codestral_vim")
 finish
endif
let g:loaded_codestral_vim = 1

runtime! autoload/codestral.vim

"Exposes the plugins functions for use with following commands:
command! -nargs=0 CodestralChat call OpenChatBuffer()
command! -nargs=0 CodestralEnable let g:codestral_enabled = 1
command! -nargs=0 CodestralDisable call CodestralDisable()
command! -nargs=0 CodestralCompletionEnable call codestral#CompletionEnable()
command! -nargs=0 CodestralCompletionDisable call codestral#CompletionDisable()
command! -nargs=0 CodestralDebug call codestral#ToggleDebug()
