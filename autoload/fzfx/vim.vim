let s:cpo_save = &cpo
set cpo&vim

" ======== infra ========

let s:is_win = has('win32') || has('win64')

if s:is_win && &shellslash
    set noshellslash
    let s:base_dir = expand('<sfile>:p:h:h:h')
    set shellslash
else
    let s:base_dir = expand('<sfile>:p:h:h:h')
endif

if s:is_win
    let s:fzfx_bin = s:base_dir.'\bin\'
else
    let s:fzfx_bin = s:base_dir.'/bin/'
endif

if has('nvim')
    let s:vim='nvim'
else
    let s:vim='vim'
endif

let s:_fzfx_enable_debug = get(g:, '_fzfx_enable_debug', 0)
let $_FZFX_ENABLE_DEBUG = s:_fzfx_enable_debug

function! s:exception(msg)
    throw "[fzfx.vim] Error! ".a:msg
endfunction

function! s:warning(msg)
    echohl WarningMsg
    echomsg "[fzfx.vim] Warning! ".a:msg
    echohl None
endfunction

function! s:message(msg)
    echomsg "[fzfx.vim] ".a:msg
endfunction

function! s:debug(msg)
    if s:_fzfx_enable_debug
        echomsg "[fzfx.vim|debug] ".a:msg
    endif
endfunction

" ======== hack: script local function ========

" this plugin heavily leverage the 'fzf.vim' plugin and its script local
" functions, because I don't have time to fully re-write another fzf.vim and I
" don't think I could do better than the author.
" so hack into fzf.vim autoload script local funciton, and use it as a library
" is the best solution for now.

function! s:get_sid(scriptname)
    let all_scripts = split(execute('scriptnames'), '\n')
    let matched_line = ''
    for line in all_scripts
        " fix the backslash for Windows.
        let normalized_line = substitute(line, "\\", "/", "g")
        if normalized_line =~ a:scriptname
            " first time matching a script.
            if matched_line ==? ''
                let matched_line = normalized_line
            else
                " multiple matches, unexpected.
                call s:warning("Found multiple '".a:scriptname."' files with same name.")
            endif
        endif
    endfor
    " echo "get_sid-1, matched_line:[".matched_line."], scriptname:[".a:scriptname."]"
    if matched_line ==? ''
        return [v:null, v:null]
    endif

    " the matching line looks like:
    " `20: ~/src/ruanyl/vim-gh-line/plugin/vim-gh-line.vim`
    " extract the first number before : and return it as the scriptID
    let matched_splits = split(matched_line)
    if len(matched_splits) != 2
        call s:warning('Failed to parse matched line: '.matched_line)
        return [v:null, v:null]
    endif

    let first_entry = matched_splits[0]
    let scriptpath = matched_splits[1]
    let sid = substitute(first_entry, ':', '', '')
    " echo "get_sid-2, sid:[".sid."], scriptpath:[".scriptpath."]"
    return [sid, scriptpath]
endfunction

