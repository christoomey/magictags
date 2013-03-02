function! s:InitTagsFile()
  if s:GitRepoPathToRoot() == s:NOT_IN_GIT_REPO
    return
  endif
  let init_cmd = s:CtagsCmd(s:git_repo_cdup_path)
  call s:RunShellCmd(init_cmd)
endfunction

function! s:CtagsCmd(file_or_path, ...)
  let is_appending = a:0 > 0
  if is_appending
    let ctags_base_cmd = "ctags " . s:CtagsOptions() . " -a " . s:FileAndPathForGrep()
  else
    let ctags_base_cmd = "ctags " . s:CtagsOptions()
  end
  return ctags_base_cmd
endfunction

function! s:CtagsOptions()
  return "-f ".s:TagsFilePath()." -R --exclude='*.js' --langmap='ruby:+.rake.builder.rjs' --languages=-javascript"
endfunction

function! s:TagsFilePath()
  return 'tags'
endfunction

function! s:TempTagsFilePath()
  return 'tags.temp'
endfunction

function! s:RunShellCmd(cmd)
  let cmd_in_context = 'cd ' . s:git_repo_cdup_path . ' && ' . a:cmd
  echom cmd_in_context
  return system(cmd_in_context)
endfunction

function! s:GitRepoPathToRoot()
  let git_top = system('git rev-parse --show-cdup')
  let git_fail = 'fatal:'
  if strpart(git_top, 0, strlen(git_fail)) == git_fail
    return s:NOT_IN_GIT_REPO
  else
    let s:git_repo_cdup_path = substitute('./' . git_top, '\n', '', '')
    return s:IN_GIT_REPO
  endif
endfunction

function! s:ClearStaleTags()
  let filename_regex = shellescape('	'.s:FileAndPathForGrep().'	')
  let tags_file= s:TagsFilePath()
  let tags_temp = s:TempTagsFilePath()
  let clear_cmd = 'grep -v '.filename_regex.' '.tags_file.' > '.tags_temp.' && mv '.tags_temp.' '.tags_file
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
  " if no tags at root, init tags
  " if tags file at root, append
  let file_to_update = s:RelativeFilePathAndName()
  call s:ClearStaleTags()
  call s:AppendTagsForFile(file_to_update)
endfunction

function! s:FileAndPathForGrep()
  call s:GitRepoPathToRoot()
  let absolute_git_root = fnamemodify(s:git_repo_cdup_path, ':p')[:-2]
  let cwd=getcwd()
  let file_path_below_git_root =  substitute(cwd, absolute_git_root, '', '')
  return (file_path_below_git_root . '/' . expand("%"))[1:]
endfunction

function! s:RelativeFilePathAndName()
  let cwd=getcwd()
  let current_file_with_path = expand("%:p")
  let relative_path = substitute(current_file_with_path, '^'.cwd, '', '')[1:]
  return s:git_repo_cdup_path . relative_path
endfunction

function! s:PathToFileFromGitRoot()
  let file_with_path = expand("%")
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
