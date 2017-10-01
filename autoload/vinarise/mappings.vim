"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

" Define default mappings.
function! vinarise#mappings#define_default_mappings() abort
  " Plugin keymappings
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
        \ :<C-u>call vinarise#mappings#move_by_input_address('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_by_input_offset)
        \ :<C-u>call <SID>move_by_input_offset('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_to_first_address)
        \ :<C-u>call vinarise#mappings#move_by_input_address('0%')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_move_to_last_address)
        \ :<C-u>call vinarise#mappings#move_by_input_address('100%')<CR>
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
  nnoremap <buffer><silent> <Plug>(vinarise_reload)
        \ :<C-u>call <SID>reload()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview)
        \ :<C-u>VinarisePluginBitmapView<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_next_skip)
        \ :<C-u>call <SID>move_skip(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_prev_skip)
        \ :<C-u>call <SID>move_skip(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_insert_bytes)
        \ :<C-u>call <SID>insert_bytes()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_delete_current_address)
        \ :<C-u>call <SID>delete_current_address()<CR>
  

  if exists('g:vinarise_no_default_keymappings') &&
        \ g:vinarise_no_default_keymappings
    return
  endif

  " Normal mode key-mappings.
  execute s:nowait_nmap() 'V'        '<Plug>(vinarise_edit_with_vim)'
  execute s:nowait_nmap() 'q'        '<Plug>(vinarise_hide)'
  execute s:nowait_nmap() 'Q'        '<Plug>(vinarise_exit)'
  execute s:nowait_nmap() 'l'        '<Plug>(vinarise_next_column)'
  execute s:nowait_nmap() 'h'        '<Plug>(vinarise_prev_column)'
  execute s:nowait_nmap() 'j'        '<Plug>(vinarise_next_line)'
  execute s:nowait_nmap() 'k'        '<Plug>(vinarise_prev_line)'
  execute s:nowait_nmap() '<C-f>'    '<Plug>(vinarise_next_screen)'
  execute s:nowait_nmap() '<C-b>'    '<Plug>(vinarise_prev_screen)'
  execute s:nowait_nmap() '<PageDown>'   '<Plug>(vinarise_next_screen)'
  execute s:nowait_nmap() '<PageUp>'     '<Plug>(vinarise_prev_screen)'
  execute s:nowait_nmap() '<C-d>'    '<Plug>(vinarise_next_half_screen)'
  execute s:nowait_nmap() '<C-u>'    '<Plug>(vinarise_prev_half_screen)'
  execute s:nowait_nmap() '<C-g>'    '<Plug>(vinarise_print_current_position)'
  execute s:nowait_nmap() 'r'        '<Plug>(vinarise_change_current_address)'
  execute s:nowait_nmap() 'R'        '<Plug>(vinarise_overwrite_from_current_address)'
  execute s:nowait_nmap() 'gG'       '<Plug>(vinarise_move_by_input_address)'
  execute s:nowait_nmap() 'go'       '<Plug>(vinarise_move_by_input_offset)'
  execute s:nowait_nmap() 'gg'       '<Plug>(vinarise_move_to_first_address)'
  execute s:nowait_nmap() 'G'        '<Plug>(vinarise_move_to_last_address)'
  execute s:nowait_nmap() '0'        '<Plug>(vinarise_line_first_address)'
  execute s:nowait_nmap() '^'        '<Plug>(vinarise_line_first_address)'
  execute s:nowait_nmap() 'gh'       '<Plug>(vinarise_line_first_address)'
  execute s:nowait_nmap() '$'        '<Plug>(vinarise_line_last_address)'
  execute s:nowait_nmap() 'gl'       '<Plug>(vinarise_line_last_address)'
  execute s:nowait_nmap() '/'        '<Plug>(vinarise_search_binary)'
  execute s:nowait_nmap() '?'        '<Plug>(vinarise_search_binary_reverse)'
  execute s:nowait_nmap() 'g/'       '<Plug>(vinarise_search_string)'
  execute s:nowait_nmap() 'g?'       '<Plug>(vinarise_search_string_reverse)'
  execute s:nowait_nmap() 'e/'       '<Plug>(vinarise_search_regexp)'
  execute s:nowait_nmap() 'n'        '<Plug>(vinarise_search_last_pattern)'
  execute s:nowait_nmap() 'N'        '<Plug>(vinarise_search_last_pattern_reverse)'
  execute s:nowait_nmap() 'E'        '<Plug>(vinarise_change_encoding)'
  execute s:nowait_nmap() '<C-l>'    '<Plug>(vinarise_redraw)'
  execute s:nowait_nmap() 'g<C-l>'   '<Plug>(vinarise_reload)'
  execute s:nowait_nmap() 'B'        '<Plug>(vinarise_bitmapview)'
  execute s:nowait_nmap() 'w'        '<Plug>(vinarise_next_skip)'
  execute s:nowait_nmap() 'b'        '<Plug>(vinarise_prev_skip)'
  execute s:nowait_nmap() 'i'        '<Plug>(vinarise_insert_bytes)'
  execute s:nowait_nmap() 'x'        '<Plug>(vinarise_delete_current_address)'