" there're two source files in 'fzf.vim' plugin:
"
" 1. fzf.vim/plugin/fzf.vim
" 2. fzf.vim/autoload/fzf/vim.vim
"
" the 1st is always available in 'scriptnames' result (if config correctly),
" but the 2nd is missing in 'scriptnames' (because I'm using lazy.nvim and lazy
" loading fzf.vim), so here we first try to find the 2nd, or fallback to find
" the 1st if 2nd is missing, and build the 2nd path from 1st.
function! s:get_fzf_autoload_sid()
    let [autoload_sid, _1] = s:get_sid("fzf.vim/autoload/fzf/vim.vim")
    " echo "get_fzf_sid-1, autoload_sid:[".autoload_sid."], _1:["._1."]"
    if autoload_sid isnot v:null
        return autoload_sid
    endif

    let [plugin_sid, plugin_path] = s:get_sid("fzf.vim/plugin/fzf.vim")
    " echo "get_fzf_sid-2, plugin_sid:[".plugin_sid."], plugin_path:[".plugin_path."]"
    if plugin_sid is v:null
        call s:exception("Failed to find vimscript 'fzf.vim/plugin/fzf.vim'")
        return v:null
    endif

    " remove the 'plugin/fzf.vim' from the tail, then append 'autoload/fzf/vim.vim'
    let autoload_path = expand(plugin_path[:-15].'autoload/fzf/vim.vim')
    " echo "get_fzf_sid-3, plugin_path:[".plugin_path."], stridx:[".stridx(plugin_path, "\\")."], autoload_path:[".autoload_path."], filereadable:[".filereadable(autoload_path)."]"
    if filereadable(autoload_path)
        execute "source ".autoload_path
    else
        call s:exception("Failed to source vimscript '".autoload_path."'")
        return v:null
    endif

    let [autoload_sid2, _2] = s:get_sid("fzf.vim/autoload/fzf/vim.vim")
    " echo "get_fzf_sid-4, autoload_sid2:[".autoload_sid2."], _2:["._2."]"
    if autoload_sid2 isnot v:null
        return autoload_sid2
    endif

    call s:exception("Failed to find vimscript '".autoload_path."' SID")
    return v:null
endfunction

let s:fzf_autoload_sid = s:get_fzf_autoload_sid()

function! s:get_fzf_autoload_func_ref(sid, name)
    return function('<SNR>'.a:sid.'_'.a:name)
endfunction

" script local functions import from fzf.vim autoload.
let s:action_for_ref = s:get_fzf_autoload_func_ref(s:fzf_autoload_sid, "action_for")
let s:magenta_ref = s:get_fzf_autoload_func_ref(s:fzf_autoload_sid, "magenta")
let s:bufopen_ref = s:get_fzf_autoload_func_ref(s:fzf_autoload_sid, "bufopen")

" ======== defaults ========

" grep/find commands
let s:default_rg_command = "rg --column -n --no-heading --color=always -S"
let s:default_grep_command = "grep -R -n --color=always -s -I"
let s:fzfx_grep_command = get(g:, 'fzfx_grep_command', executable('rg') ? s:default_rg_command : s:default_grep_command." --exclude-dir='*/.*'")
let s:fzfx_unrestricted_grep_command = get(g:, 'fzfx_unrestricted_grep_command', executable('rg') ? s:default_rg_command.' -uu' : s:default_grep_command)

let $_FZFX_GREP_COMMAND = s:fzfx_grep_command
let $_FZFX_UNRESTRICTED_GREP_COMMAND = s:fzfx_unrestricted_grep_command

let s:default_fd_command = 'fd . -cnever -tf -tl -L -i'
let s:default_find_command = 'find . -type f,l'
let s:fzfx_find_command = get(g:, 'fzfx_find_command', executable('fd') ? s:default_fd_command : s:default_find_command." -not -path '*/.*'")
let s:fzfx_unrestricted_find_command = get(g:, 'fzfx_unrestricted_find_command', executable('fd') ? s:default_fd_command.' -u' : s:default_find_command)

" `git branch -a --color`
let s:fzfx_git_branch_command = get(g:, 'fzfx_git_branch_command', 'git branch -a --color')

" key actions

" live grep
let s:fzfx_live_grep_fzf_mode_action = get(g:, 'fzfx_live_grep_fzf_mode_action', 'ctrl-f')
let s:fzfx_live_grep_rg_mode_action = get(g:, 'fzfx_live_grep_rg_mode_action', 'ctrl-r')
" buffers
let s:fzfx_buffers_close_action = get(g:, 'fzfx_buffers_close_action', 'ctrl-d')

let s:default_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit'
            \ }

" cache

