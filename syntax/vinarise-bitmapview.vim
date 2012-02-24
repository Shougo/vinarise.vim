"=============================================================================
" FILE: syntax/vinarise-bitmapview.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 24 Feb 2012.
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

if version < 700
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

syntax match vinarise_BitmapviewAddress       '^\x\+:'
      \ contains=vinarise_BitmapviewSep
syntax match vinarise_BitmapviewSep contained ':'
syntax match vinarise_BitmapviewLine       '[^:]*$'
      \ contains=vinarise_BitmapviewNull,vinarise_BitmapviewCntrl,vinarise_BitmapviewAscii,vinarise_BitmapviewEscape
syntax match vinarise_BitmapviewNull contained ' '
syntax match vinarise_BitmapviewCntrl contained '.'
syntax match vinarise_BitmapviewAscii contained '+'
syntax match vinarise_BitmapviewEscape contained '*'

highlight default link vinarise_BitmapviewAddress Comment
highlight default link vinarise_BitmapviewSep Identifier
highlight default link vinarise_BitmapviewNull Normal
highlight default link vinarise_BitmapviewCntrl Special
highlight default link vinarise_BitmapviewAscii String
highlight default link vinarise_BitmapviewEscape Statement

let b:current_syntax = 'vinarise-bitmapview'

" vim: foldmethod=marker
