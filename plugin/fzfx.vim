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
command! -bang -range FzfxFilesV call fzfx#vim#files(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 0})
command! -bang -range FzfxFilesUV call fzfx#vim#files(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 1})
" find word
command! -bang FzfxFilesW call fzfx#vim#files(expand('<cword>'), <bang>0, {'unrestricted': 0})
command! -bang FzfxFilesUW call fzfx#vim#files(expand('<cword>'), <bang>0, {'unrestricted': 1})

" deprecated
command! -bang -nargs=? -complete=dir FzfxUnrestrictedFiles call fzfx#vim#unrestricted_files(<q-args>, <bang>0)

" ======== buffers ========
command! -bar -bang -nargs=? -complete=dir FzfxBuffers call fzfx#vim#buffers(<q-args>, <bang>0)

" ======== live grep ========
command! -bang -nargs=* FzfxLiveGrep call fzfx#vim#live_grep(<q-args>, <bang>0, {'unrestricted': 0})
command! -bang -nargs=* FzfxLiveGrepU call fzfx#vim#live_grep(<q-args>, <bang>0, {'unrestricted': 1})
" grep word
command! -bang FzfxLiveGrepW call fzfx#vim#live_grep(expand('<cword>'), <bang>0, {'unrestricted': 0})
command! -bang FzfxLiveGrepUW call fzfx#vim#live_grep(expand('<cword>'), <bang>0, {'unrestricted': 1})
" grep visual
command! -bang -range FzfxLiveGrepV call fzfx#vim#live_grep(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 0})
command! -bang -range FzfxLiveGrepUV call fzfx#vim#live_grep(fzfx#vim#_visual_select(), <bang>0, {'unrestricted': 1})

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

" ======== lsp ========
" severity: 1-ERROR, 2-WARN, 3-INFO, 4-HINT
command! -bang FzfxLspDocumentDiagnostics call fzfx#vim#lsp_diagnostics(<q-args>, <bang>0, {'workspace': 0, 'severity': 'HINT'})
command! -bang FzfxLspWorkspaceDiagnostics call fzfx#vim#lsp_diagnostics(<q-args>, <bang>0, {'workspace': 1, 'severity': 'HINT'})

let s:cpo_save = &cpo
set cpo&vim
