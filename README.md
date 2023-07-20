<!-- markdownlint-disable MD013 MD034 -->

# fzfx.vim

E(x)tended fzf commands missing in fzf.vim.

- [Requirement](#requirement)
  - [Rust commands](#rust-commands)
  - [Git, mingw & coreutils (for Windows)](#git-mingw--coreutils-for-windows)
- [Install](#install)
  - [vim-plug](#vim-plug)
  - [packer.nvim](#packernvim)
  - [lazy.nvim](#lazynvim)
- [Usage](#usage)
  - [Key mapping](#key-mapping)
- [Commands](#commands)
  - [FzfxFiles(UVW)](#fzfxfilesuvw)
  - [FzfxBuffers](#fzfxbuffers)
  - [FzfxLiveGrep(UVW)](#fzfxlivegrepuvw)
  - [FzfxBranches](#fzfxbranches)
  - [FzfxResumeLiveGrep/FzfxResumeFiles](#fzfxresumelivegrepfzfxresumefiles)
- [Config](#config)
- [Credit](#credit)

## Requirement

- Vim &ge; 7.4.1304 or Neovim (Neovim &ge 0.8 for optional lsp diagnostics).
- [fzf](https://github.com/junegunn/fzf) and [fzf.vim](https://github.com/junegunn/fzf.vim).

### Rust commands

Recommand to install [rust](https://www.rust-lang.org/), then install [ripgrep](https://github.com/BurntSushi/ripgrep) and [fd](https://github.com/sharkdp/fd) via cargo:

```bash
cargo install ripgrep
cargo install fd-find
```

Optionally install [bat](https://github.com/sharkdp/bat) and [git-delta](https://dandavison.github.io/delta/installation.html) for better preview:

```bash
cargo install --locked bat
cargo install git-delta
```

### Git, mingw & coreutils (for Windows)

Since the cmd scripts on Windows are actually implemented by forwarding
user input to linux shell scripts, thus we are relying on the embeded shell
installed with [scoop](scoop.sh).

Run PowerShell commands:

```powershell
# scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add extras
scoop install git
scoop install mingw
scoop install uutils-coreutils
```

After this step, **git.exe** and Linux built-in commands(**sh.exe**, **cp.exe**,
**mv.exe**, **ls.exe**, etc) will be available in **%PATH%**.

## Install

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
call plug#begin()

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'linrongbin16/fzfx.vim'

call plug#end()
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
return require('packer').startup(function(use)

    use { "junegunn/fzf", run = ":call fzf#install()" }
    use { "junegunn/fzf.vim", requires = { "junegunn/fzf" } }
    use {
        "linrongbin16/fzfx.vim",
        requires = { "junegunn/fzf", "junegunn/fzf.vim" },
    }

end)
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {

    { "junegunn/fzf", build = ":call fzf#install()" },
    { "junegunn/fzf.vim", dependencies = { "junegunn/fzf" } },
    {
        "linrongbin16/fzfx.vim",
        dependencies = { "junegunn/fzf", "junegunn/fzf.vim" },
    },

}
```

## Usage

### Key mapping

For Vim:

```vim
" ======== files ========

" find files, filter hidden and ignored files
nnoremap <space>f :\<C-U>FzfxFiles<CR>
" you can also find by visual selected
xnoremap <space>f :\<C-U>FzfxFilesV<CR>
" unrestrictly find files, include hidden and ignored files
nnoremap <space>uf :\<C-U>FzfxFilesU<CR>
" you can also unrestrictly find by visual selected
xnoremap <space>uf :\<C-U>FzfxFilesUV<CR>

" find files by cursor word
nnoremap <space>wf :\<C-U>FzfxFilesW<CR>
" unrestrictly find files by cursor word
nnoremap <space>uwf :\<C-U>FzfxFilesUW<CR>

" ======== buffers ========

nnoremap <space>b :\<C-U>FzfxBuffers<CR>

" ======== live grep ========

" live grep, filter hidden and ignored files
nnoremap <space>l :\<C-U>FzfxLiveGrep<CR>
" you can also grep by visual selected
xnoremap <space>l :\<C-U>FzfxLiveGrepV<CR>
" unrestrictly live grep, include hidden and ignored files
nnoremap <space>ul :\<C-U>FzfxLiveGrepU<CR>
" you can also unrestrictly grep by visual selected
xnoremap <space>ul :\<C-U>FzfxLiveGrepUV<CR>

" live grep by cursor word, filter hidden and ignored files
nnoremap <space>wl :\<C-U>FzfxLiveGrepW<CR>
" unrestrictly live grep by cursor word, include hidden and ignored files
nnoremap <space>uwl :\<C-U>FzfxLiveGrepUW<CR>

" ======== git branches ========

nnoremap <space>gb :\<C-U>FzfxBranches<CR>

```

For Neovim:

```lua
-- ======== files ========

-- find files, filter hidden and ignored files
vim.keymap.set('n', '<space>f', '<cmd>FzfxFiles<cr>',
        {silent=true, noremap=true, desc="Search files"})
-- you can also find by visual selected
vim.keymap.set('x', '<space>f', '<cmd>FzfxFilesV<CR>',
        {silent=true, noremap=true, desc="Search files"})
-- unrestrictly find files, include hidden and ignored files
vim.keymap.set('n', '<space>uf',
        '<cmd>FzfxFilesU<cr>',
        {silent=true, noremap=true, desc="Unrestricted search files"})
-- you can also unrestrictly find by visual selected
vim.keymap.set('x', '<space>uf',
        '<cmd>FzfxFilesUV<CR>',
        {silent=true, noremap=true, desc="Unrestricted search files"})

-- find files by cursor word
vim.keymap.set('n', '<space>wf', '<cmd>FzfxFilesW<cr>',
        {silent=true, noremap=true, desc="Search files by cursor word"})
-- unrestrictly find files by cursor word
vim.keymap.set('n', '<space>uwf', '<cmd>FzfxFilesUW<cr>',
        {silent=true, noremap=true, desc="Unrestricted search files by cursor word"})

-- ======== buffers ========

vim.keymap.set('n', '<space>b', '<cmd>FzfxBuffers<cr>',
        {silent=true, noremap=true, desc="Search buffers"})

-- ======== live grep ========

-- live grep, filter hidden and ignored files
vim.keymap.set('n', '<space>l',
        '<cmd>FzfxLiveGrep<cr>',
        {silent=true, noremap=true, desc="Live grep"})
-- you can also grep by visual selected
vim.keymap.set('x', '<space>l',
        "<cmd>FzfxLiveGrepV<cr>",
        {silent=true, noremap=true, desc="Live grep"})
-- unrestrictly live grep, include hidden and ignored files
vim.keymap.set('n', '<space>ul',
        '<cmd>FzfxLiveGrepU<cr>',
        {silent=true, noremap=true, desc="Unrestricted live grep"})
-- you can also unrestrictly grep by visual selected
vim.keymap.set('x', '<space>ul',
        "<cmd>FzfxLiveGrepUV<cr>",
        {silent=true, noremap=true, desc="Live grep"})

-- live grep by cursor word, filter hidden and ignored files
vim.keymap.set('n', '<space>wl',
        -- deprecated, use FzfxLiveGrepW instead
        -- '<cmd>FzfxGrepWord<cr>',
        '<cmd>FzfxLiveGrepW<cr>',
        {silent=true, noremap=true, desc="Grep word under cursor"})
-- unrestrictly live grep by cursor word, include hidden and ignored files
vim.keymap.set('n', '<space>uwl',
        '<cmd>FzfxLiveGrepUW<cr>',
        {silent=true, noremap=true, desc="Unrestricted grep word under cursor"})

-- ======== git branches ========

vim.keymap.set('n', '<space>gb', '<cmd>FzfxBranches<cr>',
        {silent=true, noremap=true, desc="Search git branches"})
```

## Commands

The variants are named following below rules:

- Unrestricted searching (include hidden and ignored files) variants use `U` suffix.
- Searching by visual selection variants use `V` suffix.
- Searching by cursor word variants use `W` suffix.

### FzfxFiles(UVW)

https://github.com/linrongbin16/fzfx.vim/assets/6496887/4bc44577-345c-4b71-bd2f-f262d39bff9b

- `FzfxFiles(U)` is almost the same with (`Fzf`)`Files`, except it's using fd command:

  ```bash
  # short version
  fd -cnever -tf -tl -L -i
  # e.g.
  fd --color=never --type f --type symlink --follow --ignore-case
  ```

  Note: the unrestricted variants add `-u` option.

- `FzfxFiles(U)V` is a variant of `FzfxFiles(U)`, except it searches by
  visual selection.

- `FzfxFiles(U)W` is a variant of `FzfxFiles(U)`, except it searches by
  cursor word, e.g. `expand('<cword>')`.

### FzfxBuffers

https://github.com/linrongbin16/fzfx.vim/assets/6496887/1864fde1-0cba-40d2-8e53-b72140fb7675

- `FzfxBuffers` is almost the same with (`Fzf`)`Buffers`, except it's using `ctrl-d`
  to delete buffers:

### FzfxLiveGrep(UVW)

https://github.com/linrongbin16/fzfx.vim/assets/6496887/24f936fe-50cc-48fe-b8e5-c0847c5f546a

- `FzfxLiveGrep(U)` is almost the same with (`Fzf`)`RG`, except:

  1. it's using rg command:

     ```bash
     rg --column -n --no-heading --color=always -S
     # e.g.
     rg --column --line-number --no-heading --color=always --smart-case
     ```

     Note: the unrestricted variants add `-uu` options.

  2. it allows user add rg's raw options by parsing `--` flag, treat the left part
     as query content, the right side as rg's raw options. A most common use case
     is searching by file type (via `--glob` or `--iglob` option), for example
     input `fzf -- -g '*.lua'` will search on lua files.

- `FzfxLiveGrep(U)V` is a variant of `FzfxLiveGrep(U)`, except it searches by
  visual selection:

- `FzfxLiveGrep(U)W` is a variant of `FzfxLiveGrep(U)`, except it searches by
  cursor word, e.g. `expand('<cword>')`.

### FzfxBranches

https://github.com/linrongbin16/fzfx.vim/assets/6496887/e4b3e4b9-9b38-4fd7-bb8b-b7946fc49232

- `FzfxBranches` can search git branches, and use `ENTER` to switch to the
  selected branch:

### FzfxResumeLiveGrep/FzfxResumeFiles

- `FzfxResumeLiveGrep` can resume last live grep (include all variants).
- `FzfxResumeFiles` can resume last files search (include all variants).

## Config

There're some global variables you can speicify to config:

```vim
""" ======== find/grep commands ========

" live grep
let g:fzfx_grep_command = executable('rg')
        \ ? 'rg --column --line-number --no-heading --color=always --smart-case'
        \ : "grep --recursive --line-number --color=always --no-messages --binary-files=without-match --exclude-dir='*/.*'"
let g:fzfx_unrestricted_grep_command = executable('rg')
        \ ? 'rg --column --line-number --no-heading --color=always --smart-case --unrestricted --unrestricted'
        \ : "grep --recursive --line-number --color=always --no-messages --binary-files=without-match"

" files
let g:fzfx_find_command = executable('fd')
        \ ? 'fd . --color=never --type f --type symlink --follow --ignore-case'
        \ : "find . -type f,l -not -path '*/.*'"
let g:fzfx_unrestricted_find_command = executable('fd')
        \ ? 'fd . --color=never --type f --type symlink --follow --ignore-case --unrestricted'
        \ : "find . -type f,l"

" git branches
let g:fzfx_git_branch_command = 'git branch -a --color'

""" ======== key actions ========

" live grep
let g:fzfx_live_grep_fzf_mode_action = 'ctrl-f'
let g:fzfx_live_grep_rg_mode_action = 'ctrl-r'

" buffers
let g:fzfx_buffers_close_action = 'ctrl-d'

""" ======== resume last search ========

" live grep resume
let g:fzfx_resume_live_grep_cache = '~/.cache/'.(has('nvim') ? 'nvim' : 'vim').'/fzfx.vim/resume_live_grep_cache'
let g:fzfx_resume_live_grep_opts_cache = '~/.cache/'.(has('nvim') ? 'nvim' : 'vim').'/fzfx.vim/resume_live_grep_opts_cache'

" files resume
let g:fzfx_resume_files_cache = '~/.cache/'.(has('nvim') ? 'nvim' : 'vim').'/fzfx.vim/resume_files_cache'
let g:fzfx_resume_files_opts_cache = '~/.cache/'.(has('nvim') ? 'nvim' : 'vim').'/fzfx.vim/resume_files_opts_cache'
```

## Credit

- [fzf.vim](https://github.com/junegunn/fzf.vim): Things you can do with
  [fzf](https://github.com/junegunn/fzf) and Vim.
- [fzf-lua](https://github.com/ibhagwan/fzf-lua): Improved fzf.vim written in lua.

## Contribute

Please open [issue](https://github.com/linrongbin16/fzfx.vim/issues)/[PR](https://github.com/linrongbin16/fzfx.vim/pulls) for anything about fzfx.vim.

Like fzfx.vim? Consider

[![buymeacoffee](https://img.shields.io/badge/-Buy%20Me%20a%20Coffee-ff5f5f?logo=ko-fi&logoColor=white)](https://www.buymeacoffee.com/linrongbin16)
[![Wechat Pay](https://img.shields.io/badge/-Tip%20Me%20on%20WeChat-brightgreen?logo=wechat&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
[![Alipay](https://img.shields.io/badge/-Tip%20Me%20on%20Alipay-blue?logo=alipay&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
