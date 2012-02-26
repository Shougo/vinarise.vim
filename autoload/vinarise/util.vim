"=============================================================================
" FILE: util.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 26 Feb 2012.
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

let s:V = vital#of('vinarise')

function! vinarise#util#truncate_smart(...)"{{{
  return call(s:V.truncate_smart, a:000)
endfunction"}}}

function! vinarise#util#truncate(...)"{{{
  return call(s:V.truncate, a:000)
endfunction"}}}

function! vinarise#util#strchars(...)"{{{
  return call(s:V.strchars, a:000)
endfunction"}}}

function! vinarise#util#wcswidth(...)"{{{
  return call(s:V.wcswidth, a:000)
endfunction"}}}
function! vinarise#util#strwidthpart(...)"{{{
  return call(s:V.strwidthpart, a:000)
endfunction"}}}
function! vinarise#util#strwidthpart_reverse(...)"{{{
  return call(s:V.strwidthpart_reverse, a:000)
endfunction"}}}
function! vinarise#util#is_windows(...)"{{{
  return call(s:V.is_windows, a:000)
endfunction"}}}
function! vinarise#util#is_mac(...)"{{{
  return call(s:V.is_mac, a:000)
endfunction"}}}

function! s:buflisted(bufnr)"{{{
  return exists('t:unite_buffer_dictionary') ?
        \ has_key(t:unite_buffer_dictionary, a:bufnr) && buflisted(a:bufnr) :
        \ buflisted(a:bufnr)
endfunction"}}}

function! vinarise#util#expand(path)"{{{
  return expand(escape(a:path, '*?[]"={}'))
endfunction"}}}

function! vinarise#util#substitute_path_separator(...)
  return call(s:V.substitute_path_separator, a:000)
endfunction
function! vinarise#util#escape_file_searching(...)
  return call(s:V.escape_file_searching, a:000)
endfunction

function! vinarise#util#alternate_buffer()"{{{
  if s:buflisted(bufnr('#'))
    buffer #
    return
  endif

  let listed_buffer = filter(range(1, bufnr('$')),
        \ "s:buflisted(v:val) || v:val == bufnr('%')")
  let current = index(listed_buffer, bufnr('%'))
  if current < 0 || len(listed_buffer) < 2
    enew
  else
    execute 'buffer' ((current < len(listed_buffer) / 2) ?
          \ listed_buffer[current+1] : listed_buffer[current-1])
  endif
endfunction"}}}
function! vinarise#util#delete_buffer(...)"{{{
  let bufnr = get(a:000, 0, bufnr('%'))
  call vinarise#util#alternate_buffer()
  execute 'bdelete!' bufnr
endfunction"}}}
function! s:buflisted(bufnr)"{{{
  return exists('t:unite_buffer_dictionary') ?
        \ has_key(t:unite_buffer_dictionary, a:bufnr) && buflisted(a:bufnr) :
        \ buflisted(a:bufnr)
endfunction"}}}

" vim: foldmethod=marker
