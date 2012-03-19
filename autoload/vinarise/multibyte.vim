"=============================================================================
" FILE: multibyte.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 19 Mar 2012.
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

function! vinarise#multibyte#get_supported_encodings_pattern()"{{{
  " Ascii only.
  return (v:version >= 703) ?
        \'^\%(utf-8\|latin1\)$'
        \ : '^latin1$'
endfunction"}}}
function! vinarise#multibyte#make_ascii_line(line_address, bytes)"{{{
  let encoding = vinarise#get_current_vinarise().context.encoding
  if encoding ==# 'utf-8'
    " UTF-8.
    return s:make_utf8_line(a:line_address, a:bytes)
  else
    " Ascii.
    return s:make_latin1_line(a:line_address, a:bytes)
  endif
endfunction"}}}

function! s:make_latin1_line(line_address, bytes)"{{{
  " Make new line.
  let ascii_line = ''

  for offset in range(0, b:vinarise.width - 1)
    if offset >= len(a:bytes)
      let ascii_line .= ' '
    else
      let num = a:bytes[offset]
      let ascii_line .= (num < 32 || num > 127) ?
            \ '.' : nr2char(num)
    endif
  endfor

  return ascii_line
endfunction"}}}

function! s:make_utf8_line(line_address, bytes)"{{{
  let base_address = a:line_address * b:vinarise.width
  " Make new line.
  let ascii_line = ''

  let offset = 0
  while offset < b:vinarise.width
    if offset >= len(a:bytes)
      let ascii_line .= ' '
      let offset += 1
      continue
    endif

    let num = a:bytes[offset]
    if num < 0x80
      " Ascii.
      let ascii_line .= (num < 32) ?
            \ '.' : nr2char(num)
      let offset += 1
      continue
    elseif num < 0xc0
      " Search byte.
      let ascii_line .= '.'
      let offset += 1
      continue
    elseif num < 0xe0
      " 2byte code.
      let add_offset = 2
    elseif num < 0xf0
      " 3byte code.
      let add_offset = 3
    else
      " 4byte code.
      let add_offset = 4
    endif

    let chars = iconv(b:vinarise.get_chars(
          \ base_address + offset, add_offset), 'utf-8', &encoding)
    let ascii_line .= chars . repeat('.', add_offset - strwidth(chars))
    let offset += add_offset
  endwhile

  return ascii_line
endfunction"}}}

" vim: foldmethod=marker
