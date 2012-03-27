"=============================================================================
" FILE: multibyte.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 27 Mar 2012.
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
        \'^\%(utf-8\|cp932\|latin1\|\%(utf-16\|ucs-2\)\%(le\|be\|bom\)\?\)$'
        \ : '^latin1$'
endfunction"}}}
function! vinarise#multibyte#make_ascii_line(line_address, bytes)"{{{
  let encoding = vinarise#get_current_vinarise().context.encoding
  if encoding =~? '^utf-\?8$'
    " UTF-8.
    return s:make_utf8_line(a:line_address, a:bytes)
  elseif encoding ==? 'cp932'
    " Cp932(Shift_JIS).
    return s:make_cp932_line(a:line_address, a:bytes)
  elseif encoding =~? '\%(utf-\?16\|ucs-\?2\)\%(le\|be\|bom\)\?'
    " UTF-16.
    return s:make_utf16_line(a:line_address, a:bytes,
          \ encoding !~? '\%(utf-\?16\|ucs-\?2\)be$')
  else
    " Ascii.
    return s:make_latin1_line(a:line_address, a:bytes)
  endif
endfunction"}}}

function! s:make_latin1_line(line_address, bytes)"{{{
  " Make new line.
  let ascii_line = '   '

  for offset in range(0, b:vinarise.width - 1)
    if offset >= len(a:bytes)
      let ascii_line .= ' '
    else
      let num = a:bytes[offset]
      let ascii_line .= (num <= 0x1f || num >= 0x80) ?
            \ '.' : nr2char(num)
    endif
  endfor

  return ascii_line . '  '
endfunction"}}}

function! s:make_utf8_line(line_address, bytes)"{{{
  let encoding = vinarise#get_current_vinarise().context.encoding
  let base_address = a:line_address * b:vinarise.width
  " Make new line.
  let ascii_line = '   '

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
      let ascii_line .= (num <= 0x1f) ?
            \ '.' : nr2char(num)
      let offset += 1
      continue
    elseif num < 0xc0
      " Search first byte.
      let prev_bytes = reverse(b:vinarise.get_bytes(
            \ base_address + offset - 3, min([base_address, 3])))
      let first_bytes = filter(copy(prev_bytes), 'v:val > 0xc0')
      if empty(first_bytes)
        " Skip.
        let ascii_line .= '.'
        let offset += 1
        continue
      endif

      let num = first_bytes[0]
      let sub_offset = index(prev_bytes, num) + 1
      if offset == 0
        let ascii_line = repeat(' ', 3 - sub_offset)
      endif

      let offset -= sub_offset
    endif

    if num < 0xe0
      " 2byte code.
      let add_offset = 2
    elseif num < 0xf0
      " 3byte code.
      let add_offset = 3
    else
      " 4byte code.
      let add_offset = 4
    endif

    let chars = b:vinarise.get_chars(
          \ base_address + offset, add_offset, encoding, &encoding)
    if chars =~ '?'
      " Failed convert.
      let chars = '.'
    endif
    let ascii_line .= chars
    if strwidth(ascii_line) < b:vinarise.width + 2
      let ascii_line .= repeat('.', add_offset - strwidth(chars))
    endif

    let offset += add_offset
  endwhile

  return ascii_line . repeat(' ',
        \ strwidth(ascii_line) - (b:vinarise.width + 4))
endfunction"}}}

