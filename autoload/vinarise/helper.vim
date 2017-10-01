"=============================================================================
" FILE: helper.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vinarise#helper#parse_address(string, cur_text) abort
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
endfunction
