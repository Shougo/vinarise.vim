"=============================================================================
" FILE: vinarise.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 10 Sep 2012.
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

" Check Python."{{{
if !has('python')
  echoerr 'Vinarise requires python interface.'
  finish
endif
"}}}

let s:save_cpo = &cpo
set cpo&vim

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
let s:V = vital#of('vinarise')
let s:BM = s:V.import('Vim.Buffer.Manager')
let s:manager = s:BM.new()  " creates new manager
call s:manager.config('opener', 'silent edit')

let s:vinarise_dicts = []

let s:vinarise_options = [
      \ '-split', '-split-command',
      \ '-winwidth=', '-winheight=',
      \ '-overwrite', '-encoding='
      \]
let s:current_vinarise = {}
let s:use_current_vinarise = 0
let s:vinarise_plugins = {}
"}}}

function! vinarise#complete(arglead, cmdline, cursorpos)"{{{
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
endfunction"}}}
function! vinarise#complete_encodings(arglead, cmdline, cursorpos)"{{{
  return sort(filter(vinarise#multibyte#get_supported_encoding_list(),
        \ 'stridx(v:val, a:arglead) == 0'))
endfunction"}}}
function! vinarise#get_options()"{{{
  return copy(s:vinarise_options)
endfunction"}}}
function! vinarise#print_error(string)"{{{
  echohl Error | echo a:string | echohl None
endfunction"}}}
function! vinarise#start(filename, context)"{{{
  if empty(s:vinarise_plugins)
    call s:load_plugins()
  endif

  let filename = vinarise#util#expand(a:filename)
  let context = s:initialize_context(a:context)

  if empty(context.bytes)
    if filename == ''
      let filename = bufname('%')
      if &l:buftype =~ 'nofile'
        call vinarise#print_error(
              \ '[vinarise] Nofile buffer is detected. This operation is invalid.')
        return
      elseif &l:modified
        call vinarise#print_error(
              \ '[vinarise] Modified buffer is detected! This operation is invalid.')
        return
      endif
    endif

    if !filereadable(filename)
      call vinarise#print_error(
            \ '[vinarise] File "'.filename.'" is not found.')
      return
    endif

    let filesize = getfsize(filename)
    if filesize == 0
      call vinarise#print_error(
            \ '[vinarise] File "'.filename.'" is empty. '.
            \ 'vinarise cannot open empty file.')
      return
    endif
  else
    let filesize = len(context.bytes)
  endif

  if context.encoding !~?
        \ vinarise#multibyte#get_supported_encoding_pattern()
    call vinarise#print_error(
          \ '[vinarise] encoding type: "'.context.encoding.'" is not supported.')
    return
  endif

  if !s:loaded_vinarise
    execute 'pyfile' s:plugin_path.'/vinarise/vinarise.py'
    let s:loaded_vinarise = 1
  endif

  execute 'python' g:vinarise_var_prefix.' = VinariseBuffer()'

  " try
    if empty(context.bytes)
      execute 'python' g:vinarise_var_prefix.
            \ ".open(vim.eval('vinarise#util#iconv(filename, &encoding, \"char\")'),".
            \ "vim.eval('vinarise#util#is_windows()'))"
    else
      execute 'python' g:vinarise_var_prefix.
            \ ".open_bytes(vim.eval('len(context.bytes)'),".
            \ "vim.eval('vinarise#util#is_windows()'))"

      " Set values.
      let address = 0
      for byte in context.bytes
        execute 'python' g:vinarise_var_prefix.
              \ '.set_byte(vim.eval("address"), vim.eval("byte"))'
        let address += 1
      endfor
    endif
  " catch
    " call vinarise#print_error(v:exception)
    " call vinarise#print_error(v:throwpoint)
    " call vinarise#print_error('file : "' . filename . '" Its filesize may be too large.')
    " return
  " endtry

  if context.split
    execute context.split_command
  endif

  if !context.overwrite
    let prefix = s:vinarise_BUFFER_NAME . ' - ' . filename
    if filename == ''
      let prefix .= 'noname'
    endif
    let bufname = prefix . s:get_postfix(prefix, 1)
    let ret = s:manager.open(bufname)
    if ret.bufnr <= 0
      call vinarise#print_error(
            \ '[vinarise] Failed to open Buffer.')
      return
    endif
  endif

  call s:initialize_vinarise_buffer(context, filename, filesize)

  let s:current_vinarise = b:vinarise

  call vinarise#mappings#move_to_address(0)

  setlocal nomodified

  if filename != '' && !empty(context.bytes)
    " Write data.
    call vinarise#write_buffer(filename)
  endif
