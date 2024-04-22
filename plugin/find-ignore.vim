" Plugin: GitIgnoreSearch
" Description: Adds commands to search files and content respecting .gitignore with error handling.

" Function to check if the current directory is a Git repository
function! s:IsGitRepo()
  return system('git rev-parse --is-inside-work-tree') =~? '^true$'
endfunction

" Function to get list of files tracked by git, respecting .gitignore
function! s:GetGitFiles()
  if !s:IsGitRepo()
    echoerr "Not a Git repository. Please run this command within a Git repository."
    return []
  endif
  return split(system('git ls-files'), "\n")
endfunction

" Command to open a file found by git ls-files
command! -nargs=1 GitFind call s:GitFind(<q-args>)

function! s:GitFind(pattern)
  let files = s:GetGitFiles()
  if empty(files)
    return
  endif
  let matches = filter(copy(files), 'v:val =~ a:pattern')
  if empty(matches)
    echo "No files match your pattern."
    return
  endif
  execute 'edit ' . matches[0]
endfunction

" Command to search within files found by git ls-files
command! -nargs=1 GitGrep call s:GitGrep(<q-args>)

function! s:GitGrep(search_term)
  let files = s:GetGitFiles()
  if empty(files)
    return
  endif
  let grep_cmd = 'vimgrep /' . a:search_term . '/gj ' . join(map(files, 'fnameescape(v:val)'), ' ')
  execute grep_cmd
  copen
endfunction
