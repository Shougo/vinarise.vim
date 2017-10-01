"=============================================================================
" FILE: bitmapview.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vinarise#plugins#bitmapview#define() abort
  return s:plugin
endfunction

" Variables
let s:save_gui = []

let s:font_pattern =
      \ vinarise#util#is_windows() ||
      \ vinarise#util#is_mac() || has('nvim') ?  ':h\zs\d\+':
      \ has('gui_gtk') ?       '\s\+\zs\d\+$':
      \ has('X11') ?           '\v%([^-]*-){6}\zs\d+\ze%(-[^-]*){7}':
      \                        '*Unknown system*'

let s:manager = vinarise#util#get_vital().import('Vim.Buffer')

let g:vinarise_guifont = get(g:, 'vinarise_guifont', '')


let s:plugin = {
      \ 'name' : 'bitmapview',
      \ 'description' : 'bitmap view',
      \}

function! s:plugin.initialize(vinarise, context) abort
  command! -bar VinarisePluginBitmapView
        \ call s:bitmapview_open()
endfunction
function! s:plugin.finalize(vinarise, context) abort
endfunction

function! s:bitmapview_open() abort
  let prev_bufnr = bufnr('%')
  let vinarise = vinarise#get_current_vinarise()
  let filesize = vinarise.filesize

  let prefix = vinarise#util#is_windows() ?
        \ '[bitmapview] - ' : '*bitmapview* - '
  let loaded = s:manager.open(vinarise.current_dir . '/' .
        \ prefix . fnamemodify(vinarise.filename, ':t'), 'silent edit')
  if !loaded
    call vinarise#view#print_error(
          \ '[vinarise] Failed to open Buffer.')
    return
  endif

  if !exists(':GuiFont') && !has('gui_running')
    if has('nvim') && !exists(':GuiFont')
      call vinarise#view#print_error('[vinarise] '
            \.'You should install neovim-gui-shim plugin with GUI client.')
    else
      call vinarise#view#print_error('[vinarise] '
            \.'You should not use this feature in Console mode.'
            \.'  It is too slow and may be crash.')
    endif
  endif

  match

  setlocal nolist
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal hidden
  setlocal foldcolumn=0
  setlocal nonumber

  " Autocommands.
  augroup plugin-vinarise
    autocmd BufWinEnter <buffer>
          \ call s:change_windowsize()
    autocmd BufWinLeave,BufUnload <buffer>
          \ call s:restore_windowsize()
  augroup END

  let b:bitmapview = {}
  let b:bitmapview.vinarise = vinarise
  let b:bitmapview.prev_bufnr = prev_bufnr
  let b:bitmapview.filesize = filesize
  let b:bitmapview.offset = 10
  let b:bitmapview.width = (&columns - b:bitmapview.offset) / 2

  call s:change_windowsize()

  call s:define_default_mappings()

  " User's initialization.
  setfiletype vinarise-bitmapview

  call s:print_lines(winheight(0))

  call s:set_cursor_address(0)
endfunction

function! s:define_default_mappings() abort
  " Plugin keymappings
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_to_current_address)
        \ :<C-u>call <SID>move_to_current_address()<CR>
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
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_by_input_address)
        \ :<C-u>call <SID>move_by_input_address('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_by_input_offset)
        \ :<C-u>call <SID>move_by_input_offset('')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_to_first_address)
        \ :<C-u>call <SID>move_by_input_address('0%')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_move_to_last_address)
        \ :<C-u>call <SID>move_by_input_address('100%')<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_next_skip)
        \ :<C-u>call <SID>move_skip(1)<CR>
  nnoremap <buffer><silent> <Plug>(vinarise_bitmapview_prev_skip)
        \ :<C-u>call <SID>move_skip(0)<CR>

  if exists('g:vinarise_no_default_keymappings') &&
        \ g:vinarise_no_default_keymappings
    return
  endif

  " Normal mode key-mappings.
  nmap <buffer> <CR>      <Plug>(vinarise_bitmapview_move_to_current_address)
  nmap <buffer> B         <Plug>(vinarise_bitmapview_move_to_current_address)
  nmap <buffer> q         <Plug>(vinarise_bitmapview_exit)
  nmap <buffer> j         <Plug>(vinarise_bitmapview_next_line)
  nmap <buffer> k         <Plug>(vinarise_bitmapview_prev_line)
  nmap <buffer> <C-f>     <Plug>(vinarise_bitmapview_next_screen)
  nmap <buffer> <C-b>     <Plug>(vinarise_bitmapview_prev_screen)
  nmap <buffer> <C-d>     <Plug>(vinarise_bitmapview_next_half_screen)
  nmap <buffer> <C-u>     <Plug>(vinarise_bitmapview_prev_half_screen)
  nmap <buffer> <C-g>     <Plug>(vinarise_bitmapview_print_current_position)
  nmap <buffer> gG        <Plug>(vinarise_bitmapview_move_by_input_address)
  nmap <buffer> go        <Plug>(vinarise_bitmapview_move_by_input_offset)
  nmap <buffer> gg        <Plug>(vinarise_bitmapview_move_to_first_address)
  nmap <buffer> G         <Plug>(vinarise_bitmapview_move_to_last_address)
  nmap <buffer> w         <Plug>(vinarise_bitmapview_next_skip)
  nmap <buffer> b         <Plug>(vinarise_bitmapview_prev_skip)
endfunction

