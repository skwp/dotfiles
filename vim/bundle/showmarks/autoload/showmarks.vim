" Display marks in the signs column
" Maintainer:	A. Politz <cbyvgmn@su-gevre.qr>
" Last change: 2008-02-06
" v0.1

let s:marks = 'abcdefghijklmnopqrstuvwxyz' .'ABCDEFGHIJKLMNOPQRSTUVWXYZ' .'<>' 
let s:all_marks = split(s:marks . '0123456789(){}''^."','\ze')

"Hlgroup for signs
:highlight default link hlShowMarks Question
"Which buffers have the plugin activated ?
let s:handled_buffers = []
"Prefix for the signname
let s:sign_prefix = 'showmarks-'
"Undef signs, if plugin is inactive
let s:have_signs_defined = 0
"Try to avoid id-conflicts
let s:sign_id_incr = 947380
"ids for top and bottom signs
let s:top_sign_id = s:sign_id_incr - 1
let s:bot_sign_id = s:sign_id_incr - 2


"public interface
func! showmarks#ShowMarks( cmd, ... )
  let to = a:0 ? a:1 : 1
  let to = to >= 0 ? to : 1
  if a:cmd =~ 'once'
    "Disable afterwards regardless of current state
    let force_disable = a:0 > 1 && a:2
    call s:EnableLocalOneTime(to,force_disable)
  elseif a:cmd =~ 'preview'
    :call s:PreviewMarks(to)
  else
    let enable = a:cmd =~ 'enable' 
    let global = a:cmd =~ 'global'
    if enable
      if global
	call s:EnableGlobal()
      else
	call s:EnableLocal()
      endif
    else
      if global
	call s:DisableGlobal()
      else
	call s:DisableLocal()
      endif
    endif
  endif
endfun


func! s:GetWantedMarks()
  if !exists('g:showmarks_marks')
    let g:showmarks_marks=s:marks
    return g:showmarks_marks
  elseif type(g:showmarks_marks) != type('string')
    return s:marks
  else
    return g:showmarks_marks
  endif
endfun


func! s:UpdateSigns( )
  if !exists('b:showmarks')
    "Remeber which id is displayed in which lnum.
    let b:showmarks = {}
    let b:showmarks.topline = 0
    let b:showmarks.botline = 0
  endif
  "Find the first and last nonfolded line in the window.
  let top = line('w0')
  let bot = line('w$')
  while foldclosed(top) >= 0 && top < bot
    let top = foldclosedend(top)+1
  endwhile
  if top >= bot
    let top = 0
    let bot = 0
    let b:showmarks.topline = 0
    let b:showmarks.botline = 0
  else
    for l in range(top+1,bot)
      if foldclosed(l) < 0
	let bot=l
      endif
    endfor
  endif
  "Figure out if the windows top and bottom lines have changed. If
  "not don't bother with updating the top/bot markers. 
  if b:showmarks.topline == top && b:showmarks.botline == bot
    let do_bottop_signs = 0
  else
    let b:showmarks.topline = top
    let b:showmarks.botline = bot
    let do_bottop_signs = 1
  endif

  if do_bottop_signs
    let topsign = { 'lnum' :  1, 'mark' : '' , 'ok' : 1}
    let botsign = { 'lnum' : line('$') , 'mark' : '' , 'ok' : 1}
  endif

  for id in range(len(s:all_marks))
    let mark = s:all_marks[id]
    "At least try! to avoid id-conflicts
    let id += s:sign_id_incr "Some random value
    let [ bnr, lnum ] = getpos("'".mark)[0:1]
    "Sort out file and global marks ( '0-9 'A-Z ) from another
    "buffer
    if bnr && bnr != bufnr('%')
      continue
    endif

    let want_mark = s:GetWantedMarks() =~ '\V'.mark
    if !lnum || !want_mark
      "Mark not set, or don't want it anymore. Remove it from
      "b:showmarks and undisplay the sign
      if has_key(b:showmarks,id)
        call remove(b:showmarks,id)
	silent exec 'sign unplace '.id.' buffer='.bufnr('%')
      endif
    else "if lnum && want_mark
      "Found a valid mark and want it.
      if do_bottop_signs
	"Check for a candidate for the bot and top marks
	if lnum < top && lnum >= topsign.lnum 
	  let topsign.mark = mark
	  let topsign.lnum = lnum
	elseif lnum > bot && lnum <= botsign.lnum 
	  let botsign.mark = mark
	  let botsign.lnum = lnum
	elseif lnum == top
	  "Don't overrule real marks at this position.
	  let topsign.ok = 0
	elseif lnum == bot
	  let botsign.ok = 0
	endif
      endif

      if !has_key(b:showmarks,id)
	let b:showmarks[id]= 0
      endif
      "Show the sign, if it's not already displayed where it
      "belongs.
      if b:showmarks[id] != lnum
	silent! exec 'sign unplace '.id.' buffer='.bufnr('%')
	silent! exec 'sign place '.id.' line='.lnum.' name='.s:sign_prefix.mark.' buffer='.bufnr('%')
	let b:showmarks[id]=lnum
      endif
    endif
  endfor
  if do_bottop_signs
    "Unplace,undef,def and place the top and bottom signs, if necessary.
    silent! exec 'sign unplace '.s:top_sign_id.' buffer='.bufnr('%')
    silent! exec 'sign undefine '.s:sign_prefix.'topline'
    if topsign.ok && !empty(topsign.mark)
      silent  exec 'sign define '.s:sign_prefix.'topsign text=/'.(topsign.mark).' texthl=hlShowMarks'
      silent  exec  'sign place '.s:top_sign_id.' line='.top.' name='.s:sign_prefix.'topsign buffer='.bufnr('%')
    endif

    silent! exec 'sign unplace '.s:bot_sign_id.' buffer='.bufnr('%')
    silent! exec 'sign undefine '.s:sign_prefix.'botline'
    if botsign.ok && !empty(botsign.mark)
      silent  exec 'sign define '.s:sign_prefix.'botsign text=\'.(botsign.mark).' texthl=hlShowMarks'
      silent  exec  'sign place '.s:bot_sign_id.' line='.bot.' name='.s:sign_prefix.'botsign buffer='.bufnr('%')
    endif
  endif
