"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 04 May 2012.
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
  nnoremap <buffer><silent> <Plug>(vinarise_next_column)
        \ :<C-u>call <SID>move_col(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_prev_column)
        \ :<C-u>call <SID>move_col(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_line_first_address)
        \ :<C-u>call <SID>move_line_address(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_line_last_address)
        \ :<C-u>call <SID>move_line_address(0)<CR>
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
  nnoremap <buffer><silent>
        \ <Plug>(vinarise_overwrite_from_current_address)
        \ :<C-u>call <SID>overwrite_from_current_address()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_by_input_address)
        \ :<C-u>call <SID>move_by_input_address('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_by_input_offset)
        \ :<C-u>call <SID>move_by_input_offset('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_to_first_address)
        \ :<C-u>call <SID>move_by_input_address('0%')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_to_last_address)
        \ :<C-u>call <SID>move_by_input_address('100%')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_search_binary)
        \ :<C-u>call <SID>search_buffer('binary', 0, '')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_search_binary_reverse)
        \ :<C-u>call <SID>search_buffer('binary', 1, '')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_search_string)
        \ :<C-u>call <SID>search_buffer('string', 0, '')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_search_string_reverse)
        \ :<C-u>call <SID>search_buffer('string', 1, '')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_search_regexp)
        \ :<C-u>call <SID>search_buffer('regexp', 0, '')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_search_last_pattern)
        \ :<C-u>call <SID>search_buffer(
        \    b:vinarise.last_search_type, 0, b:vinarise.last_search_string)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_search_last_pattern_reverse)
        \ :<C-u>call <SID>search_buffer(
        \    b:vinarise.last_search_type, 1, b:vinarise.last_search_string)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_change_encoding)
        \ :<C-u>call <SID>change_encoding()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_redraw)
        \ :<C-u>call vinarise#mappings#redraw()<CR>
  "}}}

  if exists('g:vinarise_no_default_keymappings') &&
        \ g:vinarise_no_default_keymappings
    return
  endif

  " Normal mode key-mappings.
  nmap <buffer> V <Plug>(vinarise_edit_with_vim)
  nmap <buffer> q <Plug>(vinarise_hide)
  nmap <buffer> Q <Plug>(vinarise_exit)
  nmap <buffer> l         <Plug>(vinarise_next_column)
  nmap <buffer> h         <Plug>(vinarise_prev_column)
  nmap <buffer> j         <Plug>(vinarise_next_line)
  nmap <buffer> k         <Plug>(vinarise_prev_line)
  nmap <buffer> <C-f>     <Plug>(vinarise_next_screen)
  nmap <buffer> <C-b>     <Plug>(vinarise_prev_screen)
  nmap <buffer> <C-d>     <Plug>(vinarise_next_half_screen)
  nmap <buffer> <C-u>     <Plug>(vinarise_prev_half_screen)
  nmap <buffer> <C-g>     <Plug>(vinarise_print_current_position)
  nmap <buffer> r    <Plug>(vinarise_change_current_address)
  nmap <buffer> R    <Plug>(vinarise_overwrite_from_current_address)
  nmap <buffer> gG    <Plug>(vinarise_move_by_input_address)
  nmap <buffer> go    <Plug>(vinarise_move_by_input_offset)
  nmap <buffer> gg    <Plug>(vinarise_move_to_first_address)
  nmap <buffer> G     <Plug>(vinarise_move_to_last_address)
  nmap <buffer> 0          <Plug>(vinarise_line_first_address)
  nmap <buffer> ^          <Plug>(vinarise_line_first_address)
  nmap <buffer> gh         <Plug>(vinarise_line_first_address)
  nmap <buffer> $          <Plug>(vinarise_line_last_address)
  nmap <buffer> gl         <Plug>(vinarise_line_last_address)
  nmap <buffer> /          <Plug>(vinarise_search_binary)
  nmap <buffer> ?          <Plug>(vinarise_search_binary_reverse)
  nmap <buffer> g/         <Plug>(vinarise_search_string)
  nmap <buffer> g?         <Plug>(vinarise_search_string_reverse)
  nmap <buffer> e/         <Plug>(vinarise_search_regexp)
  nmap <buffer> n          <Plug>(vinarise_search_last_pattern)
  nmap <buffer> N          <Plug>(vinarise_search_last_pattern_reverse)
  nmap <buffer> E          <Plug>(vinarise_change_encoding)
  nmap <buffer> <C-l>     <Plug>(vinarise_redraw)