let s:fzfx_resume_live_grep_cache = expand(get(g:, 'fzfx_resume_live_grep_cache', '~/.cache/'.s:vim.'/fzfx.vim/resume_live_grep_cache'))
let s:fzfx_resume_live_grep_opts_cache = expand(get(g:, 'fzfx_resume_live_grep_opts_cache', '~/.cache/'.s:vim.'/fzfx.vim/resume_live_grep_opts_cache'))
let s:fzfx_resume_files_cache = expand(get(g:, 'fzfx_resume_files_cache', '~/.cache/'.s:vim.'/fzfx.vim/resume_files_cache'))
let s:fzfx_resume_files_opts_cache = expand(get(g:, 'fzfx_resume_files_opts_cache', '~/.cache/'.s:vim.'/fzfx.vim/resume_files_opts_cache'))

let $_FZFX_RESUME_LIVE_GREP_CACHE = s:fzfx_resume_live_grep_cache
let $_FZFX_RESUME_FILES_CACHE = s:fzfx_resume_files_cache

" ======== utils ========

function! s:trim(s)
    if has('nvim') || v:versionlong >= 8001630
        return trim(a:s)
    else
        return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

function! s:trim_lines(lines)
    if a:lines is v:null
        return v:null
    endif
    if empty(a:lines)
        return []
    endif
    let lines = []
    for l in a:lines
        let tl = s:trim(l)
        if len(tl) > 0
            call add(lines, tl)
        endif
    endfor
    return lines
endfunction

" --expect=...
function! s:expect_keys(...)
    let keys_list = keys(get(g:, 'fzf_action', s:default_action))
    for k in a:000
        let k2 = tolower(s:trim(k))
        if len(k2) > 0
            call add(keys_list, k2)
        endif
    endfor
    return "--expect=".join(keys_list, ',')
endfunction

" cache
function! s:cache_has(key)
    if filereadable(a:key)
        let lines = readfile(a:key)
        if empty(lines)
            return v:false
        endif
        let lines = s:trim_lines(lines)
        return !empty(lines)
    endif
    return v:false
endfunction

function! s:cache_get(key)
    if filereadable(a:key)
        let lines = readfile(a:key)
        let lines = s:trim_lines(lines)
        return join(lines, '\n')
    endif
    return v:null
endfunction

function! s:cache_get_object(key)
    let j = s:cache_get(a:key)
    if j is v:null
        return v:null
    else
        return json_decode(j)
    endif
endfunction

function! s:cache_set(key, value)
    " echo "cache_set, key:[".string(a:key)."], value:[".string(a:value)."]"
    let cache_dir=fnamemodify(a:key, ':h')
    if !isdirectory(cache_dir)
        call mkdir(cache_dir, 'p')
    endif
    call writefile(split(a:value, "\n", 1), a:key, "S")
endfunction

function! s:cache_set_object(key, value)
    let j = json_encode(a:value)
    call s:cache_set(a:key, j)
endfunction


" ======== implementations ========

" visual
function! s:visual_lines(mode)
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
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
    execute "normal! \<ESC>"
    let query=''
    let mode=visualmode()
    if mode==?"v" || mode==?"\<C-V>"
        let query=s:visual_lines(mode)
    endif
    return query
endfunction

