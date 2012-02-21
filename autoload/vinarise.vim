"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 21 Feb 2012.
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
" Version: 0.3, for Vim 7.0
"=============================================================================

" Check vimproc."{{{
try
  let s:exists_vimproc_version = vimproc#version()
catch
  echoerr 'Please install vimproc Ver.4.1 or above.'
  finish
endtry
if s:exists_vimproc_version < 401
  echoerr 'Please install vimproc Ver.4.1 or above.'
  finish
endif"}}}
" Check Python."{{{
if !has('python')
  echoerr 'Vinarise requires python interface.'
  finish
endif
"}}}

" Constants"{{{
let s:FALSE = 0
let s:TRUE = !s:FALSE

if vinarise#util#is_windows()
  let s:vinarise_BUFFER_NAME = '[vinarise]'
else
  let s:vinarise_BUFFER_NAME = '*vinarise*'
endif

let s:loaded_vinarise = 0
let s:plugin_path = escape(expand('<sfile>:p:h'), '\')

let g:vinarise_var_prefix = 'vinarise_'
"}}}
" Variables  "{{{
let s:vinarise_dicts = []

let s:vinarise_options = [
      \ '-split', '-split-command',
      \ '-winwidth=', '-winheight=',
      \ '-overwrite'
      \]
"}}}

function! vinarise#get_options()"{{{
  return copy(s:vinarise_options)
endfunction"}}}
function! vinarise#print_error(string)"{{{
  echohl Error | echo a:string | echohl None
endfunction"}}}
function! vinarise#open(filename, context)"{{{
  let filename = a:filename
  if filename == ''
    let filename = bufname('%')
    if &l:buftype =~ 'nofile'
      call vinarise#print_error(
            \ 'Nofile buffer is detected. This operation is invalid.')
      return
    elseif &l:modified
      call vinarise#print_error(
            \ 'Modified buffer is detected! This operation is invalid.')
      return
    endif
  endif

  if !filereadable(filename)
    call vinarise#print_error(
          \ 'File "'.filename.'" is not found.')
    return
  endif

  let filesize = getfsize(filename)
  if vinarise#util#is_windows() && filesize == 0
    call vinarise#print_error(
          \ 'File "'.filename.'" is empty. vinarise cannot open empty file in Windows.')
    return
  endif

  if !s:loaded_vinarise
    execute 'pyfile' s:plugin_path.'/vinarise/vinarise.py'
    let s:loaded_vinarise = 1
  endif

  " try
    execute 'python' g:vinarise_var_prefix.' = VinariseBuffer()'
    execute 'python' g:vinarise_var_prefix.
          \ ".open(vim.eval('iconv(filename, &encoding, &termencoding)'),".
          \ "vim.eval('vinarise#util#is_windows()'))"
  " catch
    " call vinarise#print_error(v:exception)
    " call vinarise#print_error(v:throwpoint)
    " call vinarise#print_error('file : "' . filename . '" Its filesize may be too large.')
    " return
  " endtry

  let context = s:initialize_context(a:context)

  if context.split
    execute context.split_command
  endif

  if !context.overwrite
    edit `=s:vinarise_BUFFER_NAME . ' - ' . filename`
  endif

  setlocal modifiable

  silent % delete _
  call s:initialize_vinarise_buffer(filename, filesize)

  " Print lines.
  call s:initialize_lines()

  call vinarise#set_cursor_address(0)

  setlocal nomodifiable
  setlocal nomodified
endfunction"}}}
function! vinarise#print_lines(lines, ...)"{{{
  " Get last address.
  if a:0 >= 1
    let address = a:1
  else
    let [type, address] = vinarise#parse_address(
          \ (a:lines < 0 ? getline(1) : getline('$')), '')
  endif

  let line_address = address / 16

  if a:lines < 0
    let max_lines = line_address + a:lines
    if max_lines < 0
      let max_lines = 0
    endif
    let line_numbers = range(max_lines, line_address-1)
  else
    let max_lines = b:vinarise.filesize/16 + 1

    if max_lines > line_address + a:lines
      let max_lines = line_address + a:lines
    endif
    if max_lines - line_address < winheight(0)
          \ && line('$') < winheight(0)
      let line_address = max_lines - winheight(0) + 1
    endif
    let line_numbers = range(line_address, max_lines)
  endif

  let lines = []
  for line_nr in line_numbers
    call add(lines, vinarise#make_line(line_nr))
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
function! vinarise#make_line(line_address)"{{{
  " Make new lines.
  let hex_line = ''
  let ascii_line = ''

  for address in range(a:line_address * 16, a:line_address * 16+15)
    if address >= b:vinarise.filesize
      let hex_line .= '   '
      let ascii_line .= ' '
    else
      let num = b:vinarise.get_byte(address)
      let char = nr2char(num)

      let hex_line .= printf('%02x', num) . ' '
      let ascii_line .= num < 32 || num > 127 ? '.' : char
    endif
  endfor

  return printf('%07x0: %-48s |  %s  ',
        \ a:line_address, hex_line, ascii_line)
endfunction"}}}
function! vinarise#parse_address(string, cur_text)"{{{
  " Get last address.
  let base_address = matchstr(a:string, '\x\+\ze0').'0'

  " Default.
  let type = 'address'
  let address = str2nr(base_address, 16)

  if a:cur_text =~ '^\s*\x\+\s*:[[:xdigit:][:space:]]\+\S$'
    " Check hex line.
    let offset = len(split(matchstr(a:cur_text,
          \ '^\s*\x\+\s*:\zs[[:xdigit:][:space:]]\+$'))) - 1
    if 0 <= offset && offset < 16
      let type = 'hex'
      let address += offset
    endif
  elseif a:cur_text =~ '|  \zs.*$'
    let offset = len(matchstr(a:cur_text, '|  \zs.*$')) - 1
    if 0 <= offset && offset < 16
      let type = 'ascii'
      let address += offset
    endif
  endif

  return [type, address]
endfunction"}}}
function! vinarise#get_cur_text(string, col)"{{{
  return matchstr(a:string, '^.*\%' . a:col . 'c.')
endfunction"}}}
function! vinarise#release_buffer(bufnr)"{{{
  " Close previous variable.
  let vinarise = getbufvar(a:bufnr, 'vinarise')
  call vinarise.close()
endfunction"}}}
function! vinarise#write_buffer(filename)"{{{
  " Write current buffer.
  let filename = a:filename
  if getbufvar(bufnr(a:filename), '&filetype') ==# 'vinarise'
    " Use vinarise original path.
    let filename = getbufvar(bufnr(a:filename), 'vinarise').filename
  endif

  call b:vinarise.write(filename)

  setlocal nomodified
  echo printf('"%s" %d bytes', filename, b:vinarise.filesize)
endfunction"}}}
function! vinarise#set_cursor_address(address)"{{{
  let line_address = a:address / 16
  let hex_line = repeat(' \x\x', (a:address%16)+1)
  let [lnum, col] = searchpos(
        \ printf('%07x0:%s', line_address, hex_line), 'cew')
  call cursor(lnum, col-1)
endfunction"}}}

" Misc.
function! s:initialize_vinarise_buffer(filename, filesize)"{{{
  if exists('b:vinarise')
    call vinarise#release_buffer(bufnr('%'))
  endif

  execute 'python' g:vinarise_var_prefix.bufnr('%').
        \ ' = '.g:vinarise_var_prefix

  let b:vinarise = {
   \  'filename' : a:filename,
   \  'python' : g:vinarise_var_prefix.bufnr('%'),
   \  'filesize' : a:filesize,
   \  'last_search_string' : '',
   \  'last_search_type' : 'binary',
   \ }

  " Wrapper functions.
  function! b:vinarise.open(filename)"{{{
    execute 'python' self.python.
          \ ".open(vim.eval('iconv(a:filename, &encoding, &termencoding)'),".
          \ "vim.eval('vinarise#util#is_windows()'))"
  endfunction"}}}
  function! b:vinarise.close()"{{{
    execute 'python' self.python.'.close()'
  endfunction"}}}
  function! b:vinarise.write(path)"{{{
    execute 'python' self.python.'.write('
          \ "vim.eval('a:path'))"
  endfunction"}}}
  function! b:vinarise.get_byte(address)"{{{
    execute 'python' 'vim.command("let num = " + str('.
          \ self.python .'.get_byte(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.set_byte(address, value)"{{{
    execute 'python' self.python .
          \ '.set_byte(vim.eval("a:address"), vim.eval("a:value"))'
  endfunction"}}}
  function! b:vinarise.get_percentage(address)"{{{
    execute 'python' 'vim.command("let percentage = " + str('.
          \ b:vinarise.python .'.get_percentage(vim.eval("a:address"))))'
    return percentage
  endfunction"}}}
  function! b:vinarise.get_percentage_address(percentage)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ b:vinarise.python .
          \ ".get_percentage_address(vim.eval('a:percentage'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find(address, str)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ b:vinarise.python .
          \ ".find(vim.eval('a:address'), vim.eval('a:str'))))"
    return address
  endfunction"}}}
  function! b:vinarise.rfind(address, str)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ b:vinarise.python .
          \ ".rfind(vim.eval('a:address'), vim.eval('a:str'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find_regexp(address, str)"{{{
    try
      execute 'python' 'vim.command("let address = " + str('.
            \ b:vinarise.python .
            \ ".find_regexp(vim.eval('a:address'), vim.eval('a:str'))))"
    catch
      call vinarise#print_error('Invalid regexp pattern!')
      return -1
    endtry

    return address
  endfunction"}}}

  " Basic settings.
  setlocal nolist
  setlocal buftype=acwrite
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal foldcolumn=0

  " Autocommands.
  augroup plugin-vinarise
    autocmd CursorMoved <buffer> call s:match_ascii()
    autocmd BufDelete <buffer> call vinarise#release_buffer(expand('<abuf>'))
    autocmd BufWriteCmd <buffer> call vinarise#write_buffer(expand('<afile>'))
  augroup END

  call vinarise#mappings#define_default_mappings()

  " User's initialization.
  setfiletype vinarise
endfunction"}}}
function! s:initialize_lines()"{{{
  call vinarise#print_lines(winheight(0))
endfunction"}}}
function! s:match_ascii()"{{{
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  if type != 'hex'
    match
    return
  endif

  let offset = address % 16

  execute 'match' g:vinarise_cursor_ascii_highlight.
        \ ' /\%'.line('.').'l\%'.(63+offset).'c/'
endfunction"}}}

function! s:initialize_context(context)"{{{
  let default_context = {
        \ 'winwidth' : 0,
        \ 'winheight' : 0,
        \ 'split' : 0,
        \ 'split_command' : 'split',
        \ 'overwrite' : 0,
        \ }
  let context = extend(default_context, a:context)

  if &l:modified && !&l:hidden
    " Split automatically.
    let context.split = 1
  endif

  return context
endfunction"}}}

" vim: foldmethod=marker
