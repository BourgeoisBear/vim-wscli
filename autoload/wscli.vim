" vim-wscli - Vim interface to wscli websocket client
" Vim license. See ':help license'
" Copyright 2022 Jason Stewart <support@eggplantsd.com>

function! s:CleanUp()
	unlet t:wscli_buf
	unlet t:wscli_job
	unlet t:wscli_chan
endfunction

function! s:IsOpen()
	return exists('t:wscli_buf') && (term_getstatus(t:wscli_buf) =~? 'running')
endfunction

function! wscli#SendVisual()
	let a_send = s:get_visual_selection()
	silent! normal! gv
	call wscli#Send(a_send)
endfunction

function! wscli#SendParagraph()
	let a_prev = @a
	silent! normal! {"ay}
	let a_send = @a
	let @a = a_prev
	call wscli#Send(a_send)
endfunction

function! wscli#Send(text)
	" NOTE: do this after grabbing the text, since
	"       Toggle() can open a new buffer and change
	"       the focus (i.e. grabbing wrong text).
	if !s:IsOpen()
		call wscli#Toggle()
	endif
	call ch_sendraw(t:wscli_chan, a:text . "\n")
endfunction

function! wscli#Toggle()

	" TODO: find/install command

	if s:IsOpen()
		call term_setkill(t:wscli_buf, 'kill')
		silent! execute 'bd!' . t:wscli_buf
		call s:CleanUp()
		return
	endif

	let job_opts = {
				\ 'cwd': expand('$HOME/Projects/wscli'),
				\ 'in_io': 'pipe',
				\ 'term_rows': 14,
				\ 'norestore': 1,
				\ 'term_finish': 'close',
				\ }

	let t:wscli_buf = term_start(['go', 'run', '.'], job_opts)
	let t:wscli_job = term_getjob(t:wscli_buf)
	let t:wscli_chan = job_getchannel(t:wscli_job)

	" NOTE: string(chan) == 'channel fail' is error
	if string(t:wscli_chan) == 'channel fail'
		echoerr 'JOB CHANNEL FAILURE'
		call s:CleanUp()
		return
	endif

	" preserve focus
	wincmd p

endfunction

function! s:get_visual_selection()
	let [line_start, column_start] = getpos("'<")[1:2]
	let [line_end, column_end] = getpos("'>")[1:2]
	let lines = getline(line_start, line_end)
	if len(lines) == 0
		return ''
	endif
	let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][column_start - 1:]
	return join(lines, "\n")
endfunction
