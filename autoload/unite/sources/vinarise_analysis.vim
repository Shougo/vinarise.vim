"=============================================================================
" FILE: vinarise_analysis.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" Last Modified: 15 Aug 2012.
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

  let candidates = s:call_analyzer(
        \ a:context.source__analyzer_name, 'parse',
        \ a:context.source__vinarise, a:context)

  return []
endfunction "}}}

function! s:call_analyzer(analyzer_name, function, vinarise, context)
  let analyzer = s:analyzers[a:analyzer_name]
  if has_key(analyzer, a:function)
    return call(analyzer[a:function], [a:vinarise, a:context], analyzer)
  endif

  return 0
endfunction

function! unite#sources#vinarise_analysis#add_analyzers(analyzer)"{{{
  let s:analyzers[a:analyzer.name] = a:analyzer
endfunction"}}}

" vim: foldmethod=marker
