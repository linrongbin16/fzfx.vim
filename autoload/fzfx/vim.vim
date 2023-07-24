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

let s:_fzfx_enable_debug = get(g:, '_fzfx_enable_debug', 1)
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
                call s:warning("Found multiple '".a:scriptname."' files with same name!")
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
        call s:warning('Failed to parse matched line: '.matched_line.'!')
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
let s:red_ref = s:get_fzf_autoload_func_ref(s:fzf_autoload_sid, "red")
let s:cyan_ref = s:get_fzf_autoload_func_ref(s:fzf_autoload_sid, "cyan")
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

let s:default_cache_dir = '~/.cache/vim/fzfx.vim'
let s:_path_slash = s:is_win ? '\' : '/'
if has('nvim')
    let s:default_cache_dir = stdpath('data').s:_path_slash.'fzfx.vim'
endif
let s:fzfx_resume_cache_dir = expand(get(g:, 'fzfx_resume_cache_dir', s:default_cache_dir))

if exists("g:fzfx_resume_live_grep_cache")
    call s:warning("Config 'g:fzfx_resume_live_grep_cache' is deprecated, please use 'g:fzfx_resume_cache_dir'!")
    let s:fzfx_resume_live_grep_cache = expand(get(g:, 'fzfx_resume_live_grep_cache', '~/.cache/'.s:vim.'/fzfx.vim/resume_live_grep_cache'))
else
    let s:fzfx_resume_live_grep_cache = s:fzfx_resume_cache_dir.s:_path_slash.'resume_live_grep_cache'
endif
if exists("g:fzfx_resume_live_grep_cache")
    call s:warning("Config 'g:fzfx_resume_live_grep_opts_cache' is deprecated, please use 'g:fzfx_resume_cache_dir'!")
    let s:fzfx_resume_live_grep_opts_cache = expand(get(g:, 'fzfx_resume_live_grep_opts_cache', '~/.cache/'.s:vim.'/fzfx.vim/resume_live_grep_opts_cache'))
else
    let s:fzfx_resume_live_grep_opts_cache = s:fzfx_resume_cache_dir.s:_path_slash.'resume_live_grep_opts_cache'
endif
if exists("g:fzfx_resume_files_cache")
    call s:warning("Config 'g:fzfx_resume_files_cache' is deprecated, please use 'g:fzfx_resume_cache_dir'!")
    let s:fzfx_resume_files_cache = expand(get(g:, 'fzfx_resume_files_cache', '~/.cache/'.s:vim.'/fzfx.vim/resume_files_cache'))
else
    let s:fzfx_resume_files_cache = s:fzfx_resume_cache_dir.s:_path_slash.'resume_files_cache'
endif
if exists("g:fzfx_resume_files_opts_cache")
    call s:warning("Config 'g:fzfx_resume_files_opts_cache' is deprecated, please use 'g:fzfx_resume_cache_dir'!")
    let s:fzfx_resume_files_opts_cache = expand(get(g:, 'fzfx_resume_files_opts_cache', '~/.opts_cache/'.s:vim.'/fzfx.vim/resume_files_opts_cache'))
else
    let s:fzfx_resume_files_opts_cache = s:fzfx_resume_cache_dir.s:_path_slash.'resume_files_opts_cache'
endif

let $_FZFX_RESUME_LIVE_GREP_CACHE = s:fzfx_resume_live_grep_cache
let $_FZFX_RESUME_FILES_CACHE = s:fzfx_resume_files_cache

" disabled filetype
let s:fzfx_disabled_history_filetypes = get(g:, 'fzfx_disabled_history_filetypes', {'NvimTree':1, 'neo-tree':1, 'CHADTree':1, 'undotree':1, 'vista':1})

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

" resume grep
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

" resume files
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

" gbranches
function! s:parse_gitbranch(branch)
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

function! s:gitbranches_sink(lines) abort
    " echo "lines:".string(a:lines)
    let action=a:lines[0]
    if action==?'enter' || action==?'double-click'
        let branch = s:parse_gitbranch(a:lines[1])
        execute '!git checkout '.branch
    endif
endfunction

function! fzfx#vim#gitbranches(query, fullscreen)
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
                \ 'sink*': {lines -> s:gitbranches_sink(lines)},
                \ 'options': [
                \   '--no-multi',
                \   '--delimiter=:',
                \   '--prompt', 'Branches> ',
                \   '--preview', git_branches_previewer.' {}',
                \   '--header', git_branch_header,
                \   s:expect_keys("enter", "double-click"),
                \ ]}
    call fzf#run(fzf#wrap('branches', fzf#vim#with_preview(spec), a:fullscreen))
endfunction

function! fzfx#vim#branches(query, fullscreen)
    call s:warning("'FzfxBranches' is deprecated, use 'FzfxGBranches'!")
    call fzfx#vim#gitbranches(a:query, a:fullscreen)
endfunction

