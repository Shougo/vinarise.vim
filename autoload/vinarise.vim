"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
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

let s:save_cpo = &cpo
set cpo&vim

function! vinarise#version() "{{{
  return str2nr(printf('%02d%02d', 2, 0))
endfunction"}}}

" Variables  "{{{
let s:vinarise_options = [
      \ '-split', '-split-command',
      \ '-winwidth=', '-winheight=',
      \ '-overwrite', '-encoding=', '-position=',
      \]
let s:current_vinarise = {}
let s:use_current_vinarise = 0
"}}}

function! vinarise#complete(arglead, cmdline, cursorpos) "{{{
  let _ = []

  let args = split(join(split(a:cmdline)[1:]), '\\\@<!\s\+')
  if empty(args)
    let arglead = ''
  else
    let arglead = substitute(args[-1], '\\\(.\)', '\1', 'g')
  endif

  " Filename completion.
  let _ += map(split(vinarise#util#substitute_path_separator(
        \   glob(arglead . '*')), '\n'),
        \   "isdirectory(v:val) ? v:val.'/' : v:val")
  let home_pattern = '^'.
        \ vinarise#util#substitute_path_separator(
        \  expand('~')).'/'
  call map(_, "substitute(v:val, home_pattern, '\\~/', '')")

  " Option names completion.
  let _ +=  copy(s:vinarise_options)

  if a:arglead =~ '^-encoding='
    " Encodings completion.
    let _ += map(vinarise#complete_encodings(
          \ matchstr(arglead, '^-encoding=\zs.*'), a:cmdline, a:cursorpos),
          \ "'-encoding='.v:val")
  endif

  call sort(filter(_, 'stridx(v:val, arglead) == 0'))
  call map(_, "escape(v:val, ' \\')")
  if !empty(args) && args[-1] !=# a:arglead
    call map(_, "v:val[len(args[-1])-len(a:arglead) :]")
  endif

  return _
endfunction"}}}
function! vinarise#complete_encodings(arglead, cmdline, cursorpos) "{{{
  return sort(filter(vinarise#multibyte#get_supported_encoding_list(),
        \ 'stridx(v:val, a:arglead) == 0'))
endfunction"}}}
function! vinarise#get_options() "{{{
  return copy(s:vinarise_options)
endfunction"}}}
function! vinarise#get_cur_text(string, col) "{{{
  return matchstr(a:string, '^.*\%' . a:col . 'c.')
endfunction"}}}

function! vinarise#set_current_vinarise(vinarise) "{{{
  let s:current_vinarise = a:vinarise
endfunction"}}}
function! vinarise#get_current_vinarise() "{{{
  return exists('b:vinarise') && !s:use_current_vinarise ?
        \ b:vinarise : s:current_vinarise
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
