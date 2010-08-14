"=============================================================================
" FILE: syntax/vinarise-dump-objdump.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 14 Aug 2010
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

syntax case ignore

" Read the C syntax to start with
runtime! syntax/c.vim
unlet b:current_syntax

" Match the labels and Assembly lines
syntax match       vdumpLabel                '^\x\+\s\+<.*>:$'
syntax match       vdumpAsm                  '^\s*\x\+:\s\+\x\+.*$' contains=vdumpAsmLabel,vdumpDecNumber,vdumpOctNumber,vdumpHexNumber,vdumpBinNumber,vdumpAddressNum,vdumpMachine,vdumpJumps,vdumpCalls,vdumpAlerts,vdumpXmmRegister,vdumpStackPointer,vdumpFramePointer,vdumpInstructionPtr,vdumpRegister,vdumpAsmSpecialComment,vdumpAsmComment,vdumpAsmInclude,vdumpAsmCond,vdumpAsmMacro,vdumpAsmDirective

syntax match vdumpDumpLine       '^\s\+\x\{6,}\s\+\x\+\s.*$' contains=vdumpDumpAddress,vdumpDumpAscii
syntax match vdumpDumpAddress '^\s\+\x\{6,}' contained 
syntax match vdumpDumpAscii '\s\{2,}.\{,16}$' contains=vdumpDumpDot contained 
syntax match vdumpDumpDot '[.\r]' contained 

syntax match vdumpAsmLabel            '^\s*\x\+:'

syntax match vdumpDecNumber		'0\+[1-7]\=[\t\n$,; ]'
syntax match vdumpDecNumber		'[1-9]\d*'
syntax match vdumpOctNumber		'0\o\+'
syntax match vdumpHexNumber		'0[xX]\x\+'
syntax match vdumpHexNumber		'\<\x\+\>'
syntax match vdumpBinNumber		'0[bB][01]*'
syntax match vdumpMachine		'\s\+\zs\x\x\ze\s\+'
syntax match vdumpJumps			'\<j[a-z]\+\>'
syntax match vdumpJumps			'\<jmpq\>'
syntax match vdumpJumps			'\<retq\>'
syntax match vdumpJumps			'\<leaveq\>'
syntax match vdumpCalls			'\<callq\?\>'
syntax match vdumpAlerts		'\*\*\+\w\+'

syntax match vdumpXmmRegister		'\<xmm1\?\d\>'
syntax match vdumpStackPointer		'\<[er]sp\>'
syntax match vdumpFramePointer		'\<[er]bp\>'
syntax match vdumpInstructionPtr	'\<[er]ip\>'
syntax match vdumpRegister		'%\w\+'

syntax match vdumpAsmSpecialComment	';\*\*\*.*'
syntax match vdumpAsmComment		';.*'hs=s+1
syntax match vdumpAsmComment		'#.*'hs=s+1

syntax match vdumpAsmInclude		'\<\.include\>'
syntax match vdumpAsmCond		'\<\.if\>'
syntax match vdumpAsmCond		'\<\.else\>'
syntax match vdumpAsmCond		'\<\.endif\>'
syntax match vdumpAsmMacro		'\<\.macro\>'
syntax match vdumpAsmMacro		'\<\.endm\>'

syntax match vdumpAsmDirective		'\<\.[a-z][a-z]\+\>'


syntax case match

highlight def link vdumpDumpAddress Type
highlight def link vdumpDumpAscii Statement

highlight def link vdumpAsmSection Special
highlight def link vdumpAsmLabel Label
highlight def link vdumpAsmComment Comment
highlight def link vdumpAsmDirective Statement

highlight def link vdumpAsmInclude Include
highlight def link vdumpAsmCond PreCondit
highlight def link vdumpAsmMacro Macro

highlight def link vdumpHexNumber Number
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
