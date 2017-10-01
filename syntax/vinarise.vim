"=============================================================================
" FILE: syntax/vinarise.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

if version < 700
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

syntax match vinariseAddress       '^\s*\x\+:' contains=vinariseSep
syntax match vinariseSep contained ':'
syntax match vinariseAsciiLine '|.*\s*$' contains=vinariseAscii,vinariseSep2
syntax match vinariseAscii contained '.*' contains=vinariseDot
syntax match vinariseSep2 contained '|'
syntax match vinariseDot contained '[.\r]'

highlight default link vinariseAddress Constant
highlight default link vinariseSep Identifier
highlight default link vinariseSep2 Identifier
highlight default link vinariseAscii Statement

let b:current_syntax = 'vinarise'
