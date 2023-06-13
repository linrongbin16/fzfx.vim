" utils
let s:is_win = has('win32') || has('win64')

if s:is_win && &shellslash
  set noshellslash
  let s:base_dir = expand('<sfile>:p:h:h:h')
  set shellslash
else
  let s:base_dir = expand('<sfile>:p:h:h:h')
endif

if s:is_win
    let s:fzfx_bin=s:base_dir.'\bin\'
else
    let s:fzfx_bin=s:base_dir.'/bin/'
endif

" defaults
" `rg --column --line-number --no-heading --color=always --smart-case`
let s:fzfx_grep_command=get(g:, 'fzfx_grep_command', "rg --column -n --no-heading --color=always -S -g '!*.git/'")
let s:fzfx_unrestricted_grep_command=get(g:, 'fzfx_unrestricted_grep_command', 'rg --column -n --no-heading --color=always -S -uu')

" `fd --color=never --type f --type symlink --follow --exclude .git`
if executable('fd')
    let s:fzfx_find_command=get(g:, 'fzfx_find_command', 'fd -cnever -tf -tl -L -E .git')
    let s:fzfx_unrestricted_find_command=get(g:, 'fzfx_unrestricted_find_command', 'fd -cnever -tf -tl -L -u')
elseif executable('fdfind')
    let s:fzfx_find_command=get(g:, 'fzfx_find_command', 'fdfind -cnever -tf -tl -L -E .git')
    let s:fzfx_unrestricted_find_command=get(g:, 'fzfx_unrestricted_find_command', 'fdfind -cnever -tf -tl -L -u')
endif

" `git branch -a --color --list`
let s:fzfx_git_branch_command=get(g:, 'fzfx_git_branch_command', 'git branch -a --color --list')

" providers
let s:live_grep_provider=s:fzfx_bin.'fzfx_live_grep_provider'
let s:unrestricted_live_grep_provider=s:fzfx_bin.'fzfx_unrestricted_live_grep_provider'
let s:grep_word_provider=s:fzfx_grep_command.' -w'
let s:unrestricted_grep_word_provider=s:fzfx_unrestricted_grep_command.' -w'
let s:files_provider=s:fzfx_find_command
let s:unrestricted_files_provider=s:fzfx_unrestricted_find_command
let s:word_files_provider=s:fzfx_find_command
let s:unrestricted_word_files_provider=s:fzfx_unrestricted_find_command
let s:git_branches_provider=s:fzfx_git_branch_command

" previewers
let s:git_branches_previewer=s:fzfx_bin.'fzfx_git_branches_previewer'

function! s:live_grep(query, provider, fullscreen)
    let fuzzy_search_header=':: <ctrl-g> to Fuzzy Search'
    let regex_search_header=':: <ctrl-r> to Regex Search'
    let command_fmt = a:provider.' %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf('sleep 0.1;'.command_fmt, '{q}')
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

function! s:grep_word(query, provider, fullscreen)
    let command_fmt = a:provider.' %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf('sleep 0.1;'.command_fmt, '{q}')
    let spec = {'options': [
                \ '--disabled',
                \ '--print-query',
                \ '--query', a:query,
                \ '--bind', 'change:reload:'.reload_command,
                \ '--prompt', '*Word> ',
                \ ]}
    let spec = fzf#vim#with_preview(spec)
    call fzf#vim#grep(initial_command, spec, a:fullscreen)
endfunction

function! fzfx#vim#grep_word(query, fullscreen)
    call s:grep_word(a:query, s:grep_word_provider, a:fullscreen)
endfunction

function! fzfx#vim#unrestricted_grep_word(query, fullscreen)
    call s:grep_word(a:query, s:unrestricted_grep_word_provider, a:fullscreen)
endfunction

function! s:files(query, provider, fullscreen)
    let command_fmt = a:provider.' %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let spec = { 'source': initial_command, }
    let spec = fzf#vim#with_preview(spec)
    call fzf#vim#files(a:query, spec, a:fullscreen)
endfunction

function! fzfx#vim#files(query, fullscreen)
    call s:files(a:query, s:files_provider, a:fullscreen)
endfunction

function! fzfx#vim#unrestricted_files(query, fullscreen)
    call s:files(a:query, s:unrestricted_files_provider, a:fullscreen)
endfunction

function! fzfx#vim#git_branches(query, fullscreen)
    let command_fmt = s:git_branches_provider.' %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let spec = { 'source': initial_command,
                    \ 'options': [
                    \ '--print-query',
                    \ '--query', a:query,
                    \ '--prompt', 'GitBranches> ',
                    \ '--preview', s:git_branches_previewer.' {}',
                    \ ]}
    let spec = fzf#vim#with_preview(spec, a:fullscreen)
    call fzf#run(fzf#wrap(spec))
endfunction
