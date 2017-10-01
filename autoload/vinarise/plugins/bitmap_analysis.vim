"=============================================================================
" FILE: bitmap_analysis.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vinarise#plugins#bitmap_analysis#define() abort
  return s:plugin
endfunction

let s:plugin = {
      \ 'name' : 'bitmap_analysis',
      \ 'description' : 'bitmap analyzer',
      \}

function! s:plugin.initialize(vinarise, context) abort
  call unite#sources#vinarise_analysis#add_analyzers(s:analyzer)
endfunction
function! s:plugin.finalize(vinarise, context) abort
endfunction

let s:analyzer = {
      \ 'name' : 'bitmap',
      \ 'description' : 'bitmap analyzer',
      \}

function! s:analyzer.detect(vinarise, context) abort
  return a:vinarise.get_bytes(0, 2) == [0x42, 0x4d]
endfunction

function! s:analyzer.parse(vinarise, context) abort
  let candidates = []
  let offset = 0

  let file_header = { 'name' : 'BITMAPFILEHEADER', 'value' : []}

  let value = {
        \ 'name' : 'bfType', 'value' : '"BM"',
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ }
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfSize', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfReserved1', 'value' : a:vinarise.get_int16_le(offset),
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfReserved2', 'value' : a:vinarise.get_int16_le(offset),
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(file_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'bfOffBits', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(file_header.value, value)
  let offset += value.size

  call add(candidates, file_header)

  let bisize = a:vinarise.get_int32_le(offset)

  if bisize == 40
    let [candidates, offset] = s:analyze_info_header(
          \ a:vinarise, candidates, offset)
  endif

  return candidates
endfunction

function! s:analyze_info_header(vinarise, candidates, offset) abort
  " BITMAPINFOHEADER
  let offset = a:offset
  let info_header = { 'name' : 'BITMAPINFOHEADER', 'value' : []}

  let value = {
        \ 'name' : 'biSize', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biWidth', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biHeight', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biPlains', 'value' : a:vinarise.get_int16_le(offset),
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biBitCount', 'value' : a:vinarise.get_int16_le(offset),
        \ 'size' : 2, 'type' : 'unsigned short', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biCompression', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biSizeImage', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biXPixPerMeter', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biYPixPerMeter', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biClrUsed', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  let value = {
        \ 'name' : 'biClrImportant', 'value' : a:vinarise.get_int32_le(offset),
        \ 'size' : 4, 'type' : 'unsigned long', 'address' : offset,
        \ 'raw_type' : 'number',
        \ }
  let value.raw_value = value.value
  call add(info_header.value, value)
  let offset += value.size

  call add(a:candidates, info_header)

  return [a:candidates, offset]
endfunction
