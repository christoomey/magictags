function! s:InitTagsFile()
  let init_cmd = "ctags -f tags -R --exclude='*.js' --langmap='ruby:+.rake.builder.rjs' --languages=-javascript ./"
  call system(init_cmd)
endfunction

function! s:DefineCommands()
  command! MagicInitTagsFile call s:InitTagsFile()
endfunction

call s:DefineCommands()