" live grep
function! fzfx#vim#live_grep(query, fullscreen, opts)
    let fzf_mode_key=s:fzfx_live_grep_fzf_mode_action
    let rg_mode_key=s:fzfx_live_grep_rg_mode_action
    let fuzzy_search_header=':: Press '.call(s:magenta_ref, [toupper(fzf_mode_key), 'Special']).' to fzf mode'
    let regex_search_header=':: Press '.call(s:magenta_ref, [toupper(rg_mode_key), 'Special']).' to rg mode'

    let live_grep_provider=s:fzfx_bin.'live_grep_provider'
    let unrestricted_live_grep_provider=s:fzfx_bin.'unrestricted_live_grep_provider'
    let provider= a:opts.unrestricted ? unrestricted_live_grep_provider : live_grep_provider
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
                \ '--bind', fzf_mode_key.':unbind(change,'.fzf_mode_key.')+change-prompt(Rg> )+enable-search+change-header('.regex_search_header.')+rebind('.rg_mode_key.')',
                \ '--bind', rg_mode_key.':unbind('.rg_mode_key.')+change-prompt(*Rg> )+disable-search+change-header('.fuzzy_search_header.')+reload('.reload_command.')+rebind(change,'.fzf_mode_key.')',
                \ '--bind', 'change:reload:'.reload_command,
                \ '--header', fuzzy_search_header,
                \ '--prompt', '*Rg> '
                \ ]}
    let spec = fzf#vim#with_preview(spec)
    call s:cache_set_object(s:fzfx_resume_live_grep_opts_cache, a:opts)
    call fzf#vim#grep(initial_command, spec, a:fullscreen)
endfunction

" deprecated
function! fzfx#vim#unrestricted_live_grep(query, fullscreen)
    call s:warning("'FzfxUnrestrictedLiveGrep' is deprecated, use 'FzfxLiveGrepU'!")
    call fzfx#vim#live_grep(a:query, a:fullscreen, {'unrestricted': 1})
endfunction
" deprecated
function! fzfx#vim#live_grep_visual(fullscreen)
    call s:warning("'FzfxLiveGrepVisual' is deprecated, use 'FzfxLiveGrepV'!")
    let query=fzfx#vim#_visual_select()
    call fzfx#vim#live_grep(query, a:fullscreen, {'unrestricted': 0})
endfunction

" deprecated
function! fzfx#vim#unrestricted_live_grep_visual(fullscreen)
    call s:warning("'FzfxUnrestrictedLiveGrepVisual' is deprecated, use 'FzfxLiveGrepUV'!")
    let query=fzfx#vim#_visual_select()
    call fzfx#vim#live_grep(query, a:fullscreen, {'unrestricted': 1})
endfunction

" deprecated
function! fzfx#vim#grep_word(fullscreen)
    call s:warning("'FzfxGrepWord' is deprecated, use 'FzfxLiveGrepW'!")
    call fzfx#vim#live_grep(expand('<cword>'), a:fullscreen, {'unrestricted': 0})
endfunction

" deprecated
function! fzfx#vim#unrestricted_grep_word(fullscreen)
    call s:warning("'FzfxUnrestrictedGrepWord' is deprecated, use 'FzfxLiveGrepUW'!")
    call fzfx#vim#live_grep(expand('<cword>'), a:fullscreen, {'unrestricted': 1})
endfunction

" files
function! fzfx#vim#files(query, fullscreen, opts)
    let provider = a:opts.unrestricted ? s:fzfx_unrestricted_find_command : s:fzfx_find_command
    let initial_command = provider.' || true'
    " echo "a:query:".a:query.",initial_command:".initial_command
    let spec = { 'source': initial_command,
                \ 'options': [
                \   '--query', a:query,
                \ ]}
    let spec = fzf#vim#with_preview(spec)
    call s:cache_set(s:fzfx_resume_files_cache, a:query)
    call s:cache_set_object(s:fzfx_resume_files_opts_cache, a:opts)
    call fzf#vim#files('', spec, a:fullscreen)
endfunction

" deprecated
function! fzfx#vim#unrestricted_files(query, fullscreen)
    call s:warning("'FzfxUnrestrictedFiles' is deprecated, use 'FzfxFilesU'!")
    call fzfx#vim#files(a:query, a:fullscreen, {'unrestricted':1})
endfunction

" buffers
function! s:buffers_sink(lines, query, fullscreen)
    " echo "lines0:".string(a:lines)
    if len(a:lines) < 2
        return
    endif
    let b = matchstr(a:lines[1], '\[\zs[0-9]*\ze\]')
    let bufname=split(a:lines[1])[-1]
    let action = a:lines[0]
    " echo "lines0.5:".string(a:lines).",b:".b."(".string(bufname).")"
    if action ==? s:fzfx_buffers_close_action
        execute 'bdelete' b
        " echo "lines2:".string(a:lines).",bdelete:".b."(".bufname.")"
        call fzfx#vim#buffers(a:query, a:fullscreen)
    else
        call call(s:bufopen_ref, [a:lines])
    endif
