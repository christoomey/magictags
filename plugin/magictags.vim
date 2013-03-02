function! s:InitTagsFile()
  if s:GitRepoPathToRoot() == s:NOT_IN_GIT_REPO
    return
  endif
  let init_cmd = s:CtagsCmd('./')
  call s:RunShellCmd(init_cmd)
endfunction

function! s:CtagsCmd(file_or_path, ...)
  let is_appending = a:0 > 0
  if is_appending
    let ctags_base_cmd = "ctags " . s:CtagsOptions() . " -a"
  else
    let ctags_base_cmd = "ctags " . s:CtagsOptions()
  end
  return join([ctags_base_cmd, a:file_or_path])
endfunction

function! s:CtagsOptions()
  return "-f tags -R --exclude='*.js' --langmap='ruby:+.rake.builder.rjs' --languages=-javascript"
endfunction

function! s:RunShellCmd(cmd)
  return system(a:cmd)
endfunction

function! s:GitRepoPathToRoot()
  let git_top = s:RunShellCmd('git rev-parse --show-cdup')
  let git_fail = 'fatal:'
  if strpart(git_top, 0, strlen(git_fail)) == git_fail
    return s:NOT_IN_GIT_REPO
  else
    let s:git_repo_cdup_path = substitute('./' . git_top, '\n', '', '')
    return s:IN_GIT_REPO
  endif
endfunction

function! s:ClearStaleTags(file_to_update)
  let filename_regex = shellescape('\t'.a:file_to_update.'\t')
  let clear_cmd = 'grep -v '.filename_regex.' tags > .tags.temp && mv .tags.temp tags'
  call s:RunShellCmd(clear_cmd)
endfunction

function! s:AppendTagsForFile(file_to_update)
  let append = 1
  let append_cmd = s:CtagsCmd(a:file_to_update, append)
  call s:RunShellCmd(append_cmd)
endfunction

function! s:UpdateTagsForFile()
  if s:GitRepoPathToRoot() == s:NOT_IN_GIT_REPO
    return
  endif
  let file_to_update = s:RelativeFilePathAndName()
  call s:ClearStaleTags(file_to_update)
  call s:AppendTagsForFile(file_to_update)
endfunction

function! s:RelativeFilePathAndName()
  let cwd=getcwd()
  let current_file_with_path = expand("%:p")
  return substitute(current_file_with_path, '^'.cwd, '.', '')
endfunction

function! s:HookAutoCmds()
  autocmd BufWritePost,FileWritePost *.rb call s:UpdateTagsForFile()
endfunction

function! s:DefineCommands()
  command! MagicInitTagsFile call s:InitTagsFile()
endfunction

let s:NOT_IN_GIT_REPO = 'not_in_git_repo'
let s:IN_GIT_REPO = 'in_git_repo'
call s:DefineCommands()
call s:HookAutoCmds()
