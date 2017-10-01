"=============================================================================
" FILE: view.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vinarise#view#print_error(string) abort
  echohl Error | echo a:string | echohl None
endfunction
function! vinarise#view#print_lines(lines, ...) abort
  " Get last address.
  if a:0 >= 1
    let address = a:1
  else
    let address = vinarise#helper#parse_address(
          \ (a:lines < 0 ? getline(1) : getline('$')), '')[1]
  endif

  let line_address = address / b:vinarise.width

  if a:lines < 0
    let max_lines = line_address + a:lines
    if max_lines < 0
      let max_lines = 0
    endif
    let line_numbers = range(max_lines, line_address-1)
  else
    let max_lines = b:vinarise.filesize / b:vinarise.width

    if max_lines > line_address + a:lines
      let max_lines = line_address + a:lines
    endif
    if max_lines - line_address < winheight(0)
          \ && line('$') == 1
      let line_address = max_lines - winheight(0) + 1
    endif
    if line_address < 0
      let line_address = 0
    endif
    let line_numbers = range(line_address, max_lines)
  endif

  let lines = []
  for line_nr in line_numbers
    call add(lines, vinarise#view#make_line(line_nr))
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
function! vinarise#view#make_line(line_address) abort
  " Make new line.
  let bytes = b:vinarise.get_bytes(
        \ a:line_address * b:vinarise.width, b:vinarise.width)

  let ascii_line =
        \ vinarise#multibyte#make_ascii_line(a:line_address, bytes)

  let hex_line = ''
  for offset in range(0, b:vinarise.width - 1)
    let hex_line .= offset >= len(bytes) ?
          \ '   ' : printf('%02x', bytes[offset]) . ' '
  endfor

  return printf('%07x0: %-48s|%s',
        \ a:line_address, hex_line, ascii_line)
endfunction

function! vinarise#view#set_cursor_address(address) abort
  let line_address = (a:address / b:vinarise.width) * b:vinarise.width
  let hex_line = repeat(' \x\x', a:address - line_address + 1)
  let [lnum, col] = searchpos(
        \ printf('%08x:%s', line_address, hex_line), 'cew')
  call cursor(lnum, col-1)
endfunction