endfunction"}}}

function! vinarise#mappings#move_to_address(address)"{{{
  let address = a:address
  if address >= b:vinarise.filesize
    let address = b:vinarise.filesize - 1
  endif

  setlocal modifiable
  let modified_save = &l:modified

  silent % delete _

  let first_address = address - (winheight(0)/2) * b:vinarise.width
  if first_address < 0
    let first_address = 0
  endif
  call vinarise#print_lines(winheight(0), first_address)

  let &l:modified = modified_save
  setlocal nomodifiable

  " Set cursor.
  call vinarise#set_cursor_address(address)
endfunction "}}}
function! vinarise#mappings#redraw()"{{{
  " Redraw vinarise buffer.

  let [_, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  call vinarise#mappings#move_to_address(address)
endfunction "}}}

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

  call vinarise#release_buffer(bufnr('%'))
  call vinarise#util#delete_buffer()
endfunction"}}}
function! s:print_current_position()"{{{
  " Get current address.
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  let percentage = b:vinarise.get_percentage(address)

  echo printf('[%s] %8d / %8d (%3d%%)',
        \ type, address, b:vinarise.filesize - 1, percentage)
endfunction"}}}
function! s:change_current_address()"{{{
  " Get current address.
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  if type == 'address'
    " Invalid.
    return
  endif

  let old_value = b:vinarise.get_byte(address)

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

  call b:vinarise.set_byte(address, value)

  setlocal modifiable

  " Change current line.
  call setline('.', vinarise#make_line(address / b:vinarise.width))
  setlocal modified

  setlocal nomodifiable
endfunction"}}}
function! s:overwrite_from_current_address()"{{{
  " Get current address.
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  if type == 'address'
    " Invalid.
    return
  endif

  let value = ''
  while 1
    echo printf('Please input new value from 0x%08x: ', address)
    let value = input(' 0x', value)
    redraw

    if value == ''
      return
    elseif value !~ '^\x\+$'
      call vinarise#print_error('The value must be hex.')
    elseif len(value) % 2 != 0
      call vinarise#print_error('The value length must be 2^n.')
    else
      break
    endif
  endwhile

  " Set values.
  let offset = 0
  for value in map(split(
        \ substitute(value, '\x\x\zs', ' ', 'g')), 'str2nr(v:val, 16)')
    call b:vinarise.set_byte(address + offset, value)
    let offset += 1
  endfor

  " Change from current line.
  call vinarise#mappings#move_to_address(address)

  setlocal modified
endfunction"}}}

function! s:move_col(is_next)"{{{
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  if a:is_next
    if type ==# 'hex'
      if (address % b:vinarise.width) == (b:vinarise.width - 1)
            \ || (address == b:vinarise.get_percentage_address(100))
        silent call search('|', 'W')
        call cursor(0, col('.') + 4)
      else
        normal! w
      endif
    elseif !(type ==# 'ascii' &&
            \ address % b:vinarise.width == (b:vinarise.width - 1))
      normal! l
    endif
  else
    if type ==# 'hex'
      if address % b:vinarise.width != 0
        normal! b
      endif
    else
      if type ==# 'ascii' && address % b:vinarise.width == 0
        silent call search('|', 'bW')
        call cursor(0, col('.') - 3)
      else
        normal! h
      endif
    endif
  endif
endfunction "}}}
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
function! s:move_line_address(is_first)"{{{
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  let address = (address / b:vinarise.width) * b:vinarise.width
  if !a:is_first
    let address += 15
  endif

  call vinarise#set_cursor_address(address)
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
function! s:move_by_input_offset(input)"{{{
  " Get current address.
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  let rest = max([0, b:vinarise.filesize - address - 1])
  let offset = (a:input == '') ?
        \ input(printf('Please input offset(min -0x%x, max 0x%x) : ',
        \ address, rest), '') : a:input
  redraw

  if offset == ''
    echo 'Canceled.'
    return
  endif

  if offset =~ '^\-\?0x\x\+$'
    " Convert hex offset.
    let offset = str2nr(offset, 16)
    let address = max([0, min([address + rest, address + offset])])
  elseif offset =~ '^\-\?\d\+%$'
    " Convert percentage offset.
    let offset = offset[ :-2]
    let current = b:vinarise.get_percentage(address)
    let percentage = max([0, min([100, current + offset])])
    let address = b:vinarise.get_percentage_address(percentage)
  else
    echo 'Invalid offset.'
    return
  endif

  call s:move_by_input_address(printf("0x%x", address))
endfunction "}}}
function! s:move_by_input_address(input)"{{{
  let address = (a:input == '') ?
        \ input(printf('Please input new address(max 0x%x) : ',
        \     b:vinarise.filesize), '0x') : a:input
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
    let address = b:vinarise.get_percentage_address(percentage)
  endif

  if address !~ '^\d\+$'
    echo 'Invalid address.'
    return
  endif

  call vinarise#mappings#move_to_address(address)
endfunction "}}}
function! s:search_buffer(type, is_reverse, string)"{{{
  if a:string != ''
    let string = a:string
  elseif a:type ==# 'binary'
    let string = input('Please input search binary(! is not pattern) : ', '0x')
    redraw
  elseif a:type ==# 'string'
    let string = input('Please input search string : ')
    redraw
  elseif a:type ==# 'regexp'
    let string = input('Please input Python regexp : ')
    redraw
  endif

  if string == ''
    echo 'Canceled.'
    return
  endif

  if a:type ==# 'binary'
    let binary = string

    let is_not_pattern = binary =~ '^!'
    if is_not_pattern
      let binary = binary[1:]
    endif

    if binary =~ '^0x\x\+$'
      let binary = binary[2:]
    else
      " Convert to hex offset.
      let binary = printf('%x', binary)
    endif

    if binary !~ '^\x\+$'
      echo 'Invalid input.'
      return
    endif

    if len(binary) % 2 != 0
      " Add prefix "0".
      let binary = '0' . binary
    endif
  endif

  let [_, start] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  if a:is_reverse
    let start -= 1
  else
    let start += 1
  endif

  if a:type ==# 'binary'
    if is_not_pattern
      let address = a:is_reverse ?
            \ b:vinarise.rfind_binary_not(start, binary) :
            \ b:vinarise.find_binary_not(start, binary)
    else
      let address = a:is_reverse ?
            \ b:vinarise.rfind_binary(start, binary) :
            \ b:vinarise.find_binary(start, binary)
    endif
  elseif a:type ==# 'regexp'
    let address = b:vinarise.find_regexp(start, string,
          \ &encoding,
          \  vinarise#get_current_vinarise().context.encoding)
  else
    let address = a:is_reverse ?
          \ b:vinarise.rfind(start, string,
          \  &encoding,
          \  vinarise#get_current_vinarise().context.encoding) :
          \ b:vinarise.find(start, string,
          \  &encoding,
          \  vinarise#get_current_vinarise().context.encoding)
  endif

  if address < 0
    echo 'Pattern not found.'
    return
  endif

  call vinarise#mappings#move_to_address(address)

  let b:vinarise.last_search_string = string
  let b:vinarise.last_search_type = a:type
endfunction "}}}
function! s:change_encoding()"{{{
  let context = vinarise#get_current_vinarise().context
  let encoding = input('Please input new encoding type: '.
        \ context.encoding . ' -> ', '', 'customlist,vinarise#complete_encodings')
  redraw

  if encoding == ''
    return
  elseif encoding !~?
        \ vinarise#multibyte#get_supported_encoding_pattern()
    call vinarise#print_error(
          \ 'encoding type: "'.encoding.'" is not supported.')
    return
  endif

  " Change encoding type.
  let context.encoding = encoding

  " Redraw vinarise buffer.
  call vinarise#mappings#redraw()
endfunction"}}}


" vim: foldmethod=marker
