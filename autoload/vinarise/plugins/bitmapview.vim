"=============================================================================
" FILE: bitmapview.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" Last Modified: 24 Feb 2012.
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

let s:save_cpo = &cpo
set cpo&vim

function! vinarise#plugins#bitmapview#define()
  return s:plugin
endfunction

let s:save_gui = []

let s:font_pattern =
      \ unite#util#is_win() ||
      \ unite#util#is_mac() ?  ':h\zs\d\+':
      \ has('gui_gtk') ?       '\s\+\zs\d\+$':
      \ has('X11') ?           '\v%([^-]*-){6}\zs\d+\ze%(-[^-]*){7}':
      \                        '*Unknown system*'

let s:plugin = {
      \ 'name' : 'bitmapview',
      \ 'description' : 'bitmap view',
      \}

function! s:plugin.initialize(vinarise, context)"{{{
  command! VinarisePluginBitmapView call s:bitmapview_open()

endfunction"}}}
function! s:plugin.finalize(vinarise, context)"{{{
endfunction"}}}

function! s:bitmapview_open()
  let vinarise = vinarise#get_current_vinarise()

  let prefix = vimfiler#util#is_windows() ?
        \ '[bitmapview] - ' : '*bitmapview* - '
  edit `=prefix . vinarise.filename`
  match

  let b:bitmapview = {}
  let b:bitmapview.vinarise = vinarise

  if has('gui_running')
    call s:change_windowsize()
  endif

  let b:bitmapview.width = (winwidth(0) - 10) / 16 * 16

  setlocal nolist
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal hidden
  setlocal foldcolumn=0

  " Autocommands.
  augroup plugin-vinarise
    autocmd BufWinLeave <buffer> call s:finalize(expand('<abuf>'))
  augroup END

  call s:define_default_mappings()

  " User's initialization.
  setfiletype vinarise-bitmapview

  call s:print_lines(winheight(0))

  call s:set_cursor_address(0)
