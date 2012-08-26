"=============================================================================
" FILE: vinarise_analysis.vim
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

" Variables  "{{{
"}}}

" Actions "{{{
" }}}

function! unite#sources#vinarise_analysis#define() "{{{
  return s:source
endfunction "}}}

let s:analyzers = {}
let s:source = {
      \ 'name': 'vinarise/analysis',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'default_action' : 'jump',
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  if &filetype !=# 'vinarise'
    return
  endif

  if empty(s:analyzers)
    call s:init_analyzers()
  endif

  let a:context.source__analyzer_name = get(a:args, 0, '')
  let a:context.source__vinarise = vinarise#get_current_vinarise()

  if a:context.source__analyzer_name == ''
    " Detect analyzer.
    for analyzer in keys(s:analyzers)
      if s:call_analyzer(analyzer, 'detect',
            \ a:context.source__vinarise, a:context)
        let a:context.source__analyzer_name = analyzer
        break
      endif
    endfor
  endif

  if a:context.source__analyzer_name != ''
    call s:call_analyzer(
          \ a:context.source__analyzer_name, 'initialize',
          \ a:context.source__vinarise, a:context)
  endif
endfunction"}}}

function! s:source.gather_candidates(args, context) "{{{
  if !has_key(a:context, 'source__vinarise')
    call unite#print_message(
          \ '[vinarise/analysis] not in vinarise buffer.')
    return []
  endif

  if empty(a:context.source__analyzer_name)
    call unite#print_message(
          \ '[vinarise/analysis] empty analyzer.')
    return []
  endif

  call unite#print_message('[vinarise/analysis] analyzer : '
        \ . a:context.source__analyzer_name)

  let candidates = s:initialize_candidates(s:call_analyzer(
        \ a:context.source__analyzer_name, 'parse',
        \ a:context.source__vinarise, a:context), 0)

  return candidates
endfunction "}}}

" Actions"{{{
let s:source.action_table.jump = {
      \ 'description' : 'jump to the structure item',
      \ }
function! s:source.action_table.jump.func(candidate)"{{{
  if !has_key(a:candidate, 'action__address')
        \ || &filetype !=# 'vinarise'
    return
  endif

  call vinarise#mappings#move_to_address(a:candidate.action__address)
endfunction"}}}

let s:source.action_table.edit = {
      \ 'description' : 'edit the structure item',
      \ 'is_invalidate_cache' : 1,
      \ }
function! s:source.action_table.edit.func(candidate)"{{{
  if !has_key(a:candidate, 'action__address')
        \ || !has_key(a:candidate, 'action__size')
        \ || !has_key(a:candidate, 'action__value')
        \ || !has_key(a:candidate, 'action__type')
        \ || &filetype !=# 'vinarise'
    call unite#print_error('Cannot edit this candidate.')
    return
  endif

  let old_value = a:candidate.action__value
  let value = input('Please input new value: '.
        \ printf('%x', old_value) . ' -> ')
  redraw
  if value == ''
    return
  elseif value !~ '^\x\x\?$'
    echo 'Invalid value.'
    return
  endif
"   let value = str2nr(value, 16)
" 
"   call b:vinarise.set_byte(address, value)
endfunction"}}}
"}}}

function! s:initialize_candidates(list, level)"{{{
  let candidates = []
  for item in a:list
    let dict = (type(item) == type('')) ?
          \ {'name' : item} : item

    if has_key(dict, 'type')
      let dict.name = dict.type.' '.dict.name
    endif
    let dict.name = repeat(' ', a:level*8) . dict.name

    let candidate = {
          \ 'word' : dict.name,
          \}
    if has_key(dict, 'address')
      let candidate.action__address = dict.address
    endif
    if has_key(dict, 'size')
      let candidate.action__size = dict.size
    endif
    if has_key(dict, 'raw_value')
      let candidate.action__value = dict.raw_value
    endif
    if has_key(dict, 'raw_type')
      let candidate.action__type = dict.raw_type
    endif

    if type(get(dict, 'value', '')) == type([])
      call add(candidates, candidate)

      let candidates += s:initialize_candidates(
            \ dict.value, a:level + 1)
    else
      let abbr = has_key(dict, 'value') ?
            \        dict.name.' : '.dict.value : dict.name
      let candidate.abbr = abbr

      call add(candidates, candidate)
    endif

    unlet item
  endfor

  return candidates
endfunction"}}}

function! s:call_analyzer(analyzer_name, function, vinarise, context)"{{{
  let analyzer = s:analyzers[a:analyzer_name]
  if has_key(analyzer, a:function)
    return call(analyzer[a:function], [a:vinarise, a:context], analyzer)
  endif

  return 0
endfunction"}}}

function! unite#sources#vinarise_analysis#add_analyzers(analyzer)"{{{
  let s:analyzers[a:analyzer.name] = a:analyzer
endfunction"}}}

" vim: foldmethod=marker