function! s:make_utf16_line(line_address, bytes, is_little_endian)"{{{
  let encoding = vinarise#get_current_vinarise().context.encoding
  let base_address = a:line_address * b:vinarise.width
  " Make new line.
  let ascii_line = '   '

  let offset = 0
  while offset < b:vinarise.width
    if offset >= len(a:bytes)
      let ascii_line .= ' '
      let offset += 1
      continue
    endif

    let num = b:vinarise.get_int16(
          \ base_address + offset, a:is_little_endian)

    if num < 0x80
      " Ascii.
      let ascii_line .= (num <= 0x1f) ?
            \ '.' : nr2char(num)
      if a:is_little_endian
        let ascii_line .= ' '
      else
        let ascii_line = ' ' . ascii_line
      endif
      let offset += 2
      continue
    elseif 0xdc00 <= num && num <= 0xdcff
          \ && base_address + offset > 2
      let num = b:vinarise.get_int16(
            \ base_address + offset - 2, a:is_little_endian)
      let sub_offset = 2
      if offset == 0
        let ascii_line = repeat(' ', 3 - sub_offset)
      endif

      let offset -= sub_offset
    endif

    if 0xd800 <= num && num <= 0xd8ff
      " Surrogate pair.
      " 4byte code.
      let add_offset = 4
    else
      " 2byte code.
      let add_offset = 2
    endif

    let chars = b:vinarise.get_chars(
          \ base_address + offset, add_offset, encoding, &encoding)
    if chars =~ '?'
      " Failed convert.
      let chars = '.'
    endif
    let ascii_line .= chars
    if strwidth(ascii_line) < b:vinarise.width + 2
      let ascii_line .= repeat('.', add_offset - strwidth(chars))
    endif

    let offset += add_offset
  endwhile

  return ascii_line . repeat(' ',
        \ strwidth(ascii_line) - (b:vinarise.width + 4))
endfunction"}}}

function! s:make_cp932_line(line_address, bytes)"{{{
  let encoding = vinarise#get_current_vinarise().context.encoding
  let base_address = a:line_address * b:vinarise.width
  " Make new line.
  let ascii_line = '   '

  let offset = 0
  while offset < b:vinarise.width
    if offset >= len(a:bytes)
      let ascii_line .= ' '
      let offset += 1
      continue
    endif

    let num = a:bytes[offset]

    if (num >= 0x40 && num <= 0x7e) || (num >= 0x80 && num <= 0xfc)
      " Search first byte.
      let prev_bytes = reverse(b:vinarise.get_bytes(
            \ base_address + offset - 2, min([base_address, 2])))
      let prev_byte = get(prev_bytes, 0)
      let prepre_byte = get(prev_bytes, 1, 0)
      if (prepre_byte >= 0x81 && prepre_byte <= 0x9f)
            \  || (prepre_byte >= 0xe0 && prepre_byte <= 0xef)
        " Cancel.
        let prev_byte = 0
      endif

      if (prev_byte >= 0x81 && prev_byte <= 0x9f)
            \ || (prev_byte >= 0xe0 && prev_byte <= 0xef)
        let sub_offset = 1
        if offset == 0
          let ascii_line = repeat(' ', 3 - sub_offset)
        endif

        let offset -= sub_offset
        let num = prev_byte
      endif
    endif

    if num < 0x80
      " Ascii.
      let ascii_line .= (num <= 0x1f) ?
            \ '.' : nr2char(num)
      let offset += 1
      continue
    elseif num >= 0xa0 && num <= 0xdf
      " 1byte code(hankaku-kana).
      let add_offset = 1
    elseif (num >= 0x81 && num <= 0x9f) || (num >= 0xe0 && num <= 0xef)
      " 2byte code.
      let add_offset = 2
    else
      " Unknown.
      let ascii_line .= '.'
      let offset += 1
      continue
    endif

    let chars = b:vinarise.get_chars(
          \ base_address + offset, add_offset, encoding, &encoding)
    if chars =~ '?'
      " Failed convert.
      let chars = '.'
    endif
    let ascii_line .= chars
    if strwidth(ascii_line) < b:vinarise.width + 2
      let ascii_line .= repeat('.', add_offset - strwidth(chars))
    endif

    let offset += add_offset
  endwhile

  return ascii_line . repeat(' ',
        \ strwidth(ascii_line) - (b:vinarise.width + 4))
endfunction"}}}

" vim: foldmethod=marker