" history files
function! s:recent_files()
    return filter([expand('%')], 'len(v:val)')
                \ + filter(map(fzf#vim#_buflisted_sorted(), 'bufname(v:val)'), 'len(v:val)')
                \ + filter(copy(v:oldfiles), "filereadable(fnamemodify(v:val, ':p'))")
endfunction

function! s:history_files_filter(idx, val)
    let ft = getbufvar(a:val, "&filetype")
    if !has_key(s:fzfx_disabled_history_filetypes, ft)
        return v:true
    endif
    return s:fzfx_disabled_history_filetypes[ft] <= 0
endfunction

function! s:history_files_compare(a, b, cwd_path, home_path)
    " first sort by:
    "   1. files under current folder
    "   2. user home
    "   3. other folder outside of user home
    " then sort by:
    "   1. last modified time, if getftime exists
    "   2. full path length
    let full_a = expand(a:a)
    let full_b = expand(a:b)
    let a_in_home = len(full_a) >= len(a:home_path) && full_a[0:len(a:home_path)-1] ==# a:home_path
    let a_in_cwd = len(full_a) >= len(a:cwd_path) && full_a[0:len(a:cwd_path)-1] ==# a:cwd_path
    let b_in_home = len(full_b) >= len(a:home_path) && full_b[0:len(a:home_path)-1] ==# a:home_path
    let b_in_cwd = len(full_b) >= len(a:cwd_path) && full_b[0:len(a:cwd_path)-1] ==# a:cwd_path
    " both a and b not in home
    if !a_in_home && !b_in_home
        return exists('*getftime') ? (getftime(full_a) - getftime(full_b)) : (len(full_a) - len(full_b))
    endif
    " either a or b in home
    if !a_in_home
        return 1
    endif
    if !b_in_home
        return -1
    endif
    " both a and b in home, and not in cwd
    if !a_in_cwd && !b_in_cwd
        return exists('*getftime') ? (getftime(full_a) - getftime(full_b)) : (len(full_a) - len(full_b))
    endif
    " either a or b in cwd
    if !a_in_cwd
        return 1
    endif
    if !b_in_cwd
        return -1
    endif
    " both a and b in cwd
    return exists('*getftime') ? (getftime(full_a) - getftime(full_b)) : (len(full_a) - len(full_b))
endfunction

function! s:_history_files_append(builder, value)
    return len(a:builder) > 0 ? a:builder.' '.a:value : a:builder.a:value
endfunction

function! s:_history_files_render(name)
    let parent_dir = fnamemodify(a:name, ':h')
    let filebase = fnamemodify(a:name, ':t')
    return parent_dir.'/'.call(s:red_ref, [filebase, 'Exception'])
endfunction

function! s:history_files_format(idx, val, today_y, today_m, today_d)
    if exists('*getftime') && exists('*strftime')
        let timestamp = getftime(a:val)
        if timestamp > 0
            let builder = ''
            let date = split(strftime('%Y %m %d', timestamp))
            let that_y = str2nr(date[0])
            let that_m = str2nr(date[1])
            let that_d = str2nr(date[2])
            if that_y != a:today_y
                let builder = s:_history_files_append(builder, string(a:today_y-that_y).' year'.((a:today_y-that_y) > 1 ? 's' : ''))
            endif
            if that_m != a:today_m
                let builder = s:_history_files_append(builder, string(a:today_m-that_m).' mmonth'.((a:today_m-that_m) > 1 ? 's' : ''))
            endif
            if that_d != a:today_d
                let builder = s:_history_files_append(builder, string(a:today_d-that_d).' day'.((a:today_d-that_d) > 1 ? 's' : ''))
            endif
            if len(builder) > 0
                let builder = append(builder, "ago")
            endif
            let time = strftime('%H:%M:%S %Z', timestamp)
            if len(builder) > 0
                let datetime = append(builder, time)
            else
                let datetime = time
            endif
            return s:_history_files_render(a:val).':last modified at '.call(s:cyan_ref, [datetime, 'Constant'])
        else
            return s:_history_files_render(a:val).':last modified unknown'
        endif
    else
        return s:_history_files_render(a:val).':last modified unknown'
    endif
endfunction

function! s:history_files_sink(lines)
    call s:debug("lines:".string(a:lines))
endfunction

function! fzfx#vim#history_files(query, fullscreen)
    if exists('*strftime')
        let today = split(strftime('%Y %m %d'))
        let today_y = str2nr(today[0])
        let today_m = str2nr(today[1])
        let today_d = str2nr(today[2])
    else
        let today_y = -1
        let today_m = -1
        let today_d = -1
    endif
    let cwd_path = getcwd()
    let home_path = expand('~')
    let recent_files = map(
                \ fzf#vim#_uniq(map(
                \   sort(
                \       filter(s:recent_files(), function('s:history_files_filter')),
                \       {a, b -> s:history_files_compare(a, b, cwd_path, home_path)},
                \   ),
                \   'fnamemodify(v:val, ":~:.")'
                \ )),
                \ {idx, val -> s:history_files_format(idx, val, today_y, today_m, today_d)})
    " call s:debug("recent files:".string(recent_files))
    let spec = {
                \ 'source': recent_files,
                \ 'sink*': {lines -> s:history_files_sink(lines)},
                \ 'options': [
                \   '--no-multi',
                \   '--delimiter=:',
                \   '--prompt', 'History Files> ',
                \   '--header-lines', !empty(expand('%')),
                \   s:expect_keys("enter", "double-click"),
                \ ],
                \ 'placeholder':  '{1}'}
    return fzf#run(fzf#wrap('history-files', fzf#vim#with_preview(spec), a:fullscreen))
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
