"=============================================================================
" FILE: init.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

" Check Python. "{{{
if has('python3')
  let s:python = 'python3'
  let s:pyfile = 'py3file'
elseif has('python')
  let s:python = 'python'
  let s:pyfile = 'pyfile'
else
  echoerr 'Vinarise requires python interface.'
  finish
endif
"}}}

" Constants "{{{
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
let s:manager = vinarise#util#get_vital().import('Vim.Buffer')

let s:vinarise_dicts = []

let s:current_vinarise = {}
let s:use_current_vinarise = 0
let s:vinarise_plugins = {}
"}}}

function! vinarise#init#start(filename, context) abort "{{{
  if empty(s:vinarise_plugins)
    call s:load_plugins()
  endif

  let filename = vinarise#util#expand(a:filename)
  let encoding = getbufvar(filename, '&fileencoding')
  if encoding != '' && get(a:context, 'encoding', '') == ''
        \ && encoding =~? vinarise#multibyte#get_supported_encoding_pattern()
    let a:context.encoding = encoding
  endif

  let context = s:initialize_context(a:context)

  if empty(context.bytes)
    if filename == ''
      let filename = expand('%:p')
      if &l:buftype =~ 'nofile'
        call vinarise#view#print_error(
              \ '[vinarise] Nofile buffer is detected. This operation is invalid.')
        return
      elseif &l:modified
        call vinarise#view#print_error(
              \ '[vinarise] Modified buffer is detected! This operation is invalid.')
        return
      endif
    endif

    if !filereadable(filename)
      call vinarise#view#print_error(
            \ '[vinarise] File "'.filename.'" is not found.')
      return
    endif

    let filesize = getfsize(filename)
    if filesize == 0
      call vinarise#view#print_error(
            \ '[vinarise] File "'.filename.'" is empty. '.
            \ 'vinarise cannot open empty file.')
      return
    endif
  else
    let filesize = len(context.bytes)
  endif

  if context.encoding !~?
        \ vinarise#multibyte#get_supported_encoding_pattern()
    call vinarise#view#print_error(
          \ '[vinarise] encoding type: "'.context.encoding.'" is not supported.')
    return
  endif

  if !s:loaded_vinarise
    execute s:pyfile s:plugin_path.'/vinarise.py'
    let s:loaded_vinarise = 1
  endif

  execute s:python g:vinarise_var_prefix.' = VinariseBuffer()'

  " try
    if empty(context.bytes)
      execute s:python g:vinarise_var_prefix.
            \ ".open(vim.eval('vinarise#util#iconv(filename, &encoding, \"char\")'))"
    else
      execute s:python g:vinarise_var_prefix.
            \ ".open_bytes(vim.eval('len(context.bytes)'))"

      " Set values.
      let address = 0
      for byte in context.bytes
        execute s:python g:vinarise_var_prefix.
              \ '.set_byte(vim.eval("address"), vim.eval("byte"))'
        let address += 1
      endfor
    endif
  " catch
    " call vinarise#view#print_error(v:exception)
    " call vinarise#view#print_error(v:throwpoint)
    " call vinarise#view#print_error('file : "' . filename . '" Its filesize may be too large.')
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
    let loaded = s:manager.open(bufname, 'silent edit')
    if !loaded
      call vinarise#view#print_error(
            \ '[vinarise] Failed to open Buffer.')
      return
    endif
  endif

  call s:initialize_vinarise_buffer(context, filename, filesize)

  let s:current_vinarise = b:vinarise

  if context.position =~ '^\d\+$'
    call vinarise#mappings#move_to_address(context.position)
  else
    call vinarise#mappings#move_by_input_address(context.position)
  endif

  setlocal nomodified

  if filename != '' && !empty(context.bytes)
    " Write data.
    call vinarise#write_buffer(filename)
  endif
endfunction"}}}
function! vinarise#init#get_plugins() abort "{{{
  return s:vinarise_plugins
endfunction"}}}

