function! s:InitTagsFile()
  let init_cmd = "ctags -f tags -R --exclude='*.js' --langmap='ruby:+.rake.builder.rjs' --languages=-javascript ./"
  call s:RunShellCmd(init_cmd)
endfunction

function! s:RunShellCmd(cmd)
  return system(a:cmd)
endfunction

function! s:ClearStaleTags(file_to_update)
  let filename_regex = shellescape('\t'.a:file_to_update.'\t')
  let clear_cmd = 'grep -v '.filename_regex.' tags > .tags.temp && mv .tags.temp tags'
  call s:RunShellCmd(clear_cmd)
endfunction

function! UpdateTagsForFile()
  let file_to_update = s:RelativeFilePathAndName()
  call s:ClearStaleTags(file_to_update)
endfunction

function! s:RelativeFilePathAndName()
  let cwd=getcwd()
  let current_file_with_path = expand("%:p")
  return substitute(current_file_with_path, '^'.cwd, '.', '')
endfunction

" function! s:HookAutoCmds()
	" autocmd BufWritePost,FileWritePost * call s:UpdateTagsForFile()
" endfunction

function! s:DefineCommands()
  command! MagicInitTagsFile call s:InitTagsFile()
endfunction

call s:DefineCommands()
