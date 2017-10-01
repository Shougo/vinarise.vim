"=============================================================================
" FILE: parser.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vinarise#parser#parse_one_line(line, vinarise, offset, ...) abort
  let is_little = get(a:000, 0, 1)
  let matchlist = matchlist(a:line, '^\s*\(\S\+\)\s\+\(\S\+\)\s*;\s*$')
  if len(matchlist) < 3
    throw printf('[vinarise] Parse error in "%s"', a:line)
  endif

  let [type, name] = matchlist[1:2]

  let offset = a:offset
  let value = { 'name' : name, 'address' : a:offset, 'type' : type }
  if type ==# 'uint8_t'
    let value.value = a:vinarise.get_int8(offset)
    let value.size = 1
    let value.raw_type = 'number'
  elseif type ==# 'uint16_t'
    let value.value = a:vinarise.get_int16(offset, is_little)
    let value.size = 2
    let value.raw_type = 'number'
  elseif type ==# 'uint32_t'
    let value.value = a:vinarise.get_int32(offset, is_little)
    let value.size = 4
    let value.raw_type = 'number'
  else
    throw printf('[vinarise] Not supported type : "%s" in "%s"',
          \ type, a:line)
  endif
  let value.raw_value = value.value
  let offset += value.size

  return [value, offset]
endfunction
