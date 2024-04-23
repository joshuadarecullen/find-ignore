" autoload/gitignoresearch.vim

function! gitignoresearch#isGitRepo()
  " let isGitRepo = substitute(system('git rev-parse --is-inside-work-tree'), '\_s*', '', 'g')
  " Execute the git command and redirect standard error to null to avoid messy output
  " Uses substitute to remove all whitespace including newlines and spaces
  try
    let isGitRepo = substitute(system('git rev-parse --is-inside-work-tree 2>/dev/null'), '\_s*', '', 'g')
    return isGitRepo == 'true'
  catch
    echoerr "Detecting Git repository failed"
    return 0
  endtry
endfunction

" Get list of files tracked by git, respecting .gitignore
function! gitignoresearch#getGitFiles()
  if !gitignoresearch#isGitRepo()
    echoerr "Not a Git repository. Please run this command within a Git repository."
    return []
  endif
  try
    return split(system('git ls-files'), "\n")
  catch
    echoerr "Failed to list Git files."
    return []
  endtry
endfunction

" Completion function for GitFind (tab completion)
function! gitignoresearch#findComplete(ArgLead, CmdLine, CursorPos)
  let files = gitignoresearch#getGitFiles()
  try
    let matches = filter(files, 'v:val =~ a:ArgLead')
    redraw!
    return matches
  catch  
    echoerr "Failed to list Git files."
    return []
  endtry
endfunction

" Function to handle GitFind command
function! gitignoresearch#find(pattern)
  let files = gitignoresearch#getGitFiles()
  if empty(files)
    return
  endif

  try 
    let matches = filter(copy(files), 'v:val =~ a:pattern')
    if empty(matches)
      echo "No files match your pattern."
      return
    endif
    execute 'edit ' . matches[0]
  catch
    echoerr "Failed matching file operation"
    return

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

