"=============================================================================
" FILE: handlerss.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vinarise#handlers#release_buffer(bufnr) abort
  " Close previous variable.
  let vinarise = getbufvar(a:bufnr, 'vinarise')

  " Plugins finalization.
  for plugin in values(vinarise.plugins)
    if has_key(plugin, 'finalize')
      call plugin.finalize(vinarise, vinarise.context)
    endif
  endfor

  call vinarise.close()
endfunction
function! vinarise#handlers#write_buffer(filename) abort
  let vinarise = vinarise#get_current_vinarise()
  let filename = (a:filename ==# vinarise.bufname) ?
        \ vinarise.filename : a:filename

  if filename == ''
    call vinarise#view#print_error('filename is needed.')
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
endfunction
function! vinarise#handlers#match_ascii() abort
  let [type, address] = vinarise#helper#parse_address(getline('.'),
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
endfunction