endfunction

function! s:nowait_nmap() abort
  return 'nmap <buffer>'
        \ . ((v:version > 703 || (v:version == 703 && has('patch1261'))) ?
        \ '<nowait>' : '')
endfunction 

function! vinarise#mappings#move_by_input_address(input) abort
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
endfunction 
function! vinarise#mappings#move_to_address(address) abort
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
  call vinarise#view#print_lines(winheight(0), first_address)

  let &l:modified = modified_save
  setlocal nomodifiable

  " Set cursor.
  call vinarise#view#set_cursor_address(address)
endfunction 
function! vinarise#mappings#redraw() abort
  " Redraw vinarise buffer.
  let address = s:parse_current_address()[1]
  call vinarise#mappings#move_to_address(address)
endfunction 

function! s:edit_with_vim() abort
  let save_auto_detect = g:vinarise_enable_auto_detect
  let g:vinarise_enable_auto_detect = 0

  try
    execute 'edit' fnameescape(b:vinarise.filename)
  finally
    let g:vinarise_enable_auto_detect = save_auto_detect
  endtry
endfunction
function! s:hide() abort
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
endfunction
function! s:exit() abort
  if &l:modified
    let yes = input(
          \ 'Current vinarise buffer is modified! Exit anyway?: ')
    redraw
    if yes !~ '^y\%[es]$'
      return
    endif
  endif

  call vinarise#handlers#release_buffer(bufnr('%'))
  call vinarise#util#delete_buffer()
endfunction
function! s:print_current_position() abort
  let [type, address] = s:parse_current_address()
  let percentage = b:vinarise.get_percentage(address)

  echo printf('[%s] %8d / %8d (%3d%%)',
        \ type, address, b:vinarise.filesize - 1, percentage)
