" loaded
if exists('g:loaded_fzfx')
    finish
endif
let g:loaded_fzfx=1

" command
command! -bang -nargs=? -complete=dir FzfxFiles call fzfx#vim#files(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir FzfxUnrestrictedFiles call fzfx#vim#unrestricted_files(<q-args>, <bang>0)
command! -bang -nargs=? FzfxFilesVisual call fzfx#vim#files_visual(<q-args>, <bang>0)
command! -bang -nargs=? FzfxUnrestrictedFilesVisual call fzfx#vim#unrestricted_files_visual(<q-args>, <bang>0)

command! -bar -bang -nargs=? -complete=dir FzfxBuffers call fzfx#vim#buffers(<q-args>, <bang>0)

command! -bang -nargs=* FzfxLiveGrep call fzfx#vim#live_grep(<q-args>, <bang>0)
command! -bang -nargs=* FzfxUnrestrictedLiveGrep call fzfx#vim#unrestricted_live_grep(<q-args>, <bang>0)
command! -bang -nargs=* FzfxLiveGrepVisual call fzfx#vim#live_grep_visual(<q-args>, <bang>0)
command! -bang -nargs=* FzfxUnrestrictedLiveGrepVisual call fzfx#vim#unrestricted_live_grep_visual(<q-args>, <bang>0)

command! -bang FzfxGrepWord call fzfx#vim#grep_word(<bang>0)
command! -bang FzfxUnrestrictedGrepWord call fzfx#vim#unrestricted_grep_word(<bang>0)

command! -bang -nargs=* FzfxBranches call fzfx#vim#branches(<q-args>, <bang>0)
