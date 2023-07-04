let s:cpo_save = &cpo
set cpo&vim

" ======== utils ========
let s:is_win = has('win32') || has('win64')

if s:is_win && &shellslash
    set noshellslash
    let s:base_dir=expand('<sfile>:p:h:h:h')
    set shellslash
else
    let s:base_dir=expand('<sfile>:p:h:h:h')
endif

if s:is_win
    let s:fzfx_bin=s:base_dir.'\bin\'
else
    let s:fzfx_bin=s:base_dir.'/bin/'
endif

let s:TYPE = {'bool': type(0), 'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}

if v:version >= 704
    function! s:function(name)
        return function(a:name)
    endfunction
else
    function! s:function(name)
        " By Ingo Karkat
        return function(substitute(a:name, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_\zefunction$'), ''))
    endfunction
endif

function! s:warn(msg)
    echohl "WarningMsg"
    echomsg "".a:msg
    echohl "None"
endfunction

function! s:trim(s)
    if has('nvim') || v:versionlong >= 8001630
        return trim(a:s)
    else
        return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

" action
let s:default_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

function! s:action_for(key, ...)
    let default = a:0 ? a:1 : ''
    let Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, default)
    return type(Cmd) == s:TYPE.string ? Cmd : default
endfunction

" color
function! s:get_color(attr, ...)
    let gui = has('termguicolors') && &termguicolors
    let fam = gui ? 'gui' : 'cterm'
    let pat = gui ? '^#[a-f0-9]\+' : '^[0-9]\+$'
    for group in a:000
        let code = synIDattr(synIDtrans(hlID(group)), a:attr, fam)
        if code =~? pat
            return code
        endif
    endfor
    return ''
endfunction

let s:ansi = {'black': 30, 'red': 31, 'green': 32, 'yellow': 33, 'blue': 34, 'magenta': 35, 'cyan': 36}

function! s:csi(color, fg)
    let prefix = a:fg ? '38;' : '48;'
    if a:color[0] == '#'
        return prefix.'2;'.join(map([a:color[1:2], a:color[3:4], a:color[5:6]], 'str2nr(v:val, 16)'), ';')
    endif
    return prefix.'5;'.a:color
endfunction

function! s:ansi(str, group, default, ...)
    let fg = s:get_color('fg', a:group)
    let bg = s:get_color('bg', a:group)
    let color = (empty(fg) ? s:ansi[a:default] : s:csi(fg, 1)) .
                \ (empty(bg) ? '' : ';'.s:csi(bg, 0))
    return printf("\x1b[%s%sm%s\x1b[m", color, a:0 ? ';1' : '', a:str)
endfunction

" note: s:magenta is here
for s:color_name in keys(s:ansi)
    execute "function! s:".s:color_name."(str, ...)\n"
                \ "  return s:ansi(a:str, get(a:, 1, ''), '".s:color_name."')\n"
                \ "endfunction"
endfor

" ======== defaults ========
let s:default_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit'
            \ }

" `rg --column --line-number --no-heading --color=always --smart-case`
let s:grep_command=get(g:, 'fzfx_grep_command', "rg --column -n --no-heading --color=always -S -g '!*.git/'")
let s:unrestricted_grep_command=get(g:, 'fzfx_unrestricted_grep_command', 'rg --column -n --no-heading --color=always -S -uu')

" `fd --color=never --type f --type symlink --follow --exclude .git
" --ignore-case`
if executable('fd')
    let s:find_command=get(g:, 'fzfx_find_command', 'fd -cnever -tf -tl -L -i -E .git')
    let s:unrestricted_find_command=get(g:, 'fzfx_unrestricted_find_command', 'fd -cnever -tf -tl -L -i -u')
elseif executable('fdfind')
    let s:find_command=get(g:, 'fzfx_find_command', 'fdfind -cnever -tf -tl -L -i -E .git')
    let s:unrestricted_find_command=get(g:, 'fzfx_unrestricted_find_command', 'fdfind -cnever -tf -tl -L -i -u')
endif

" `git branch -a --color`
let s:git_branch_command=get(g:, 'fzfx_git_branch_command', 'git branch -a --color')

" ======== providers ========
let s:live_grep_provider=s:fzfx_bin.'live_grep_provider'
let s:unrestricted_live_grep_provider=s:fzfx_bin.'unrestricted_live_grep_provider'
let s:grep_word_provider=s:grep_command
let s:unrestricted_grep_word_provider=s:unrestricted_grep_command
let s:files_provider=s:find_command
let s:unrestricted_files_provider=s:unrestricted_find_command
let s:git_branches_provider=s:git_branch_command

" ======== previewers ========
let s:git_branches_previewer=s:fzfx_bin.'git_branches_previewer'

" ======== implementations ========

" visual
function! s:visual_lines(mode)
    " if a:mode==?"v"
    "     let [line_start, column_start] = getpos("v")[1:2]
    "     let [line_end, column_end] = getpos(".")[1:2]
    "     echo "char/line-wise, line_start:".line_start.",column_start:".column_start.",line_end:".line_end.",column_end:".column_end
    " else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
        " echo "block-wise, line_start:".line_start.",column_start:".column_start.",line_end:".line_end.",column_end:".column_end
    " endif
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] = [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    if a:mode==#"v" || a:mode==#"\<C-V>"
        " for char/block-wise visual, trim first line head and last line tail.
        let lines[-1] = lines[-1][: column_end - (&selection==?'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start - 1:]
        " echo "char/block-wise, mode:".a:mode
    elseif a:mode==#"V"
        " for line-wise visual, and if there's only 1 line, trim the whole
        " line. for other cases, don't do anything.
        if len(lines) == 1
            let lines[0]=s:trim(lines[0])
        endif
        " echo "line-wise, mode:".a:mode
    endif
    return join(lines, "\n")
endfunction

function! fzfx#vim#_visual_select()
    let query=''
    let mode=visualmode()
    if mode==?"v" || mode==?"\<C-V>"
        let query=s:visual_lines(mode)
    endif
    return query
endfunction

" live grep
function! fzfx#vim#live_grep(query, fullscreen, opts)
    let fuzzy_search_header=':: Press '.s:magenta('CTRL-F', 'Special').' to fzf mode'
    let regex_search_header=':: Press '.s:magenta('CTRL-R', 'Special').' to rg mode'
    let provider= a:opts.unrestricted ? s:unrestricted_live_grep_provider : s:live_grep_provider
    " echo "query:".a:query.",provider:".provider.",fullscreen:".a:fullscreen
    let command_fmt = provider.' %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    if s:is_win
        let reload_command = printf('sleep 0.1 && '.command_fmt, '{q}')
    else
        let reload_command = printf('sleep 0.1;'.command_fmt, '{q}')
    endif
    let spec = {'options': [
                \ '--disabled',
                \ '--query', a:query,
                \ '--bind', 'ctrl-f:unbind(change,ctrl-f)+change-prompt(Rg> )+enable-search+change-header('.regex_search_header.')+rebind(ctrl-r)',
                \ '--bind', 'ctrl-r:unbind(ctrl-r)+change-prompt(*Rg> )+disable-search+change-header('.fuzzy_search_header.')+reload('.reload_command.')+rebind(change,ctrl-f)',
                \ '--bind', 'change:reload:'.reload_command,
                \ '--header', fuzzy_search_header,
                \ '--prompt', '*Rg> '
                \ ]}
    let spec = fzf#vim#with_preview(spec)
    call fzf#vim#grep(initial_command, spec, a:fullscreen)
endfunction

" deprecated
function! fzfx#vim#unrestricted_live_grep(query, fullscreen)
    call s:warn("'FzfxUnrestrictedLiveGrep' is deprecated, use 'FzfxLiveGrepU'!")
    call fzfx#vim#live_grep(a:query, a:fullscreen, {'unrestricted': 1})
endfunction
" deprecated
function! fzfx#vim#live_grep_visual(fullscreen)
    call s:warn("'FzfxLiveGrepVisual' is deprecated, use 'FzfxLiveGrepV'!")
    let query=fzfx#vim#_visual_select()
    call fzfx#vim#live_grep(query, a:fullscreen, {'unrestricted': 0})
endfunction

" deprecated
function! fzfx#vim#unrestricted_live_grep_visual(fullscreen)
    call s:warn("'FzfxUnrestrictedLiveGrepVisual' is deprecated, use 'FzfxLiveGrepUV'!")
    let query=fzfx#vim#_visual_select()
    call fzfx#vim#live_grep(query, a:fullscreen, {'unrestricted': 1})
endfunction

" deprecated
function! fzfx#vim#grep_word(fullscreen)
    call s:warn("'FzfxGrepWord' is deprecated, use 'FzfxLiveGrepW'!")
    call fzfx#vim#live_grep(expand('<cword>'), a:fullscreen, {'unrestricted': 0})
endfunction

" deprecated
function! fzfx#vim#unrestricted_grep_word(fullscreen)
    call s:warn("'FzfxUnrestrictedGrepWord' is deprecated, use 'FzfxLiveGrepUW'!")
    call fzfx#vim#live_grep(expand('<cword>'), a:fullscreen, {'unrestricted': 1})
endfunction

" files
function! fzfx#vim#files(query, fullscreen, opts)
    let provider = a:opts.unrestricted ? s:unrestricted_files_provider : s:files_provider
    let initial_command = provider.' || true'
    " echo "a:query:".a:query.",initial_command:".initial_command
    let spec = { 'source': initial_command,
                \ 'options': [
                \   '--query', a:query,
                \ ]}
    let spec = fzf#vim#with_preview(spec)
    call fzf#vim#files('', spec, a:fullscreen)
endfunction

" deprecated
function! fzfx#vim#unrestricted_files(query, fullscreen)
    call s:warn("'FzfxUnrestrictedFiles' is deprecated, use 'FzfxFilesU'!")
    call fzfx#vim#files(a:query, a:fullscreen, {'unrestricted':1})
endfunction

" buffers
function! s:find_open_window(b)
    let [tcur, tcnt] = [tabpagenr() - 1, tabpagenr('$')]
    for toff in range(0, tabpagenr('$') - 1)
        let t = (tcur + toff) % tcnt + 1
        let buffers = tabpagebuflist(t)
        for w in range(1, len(buffers))
            let b = buffers[w - 1]
            if b == a:b
                return [t, w]
            endif
        endfor
    endfor
    return [0, 0]
endfunction

function! s:jump(t, w)
    execute a:t.'tabnext'
    execute a:w.'wincmd w'
endfunction

function! s:buffers_sink(lines, query, fullscreen)
    if len(a:lines) < 3
        " echo "lines0:".string(a:lines)
        return
    endif
    let b = matchstr(a:lines[2], '\[\zs[0-9]*\ze\]')
    let bufname=split(a:lines[2])[-1]
    let action = a:lines[1]
    " echo "lines0.5:".string(a:lines).",b:".b."(".string(bufname).")"
    if empty(action)
        " echo "lines1:".string(a:lines).",bdelete:".b."(".bufname.")"
        let [t, w] = s:find_open_window(b)
        if t
            call s:jump(t, w)
            return
        endif
        execute 'buffer' b
        echo "Switch to '".bufname."'"
        return
    endif
    if action==?'ctrl-d'
        execute 'bdelete' b
        " echo "lines2:".string(a:lines).",bdelete:".b."(".bufname.")"
        echo "Close '".bufname."'"
        call fzfx#vim#buffers(a:query, a:fullscreen)
    else
        let cmd = s:action_for(action)
        " echo "lines3:".string(a:lines).",cmd:".string(cmd).",b:".b."(".string(bufname).")"
        if !empty(cmd)
            execute 'silent' cmd
        endif
        execute 'buffer' b
    endif
endfunction

function! fzfx#vim#buffers(query, fullscreen)
    let close_buffer_header=':: Press '.s:magenta('CTRL-D', 'Special').' to close buffer'
    let spec = { 'sink*': {lines -> s:buffers_sink(lines, a:query, a:fullscreen)},
                \ 'options': [
                \   '--header', close_buffer_header,
                \   '--prompt', 'Buffer> '
                \ ],
                \ 'placeholder': '{1}'
                \ }
    let spec._action = get(g:, 'fzf_action', s:default_action)
    call add(spec.options, '--expect=ctrl-d,'.join(keys(spec._action), ','))
    call fzf#vim#buffers(a:query, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

" branches
function! fzfx#vim#branches(query, fullscreen)
    let git_branch_header=':: Press '.s:magenta('ENTER', 'Special').' to switch branch'
    if len(a:query) > 0
        let command_fmt = s:git_branches_provider.' --list %s'
        let initial_command = printf(command_fmt, shellescape(a:query))
    else
        let initial_command = s:git_branches_provider
    endif

    let spec = {
                \ 'source': initial_command,
                \ 'options': [
                \   '--no-multi',
                \   '--delimiter=:',
                \   '--bind', 'ctrl-l:toggle-preview',
                \   '--preview-window', 'right,50%',
                \   '--prompt', 'Branches> ',
                \   '--preview', s:git_branches_previewer.' {}',
                \   '--header', git_branch_header,
                \ ]}

    " spec sink
    let spec._action = get(g:, 'fzf_action', s:default_action)
    call add(spec.options, '--expect=enter,double-click,'.join(keys(spec._action), ','))
    function! spec.sinklist(lines) abort
        " echo "lines:".string(a:lines)
        let action=a:lines[1]
        if action==?'enter' || action==?'double-click'
            let branch=s:trim(a:lines[2])
            if len(branch) > 0 && branch[0:1]==?'*'
                let branch=branch[1:]
            endif
            let arrow_pos=stridx(branch, '->')
            if arrow_pos > 0
                let branch=s:trim(branch[arrow_pos+2:])
            endif
            execute '!git checkout '.branch
        endif
    endfunction
    let spec['sink*'] = spec.sinklist

    call fzf#run(fzf#wrap('branches', spec, a:fullscreen))
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
