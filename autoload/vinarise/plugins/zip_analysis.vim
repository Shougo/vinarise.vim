"=============================================================================
" FILE: zip_analysis.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" Last Modified: 26 Aug 2012.
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

function! vinarise#plugins#zip_analysis#define()
  return s:plugin
endfunction

" Variables  "{{{
"}}}

let s:plugin = {
      \ 'name' : 'zip_analysis',
      \ 'description' : 'zip analyzer',
      \}

function! s:plugin.initialize(vinarise, context) "{{{
  call unite#sources#vinarise_analysis#add_analyzers(s:analyzer)
endfunction"}}}
function! s:plugin.finalize(vinarise, context) "{{{
endfunction"}}}

let s:analyzer = {
      \ 'name' : 'zip',
      \ 'description' : 'zip analyzer',
      \}

function! s:analyzer.detect(vinarise, context) "{{{
  return a:vinarise.get_bytes(0, 2) == [0x50, 0x4b]
endfunction"}}}

function! s:analyzer.parse(vinarise, context) "{{{
  let candidates = []
  let offset = 0

  while 1
    let signature = a:vinarise.get_bytes(offset, 4)

    if signature == [0x50, 0x4b, 0x03, 0x04]
      " ZIP_HEADER
      let [candidates, offset] = s:analyze_zip_header(
            \ a:vinarise, candidates, offset)
    elseif signature == [0x50, 0x4b, 0x07, 0x08]
      " ZIP_HEADER(PK78)
      let [candidates, offset] = s:analyze_zip_header2(
            \ a:vinarise, candidates, offset)
    elseif signature == [0x50, 0x4b, 0x01, 0x02]
      " ZIP_CENTRAL_HEADER
      let [candidates, offset] = s:analyze_zip_central_header(
            \ a:vinarise, candidates, offset)
    elseif signature == [0x50, 0x4b, 0x05, 0x06]
      " ZIP_END_HEADER
      let [candidates, offset] = s:analyze_zip_end_header(
            \ a:vinarise, candidates, offset)
    else
      " UNKNOWN
      break
    endif
  endwhile

  return candidates
endfunction"}}}

function! s:analyze_zip_header(vinarise, candidates, offset) "{{{
  " ZIP_HEADER
  let offset = a:offset
  let header = { 'name' : 'ZIP_HEADER', 'value' : []}

  " uint8_t signature[4];
  for i in range(0, 3)
    let value = {
          \ 'name' : 'signature', 'value' : a:vinarise.get_int8(offset),
          \ 'size' : 1, 'type' : printf('uint8_t[%d]', i), 'address' : offset,
          \ 'raw_type' : 'number',
          \ }
    let value.raw_value = value.value
    call add(header.value, value)
    let offset += value.size
  endfor

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t version;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t flags;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t compression;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t dos_time;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t dos_date;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t crc32;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t compressed_size;',
        \ a:vinarise, offset)
  call add(header.value, value)
  let filesize = value.raw_value

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t uncompressed_size;',
        \ a:vinarise, offset)
  call add(header.value, value)
  let filesize += value.raw_value

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t file_name_length;',
        \ a:vinarise, offset)
  call add(header.value, value)
  let filename_offset = value.raw_value

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t extra_field_length;',
        \ a:vinarise, offset)
  call add(header.value, value)
  let data_offset = filesize + value.raw_value

  " filename
  call add(header.value, {
        \ 'name' : 'filename', 'value' :
        \      a:vinarise.get_chars(offset, filename_offset,
        \           &encoding, &encoding),
        \ 'size' : filename_offset,
        \ 'type' : 'string', 'address' : offset,
        \ })
  let offset += filename_offset

  " data
  call add(header.value, {
        \ 'name' : 'data', 'value' : '?',
        \ 'type' : 'string', 'address' : offset,
        \ })

  let offset += data_offset

  " Skip until PK78.
  while filesize == 0
    let signature = a:vinarise.get_bytes(offset, 4)

    if len(signature) != 4 || signature ==
        \ [0x50, 0x4b, 0x07, 0x08]
      break
    endif

    let offset += 1
  endwhile

  call add(a:candidates, header)

  return [a:candidates, offset]
