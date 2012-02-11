"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
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
" Version: 0.1, for Vim 7.0
"=============================================================================

if exists('g:loaded_vinarise')
  finish
endif

" Global options definition."{{{
if !exists('g:vinarise_enable_auto_detect')
  let g:vinarise_enable_auto_detect = 0
endif
"}}}

command! -nargs=? -complete=file Vinarise
      \ call s:call_vinarise({}, <q-args>)
command! -nargs=? -complete=file VinariseDump call vinarise#dump#open(<q-args>, 0)

if g:vinarise_enable_auto_detect
  augroup vinarise
    autocmd!
    autocmd BufReadPost,FileReadPost * call s:browse_check(expand('<amatch>'))
  augroup END
endif

function! s:call_vinarise(default, args)"{{{
  let args = []
  let context = a:default
  for arg in split(a:args, '\%(\\\@<!\s\)\+')
    let arg = substitute(arg, '\\\( \)', '\1', 'g')

    let matched_list = filter(copy(vinarise#get_options()),
          \  'stridx(arg, v:val) == 0')
    for option in matched_list
      let key = substitute(substitute(option, '-', '_', 'g'),
            \ '=$', '', '')[1:]
      let context[key] = (option =~ '=$') ?
            \ arg[len(option) :] : 1
      break
    endfor

    if empty(matched_list)
      call add(args, arg)
    endif
  endfor

  call vinarise#open(join(args), context)
endfunction"}}}

function! s:browse_check(filename)"{{{
  if a:filename == '' || &filetype ==# 'vinarise'
        \ || !filereadable(a:filename)
        \ || !g:vinarise_enable_auto_detect
    return
  endif

  let lines = readfile(a:filename, 'b', 1)
  if empty(lines)
    return
  endif

  if lines[0] =~ '\%(^.ELF\|!<arch>\|^MZ\)'
    call vinarise#dump#open(a:filename, 1)
  elseif lines[0] =~ '[\x00-\x09\x10-\x1f]\{5,}'
    call s:call_vinarise({'overwrite' : 1}, a:filename)
  endif
endfunction"}}}

let g:loaded_vinarise = 1

" __END__
" vim: foldmethod=marker