endfun

func! s:PreviewMarks( ... ) " autoclose
  if !exists('s:preview_tmp')
    let s:preview_tmp = tempname()
  endif

  let curbuf_marks = []
  let foreign_marks = []
  for mark in s:all_marks
    if s:GetWantedMarks() !~ '\V'.mark
      continue
    endif
    let [ bnr, lnum ] = getpos("'".mark)[0:1]
    if !lnum 
      continue
    endif
    if !bnr || bnr == bufnr('%')
      let line = ' '.mark.' '
      let line .= printf('%'.strlen(line('$')).'d',lnum).' '
      let line .= getline(lnum)
      call add(curbuf_marks,{ 'mark' : mark, 'line' : line, 'lnum' : lnum })
    else
      let line = ' '.mark.' '
      let line .= repeat(' ',strlen(line('$'))-1).'> '
      let line .= bufname(bnr)
      call add(foreign_marks,line)
    endif
  endfor

  if !empty(curbuf_marks) || !empty(foreign_marks)
    if a:0 && a:1
      let s:showmarks_pvw_timeout = a:1
      "autoclose
      augroup showmarks-PreviewMarks
	au! 
	au CursorHold * let s:showmarks_pvw_timeout-=1 | if s:showmarks_pvw_timeout<=0| wincmd z | exec 'au! showmarks-PreviewMarks' | unlet s:showmarks_pvw_timeout | endif
      augroup END
    endif

    let syntax=&syntax
    silent! exec 'ped '.s:preview_tmp
    wincmd P
    if &previewwindow
      silent %d _
      "Better than no color at all ?
      exec 'set syntax='.syntax
      
      setl nobuflisted buftype=nofile nonu nofoldenable nowrap
      setl noscrollbind stl=[Preview]ShowMarks nodiff
      silent exec ':resize '.min([ &lines/2 , len(curbuf_marks)+len(foreign_marks) ])
      call sort(curbuf_marks,'s:ComparePVWLines')
      call setline(1,map(curbuf_marks,'v:val.line'))
      call setline(line('$')+1,foreign_marks)
      call matchadd('hlShowMarks','^\s\zs.')
      call matchadd('LineNr','^\s.\s*\zs\d\+')
      call matchadd('Special','^\s*\S\s*\zs>\s*.*')
      wincmd p
    else
      echohl Error | echo "Can't open the previewwindow (ShowMarks) !" | echohl None
    endif
  endif
endfun