endfunction"}}}

function! s:analyze_zip_header2(vinarise, candidates, offset) "{{{
  " ZIP_HEADER
  let offset = a:offset
  let header = { 'name' : 'ZIP_HEADER(PK78)', 'value' : []}

  " uint8_t signature[4];
  for i in range(0, 3)
    let value = {
          \ 'name' : 'signature', 'value' : a:vinarise.get_int8(offset),
          \ 'size' : 1, 'type' : printf('uint8_t[%d]', i), 'address' : offset,
          \ 'raw_type' : 'number',
          \ }
    let value.raw_value = value.value
    call add(header.value, value)
    let offset += value.size
  endfor

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t crc32;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t compressed_size;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t uncompressed_size;',
        \ a:vinarise, offset)
  call add(header.value, value)

  call add(a:candidates, header)

  return [a:candidates, offset]
endfunction"}}}

function! s:analyze_zip_central_header(vinarise, candidates, offset) "{{{
  " ZIP_CENTRAL_HEADER
  let offset = a:offset
  let header = { 'name' : 'ZIP_CENTRAL_HEADER', 'value' : []}

  " uint8_t signature[4];
  for i in range(0, 3)
    let value = {
          \ 'name' : 'signature', 'value' : a:vinarise.get_int8(offset),
          \ 'size' : 1, 'type' : printf('uint8_t[%d]', i), 'address' : offset,
          \ 'raw_type' : 'number',
          \ }
    let value.raw_value = value.value
    call add(header.value, value)
    let offset += value.size
  endfor

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t version_made;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t version;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t flags;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t compression;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t dos_time;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t dos_date;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t crc32;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t compressed_size;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t uncompressed_size;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t file_name_length;',
        \ a:vinarise, offset)
  call add(header.value, value)
  let filename_offset = value.raw_value

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t extra_field_length;',
        \ a:vinarise, offset)
  call add(header.value, value)
  let extra_size = value.raw_value

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t file_comment_length;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t disk_number_start;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t internal_file_attributes;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t external_file_attributes;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t position;',
        \ a:vinarise, offset)
  call add(header.value, value)

  " filename
  call add(header.value, {
        \ 'name' : 'filename', 'value' :
        \      a:vinarise.get_chars(offset, filename_offset,
        \           &encoding, &encoding),
        \ 'size' : filename_offset,
        \ 'type' : 'string', 'address' : offset,
        \ })
  let offset += filename_offset

  " extra field.
  call add(header.value, {
        \ 'name' : 'extra field', 'value' : '?',
        \ 'type' : 'string', 'address' : offset,
        \ })
  let offset += extra_size

  call add(header.value, value)

  call add(a:candidates, header)
  return [a:candidates, offset]
endfunction"}}}

function! s:analyze_zip_end_header(vinarise, candidates, offset) "{{{
  " ZIP_END_HEADER
  let offset = a:offset
  let header = { 'name' : 'ZIP_END_HEADER', 'value' : []}

  " uint8_t signature[4];
  for i in range(0, 3)
    let value = {
          \ 'name' : 'signature', 'value' : a:vinarise.get_int8(offset),
          \ 'size' : 1, 'type' : printf('uint8_t[%d]', i), 'address' : offset,
          \ 'raw_type' : 'number',
          \ }
    let value.raw_value = value.value
    call add(header.value, value)
    let offset += value.size
  endfor

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t number_of_disks;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t disk_number_start;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t number_of_disk_entries;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t number_of_entries;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t central_dir_size;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint32_t central_dir_offset;',
        \ a:vinarise, offset)
  call add(header.value, value)

  let [value, offset] = vinarise#parser#parse_one_line(
        \ 'uint16_t file_comment_length;',
        \ a:vinarise, offset)
  call add(header.value, value)

  call add(a:candidates, header)

  return [a:candidates, offset]
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
