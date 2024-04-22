" plugin/find-ignore.vim

" Guard against multiple loading
if exists('g:loaded_gitignoresearch')
  finish
endif
let g:loaded_gitignoresearch = 1

" Define GitFind command with tab completion
command! -nargs=1 -complete=customlist,gitignoresearch#findComplete GitFind call gitignoresearch#find(<q-args>)

" Define GitGrep command
command! -nargs=1 GitGrep call gitignoresearch#grep(<q-args>)

