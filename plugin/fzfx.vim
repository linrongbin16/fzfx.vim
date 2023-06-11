" loaded
if exists('g:loaded_fzfx')
    finish
endif
let g:loaded_fzfx=1

" command
command! -bang -nargs=? -complete=dir FzfxFiles call fzfx#vim#files(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir FzfxUnrestrictedFiles call fzfx#vim#unrestricted_files(<q-args>, <bang>0)

command! -bang -nargs=* FzfxLiveGrep call fzfx#vim#live_grep(<q-args>, <bang>0)
command! -bang -nargs=* FzfxUnrestrictedLiveGrep call fzfx#vim#unrestricted_live_grep(<q-args>, <bang>0)

command! -bang -nargs=* FzfxGrepWord call fzfx#vim#grep_word(<q-args>, <bang>0)
command! -bang -nargs=* FzfxUnrestrictedGrepWord call fzfx#vim#unrestricted_grep_word(<q-args>, <bang>0)

command! -bang -nargs=* FzfxGitBranches call fzfx#vim#git_branches(<q-args>, <bang>0)
