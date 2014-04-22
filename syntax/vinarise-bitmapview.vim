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
      \vinarise_BitmapviewCntrl1,vinarise_BitmapviewCntrl2,
      \vinarise_BitmapviewCntrl3,vinarise_BitmapviewCntrl4,
      \vinarise_BitmapviewAscii1,vinarise_BitmapviewAscii2,
      \vinarise_BitmapviewAscii3,vinarise_BitmapviewAscii4,
      \vinarise_BitmapviewEscape1,vinarise_BitmapviewEscape2,
      \vinarise_BitmapviewEscape3,vinarise_BitmapviewEscape4,
      \vinarise_BitmapviewNewLine,vinarise_BitmapviewTab,
      \vinarise_BitmapviewNull,vinarise_BitmapviewFF

syntax match vinarise_BitmapviewCntrl1 contained '0[1-7]'
syntax match vinarise_BitmapviewCntrl2 contained '0[8-f]'
syntax match vinarise_BitmapviewCntrl3 contained '1[0-7]'
syntax match vinarise_BitmapviewCntrl4 contained '1[8-f]'
syntax match vinarise_BitmapviewAscii1 contained '[23]\x'
syntax match vinarise_BitmapviewAscii2 contained '[45]\x'
syntax match vinarise_BitmapviewAscii3 contained '6\x'
syntax match vinarise_BitmapviewAscii4 contained '7\x'
syntax match vinarise_BitmapviewEscape1 contained '[89]\x'
syntax match vinarise_BitmapviewEscape2 contained '[ab]\x'
syntax match vinarise_BitmapviewEscape3 contained '[cd]\x'
syntax match vinarise_BitmapviewEscape4 contained '[ef]\x'

syntax match vinarise_BitmapviewNewLine contained '0[ad]'
syntax match vinarise_BitmapviewTab contained '09'
syntax match vinarise_BitmapviewNull contained '00'
syntax match vinarise_BitmapviewFF contained 'ff'

highlight default link vinarise_BitmapviewAddress Comment
highlight default link vinarise_BitmapviewSep Identifier

highlight vinarise_BitmapviewCntrl1 guifg=#00a000 guibg=#00a000 ctermfg=darkgreen ctermbg=darkgreen
highlight vinarise_BitmapviewCntrl2 guifg=#00c000 guibg=#00c000 ctermfg=darkgreen ctermbg=darkgreen
highlight vinarise_BitmapviewCntrl3 guifg=#00e000 guibg=#00e000 ctermfg=green ctermbg=green
highlight vinarise_BitmapviewCntrl4 guifg=#00f000 guibg=#00f000 ctermfg=green ctermbg=green
highlight vinarise_BitmapviewAscii1 guifg=#a00000 guibg=#a00000 ctermfg=darkred ctermbg=darkred
highlight vinarise_BitmapviewAscii2 guifg=#c00000 guibg=#c00000 ctermfg=darkred ctermbg=darkred
highlight vinarise_BitmapviewAscii3 guifg=#e00000 guibg=#e00000 ctermfg=red ctermbg=red
highlight vinarise_BitmapviewAscii4 guifg=#f00000 guibg=#f00000 ctermfg=red ctermbg=red
highlight vinarise_BitmapviewEscape1 guifg=#00a0a0 guibg=#00a0a0 ctermfg=darkcyan ctermbg=darkcyan
highlight vinarise_BitmapviewEscape2 guifg=#00c0c0 guibg=#00c0c0 ctermfg=darkcyan ctermbg=darkcyan
highlight vinarise_BitmapviewEscape3 guifg=#00e0e0 guibg=#00e0e0 ctermfg=cyan ctermbg=cyan
highlight vinarise_BitmapviewEscape4 guifg=#00f0f0 guibg=#00f0f0 ctermfg=cyan ctermbg=cyan

highlight vinarise_BitmapviewNewLine guifg=#000080 guibg=#000080 ctermfg=darkblue ctermbg=darkblue
highlight vinarise_BitmapviewTab guifg=#0000f0 guibg=#0000f0 ctermfg=blue ctermbg=blue
highlight vinarise_BitmapviewNull guifg=#000000 guibg=#000000 ctermfg=black ctermbg=black
highlight vinarise_BitmapviewFF guifg=#f0f0f0 guibg=#f0f0f0 ctermfg=white ctermbg=white


let b:current_syntax = 'vinarise-bitmapview'

" vim: foldmethod=marker