" Misc.
function! s:load_plugins() abort "{{{
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
function! s:initialize_vinarise_buffer(context, filename, filesize) abort "{{{
  if exists('b:vinarise')
    call vinarise#release_buffer(bufnr('%'))
  endif

  execute s:python g:vinarise_var_prefix.bufnr('%').
        \ ' = '.g:vinarise_var_prefix

  let b:vinarise = {
   \  'context' : a:context,
   \  'filename' : a:filename,
   \  'current_dir' : vinarise#util#substitute_path_separator(
   \            fnamemodify(a:filename, ':h')),
   \  'python' : g:vinarise_var_prefix.bufnr('%'),
   \  'filesize' : a:filesize,
   \  'last_search_string' : '',
   \  'last_search_type' : 'binary',
   \  'width' : 16,
   \  'bufnr' : bufnr('%'),
   \  'bufname' : bufname('%'),
   \  'plugins' : s:vinarise_plugins,
   \ }

  " Wrapper functions.
  function! b:vinarise.open(filename) abort "{{{
    execute s:python self.python.
          \ ".open(vim.eval('vinarise#util#iconv(filename, &encoding, \"char\")'))"
  endfunction"}}}
  function! b:vinarise.open_bytes(bytes) abort "{{{
    execute s:python self.python.
          \ ".open(vim.eval('len(a:bytes)'))"
    let address = 0
    for byte in a:bytes
      call self.set_byte(address, byte)
      let address += 1
    endfor
  endfunction"}}}
  function! b:vinarise.close() abort "{{{
    execute s:python self.python.'.close()'
  endfunction"}}}
  function! b:vinarise.write(path) abort "{{{
    execute s:python self.python.'.write('
          \ "vim.eval('a:path'))"
  endfunction"}}}
  function! b:vinarise.get_byte(address) abort "{{{
    execute s:python 'vim.command("let num = " + str('.
          \ self.python .'.get_byte(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_bytes(address, count) abort "{{{
    execute s:python 'vim.command("let bytes = " + str('.
          \ self.python .".get_bytes(vim.eval('a:address'), vim.eval('a:count'))))"
    return bytes
  endfunction"}}}
  function! b:vinarise.get_int8(address) abort "{{{
    execute s:python 'vim.command("let num = " + str('.
          \ self.python .'.get_int8(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int16(address, is_little_endian) abort "{{{
    return a:is_little_endian ?
          \ self.get_int16_le(a:address) : self.get_int16_be(a:address)
  endfunction"}}}
  function! b:vinarise.get_int16_le(address) abort "{{{
    execute s:python 'vim.command("let num = " + str('.
          \ self.python .'.get_int16_le(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int16_be(address) abort "{{{
    execute s:python 'vim.command("let num = " + str('.
          \ self.python .'.get_int16_be(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int32(address, is_little_endian) abort "{{{
    return a:is_little_endian ?
          \ self.get_int32_le(a:address) : self.get_int32_be(a:address)
  endfunction"}}}
  function! b:vinarise.get_int32_le(address) abort "{{{
    execute s:python 'vim.command("let num = " + str('.
          \ self.python .'.get_int32_le(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_int32_be(address) abort "{{{
    execute s:python 'vim.command("let num = " + str('.
          \ self.python .'.get_int32_be(vim.eval("a:address"))))'
    return num
  endfunction"}}}
  function! b:vinarise.get_chars(address, count, from, to) abort "{{{
    execute s:python 'vim.command("let chars = ''" + str('.
          \ self.python .".get_chars(vim.eval('a:address'),"
          \ ."vim.eval('a:count'), vim.eval('a:from'),"
          \ ."vim.eval('a:to'))) + \"'\")"
    return chars
  endfunction"}}}
  function! b:vinarise.set_byte(address, value) abort "{{{
    execute s:python self.python .
          \ '.set_byte(vim.eval("a:address"), vim.eval("a:value"))'
  endfunction"}}}
  function! b:vinarise.get_percentage(address) abort "{{{
    execute s:python 'vim.command("let percentage = " + str('.
          \ self.python .'.get_percentage(vim.eval("a:address"))))'
    return percentage
  endfunction"}}}
  function! b:vinarise.get_percentage_address(percentage) abort "{{{
    execute s:python 'vim.command("let address = " + str('.
          \ self.python .
          \ ".get_percentage_address(vim.eval('a:percentage'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find(address, str, from, to) abort "{{{
    execute s:python 'vim.command("let address = " + str('.
          \ self.python .
          \ ".find(vim.eval('a:address'), vim.eval('a:str'),"
          \ ."vim.eval('a:from'),"
          \ ."vim.eval('a:to'))))"
    return address
  endfunction"}}}
  function! b:vinarise.rfind(address, str, from, to) abort "{{{
    execute s:python 'vim.command("let address = " + str('.
          \ self.python .
          \ ".rfind(vim.eval('a:address'), vim.eval('a:str'),"
          \ ."vim.eval('a:from'),"
          \ ."vim.eval('a:to'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find_regexp(address, str, from, to) abort "{{{
    try
      execute s:python 'vim.command("let address = " + str('.
            \ self.python .
            \ ".find_regexp(vim.eval('a:address'), vim.eval('a:str'),"
            \ ."vim.eval('a:from'),"
            \ ."vim.eval('a:to'))))"
    catch
      call vinarise#view#print_error('Invalid regexp pattern!')
      return -1
    endtry

    return address
  endfunction"}}}
  function! b:vinarise.find_binary(address, binary) abort "{{{
    execute s:python 'vim.command("let address = " + str('.
          \ self.python .
          \ ".find_binary(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}
  function! b:vinarise.rfind_binary(address, binary) abort "{{{
    execute s:python 'vim.command("let address = " + str('.
          \ self.python .
          \ ".rfind_binary(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}
  function! b:vinarise.find_binary_not(address, binary) abort "{{{
    execute s:python 'vim.command("let address = " + str('.
          \ self.python .
          \ ".find_binary_not(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}
  function! b:vinarise.rfind_binary_not(address, binary) abort "{{{
    execute s:python 'vim.command("let address = " + str('.
          \ self.python .
          \ ".rfind_binary_not(vim.eval('a:address'), vim.eval('a:binary'))))"
    return address
  endfunction"}}}
  function! b:vinarise.insert_bytes(address, bytes) abort "{{{
    execute s:python self.python .
          \ '.insert_bytes(vim.eval("a:address"), vim.eval("a:bytes"))'
  endfunction"}}}
  function! b:vinarise.delete_byte(address) abort "{{{
    execute s:python self.python .
          \ '.delete_byte(vim.eval("a:address"))'
  endfunction"}}}

  " Basic settings.
  setlocal nolist
  setlocal buftype=acwrite
  setlocal noswapfile
  setlocal nomodifiable
  setlocal nofoldenable
  setlocal hidden
  setlocal foldcolumn=0
  setlocal nonumber
  setlocal nobuflisted
  if has('conceal')
    setlocal conceallevel=3
    setlocal concealcursor=n
  endif
  if exists('+cursorcolumn')
    setlocal nocursorcolumn
  endif
  if exists('+colorcolumn')
    setlocal colorcolumn=0
  endif
  if exists('+relativenumber')
    setlocal norelativenumber
  endif

  " Autocommands.
  augroup plugin-vinarise
    autocmd BufLeave,BufWinLeave <buffer>
          \ match
    autocmd CursorMoved <buffer>
          \ call vinarise#handlers#match_ascii()
    autocmd BufWriteCmd <buffer>
          \ call vinarise#handlers#write_buffer(expand('<afile>'))
  augroup END

  call vinarise#mappings#define_default_mappings()

  " User's initialization.
  setfiletype vinarise

  " Plugins initialization.
  for plugin in values(b:vinarise.plugins)
    if has_key(plugin, 'initialize')
      call plugin.initialize(b:vinarise, b:vinarise.context)
    endif
  endfor
endfunction"}}}

function! s:initialize_context(context) abort "{{{
  let default_context = {
        \ 'winwidth' : 0,
        \ 'winheight' : 0,
        \ 'split' : 0,
        \ 'split_command' : 'split',
        \ 'overwrite' : 0,
        \ 'encoding' : (&encoding =~?
        \   vinarise#multibyte#get_supported_encoding_pattern()) ?
        \     &encoding : 'latin1',
        \ 'position' : 0,
        \ 'bytes' : [],
        \ }
  let context = extend(default_context, a:context)

  if &l:modified && !&l:hidden
    " Split automatically.
    let context.split = 1
  endif

  return context
endfunction"}}}
function! s:get_postfix(prefix, is_create) abort "{{{
  let buffers = get(a:000, 0, range(1, bufnr('$')))
  let buflist = vinarise#util#sort_by(filter(map(buffers,
        \ 'bufname(v:val)'), 'stridx(v:val, a:prefix) >= 0'),
        \ "str2nr(matchstr(v:val, '\\d\\+$'))")
  if empty(buflist)
    return ''
  endif

  let num = matchstr(buflist[-1], '@\zs\d\+$')
  return num == '' && !a:is_create ? '' :
        \ '@' . (a:is_create ? (num + 1) : num)
endfunction"}}}
