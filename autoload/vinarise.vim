"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vinarise#version() abort
  return str2nr(printf('%02d%02d', 2, 0))
endfunction

" Variables
let s:vinarise_options = [
      \ '-split', '-split-command',
      \ '-winwidth=', '-winheight=',
      \ '-overwrite', '-encoding=', '-position=',
      \]
let s:current_vinarise = {}
let s:use_current_vinarise = 0


function! vinarise#complete(arglead, cmdline, cursorpos) abort
  let _ = []

  let args = split(join(split(a:cmdline)[1:]), '\\\@<!\s\+')
  if empty(args)
    let arglead = ''
  else
    let arglead = substitute(args[-1], '\\\(.\)', '\1', 'g')
  endif

  " Filename completion.
  let _ += map(split(vinarise#util#substitute_path_separator(
        \   glob(arglead . '*')), '\n'),
        \   "isdirectory(v:val) ? v:val.'/' : v:val")
  let home_pattern = '^'.
        \ vinarise#util#substitute_path_separator(
        \  expand('~')).'/'
  call map(_, "substitute(v:val, home_pattern, '\\~/', '')")

  " Option names completion.
  let _ +=  copy(s:vinarise_options)

  if a:arglead =~ '^-encoding='
    " Encodings completion.
    let _ += map(vinarise#complete_encodings(
          \ matchstr(arglead, '^-encoding=\zs.*'), a:cmdline, a:cursorpos),
          \ "'-encoding='.v:val")
  endif

  call sort(filter(_, 'stridx(v:val, arglead) == 0'))
  call map(_, "escape(v:val, ' \\')")
  if !empty(args) && args[-1] !=# a:arglead
    call map(_, "v:val[len(args[-1])-len(a:arglead) :]")
  endif

  return _
endfunction
function! vinarise#complete_encodings(arglead, cmdline, cursorpos) abort
  return sort(filter(vinarise#multibyte#get_supported_encoding_list(),
        \ 'stridx(v:val, a:arglead) == 0'))
endfunction
function! vinarise#get_options() abort
  return copy(s:vinarise_options)
endfunction
function! vinarise#get_cur_text(string, col) abort
  return matchstr(a:string, '^.*\%' . a:col . 'c.')
endfunction

function! vinarise#set_current_vinarise(vinarise) abort
  let s:current_vinarise = a:vinarise
endfunction
function! vinarise#get_current_vinarise() abort
  return exists('b:vinarise') && !s:use_current_vinarise ?
        \ b:vinarise : s:current_vinarise
endfunction
