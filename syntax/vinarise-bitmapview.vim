"=============================================================================
" FILE: syntax/vinarise-bitmapview.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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
syntax match vinarise_BitmapviewLine       '[^:]*$' contains=
      \vinarise_BitmapviewNull,
      \vinarise_BitmapviewCntrl1,vinarise_BitmapviewCntrl2,
      \vinarise_BitmapviewAscii1,vinarise_BitmapviewAscii2,
      \vinarise_BitmapviewEscape1,vinarise_BitmapviewEscape2
syntax match vinarise_BitmapviewNull contained '00'
syntax match vinarise_BitmapviewCntrl1 contained '0\x'
syntax match vinarise_BitmapviewCntrl2 contained '1\x'
syntax match vinarise_BitmapviewAscii1 contained '[2-4]\x'
syntax match vinarise_BitmapviewAscii2 contained '[5-7]\x'
syntax match vinarise_BitmapviewEscape1 contained '[8-a]\x'
syntax match vinarise_BitmapviewEscape2 contained '[b-f]\x'

highlight default link vinarise_BitmapviewAddress Comment
highlight default link vinarise_BitmapviewSep Identifier

highlight vinarise_BitmapviewNull guifg=#808080 guibg=#808080 ctermfg=grey ctermbg=grey
highlight vinarise_BitmapviewCntrl1 guifg=#00FF00 guibg=#00FF00 ctermfg=green ctermbg=green
highlight vinarise_BitmapviewCntrl2 guifg=#008000 guibg=#008000 ctermfg=darkgreen ctermbg=darkgreen
highlight vinarise_BitmapviewAscii1 guifg=#FF0000 guibg=#FF0000 ctermfg=red ctermbg=red
highlight vinarise_BitmapviewAscii2 guifg=#800000 guibg=#800000 ctermfg=darkred ctermbg=darkred
highlight vinarise_BitmapviewEscape1 guifg=#00FF00 guibg=#00FF00 ctermfg=green ctermbg=green
highlight vinarise_BitmapviewEscape2 guifg=#008000 guibg=#008000 ctermfg=darkgreen ctermbg=darkgreen


let b:current_syntax = 'vinarise-bitmapview'

" vim: foldmethod=marker
