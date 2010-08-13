"=============================================================================
" FILE: syntax/vinarise-dump-objdump.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 13 Aug 2010
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

if exists("b:current_syntax")
  finish
endif

syn case ignore

" Read the C syntax to start with
runtime! syntax/c.vim
unlet b:current_syntax

" Match the labels and Assembly lines
syn match       vdumpLabel                '^\x\+\s\+<.*>:$'
syn match       vdumpAsm                  '^\s*\x\+:\s\+\x\+.*$' contains=vdumpAsmLabel,vdumpDecNumber,vdumpOctNumber,vdumpHexNumber,vdumpBinNumber,vdumpAddressNum,vdumpMachine,vdumpJumps,vdumpCalls,vdumpAlerts,vdumpXmmRegister,vdumpStackPointer,vdumpFramePointer,vdumpInstructionPtr,vdumpRegister,vdumpAsmSpecialComment,vdumpAsmComment,vdumpAsmInclude,vdumpAsmCond,vdumpAsmMacro,vdumpAsmDirective

syn match vdumpAsmLabel            '^\s*\x\+:'

syn match vdumpDecNumber		'0\+[1-7]\=[\t\n$,; ]'
syn match vdumpDecNumber		'[1-9]\d*'
syn match vdumpOctNumber		'0\o\+'
syn match vdumpHexNumber		'0[xX]\x\+'
syn match vdumpBinNumber		'0[bB][01]*'
syn match vdumpMachine		'\s\+\zs\x\x\ze\s\+'
syn match vdumpJumps			'\<j[a-z]\+\>'
syn match vdumpJumps			'\<jmpq\>'
syn match vdumpJumps			'\<retq\>'
syn match vdumpJumps			'\<leaveq\>'
syn match vdumpCalls			'\<callq\?\>'
syn match vdumpAlerts		'\*\*\+\w\+'

syn match vdumpXmmRegister		'\<xmm1\?\d\>'
syn match vdumpStackPointer		'\<[er]sp\>'
syn match vdumpFramePointer		'\<[er]bp\>'
syn match vdumpInstructionPtr	'\<[er]ip\>'
syn match vdumpRegister		'%\w\+'

syn match vdumpAsmSpecialComment	';\*\*\*.*'
syn match vdumpAsmComment		';.*'hs=s+1
syn match vdumpAsmComment		'#.*'hs=s+1

syn match vdumpAsmInclude		'\<\.include\>'
syn match vdumpAsmCond		'\<\.if\>'
syn match vdumpAsmCond		'\<\.else\>'
syn match vdumpAsmCond		'\<\.endif\>'
syn match vdumpAsmMacro		'\<\.macro\>'
syn match vdumpAsmMacro		'\<\.endm\>'

syn match vdumpAsmDirective		'\<\.[a-z][a-z]\+\>'


syn case match

highlight def link vdumpAsmSection Special
highlight def link vdumpAsmLabel Label
highlight def link vdumpAsmComment Comment
highlight def link vdumpAsmDirective Statement

highlight def link vdumpAsmInclude Include
highlight def link vdumpAsmCond PreCondit
highlight def link vdumpAsmMacro Macro

highlight def link vdumpHexNumber Type
highlight def link vdumpDecNumber Number
highlight def link vdumpOctNumber Number
highlight def link vdumpBinNumber Number
highlight def link vdumpMachine Number

highlight def link vdumpAsmSpecialComment Comment
highlight def link vdumpAsmType Type

highlight def link vdumpJumps PreProc
highlight def link vdumpCalls PreProc
highlight def link vdumpAlerts VisualNOS

highlight def link vdumpLabel DiffDelete

highlight def link vdumpAsmSpecialComment Special
highlight def link vdumpAsmType Type
highlight def link vdumpRegister Identifier
highlight def link vdumpXmmRegister Identifier
highlight def link vdumpFramePointer Identifier
highlight def link vdumpInstructionPtr Identifier

let b:current_syntax = 'vinarise-dump-objdump'

" vim: ts=8