func! s:EnableLocal()
  "echo 'EL in' string(s:handled_buffers)
  if index(s:handled_buffers,bufnr('%')) < 0
    call add(s:handled_buffers,bufnr('%'))
    if !s:have_signs_defined
      call s:DefSigns()
      let s:have_signs_defined = 1
    endif
    augroup showmarks
      au CursorHold <buffer> :call s:UpdateSigns()
    augroup END
  endif
  call s:UpdateSigns()
  "echo 'EL out' string(s:handled_buffers)
endfun

"Enable the plugin locally for the duration of timeout CursorHold
"events. Disable it, if it was not active or if force is 1.
func! s:EnableLocalOneTime( timeout, force )
  let idx = index(s:handled_buffers,bufnr('%'))
  call s:EnableLocal()
  if a:force || idx < 0
    let b:showmarks.timeout = a:timeout
    augroup showmarks
      au CursorHold <buffer> let b:showmarks.timeout-=1 | if b:showmarks.timeout<=0 | exec 'silent! au! showmarks CursorHold <buffer>'|call s:DisableLocal() | endif
    augroup END
  endif
endfun


func! s:DisableLocal()
  "echo 'DL in' string(s:handled_buffers)
  let idx = index(s:handled_buffers,bufnr('%'))
  if idx >= 0
    silent! au! showmarks CursorHold <buffer>
    for id in filter(range(s:sign_id_incr,s:sign_id_incr+len(s:all_marks)-1),'has_key(b:showmarks,v:val)')
      silent exec 'sign unplace '.id.' buffer='.bufnr('%')
    endfor
    silent! exec 'sign unplace '.s:bot_sign_id.' buffer='.bufnr('%')
    silent! exec 'sign unplace '.s:top_sign_id.' buffer='.bufnr('%')
    call remove(s:handled_buffers,idx)
    unlet! b:showmarks
   "if empty(s:handled_buffers)
   "  call s:DelSigns()
   "  let s:have_signs_defined = 0
   "endif
  endif
  "echo 'DL out' string(s:handled_buffers)
endfun

func! s:EnableGlobal()

  silent! au! showmarks-DisableGlobal
  augroup showmarks-EnableGlobal
    au!
    au BufRead,BufNewFile * :call s:EnableLocal()
    for b in range(1,bufnr('$'))
      if index(tabpagebuflist(),b) < 0 && buflisted(b)
	exec 'au BufEnter <buffer='.b.'> :call s:EnableLocal()|au! showmarks-EnableGlobal BufEnter <buffer='.b.'>'
      endif
    endfor
  augroup END

  let win = winnr()
  silent windo call s:EnableLocal()
  exec win.'wincmd w'
endfun

func! s:DisableGlobal()

  silent! au! showmarks-EnableGlobal
  augroup showmarks-DisableGlobal
    au!
    for b in range(1,bufnr('$'))
      if index(tabpagebuflist(),b) < 0 && buflisted(b)
	exec 'au BufEnter <buffer='.b.'> :call s:DisableLocal()|au! showmarks-DisableGlobal BufEnter <buffer='.b.'>'
      endif
    endfor
  augroup END

  let win = winnr()
  silent windo call s:DisableLocal()
  exec win.'wincmd w'
endfun


func! s:ComparePVWLines( i1, i2 )
 "if a:i1.mark =~ '[A-Z0-9]' &&  a:i2.mark !~ '[A-Z0-9]'
 "  return 1
 "elseif a:i1.mark !~ '[A-Z0-9]' &&  a:i2.mark =~ '[A-Z0-9]'
 "  return -1
 "endif
  return a:i1.lnum < a:i2.lnum ? -1 : a:i1.lnum > a:i2.lnum
endfun


func! s:DefSigns()
  for m in s:all_marks
    exec 'sign define '.s:sign_prefix.m.' text='.m.' texthl=hlShowMarks'
  endfor
endfun

func! s:DelSigns()
  for m in s:all_marks
    exec 'sign undefine '.s:sign_prefix.m
  endfor
  silent! exec 'sign undefine '.s:sign_prefix.'topline'
  silent! exec 'sign undefine '.s:sign_prefix.'botline'
endfun

finish
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <f5> :DoShowMarks<cr>
map <f6> :NoShowMarks<cr>
map <f7> :DoShowMarks!<cr>
map <f8> :NoShowMarks!<cr>
