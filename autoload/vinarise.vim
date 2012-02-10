"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 10 Feb 2012.
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
" Version: 0.2, for Vim 7.0
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
" Check Python."{{{
if !has('python')
  echoerr 'Vinarise requires python interface.'
  finish
endif
"}}}

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

let s:vinarise_options = [
      \ '-split', '-split-command',
      \ '-winwidth=', '-winheight=',
      \ '-overwrite'
      \]
"}}}

function! vinarise#get_options()"{{{
  return copy(s:vinarise_options)
endfunction"}}}
function! vinarise#open(filename, context)"{{{
  if a:filename == ''
    let l:filename = bufname('%')
  else
    let l:filename = a:filename
  endif

  let context = s:initialize_context(a:context)

  if context.split
    execute context.split_command
  endif

  if !context.overwrite
    edit `=s:vinarise_BUFFER_NAME . ' - ' . l:filename`
  endif

  silent % delete _
  call s:initialize_vinarise_buffer()

  " Print lines.
  setlocal modifiable

  python << EOF
import mmap, os, vim
b = vim.current.buffer

with open(vim.eval("l:filename"), "r+") as f:
  # Open file by memory mapping.
  m = mmap.mmap(f.fileno(), 0)
  # "vim.command('let l:output = "hoge"')

  pos = 0
  max_lines = m.size()/16 + 1
  for line_number in range(0, max_lines if max_lines < 100 else 100):
    # Make new lines.
    hex_line = ""
    ascii_line = ""

    for char in m[pos : pos+16]:
      num = ord(char)
      hex_line += "{0:02x} ".format(num)
      ascii_line += "." if num < 32 or num > 127 else char
      pos += 1

    # Add line.
    b.append('{0:07x}0: {1:48s}|  {2:16s}  '.format(line_number, hex_line, ascii_line))

  # Delete first line.
  del b[0]
EOF

  setlocal nomodifiable
endfunction"}}}

" Misc.
function! s:initialize_vinarise_buffer()"{{{
  " The current buffer is initialized.
  let b:vinarise = {}

  " Basic settings.
  setlocal number
  setlocal nolist
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
function! s:initialize_context(context)"{{{
  if !has_key(a:context, 'winwidth')
    let a:context.winwidth = 0
  endif
  if !has_key(a:context, 'winheight')
    let a:context.winheight = 0
  endif
  if !has_key(a:context, 'split')
    let a:context.split = 0
  endif
  if !has_key(a:context, 'split_command')
    let a:context.split_command = 'split'
  endif
  if !has_key(a:context, 'overwrite')
    let a:context.overwrite = 0
  endif
  if &l:modified && !&l:hidden
    " Split automatically.
    let a:context.split = 1
  endif

  return a:context
endfunction"}}}

" vim: foldmethod=marker
