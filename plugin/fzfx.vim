if exists('g:loaded_fzfx')
    finish
endif
let g:loaded_fzfx=1

let s:cpo_save = &cpo
set cpo&vim

" ======== files ========
command! -bang -nargs=? -complete=dir FzfxFiles call fzfx#vim#files(<q-args>, <bang>0, {'unrestricted': 0})
command! -bang -nargs=? -complete=dir FzfxFilesU call fzfx#vim#files(<q-args>, <bang>0, {'unrestricted': 1})
" find visual
command! -bang -nargs=? -complete=dir FzfxFilesV call fzfx#vim#files(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 0})
command! -bang -nargs=? -complete=dir FzfxFilesUV call fzfx#vim#files(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 1})
" find word
command! -bang -nargs=? -complete=dir FzfxFilesW call fzfx#vim#files(expand('<cword>'), <bang>0, {'unrestricted': 0})
command! -bang -nargs=? -complete=dir FzfxFilesUW call fzfx#vim#files(expand('<cword>'), <bang>0, {'unrestricted': 1})

" deprecated
command! -bang -nargs=? -complete=dir FzfxUnrestrictedFiles call fzfx#vim#unrestricted_files(<q-args>, <bang>0)

" ======== buffers ========
command! -bar -bang -nargs=? -complete=dir FzfxBuffers call fzfx#vim#buffers(<q-args>, <bang>0)

" ======== live grep ========
command! -bang -nargs=* FzfxLiveGrep call fzfx#vim#live_grep(<q-args>, <bang>0, {'unrestricted': 0})
command! -bang -nargs=* FzfxLiveGrepU call fzfx#vim#live_grep(<q-args>, <bang>0, {'unrestricted': 1})
" grep word
command! -bang -nargs=* FzfxLiveGrepW call fzfx#vim#live_grep(expand('<cword>'), <bang>0, {'unrestricted': 0})
command! -bang -nargs=* FzfxLiveGrepUW call fzfx#vim#live_grep(expand('<cword>'), <bang>0, {'unrestricted': 1})
" grep visual
command! -bang -nargs=* FzfxLiveGrepV call fzfx#vim#live_grep(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 0})
command! -bang -nargs=* FzfxLiveGrepUV call fzfx#vim#live_grep(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 1})

" deprecated
command! -bang -nargs=* FzfxUnrestrictedLiveGrep call fzfx#vim#unrestricted_live_grep(<q-args>, <bang>0)
command! -bang FzfxLiveGrepVisual call fzfx#vim#live_grep_visual(<bang>0)
command! -bang FzfxUnrestrictedLiveGrepVisual call fzfx#vim#unrestricted_live_grep_visual(<bang>0)
command! -bang FzfxGrepWord call fzfx#vim#grep_word(<bang>0)
command! -bang FzfxUnrestrictedGrepWord call fzfx#vim#unrestricted_grep_word(<bang>0)

" ======== git ========
command! -bang -nargs=* FzfxBranches call fzfx#vim#branches(<q-args>, <bang>0)

" ======== resume ========
command! -bang FzfxResumeLiveGrep call fzfx#vim#resume_live_grep(<bang>0)
command! -bang FzfxResumeFiles call fzfx#vim#resume_files(<bang>0)

" ======== resume ========
command! -bang -nargs=* FzfxGoogle call fzfx#vim#google(<q-args>, <bang>0, {})

let s:cpo_save = &cpo
set cpo&vim
