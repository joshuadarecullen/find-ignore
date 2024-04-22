" autoload/gitignoresearch.vim

" Check if the current directory is a Git repository
function! gitignoresearch#isGitRepo()
  return system('git rev-parse --is-inside-work-tree') =~? '^true$'
endfunction

" Get list of files tracked by git, respecting .gitignore
function! gitignoresearch#getGitFiles()
  if !gitignoresearch#isGitRepo()
    echoerr "Not a Git repository. Please run this command within a Git repository."
    return []
  endif
  return split(system('git ls-files'), "\n")
endfunction

" Completion function for GitFind
function! gitignoresearch#findComplete(ArgLead, CmdLine, CursorPos)
  let files = gitignoresearch#getGitFiles()
  return filter(files, 'v:val =~ a:ArgLead')
endfunction

" Function to handle GitFind command
function! gitignoresearch#find(pattern)
  let files = gitignoresearch#getGitFiles()
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

" Function to handle GitGrep command
function! gitignoresearch#grep(search_term)
  let files = gitignoresearch#getGitFiles()
  if empty(files)
    return
  endif
  let grep_cmd = 'vimgrep /' . a:search_term . '/gj ' . join(map(files, 'fnameescape(v:val)'), ' ')
  execute grep_cmd
  copen
endfunction

