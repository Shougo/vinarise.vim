"=============================================================================
" FILE: parser.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 26 Aug 2012.
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

function! vinarise#parser#parse_one_line(line, vinarise, offset, ...)
  let is_little = get(a:000, 0, 1)
  let matchlist = matchlist(a:line, '^\s*\(\S\+\)\s\+\(\S\+\)\s*;\s*$')
  if len(matchlist) < 3
    throw printf('[vinarise] Parse error in "%s"', a:line)
  endif

  let [all, type, name; _] = matchlist

  let offset = a:offset
  let value = { 'name' : name, 'address' : a:offset, 'type' : type }
  if type ==# 'uint8_t'
    let value.value = a:vinarise.get_int8(offset)
    let value.size = 1
    let value.raw_type = 'number'
  elseif type ==# 'uint16_t'
    let value.value = a:vinarise.get_int16(offset, is_little)
    let value.size = 2
    let value.raw_type = 'number'
  elseif type ==# 'uint32_t'
    let value.value = a:vinarise.get_int32(offset, is_little)
    let value.size = 4
    let value.raw_type = 'number'
  else
    throw printf('[vinarise] Not supported type : "%s" in "%s"',
          \ type, a:line)
  endif
  let value.raw_value = value.value
  let offset += value.size

  return [value, offset]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