endfunction
function! s:define_default_mappings()"{{{
  " Plugin keymappings"{{{
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_exit)
        \ :<C-u>call <SID>exit()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_next_line)
        \ :<C-u>call <SID>move_line(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_prev_line)
        \ :<C-u>call <SID>move_line(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_next_screen)
        \ :<C-u>call <SID>move_screen(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_prev_screen)
        \ :<C-u>call <SID>move_screen(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_next_half_screen)
        \ :<C-u>call <SID>move_half_screen(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_prev_half_screen)
        \ :<C-u>call <SID>move_half_screen(0)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_print_current_position)
        \ :<C-u>call <SID>print_current_position()<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_to_input_address)
        \ :<C-u>call <SID>move_to_input_address('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_by_input_offset)
        \ :<C-u>call <SID>move_by_input_offset('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_to_first_address)
        \ :<C-u>call <SID>move_to_input_address('0%')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_to_last_address)
        \ :<C-u>call <SID>move_to_input_address('100%')<CR>
  "}}}

  if exists('g:vimshell_no_default_keymappings') && g:vimshell_no_default_keymappings
    return
  endif

  " Normal mode key-mappings.
  nmap <buffer> q <Plug>(vinarise_bitmapview_exit)
  nmap <buffer> j         <Plug>(vinarise_bitmapview_next_line)
  nmap <buffer> k         <Plug>(vinarise_bitmapview_prev_line)
  nmap <buffer> <C-f>     <Plug>(vinarise_bitmapview_next_screen)
  nmap <buffer> <C-b>     <Plug>(vinarise_bitmapview_prev_screen)
  nmap <buffer> <C-d>     <Plug>(vinarise_bitmapview_next_half_screen)
  nmap <buffer> <C-u>     <Plug>(vinarise_bitmapview_prev_half_screen)
  nmap <buffer> <C-g>     <Plug>(vinarise_bitmapview_print_current_position)
  nmap <buffer> G     <Plug>(vinarise_bitmapview_move_to_input_address)
  nmap <buffer> go    <Plug>(vinarise_bitmapview_move_by_input_offset)
  nmap <buffer> gg    <Plug>(vinarise_bitmapview_move_to_first_address)
  nmap <buffer> gG    <Plug>(vinarise_bitmapview_move_to_last_address)
endfunction"}}}

function! s:finalize(bufnr)"{{{
  if empty(s:save_gui)
    return
  endif

  let [&guifont, &guifontwide, &lines, &columns] = s:save_gui
  let s:save_gui = []
endfunction"}}}

function! s:parse_address(string, cur_text)"{{{
  " Get last address.
  let base_address = matchstr(a:string, '^\x\+')

  " Default.
  let type = 'address'
  let address = str2nr(base_address, 16)

  if a:cur_text =~ '^\s*\x\+\s*:.\+$'
    " Check hex line.
    let offset = len(matchstr(a:cur_text, '^\s*\x\+\s*: \zs.\+$')) - 1
    if 0 <= offset && offset < b:bitmapview.width
      let type = 'bitmap'
      let address += offset
    endif
  endif

  return [type, address]
endfunction"}}}

function! s:print_lines(lines, ...)"{{{
  " Get last address.
  if a:0 >= 1
    let address = a:1
  else
    let [_, address] = s:parse_address(
          \ (a:lines < 0 ? getline(1) : getline('$')), '')
  endif

  let line_address = address / b:bitmapview.width

  if a:lines < 0
    let max_lines = line_address + a:lines
    if max_lines < 0
      let max_lines = 0
    endif
    let line_numbers = range(max_lines, line_address-1)
  else
    let max_lines = b:bitmapview.vinarise.filesize / b:bitmapview.width

    if max_lines > line_address + a:lines
      let max_lines = line_address + a:lines
    endif
    if max_lines - line_address < winheight(0)
          \ && line('$') < winheight(0)
          \ && line_address != max_lines
      let line_address = max_lines - winheight(0) + 1
    endif
    if line_address < 0
      let line_address = 0
    endif
    let line_numbers = range(line_address, max_lines)
  endif

  let lines = []
  for line_nr in line_numbers
    call add(lines, s:make_line(line_nr))
  endfor

  setlocal modifiable
  let modified_save = &l:modified

  if a:lines < 0
    call append(0, lines)
  else
    call setline('$', lines)
  endif

  let &l:modified = modified_save
  setlocal nomodifiable
endfunction"}}}
function! s:make_line(line_address)"{{{
  " Make new lines.
  let line = ''

  let i = 0
  for num in b:bitmapview.vinarise.get_bytes(
        \ a:line_address * b:bitmapview.width, b:bitmapview.width)
    let line .= (num == 0) ?   ' ' :
          \ (num < 0x1f) ? '.' : (num < 0x7f) ? '+' :  '*'
  endfor

  return printf('%08x: %s', a:line_address * b:bitmapview.width, line)
endfunction"}}}
function! s:set_cursor_address(address)"{{{
  let line_address = (a:address / b:bitmapview.width) * b:bitmapview.width
  let [lnum, col] = searchpos(
        \ printf('%08x: .\{%d}', line_address, a:address - line_address + 1), 'cew')
  call cursor(lnum, col)
endfunction"}}}

function! s:change_windowsize()"{{{
  let s:save_gui = [&guifont, &guifontwide, &lines, &columns]

  let old_fontsize = matchstr(&guifont, s:font_pattern)
  if old_fontsize == '' || old_fontsize <= 8
    return
  endif

  let &guifont = s:change_fontsize(&guifont, 8)
  let &guifontwide = s:change_fontsize(&guifontwide, 8)
  let &columns = (&columns * old_fontsize) / 8
  let &lines = (&lines * old_fontsize) / 8
endfunction"}}}
function! s:change_fontsize(font, size)
  return join(map(split(a:font, '\\\@<!,'),
        \   printf('substitute(v:val, %s, %s, "g")',
        \   string(s:font_pattern),
        \   string('\=max([1,' . a:size . '])'))), ',')
endfunction

" Mappings.
function! s:exit()"{{{
  call vinarise#util#delete_buffer()
endfunction"}}}
function! s:print_current_position()"{{{
  " Get current address.
  let [type, address] = s:parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  let percentage = b:bitmapview.vinarise.get_percentage(address)

  echo printf('[%s] %8d / %8d (%3d%%)',
        \ type, address, b:bitmapview.vinarise.filesize - 1, percentage)
endfunction"}}}

function! s:move_line(is_next)"{{{
  if a:is_next
    if line('.') == line('$')
      call s:print_lines(2)
    endif
    normal! j
  else
    if !a:is_next && line('.') == 1
      call s:print_lines(-2)
    endif
    normal! k
  endif
endfunction "}}}
function! s:move_screen(is_next)"{{{
  if a:is_next
    if line('.') + 2 * winheight(0) > line('$')
      call s:print_lines(winheight(0))
    endif
    execute "normal! \<C-f>"
  else
    if line('.') < 2 * winheight(0)
      call s:print_lines(-winheight(0))
    endif
    execute "normal! \<C-b>"
  endif
endfunction "}}}
function! s:move_half_screen(is_next)"{{{
  if a:is_next
    if line('.') + winheight(0) > line('$')
      call s:print_lines(winheight(0)/2)
    endif
    execute "normal! \<C-d>"
  else
    if !a:is_next && line('.') < winheight(0)
      call s:print_lines(-winheight(0)/2)
    endif
    execute "normal! \<C-u>"
  endif
endfunction "}}}
function! s:move_by_input_offset(input)"{{{
  " Get current address.
  let [type, address] = s:parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  let rest = max([0, b:bitmapview.vinarise.filesize - address - 1])
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
    let current = b:bitmapview.vinarise.get_percentage(address)
    let percentage = max([0, min([100, current + offset])])
    let address = b:bitmapview.vinarise.get_percentage_address(percentage)
  else
    echo 'Invalid offset.'
    return
  endif
  call s:move_to_input_address(printf("0x%x", address))
endfunction "}}}
function! s:move_to_input_address(input)"{{{
  let address = (a:input == '') ?
        \ input(printf('Please input new address(max 0x%x) : ',
        \     b:bitmapview.vinarise.filesize), '0x') : a:input
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
    let address = b:bitmapview.vinarise.get_percentage_address(percentage)
  endif

  if address !~ '^\d\+$'
    echo 'Invalid address.'
    return
  endif

  if address >= b:bitmapview.vinarise.filesize
    let address = b:bitmapview.vinarise.filesize - 1
  endif

  setlocal modifiable
  let modified_save = &l:modified

  silent % delete _
  call s:print_lines(100, address)

  let &l:modified = modified_save
  setlocal nomodifiable

  " Set cursor.
  call s:set_cursor_address(address)
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
