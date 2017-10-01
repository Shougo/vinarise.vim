"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

if exists('g:loaded_vinarise')
  finish
elseif v:version < 703
  echoerr 'vinarise does not work this version of Vim (' . v:version . ').'
  finish
endif

" Global options definition.
let g:vinarise_enable_auto_detect =
      \ get(g:, 'vinarise_enable_auto_detect', 0)
let g:vinarise_detect_large_file_size =
      \ get(g:, 'vinarise_detect_large_file_size', 10000000)
let g:vinarise_cursor_ascii_highlight =
      \ get(g:, 'vinarise_cursor_ascii_highlight', 'Search')


command! -nargs=* -bar -complete=customlist,vinarise#complete
      \ Vinarise
      \ call s:call_vinarise({}, <q-args>)

if g:vinarise_enable_auto_detect
  augroup vinarise
    autocmd!
    autocmd BufReadPost,FileReadPost *
          \ call s:browse_check(expand('<amatch>'))
  augroup END
endif

function! s:call_vinarise(default, args) abort
  let [args, context] = s:parse_args(a:default, a:args)

  call vinarise#init#start(join(args), context)
endfunction
function! s:parse_args(default, args) abort
  let args = []
  let context = a:default
  for arg in split(a:args, '\%(\\\@<!\s\)\+')
    let arg = substitute(arg, '\\\(.\)', '\1', 'g')

    let matched_list = filter(copy(vinarise#get_options()),
          \  'stridx(arg, v:val) == 0')
    for option in matched_list
      let key = substitute(substitute(option, '-', '_', 'g'),
            \ '=$', '', '')[1:]
      let context[key] = (option =~ '=$') ?
            \ arg[len(option) :] : 1
      break
    endfor

    if empty(matched_list)
      call add(args, arg)
    endif
  endfor

  return [args, context]
endfunction

function! s:browse_check(path) abort
  if bufnr('%') != expand('<abuf>')
        \ || a:path == ''
    return
  endif

  let path = vinarise#util#expand(a:path)
  if fnamemodify(path, ':t') ==# '~'
    let path = vinarise#util#expand('~')
  endif

  if (&filetype ==# 'vinarise' && line('$') != 1)
        \ || !filereadable(path)
        \ || !g:vinarise_enable_auto_detect
        \ || path =~# '/.git/index$'
    " Note: vim-fugitive opens ".git/index" binary file when executed
    " ':Gstatus'.
    return
  endif

  let lines = readfile(path, 'b', 1)
  if empty(lines)
    return
  endif

  if lines[0] =~ '[\x01-\x08\x10-\x1a\x1c-\x1f]\{5,}'
        \ || (g:vinarise_detect_large_file_size > 0 &&
        \        getfsize(path) > g:vinarise_detect_large_file_size)
    call s:call_vinarise({'overwrite' : 1}, path)
  endif
endfunction

let g:loaded_vinarise = 1