endfunction"}}}
function! vinarise#print_lines(lines, ...)"{{{
  " Get last address.
  if a:0 >= 1
    let address = a:1
  else
    let [_, address] = vinarise#parse_address(
          \ (a:lines < 0 ? getline(1) : getline('$')), '')
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
endfunction"}}}
function! vinarise#parse_address(string, cur_text)"{{{
  " Get last address.
  let base_address = matchstr(a:string, '^\x\+')

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
  elseif a:cur_text =~ '\x\+\s\+|.*$'
    let encoding = vinarise#get_current_vinarise().context.encoding
    let chars = matchstr(a:cur_text, '\x\+\s\+|\zs.*\ze.$')
    let offset = (encoding ==# 'latin1') ?
          \ len(chars) - 4 + 1 :
          \ strwidth(chars) - 4 + 1
    if offset < 0
      let offset = 0
    endif

    if offset < b:vinarise.width
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

  " Plugins finalization.
  for plugin in values(s:vinarise_plugins)
    if has_key(plugin, 'finalize')
      call plugin.finalize(vinarise, vinarise.context)
    endif
  endfor

  call vinarise.close()
endfunction"}}}
function! vinarise#write_buffer(filename)"{{{
  let vinarise = vinarise#get_current_vinarise()
  let filename = (a:filename ==# vinarise.bufname) ?
        \ vinarise.filename : a:filename

  if filename == ''
    call vinarise#print_error('filename is needed.')
    return
  endif

  if vinarise.filename == ''
    " Change filename.
    let vinarise.filename = filename
  endif

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
  let line_address = (a:address / b:vinarise.width) * b:vinarise.width
  let hex_line = repeat(' \x\x', a:address - line_address + 1)
  let [lnum, col] = searchpos(
        \ printf('%08x:%s', line_address, hex_line), 'cew')
  call cursor(lnum, col-1)
endfunction"}}}
function! vinarise#get_current_vinarise() "{{{
  return exists('b:vinarise') && !s:use_current_vinarise ?
        \ b:vinarise : s:current_vinarise
endfunction"}}}

" Misc.
function! s:load_plugins()"{{{
  " Load all plugins.
  let s:vinarise_plugins = {}

  for name in map(split(globpath(&runtimepath,
        \ 'autoload/vinarise/plugins/*.vim'), '\n'),
        \      "fnamemodify(v:val, ':t:r')")

    let define = vinarise#plugins#{name}#define()
    for dict in (type(define) == type([]) ? define : [define])
      if !empty(dict) && !has_key(s:vinarise_plugins, dict.name)
        let s:vinarise_plugins[dict.name] = dict
      endif
    endfor
    unlet define
  endfor
endfunction"}}}
function! s:initialize_vinarise_buffer(context, filename, filesize)"{{{
  if exists('b:vinarise')
    call vinarise#release_buffer(bufnr('%'))
  endif

  execute 'python' g:vinarise_var_prefix.bufnr('%').
        \ ' = '.g:vinarise_var_prefix

  let b:vinarise = {
   \  'context' : a:context,
   \  'filename' : a:filename,
   \  'python' : g:vinarise_var_prefix.bufnr('%'),
   \  'filesize' : a:filesize,
   \  'last_search_string' : '',
   \  'last_search_type' : 'binary',
   \  'width' : 16,
   \  'bufnr' : bufnr('%'),
   \  'bufname' : bufname('%'),
   \ }

  " Wrapper functions.
  function! b:vinarise.open(filename)"{{{
    execute 'python' self.python.
          \ ".open(vim.eval('vinarise#util#iconv(filename, &encoding, \"char\")'),".
          \ "vim.eval('vinarise#util#is_windows()'))"
  endfunction"}}}
  function! b:vinarise.open_bytes(bytes)"{{{
    execute 'python' self.python.
          \ ".open(vim.eval('len(a:bytes)'),".
          \ "vim.eval('vinarise#util#is_windows()'))"
    let address = 0
    for byte in a:bytes
      call self.set_byte(address, byte)
      let address += 1
    endfor
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
  function! b:vinarise.get_bytes(address, count)"{{{
    execute 'python' 'vim.command("let bytes = " + str('.
          \ self.python .".get_bytes(vim.eval('a:address'), vim.eval('a:count'))))"
    return bytes
  endfunction"}}}
  function! b:vinarise.get_int8(address)"{{{
    execute 'python' 'vim.command("let num = " + str('.
          \ self.python .'.get_int8(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int16(address, is_little_endian)"{{{
    return a:is_little_endian ?
          \ self.get_int16_le(a:address) : self.get_int16_be(a:address)
  endfunction"}}}
  function! b:vinarise.get_int16_le(address)"{{{
    execute 'python' 'vim.command("let num = " + str('.
          \ self.python .'.get_int16_le(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int16_be(address)"{{{
    execute 'python' 'vim.command("let num = " + str('.
          \ self.python .'.get_int16_be(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int32(address, is_little_endian)"{{{
    return a:is_little_endian ?
          \ self.get_int32_le(a:address) : self.get_int32_be(a:address)
  endfunction"}}}
  function! b:vinarise.get_int32_le(address)"{{{
    execute 'python' 'vim.command("let num = " + str('.
          \ self.python .'.get_int32_le(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int32_be(address)"{{{
    execute 'python' 'vim.command("let num = " + str('.
          \ self.python .'.get_int32_be(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_chars(address, count, from, to)"{{{
    execute 'python' 'vim.command("let chars = ''" + str('.
          \ self.python .".get_chars(vim.eval('a:address'),"
          \ ."vim.eval('a:count'), vim.eval('a:from'),"
          \ ."vim.eval('a:to'))) + \"'\")"
    return chars
  endfunction"}}}
  function! b:vinarise.set_byte(address, value)"{{{
    execute 'python' self.python .
          \ '.set_byte(vim.eval("a:address"), vim.eval("a:value"))'
  endfunction"}}}
  function! b:vinarise.get_percentage(address)"{{{
    execute 'python' 'vim.command("let percentage = " + str('.
          \ self.python .'.get_percentage(vim.eval("a:address"))))'
    return percentage
  endfunction"}}}
  function! b:vinarise.get_percentage_address(percentage)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ self.python .
          \ ".get_percentage_address(vim.eval('a:percentage'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find(address, str, from, to)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ self.python .
          \ ".find(vim.eval('a:address'), vim.eval('a:str'),"
          \ ."vim.eval('a:from'),"
          \ ."vim.eval('a:to'))))"
    return address
  endfunction"}}}
  function! b:vinarise.rfind(address, str, from, to)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ self.python .
          \ ".rfind(vim.eval('a:address'), vim.eval('a:str'),"
          \ ."vim.eval('a:from'),"
          \ ."vim.eval('a:to'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find_regexp(address, str, from, to)"{{{
    try
      execute 'python' 'vim.command("let address = " + str('.
            \ self.python .
            \ ".find_regexp(vim.eval('a:address'), vim.eval('a:str'),"
            \ ."vim.eval('a:from'),"
            \ ."vim.eval('a:to'))))"
    catch
      call vinarise#print_error('Invalid regexp pattern!')
      return -1
    endtry

    return address
  endfunction"}}}
  function! b:vinarise.find_binary(address, binary)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ self.python .
          \ ".find_binary(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}
  function! b:vinarise.rfind_binary(address, binary)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ self.python .
          \ ".rfind_binary(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find_binary_not(address, binary)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ self.python .
          \ ".find_binary_not(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}
  function! b:vinarise.rfind_binary_not(address, binary)"{{{
    execute 'python' 'vim.command("let address = " + str('.
          \ self.python .
          \ ".rfind_binary_not(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}

  " Basic settings.
  setlocal nolist
  setlocal buftype=acwrite
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal hidden
  setlocal foldcolumn=0

  " Autocommands.
  augroup plugin-vinarise
    autocmd BufLeave,BufWinLeave <buffer>
          \ match
    autocmd CursorMoved <buffer>
          \ call s:match_ascii()
    autocmd BufWriteCmd <buffer>
          \ call vinarise#write_buffer(expand('<afile>'))
  augroup END

  command! -buffer -nargs=1 -complete=file VinariseHex2Script
        \ call s:hex2script(<f-args>)

  call vinarise#mappings#define_default_mappings()

  " User's initialization.
  setfiletype vinarise

  " Plugins initialization.
  for plugin in values(s:vinarise_plugins)
    if has_key(plugin, 'initialize')
      call plugin.initialize(b:vinarise, b:vinarise.context)
    endif
  endfor
endfunction"}}}
function! s:match_ascii()"{{{
  let [type, address] = vinarise#parse_address(getline('.'),
        \ vinarise#get_cur_text(getline('.'), col('.')))
  if type != 'hex'
    match
    return
  endif

  let offset = address % b:vinarise.width

  let encoding = vinarise#get_current_vinarise().context.encoding

  if encoding !=# 'latin1'
    let offset = len(vinarise#util#truncate(
          \ matchstr(getline('.'), '\x\+\s\+|\zs.*\ze.$'), offset + 3)) - 3
  endif

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
        \ 'encoding' : 'latin1',
        \ 'bytes' : [],
        \ }
  let context = extend(default_context, a:context)

  if &l:modified && !&l:hidden
    " Split automatically.
    let context.split = 1
  endif

  return context
endfunction"}}}
function! s:get_postfix(prefix, is_create)"{{{
  let buffers = get(a:000, 0, range(1, bufnr('$')))
  let buflist = vimshell#util#sort_by(filter(map(buffers,
        \ 'bufname(v:val)'), 'stridx(v:val, a:prefix) >= 0'),
        \ "str2nr(matchstr(v:val, '\\d\\+$'))")
  if empty(buflist)
    return ''
  endif

  let num = matchstr(buflist[-1], '@\zs\d\+$')
  return num == '' && !a:is_create ? '' :
        \ '@' . (a:is_create ? (num + 1) : num)
endfunction"}}}
function! s:hex2script(filename)"{{{
  if !get(g:, 'loaded_hexript', 0)
    call vinarise#print_error('hexript plugin is needed.')
    return
  endif

  let vinarise = vinarise#get_current_vinarise()

  " Convert hexript data.
  let dict = { 'bytes' : vinarise.get_bytes(0, vinarise.filesize) }
  call hexript#dict_to_file(dict, a:filename)

  " Open file.
  split `=a:filename`
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
