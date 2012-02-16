"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 16 Feb 2012.
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

" Define default mappings.
function! vinarise#mappings#define_default_mappings()"{{{
  " Plugin keymappings"{{{
  nnoremap <buffer><silent> <Plug>(vinarise_edit_with_vim)
        \ :<C-u>call <SID>edit_with_vim()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_hide)
        \ :<C-u>call <SID>hide()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_exit)
        \ :<C-u>call <SID>exit()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_next_line)
        \ :<C-u>call <SID>next_line()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_next_screen)
        \ :<C-u>call <SID>next_screen()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_next_half_screen)
        \ :<C-u>call <SID>next_half_screen()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_print_current_position)
        \ :<C-u>call <SID>print_current_position()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_change_current_address)
        \ :<C-u>call <SID>change_current_address()<CR>
  "}}}

  if exists('g:vimshell_no_default_keymappings') && g:vimshell_no_default_keymappings
    return
  endif

  " Normal mode key-mappings.
  nmap <buffer> V <Plug>(vinarise_edit_with_vim)
  nmap <buffer> q <Plug>(vinarise_hide)
  nmap <buffer> Q <Plug>(vinarise_exit)
  nmap <buffer> j         <Plug>(vinarise_next_line)
  nmap <buffer> <C-f>     <Plug>(vinarise_next_screen)
  nmap <buffer> <C-d>     <Plug>(vinarise_next_half_screen)
  nmap <buffer> <C-g>     <Plug>(vinarise_print_current_position)
  nmap <buffer> r    <Plug>(vinarise_change_current_address)
endfunction"}}}

" VimShell key-mappings functions.
function! s:edit_with_vim()"{{{
  let save_auto_detect = g:vinarise_enable_auto_detect
  let g:vinarise_enable_auto_detect = 0

  try
    edit `=b:vinarise.filename`
  finally
    let g:vinarise_enable_auto_detect = save_auto_detect
  endtry
endfunction"}}}
function! s:hide()"{{{
  if b:vinarise.modified
    let yes = input(
          \ 'Current vinarise buffer is modified! Hide anyway?: ', 'yes')
    redraw
    if yes !~ '^y\%[es]$'
      return
    endif
  endif

  " Switch buffer.
  if winnr('$') != 1
    close!
  else
    call vinarise#util#alternate_buffer()
  endif
endfunction"}}}
function! s:exit()"{{{
  if b:vinarise.modified
    let yes = input(
          \ 'Current vinarise buffer is modified! Exit anyway?: ')
    redraw
    if yes !~ '^y\%[es]$'
      return
    endif
  endif

  call vinarise#util#delete_buffer()
endfunction"}}}
function! s:print_current_position()"{{{
  " Get current address.
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  echo printf('[%s] %8d / %8d byte (%3d%%)',
        \ type, address, b:vinarise.filesize, (address*100)/b:vinarise.filesize)
endfunction"}}}
function! s:change_current_address()"{{{
  " Get current address.
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  if type == 'address'
    " Invalid.
    return
  endif

  execute 'python' 'vim.command("let old_value = " + str('.
        \ b:vinarise.python .'.get_byte(vim.eval("address"))))'

  let value = input('Please input new value: '.
        \ printf('%x', old_value) . ' -> ')
  redraw
  if value == '' || value !~ '^\x\x\?$'
    echo 'Invalid value.'
    return
  endif
  let value = str2nr(value, 16)

  execute 'python' b:vinarise.python .
        \ '.set_byte(vim.eval("address"), vim.eval("value"))'

  setlocal modifiable

  " Change current line.
  call setline('.', vinarise#make_line(address / 16))
  let b:vinarise.modified = 1

  setlocal nomodifiable
endfunction"}}}

function! s:next_line()"{{{
  if line('.') == line('$')
    call vinarise#print_lines(2)
  endif

  normal! j
endfunction "}}}
function! s:next_screen()"{{{
  if line('.') + 2 * winheight(0) > line('$')
    call vinarise#print_lines(winheight(0))
  endif

  execute "normal! \<C-f>"
endfunction "}}}
function! s:next_half_screen()"{{{
  if line('.') + winheight(0) > line('$')
    call vinarise#print_lines(winheight(0)/2)
  endif

  execute "normal! \<C-d>"
endfunction "}}}

" vim: foldmethod=marker