function! s:parse_address(string, cur_text) abort
  " Get last address.
  let base_address = matchstr(a:string, '^\x\+')

  " Default.
  let type = 'address'
  let address = str2nr(base_address, 16)

  if a:cur_text =~ '^\s*\x\+\s*:.\+$'
    " Check hex line.
    let offset = len(matchstr(a:cur_text, '^\s*\x\+\s*: \zs.\+$')) - 1
    if 0 <= offset && offset < (b:bitmapview.width*2)
      let type = 'bitmap'
      let address += offset / 2
    endif
  endif

  return [type, address]
endfunction

function! s:move_to_address(address) abort
  let address = a:address
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
endfunction
function! s:print_lines(lines, ...) abort
  " Get last address.
  if a:0 >= 1
    let address = a:1
  else
    let address = s:parse_address(
          \ (a:lines < 0 ? getline(1) : getline('$')), '')[1]
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
endfunction
function! s:make_line(line_address) abort
  " Make new lines.
  let line = join(map(b:bitmapview.vinarise.get_bytes(
        \ a:line_address * b:bitmapview.width, b:bitmapview.width),
        \ "printf('%02x', v:val)"), '')
  return printf('%08x: %s', a:line_address * b:bitmapview.width, line)
endfunction
function! s:set_cursor_address(address) abort
  let line_address = (a:address / b:bitmapview.width) * b:bitmapview.width
  let [lnum, col] = searchpos(
        \ printf('%08x: .\{%d}', line_address,
        \    (a:address - line_address + 1) * 2), 'cew')
  call cursor(lnum, col)
endfunction

function! s:change_windowsize() abort
  if (!exists(':GuiFont') && !has('gui_running'))
        \ || !empty(s:save_gui) || !exists('b:bitmapview')
    return
  endif

  if has('nvim')
    let s:save_gui = [&lines, &columns, getwinposx(), getwinposy()]
  else
    let s:save_gui = [&guifont, &guifontwide, &lines, &columns,
          \ getwinposx(), getwinposy()]
  endif
  let fontsize =
        \ b:bitmapview.filesize <    1000 ? 16 :
        \ b:bitmapview.filesize <    4000 ? 8 :
        \ b:bitmapview.filesize <   16000 ? 4 :
        \ b:bitmapview.filesize < 1000000 ? 2 :
        \ 1

  if has('nvim') && exists(':GuiFont')
    execute 'GuiFont' s:change_fontsize(g:vinarise_guifont, fontsize)
  else
    if matchstr(&guifont, s:font_pattern) == ''
      return
    endif

    let &guifont = s:change_fontsize(&guifont, fontsize)
    let &guifontwide = s:change_fontsize(&guifontwide, fontsize)
  endif
  let &lines = 800 / fontsize
  let &columns = 1024 / fontsize + 20
  let b:bitmapview.width = 512 / fontsize
endfunction
function! s:restore_windowsize() abort
  if empty(s:save_gui)
    return
  endif

  if has('nvim')
    let [&lines, &columns, posx, posy] = s:save_gui
    execute 'GuiFont' g:vinarise_guifont
  else
    let [&guifont, &guifontwide, &lines, &columns,
          \ posx, posy] = s:save_gui
  endif
  if posx >= 0 && posy >= 0
    execute 'winpos' posx posy
  endif

  let s:save_gui = []
endfunction
function! s:change_fontsize(font, size) abort
  return join(map(split(a:font, '\\\@<!,'),
        \   printf('substitute(v:val, %s, %s, "g")',
        \   string(s:font_pattern),
        \   string('\=max([1,' . a:size . '])'))), ',')
endfunction

" Mappings.
function! s:exit() abort
  let prev_bufnr = b:bitmapview.prev_bufnr
  call vinarise#util#delete_buffer()
  execute 'buffer' prev_bufnr
endfunction
function! s:print_current_position() abort
  " Get current address.
  let [type, address] = s:parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  let percentage = b:bitmapview.vinarise.get_percentage(address)
  let message = printf('[%s] %8d / %8d (%3d%%)',
          \ type, address, b:bitmapview.vinarise.filesize - 1, percentage)

  if has('gui_running')
    let save_guioptions = &guioptions
    try
      set guioptions-=c
      call confirm(message)
    finally
      let &guioptions = save_guioptions
    endtry
  else
    echo message
  endif
endfunction
function! s:move_to_current_address() abort
  " Get current address.
  let address = s:parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))[1]

  execute 'buffer' b:bitmapview.vinarise.bufnr

  call vinarise#mappings#move_to_address(address)
endfunction

function! s:move_line(is_next) abort
  if a:is_next
    if line('.') == line('$')
      call s:print_lines(2)
    endif
    call cursor(line('.')+1, 0)
  else
    if !a:is_next && line('.') == 1
      call s:print_lines(-2)
    endif
    call cursor(line('.')-1, 0)
  endif
endfunction
function! s:move_screen(is_next) abort
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
endfunction
function! s:move_half_screen(is_next) abort
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
endfunction
function! s:move_by_input_offset(input) abort
  " Get current address.
  let address = s:parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))[1]
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
  call s:move_by_input_address(printf("0x%x", address))
endfunction
function! s:move_by_input_address(input) abort
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
  call s:move_to_address(address)
endfunction
function! s:move_skip(is_next) abort
  let vinarise = b:bitmapview.vinarise

  let address = s:parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))[1]

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

  call s:move_to_address(ret)
endfunction
