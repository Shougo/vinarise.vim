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
  return '^latin1$'
endfunction"}}}
function! vinarise#multibyte#make_ascii_line(line_address, bytes)"{{{
  " Make new lines.
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

" vim: foldmethod=marker
