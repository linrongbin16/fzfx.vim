" utils
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

function! s:trim(s)
    if has('nvim') || v:versionlong >= 8001630
        return trim(a:s)
    else
        return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

" the "\x1b" esc sequence causes issues
" with older Lua versions
" clear    = "\x1b[0m",
let s:ansi_colors = {
              \ 'clear': '[0m',
              \ 'bold': '[1m',
              \ 'italic': '[3m',
              \ 'underline': '[4m',
              \ 'black': '[0;30m',
              \ 'red': '[0;31m',
              \ 'green': '[0;32m',
              \ 'yellow': '[0;33m',
              \ 'blue': '[0;34m',
              \ 'magenta': '[0;35m',
              \ 'cyan': '[0;36m',
              \ 'white': '[0;37m',
              \ 'grey': '[0;90m',
              \ 'dark_grey': '[0;97m',
              \ }

function! s:set_ansi_color(content)
    return "\x1b".s:ansi_colors.red.a:content."\x1b".s:ansi_colors.clear
endfunction

" defaults
let s:default_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit'
            \ }

" `rg --column --line-number --no-heading --color=always --smart-case`
let s:grep_command=get(g:, 'fzfx_grep_command', "rg --column -n --no-heading --color=always -S -g '!*.git/'")
let s:unrestricted_grep_command=get(g:, 'fzfx_unrestricted_grep_command', 'rg --column -n --no-heading --color=always -S -uu')

" `fd --color=never --type f --type symlink --follow --exclude .git`
if executable('fd')
    let s:find_command=get(g:, 'fzfx_find_command', 'fd -cnever -tf -tl -L -E .git')
    let s:unrestricted_find_command=get(g:, 'fzfx_unrestricted_find_command', 'fd -cnever -tf -tl -L -u')
elseif executable('fdfind')
    let s:find_command=get(g:, 'fzfx_find_command', 'fdfind -cnever -tf -tl -L -E .git')
    let s:unrestricted_find_command=get(g:, 'fzfx_unrestricted_find_command', 'fdfind -cnever -tf -tl -L -u')
endif

" `git branch -a --color --list`
let s:git_branch_command=get(g:, 'git_branch_command', 'git branch -a --color')

" providers
let s:live_grep_provider=s:fzfx_bin.'live_grep_provider'
let s:unrestricted_live_grep_provider=s:fzfx_bin.'unrestricted_live_grep_provider'
let s:grep_word_provider=s:grep_command
let s:unrestricted_grep_word_provider=s:unrestricted_grep_command
let s:files_provider=s:find_command
let s:unrestricted_files_provider=s:unrestricted_find_command
let s:word_files_provider=s:find_command
let s:unrestricted_word_files_provider=s:unrestricted_find_command
let s:git_branches_provider=s:git_branch_command

" previewers
let s:git_branches_previewer=s:fzfx_bin.'git_branches_previewer'

function! s:live_grep(query, provider, fullscreen)
    let fuzzy_search_header=':: Press '.s:set_ansi_color('CTRL-G').' to fuzzy search'
    let regex_search_header=':: Press '.s:set_ansi_color('CTRL-R').' to regex search'
    let command_fmt = a:provider.' %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    if s:is_win
        let reload_command = printf('sleep 0.1 && '.command_fmt, '{q}')
    else
        let reload_command = printf('sleep 0.1;'.command_fmt, '{q}')
    endif
    let spec = {'options': [
                \ '--disabled',
                \ '--print-query',
                \ '--query', a:query,
                \ '--bind', 'ctrl-g:unbind(change,ctrl-g)+change-prompt(Rg> )+enable-search+change-header('.regex_search_header.')+rebind(ctrl-r)',
                \ '--bind', 'ctrl-r:unbind(ctrl-r)+change-prompt(*Rg> )+disable-search+change-header('.fuzzy_search_header.')+reload('.reload_command.')+rebind(change,ctrl-g)',
                \ '--bind', 'change:reload:'.reload_command,
                \ '--header', fuzzy_search_header,
                \ '--prompt', '*Rg> '
                \ ]}
    let spec = fzf#vim#with_preview(spec)
    call fzf#vim#grep(initial_command, spec, a:fullscreen)
endfunction

function! fzfx#vim#live_grep(query, fullscreen)
    call s:live_grep(a:query, s:live_grep_provider, a:fullscreen)
endfunction

function! fzfx#vim#unrestricted_live_grep(query, fullscreen)
    call s:live_grep(a:query, s:unrestricted_live_grep_provider, a:fullscreen)
endfunction

function! fzfx#vim#grep_word(fullscreen)
    call s:live_grep(expand('<cword>'), s:live_grep_provider, a:fullscreen)
endfunction

function! fzfx#vim#unrestricted_grep_word(fullscreen)
    call s:live_grep(expand('<cword>'), s:unrestricted_live_grep_provider, a:fullscreen)
endfunction

function! s:files(query, provider, fullscreen)
    let command_fmt = a:provider.' %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let spec = { 'source': initial_command, }
    let spec = fzf#vim#with_preview(spec)
    " echo 'a:query:'.string(shellescape(a:query)).',a:provider:'.string(a:provider).',a:fullscreen:'.string(a:fullscreen).',spec:'.string(spec)
    call fzf#vim#files(a:query, spec, a:fullscreen)
endfunction

function! fzfx#vim#files(query, fullscreen)
    call s:files(a:query, s:files_provider, a:fullscreen)
endfunction

function! fzfx#vim#unrestricted_files(query, fullscreen)
    call s:files(a:query, s:unrestricted_files_provider, a:fullscreen)
endfunction

function! fzfx#vim#git_branches(query, fullscreen)
    let git_branch_header=':: Press '.s:set_ansi_color('ENTER').' to switch branch'
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
                \   '--print-query',
                \   '--delimiter=:',
                \   '--bind', 'ctrl-l:toggle-preview',
                \   '--preview-window', 'right,50%',
                \   '--prompt', 'Branches> ',
                \   '--preview', s:git_branches_previewer.' {}',
                \   '--header', git_branch_header,
                \ ]}

    " spec sink
    let spec._action = get(g:, 'fzf_action', s:default_action)
    call add(spec.options, '--expect='.join(keys(spec._action), ','))
    function! spec.sinklist(lines) abort
        echo 'lines:'.string(a:lines)
        let branch=s:trim(a:lines[2])
        if len(branch) > 0 && branch[0:1]==?'*'
            let branch=branch[1:]
        endif
        let arrow_pos=stridx(branch, '->')
        if arrow_pos > 0
            let branch=s:trim(branch[arrow_pos+2:])
        endif
        execute '!git checkout '.branch
    endfunction
    let spec['sink*'] = spec.sinklist

    call fzf#run(fzf#wrap('branches', spec, a:fullscreen))
endfunction
