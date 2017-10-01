"=============================================================================
" FILE: dump.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

" Constants
if vinarise#util#is_windows()
  let s:dump_BUFFER_NAME = '[vinarise-dump-objdump]'
else
  let s:dump_BUFFER_NAME = '*vinarise-dump-objdump*'
endif

" Variables 
if !exists('g:vinarise_objdump_command')
  let g:vinarise_objdump_command = 'objdump'
endif

let s:manager = vinarise#util#get_vital().import('Vim.Buffer')


function! vinarise#plugins#dump#define() abort
  return s:plugin
endfunction

let s:plugin = {
      \ 'name' : 'dump',
      \ 'description' : 'hex dump by objdump',
      \}

function! s:plugin.initialize(vinarise, context) abort
  command! -bar VinarisePluginDump
        \ call s:dump_open()
endfunction

function! s:dump_open() abort
  if !executable(g:vinarise_objdump_command)
    echoerr g:vinarise_objdump_command . ' is not installed.'
    return
  endif

  let vinarise = vinarise#get_current_vinarise()

  let loaded = s:manager.open(s:dump_BUFFER_NAME .
        \ vinarise.filename, 'silent edit')
  if !loaded
    call vinarise#view#print_error(
          \ '[vinarise] Failed to open Buffer.')
    return
  endif

  call s:initialize_dump_buffer()

  setlocal modifiable
  execute 'silent %!'.g:vinarise_objdump_command.' -DCslx "'
        \ . vinarise.filename . '"'
  setlocal nomodifiable
  setlocal nomodified
endfunction

" Misc.
function! s:initialize_dump_buffer() abort
  " Basic settings.
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal foldcolumn=0
  setlocal tabstop=8

  " User's initialization.
  setfiletype vinarise-dump-objdump
endfunction