endfunction

function! fzfx#vim#buffers(query, fullscreen)
    let close_key=s:fzfx_buffers_close_action
    let close_buffer_header=':: Press '.call(s:magenta_ref, [toupper(close_key), 'Special']).' to close buffer'
    let spec = { 'sink*': {lines -> s:buffers_sink(lines, a:query, a:fullscreen)},
                \ 'options': [
                \   '--header', close_buffer_header,
                \   '--prompt', 'Buffer> ',
                \   s:expect_keys(close_key),
                \ ],
                \ 'placeholder': '{1}'
                \ }
    call fzf#vim#buffers(a:query, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

function! s:parse_branch(branch)
    let branch=s:trim(a:branch)
    if len(branch) > 0 && branch[0:1] ==? '*'
        let branch=branch[1:]
    endif
    let arrow_pos=stridx(branch, '->')
    if arrow_pos > 0
        let branch=s:trim(branch[arrow_pos+2:])
    endif
    return branch
endfunction

function! s:branches_sink(lines) abort
    " echo "lines:".string(a:lines)
    let action=a:lines[0]
    if action==?'enter' || action==?'double-click'
        let branch = s:parse_branch(a:lines[1])
        execute '!git checkout '.branch
    endif
endfunction

" branches
function! fzfx#vim#branches(query, fullscreen)
    let git_branch_header=':: Press '.call(s:magenta_ref, ['ENTER', 'Special']).' to switch branch'
    let git_branches_previewer=s:fzfx_bin.'git_branches_previewer'
    if len(a:query) > 0
        let command_fmt = s:fzfx_git_branch_command.' --list %s'
        let initial_command = printf(command_fmt, shellescape(a:query))
    else
        let initial_command = s:fzfx_git_branch_command
    endif

    let spec = {
                \ 'source': initial_command,
                \ 'sink*': {lines -> s:branches_sink(lines)},
                \ 'options': [
                \   '--no-multi',
                \   '--delimiter=:',
                \   '--bind', 'ctrl-l:toggle-preview',
                \   '--preview-window', 'right,50%',
                \   '--prompt', 'Branches> ',
                \   '--preview', git_branches_previewer.' {}',
                \   '--header', git_branch_header,
                \   s:expect_keys("enter", "double-click"),
                \ ]}
    call fzf#run(fzf#wrap('branches', spec, a:fullscreen))
endfunction

" resume
function! fzfx#vim#resume_live_grep(fullscreen)
    let query = ''
    let opts = {'unrestricted': 0}
    if s:cache_has(s:fzfx_resume_live_grep_cache)
        let query = s:cache_get(s:fzfx_resume_live_grep_cache)
    endif
    if s:cache_has(s:fzfx_resume_live_grep_opts_cache)
        let opts = s:cache_get_object(s:fzfx_resume_live_grep_opts_cache)
    endif
    call fzfx#vim#live_grep(query, a:fullscreen, opts)
endfunction

function! fzfx#vim#resume_files(fullscreen)
    let query = ''
    let opts = {'unrestricted': 0}
    if s:cache_has(s:fzfx_resume_files_cache)
        let query = s:cache_get(s:fzfx_resume_files_cache)
        call s:debug("resume_files-1, query:".query)
    endif
    if s:cache_has(s:fzfx_resume_files_opts_cache)
        let opts = s:cache_get_object(s:fzfx_resume_files_opts_cache)
        call s:debug("resume_files-2, opts:".string(opts))
    endif
    call fzfx#vim#files(query, a:fullscreen, opts)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
