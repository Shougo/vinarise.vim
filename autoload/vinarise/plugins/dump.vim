"=============================================================================
" FILE: dump.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 13 Aug 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Constants "{{{
if vinarise#util#is_windows()
  let s:dump_BUFFER_NAME = '[vinarise-dump-objdump]'
else
  let s:dump_BUFFER_NAME = '*vinarise-dump-objdump*'
endif
"}}}
" Variables  "{{{
if !exists('g:vinarise_objdump_command')
  let g:vinarise_objdump_command = 'objdump'
endif

let s:V = vital#of('vinarise')
let s:BM = s:V.import('Vim.BufferManager')
let s:manager = s:BM.new()  " creates new manager
call s:manager.config('opener', 'silent edit')
"}}}

let s:save_cpo = &cpo
set cpo&vim

function! vinarise#plugins#dump#define()
  return s:plugin
endfunction

let s:plugin = {
      \ 'name' : 'dump',
      \ 'description' : 'hex dump by objdump',
      \}

function! s:plugin.initialize(vinarise, context) "{{{
  command! VinarisePluginDump call s:dump_open()
endfunction"}}}

function! s:dump_open() "{{{
  if !executable(g:vinarise_objdump_command)
    echoerr g:vinarise_objdump_command . ' is not installed.'
    return
  endif

  let vinarise = vinarise#get_current_vinarise()

  let ret = s:manager.open(s:dump_BUFFER_NAME . vinarise.filename)
  if !ret.loaded
    call vinarise#print_error(
          \ '[vinarise] Failed to open Buffer.')
    return
  endif

  call s:initialize_dump_buffer()

  setlocal modifiable
  execute '%!'.g:vinarise_objdump_command.' -DCslx "'
        \ . vinarise.filename . '"'
  setlocal nomodifiable
  setlocal nomodified
endfunction"}}}

" Misc.
function! s:initialize_dump_buffer() "{{{
  " Basic settings.
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal foldcolumn=0
  setlocal tabstop=8

  " User's initialization.
  setfiletype vinarise-dump-objdump
endfunction"}}}

" vim: foldmethod=marker
