"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 17 Feb 2012.
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
        \ :<C-u>call <SID>move_line(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_prev_line)
        \ :<C-u>call <SID>move_line(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_next_screen)
        \ :<C-u>call <SID>move_screen(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_prev_screen)
        \ :<C-u>call <SID>move_screen(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_next_half_screen)
        \ :<C-u>call <SID>move_half_screen(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_prev_half_screen)
        \ :<C-u>call <SID>move_half_screen(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_print_current_position)
        \ :<C-u>call <SID>print_current_position()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_change_current_address)
        \ :<C-u>call <SID>change_current_address()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_to_input_address)
        \ :<C-u>call <SID>move_to_input_address()<CR>
  "}}}

  if exists('g:vimshell_no_default_keymappings') && g:vimshell_no_default_keymappings
    return
  endif

  " Normal mode key-mappings.
  nmap <buffer> V <Plug>(vinarise_edit_with_vim)
  nmap <buffer> q <Plug>(vinarise_hide)
  nmap <buffer> Q <Plug>(vinarise_exit)
  nmap <buffer> j         <Plug>(vinarise_next_line)
  nmap <buffer> k         <Plug>(vinarise_prev_line)
  nmap <buffer> <C-f>     <Plug>(vinarise_next_screen)
  nmap <buffer> <C-b>     <Plug>(vinarise_prev_screen)
  nmap <buffer> <C-d>     <Plug>(vinarise_next_half_screen)
  nmap <buffer> <C-u>     <Plug>(vinarise_prev_half_screen)
  nmap <buffer> <C-g>     <Plug>(vinarise_print_current_position)
  nmap <buffer> r    <Plug>(vinarise_change_current_address)
  nmap <buffer> G    <Plug>(vinarise_move_to_input_address)
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
  if &l:modified
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
  if &l:modified
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
  execute 'python' 'vim.command("let percentage = " + str('.
        \ b:vinarise.python .'.get_percentage(vim.eval("address"))))'

  echo printf('[%s] %8d / %8d byte (%3d%%)',
        \ type, address, b:vinarise.filesize, percentage)
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
  if value == ''
    return
  elseif value !~ '^\x\x\?$'
    echo 'Invalid value.'
    return
  endif
  let value = str2nr(value, 16)

  execute 'python' b:vinarise.python .
        \ '.set_byte(vim.eval("address"), vim.eval("value"))'

  setlocal modifiable

  " Change current line.
  call setline('.', vinarise#make_line(address / 16))
  setlocal modified

  setlocal nomodifiable
endfunction"}}}

function! s:move_line(is_next)"{{{
  if a:is_next
    if line('.') == line('$')
      call vinarise#print_lines(2)
    endif
    normal! j
  else
    if !a:is_next && line('.') == 1
      call vinarise#print_lines(-2)
    endif
    normal! k
  endif
endfunction "}}}
function! s:move_screen(is_next)"{{{
  if a:is_next
    if line('.') + 2 * winheight(0) > line('$')
      call vinarise#print_lines(winheight(0))
    endif
    execute "normal! \<C-f>"
  else
    if line('.') < 2 * winheight(0)
      call vinarise#print_lines(-winheight(0))
    endif
    execute "normal! \<C-b>"
  endif
endfunction "}}}
function! s:move_half_screen(is_next)"{{{
  if a:is_next
    if line('.') + winheight(0) > line('$')
      call vinarise#print_lines(winheight(0)/2)
    endif
    execute "normal! \<C-d>"
  else
    if !a:is_next && line('.') < winheight(0)
      call vinarise#print_lines(-winheight(0)/2)
    endif
    execute "normal! \<C-u>"
  endif
endfunction "}}}
function! s:move_to_input_address()"{{{
  let address = input(printf('Please input new address(max 0x%x) : ',
        \ b:vinarise.filesize), '0x')
  redraw
  if address == ''
    echo 'Canceled.'
    return
  endif
  if address =~ '^0x\x\+$'
    " Convert hex.
    let address = str2nr(address, 16)
  elseif address =~ '^\d\+%$'
    " Convert percentage.
    let percentage = address[: -2]
    execute 'python' 'vim.command("let address = " + str('.
          \ b:vinarise.python .
          \ ".get_percentage_address(vim.eval('percentage'))))"
  endif

  if address !~ '^\d\+$'
    echo 'Invalid address.'
    return
  endif

  setlocal modifiable
  let modified_save = &l:modified

  silent % delete _
  call vinarise#print_lines(100, address)

  let &l:modified = modified_save
  setlocal nomodifiable

  " Set cursor.
  call vinarise#set_cursor_address(address)
endfunction "}}}

" vim: foldmethod=marker