endfunction
function! s:change_current_address() abort
  let [type, address] = s:parse_current_address()
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
  call setline('.', vinarise#view#make_line(address / b:vinarise.width))
  setlocal modified

  setlocal nomodifiable
endfunction
function! s:insert_bytes() abort
  let [type, address] = s:parse_current_address()
  if type == 'address'
    " Invalid.
    return
  endif

  let old_value = b:vinarise.get_byte(address)

  let value = input('Please input insert value: ')
  redraw
  if value == ''
    return
  elseif value !~ '^\x\x\?$'
    echo 'Invalid value.'
    return
  endif
  let value = str2nr(value, 16)

  call b:vinarise.insert_bytes(address, [value])

  " Redraw vinarise buffer.
  call vinarise#mappings#redraw()
endfunction
function! s:overwrite_from_current_address() abort
  let [type, address] = s:parse_current_address()
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
      call vinarise#view#print_error('The value must be hex.')
    elseif len(value) % 2 != 0
      call vinarise#view#print_error('The value length must be 2^n.')
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
endfunction
function! s:delete_current_address() abort
  let [type, address] = s:parse_current_address()
  if type == 'address'
    " Invalid.
    return
  endif

  call b:vinarise.delete_byte(address)

  " Redraw vinarise buffer.
  call vinarise#mappings#redraw()
endfunction
function! s:parse_current_address() abort
  return vinarise#helper#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
endfunction

function! s:move_col(is_next) abort
  let [type, address] = s:parse_current_address()
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
      call cursor(0, col('.') + 1)
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
        call cursor(0, col('.') - 1)
      endif
    endif
  endif
endfunction 
function! s:move_line(is_next) abort
  if a:is_next
    if line('.') == line('$')
      call vinarise#view#print_lines(2)
    endif
    call cursor(line('.') + 1, 0)
  else
    if !a:is_next && line('.') == 1
      call vinarise#view#print_lines(-2)
    endif
    call cursor(line('.') - 1, 0)
  endif
endfunction 
function! s:move_line_address(is_first) abort
  let address = s:parse_current_address()[1]
  let address = (address / b:vinarise.width) * b:vinarise.width
  if !a:is_first
    let address += 15
  endif

  call vinarise#view#set_cursor_address(address)
endfunction 
function! s:move_screen(is_next) abort
  if a:is_next
    if line('.') + 2 * winheight(0) > line('$')
      call vinarise#view#print_lines(winheight(0))
    endif
    execute "normal! \<C-f>"
  else
    if line('.') < 2 * winheight(0)
      call vinarise#view#print_lines(-winheight(0))
    endif
    execute "normal! \<C-b>"
  endif
endfunction 
function! s:move_half_screen(is_next) abort
  if a:is_next
    if line('.') + winheight(0) > line('$')
      call vinarise#view#print_lines(winheight(0)/2)
    endif
    execute "normal! \<C-d>"
  else
    if !a:is_next && line('.') < winheight(0)
      call vinarise#view#print_lines(-winheight(0)/2)
    endif
    execute "normal! \<C-u>"
  endif
endfunction 
function! s:move_by_input_offset(input) abort
  let address = s:parse_current_address()[1]
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

  call vinarise#mappings#move_by_input_address(printf("0x%x", address))
endfunction 
function! s:move_skip(is_next) abort
  let vinarise = b:vinarise

  let address = s:parse_current_address()[1]

  let value = vinarise.get_byte(address)
  let binary = '00'
  if value != 0
    " Search zero
    let ret = a:is_next ?
          \ vinarise.find_binary(address + 1, binary) :
          \ vinarise.rfind_binary(address - 1, binary)
  else
    " Search non zero
    let ret = a:is_next ?
          \ vinarise.find_binary_not(address + 1, binary) :
          \ vinarise.rfind_binary_not(address - 1, binary)
  endif

  if ret < 0
    let ret = a:is_next ? vinarise.filesize : 0
  endif

  call vinarise#mappings#move_to_address(ret)
endfunction 
function! s:search_buffer(type, is_reverse, string) abort
  let string = ''
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

  let is_not_pattern = 0
  let binary = ''
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

  let start = s:parse_current_address()[1]
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
endfunction 
function! s:change_encoding() abort
  let context = vinarise#get_current_vinarise().context
  let encoding = input('Please input new encoding type: '.
        \ context.encoding . ' -> ', '', 'customlist,vinarise#complete_encodings')
  redraw

  if encoding == ''
    return
  elseif encoding !~?
        \ vinarise#multibyte#get_supported_encoding_pattern()
    call vinarise#view#print_error(
          \ 'encoding type: "'.encoding.'" is not supported.')
    return
  endif

  " Change encoding type.
  let context.encoding = encoding

  " Redraw vinarise buffer.
  call vinarise#mappings#redraw()
endfunction
function! s:reload() abort
  let address = s:parse_current_address()[1]

  let vinarise = vinarise#get_current_vinarise()
  let context = deepcopy(vinarise.context)
  let filename = vinarise#get_current_vinarise().filename

  call vinarise#init#start(filename, context)

  call vinarise#mappings#move_to_address(address)
endfunction
