"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 11 Aug 2010
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
" Version: 0.1, for Vim 7.0
"=============================================================================

" Check vimproc."{{{
try
  let s:exists_vimproc_version = vimproc#version()
catch
  echoerr 'Please install vimproc Ver.4.1 or above.'
  finish
endtry
if s:exists_vimproc_version < 401
  echoerr 'Please install vimproc Ver.4.1 or above.'
  finish
endif"}}}

" Constants"{{{
let s:FALSE = 0
let s:TRUE = !s:FALSE

if has('win16') || has('win32') || has('win64')  " on Microsoft Windows
  let s:vinarise_BUFFER_NAME = '[vinarise]'
else
  let s:vinarise_BUFFER_NAME = '*vinarise*'
endif
"}}}
" Variables  "{{{
let s:vinarise_dicts = []
"}}}

function! vinarise#open(filename)"{{{
  if a:filename == ''
    let l:filename = bufname('%')
  else
    let l:filename = a:filename
  endif

  let l:file = vimproc#fopen(l:filename, 'O_RDONLY | O_BINARY', 0)
  let l:output = l:file.read(1024)
  while !l:file.eof && len(l:output) < 1024
    let l:output .= l:file.read(1024 - len(l:output))
  endwhile
  call l:file.close()

  edit `=s:vinarise_BUFFER_NAME . ' - ' . l:filename`
  call s:initialize_vinarise_buffer()
  
  let b:vinarise.lines = {}
  let cnt = 0
  let i = 0
  let l:max = len(l:output)
  while i < l:max
    let b:vinarise.lines[cnt] = strpart(l:output, i, 16)
    
    let cnt += 1
    let i += 16
  endwhile

  call s:print_lines()
endfunction"}}}

" Misc.
function! s:initialize_vinarise_buffer()"{{{
  " The current buffer is initialized.
  let b:vinarise = {}

  " Basic settings.
  setlocal number
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal foldcolumn=0

  " Autocommands.
  augroup plugin-vinarise
  augroup END

  " User's initialization.
  setfiletype vinarise

  return
endfunction"}}}

function! s:print_lines()
  setlocal modifiable
  
  let i = 0
  let l:max = len(b:vinarise.lines)
  while i < l:max
    let l:line = b:vinarise.lines[i]
    let l:hex_line = ''
    let l:ascii_line = ''
    
    let j = 0
    let l:max2 = len(l:line)
    while j < l:max2
      let l:num = char2nr(l:line[j])
      let l:hex_line .= printf('%02x', l:num) . ' '
      let l:ascii_line .= l:num < 32 || l:num > 127 ? '.' : l:line[j]

      let j += 1
    endwhile

    call append('$', printf(' %07x0 : %-48s |  %s  ', i, l:hex_line, l:ascii_line))
    
    let i += 1
  endwhile
  
  setlocal nomodifiable
endfunction

" vim: foldmethod=marker
