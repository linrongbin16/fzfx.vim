# fzfx.vim

E(x)tended fzf commands missing in fzf.vim.

- [Dependency](#dependency)
  - [Rust commands](#rust-commands)
  - [Git (for Windows)](#git-for-windows)
- [Install](#install)
  - [vim-plug](#vim-plug)
  - [lazy.nvim](#lazynvim)
- [Usage](#usage)
  - [Key mapping](#key-mapping)
- [Commands](#commands)
  - [FzfxFiles(UVW)](#fzfxfilesuvw)
  - [FzfxBuffers](#fzfxbuffers)
  - [FzfxLiveGrep(UVW)](#fzfxlivegrepuvw)
  - [FzfxBranches](#fzfxbranches)
- [Config](#config)
- [Credit](#credit)

## Dependency

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

### Git (for Windows)

Since the cmd scripts on Windows are actually implemented by forwarding
user input to linux shell scripts, thus we are relying on the embeded shell installed with
[Git for Windows](https://git-scm.com/download/win).

Install with the below 3 options:

1. In **Select Components**, select **Associate .sh files to be run with Bash**.
   <!-- ![install-windows-git1](https://github.com/linrongbin16/fzfx.vim/assets/6496887/6e1065f4-9d94-4564-848f-3f505e3e5b0c) -->
   <p align="center" width="70%">
       <img alt="install-windows-git1.png" src="https://github.com/linrongbin16/fzfx.vim/assets/6496887/6e1065f4-9d94-4564-848f-3f505e3e5b0c"
           width="70%" />
   </p>

2. In **Adjusting your PATH environment**, select **Use Git and optional Unix
   tools from the Command Prompt**.
   <!-- ![install-windows-git2](https://github.com/linrongbin16/fzfx.vim/assets/6496887/d1b73beb-c95f-4fba-83c7-2eaf369db692) -->
   <p align="center" width="70%">
       <img alt="install-windows-git2.png" src="https://github.com/linrongbin16/fzfx.vim/assets/6496887/d1b73beb-c95f-4fba-83c7-2eaf369db692"
           width="70%" />
   </p>

3. In **Configuring the terminal emulator to use with Git Bash**, select **Use
   Windows's default console window**.
   <!-- ![install-windows-git3](https://github.com/linrongbin16/fzfx.vim/assets/6496887/1b05584f-a030-4555-b588-f344f933a523) -->
   <p align="center" width="70%">
       <img alt="install-windows-git3.png" src="https://github.com/linrongbin16/fzfx.vim/assets/6496887/1b05584f-a030-4555-b588-f344f933a523"
           width="70%" />
   </p>

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

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    {
        "junegunn/fzf",
        build = ":call fzf#install()",
    },
    {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
    },
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
" files
nnoremap <space>f :\<C-U>FzfxFiles<CR>
xnoremap <space>f :\<C-U>FzfxFilesV<CR>
" deprecated, use FzfxFilesU instead
" nnoremap <space>uf :\<C-U>FzfxUnrestrictedFiles<CR>
nnoremap <space>uf :\<C-U>FzfxFilesU<CR>
xnoremap <space>uf :\<C-U>FzfxFilesUV<CR>

" find files by cursor word
nnoremap <space>wf :\<C-U>FzfxFilesW<CR>
nnoremap <space>uwf :\<C-U>FzfxFilesUW<CR>

" buffers
nnoremap <space>b :\<C-U>FzfxBuffers<CR>

" live grep
nnoremap <space>l :\<C-U>FzfxLiveGrep<CR>
" deprecated, use FzfxLiveGrepV instead
" xnoremap <space>l :\<C-U>FzfxLiveGrepVisual<CR>
xnoremap <space>l :\<C-U>FzfxLiveGrepV<CR>
" deprecated, use FzfxLiveGrepU instead
" nnoremap <space>ul :\<C-U>FzfxUnrestrictedLiveGrep<CR>
nnoremap <space>ul :\<C-U>FzfxLiveGrepU<CR>
" deprecated, use FzfxLiveGrepUV instead
" xnoremap <space>ul :\<C-U>FzfxUnrestrictedLiveGrepVisual<CR>
xnoremap <space>ul :\<C-U>FzfxLiveGrepUV<CR>

" grep word
" deprecated, use FzfxLiveGrepW instead
" nnoremap <space>wl :\<C-U>FzfxGrepWord<CR>
nnoremap <space>wl :\<C-U>FzfxLiveGrepW<CR>
" deprecated, use FzfxLiveGrepUW instead
" nnoremap <space>uwl :\<C-U>FzfxUnrestrictedGrepWord<CR>
nnoremap <space>uwl :\<C-U>FzfxLiveGrepUW<CR>

" git branches
nnoremap <space>gb :\<C-U>FzfxBranches<CR>

```

For Neovim:

```lua
-- files
vim.keymap.set('n', '<space>f', '<cmd>FzfxFiles<cr>',
        {silent=true, noremap=true, desc="Search files"})
vim.keymap.set('x', '<space>f', ':<C-U>FzfxFilesV<CR>',
        {silent=true, noremap=true, desc="Search files"})
vim.keymap.set('n', '<space>uf',
        -- deprecated, use FzfxFilesU instead
        -- '<cmd>FzfxUnrestrictedFiles<cr>',
        '<cmd>FzfxFilesU<cr>',
        {silent=true, noremap=true, desc="Unrestricted search files"})
vim.keymap.set('x', '<space>uf',
        ':<C-U>FzfxFilesUV<CR>',
        {silent=true, noremap=true, desc="Unrestricted search files"})

-- find files by cursor word
vim.keymap.set('n', '<space>wf', '<cmd>FzfxFilesW<cr>',
        {silent=true, noremap=true, desc="Search files by cursor word"})
vim.keymap.set('n', '<space>uwf', '<cmd>FzfxFilesUW<cr>',
        {silent=true, noremap=true, desc="Unrestricted search files by cursor word"})

-- buffers
vim.keymap.set('n', '<space>b', '<cmd>FzfxBuffers<cr>',
        {silent=true, noremap=true, desc="Search buffers"})

-- live grep
vim.keymap.set('n', '<space>l',
        '<cmd>FzfxLiveGrep<cr>',
        {silent=true, noremap=true, desc="Live grep"})
vim.keymap.set('n', '<space>ul',
        -- deprecated, use FzfxLiveGrepU instead
        -- '<cmd>FzfxUnrestrictedLiveGrep<cr>',
        '<cmd>FzfxLiveGrepU<cr>',
        {silent=true, noremap=true, desc="Unrestricted live grep"})

vim.keymap.set('x', '<space>l',
        function()
            vim.cmd('execute "normal \\<ESC>"')
            -- deprecated, use FzfxLiveGrepV instead
            -- vim.cmd("FzfxLiveGrepVisual")
            vim.cmd("FzfxLiveGrepV")
        end,
        {silent=true, noremap=true, desc="Live grep"})
vim.keymap.set('x', '<space>ul',
        function()
            vim.cmd('execute "normal \\<ESC>"')
            -- deprecated, use FzfxLiveGrepUV instead
            -- vim.cmd("FzfxUnrestrictedLiveGrepVisual")
            vim.cmd("FzfxLiveGrepUV")
        end,
        {silent=true, noremap=true, desc="Live grep"})

-- grep word
vim.keymap.set('n', '<space>wl',
        -- deprecated, use FzfxLiveGrepW instead
        -- '<cmd>FzfxGrepWord<cr>',
        '<cmd>FzfxLiveGrepW<cr>',
        {silent=true, noremap=true, desc="Grep word under cursor"})
vim.keymap.set('n', '<space>uwl',
        -- deprecated, use FzfxLiveGrepUW instead
        -- '<cmd>FzfxUnrestrictedGrepWord<cr>',
        '<cmd>FzfxLiveGrepUW<cr>',
        {silent=true, noremap=true, desc="Unrestricted grep word under cursor"})

-- git branches
vim.keymap.set('n', '<space>gb', '<cmd>FzfxBranches<cr>',
        {silent=true, noremap=true, desc="Search git branches"})
```

Warning: to support visual mode key mapping, you must use one of below methods
to make visual selection working correctly:

1. Speicify `vim.cmd('execute "normal \\<ESC>"')` to exit visual mode before
   calling fzfx command.

2. Speicify `:<C-U>FzfxCommand<CR>` to calling fzfx command.

For details please see: https://github.com/neovim/neovim/discussions/24055#discussioncomment-6213580.

## Commands

The variants are named following below rules:

- Unrestricted searching (include hidden and ignored files) variants use `U` suffix.
- Searching by visual selection variants use `V` suffix.
- Searching by cursor word variants use `W` suffix.

### FzfxFiles(UVW)

- `FzfxFiles(U)` is almost the same with (`Fzf`)`Files`, except it's using fd command:

  ```bash
  # short version
  fd -cnever -tf -tl -L -i -E .git
  # e.g.
  fd --color=never --type f --type symlink --follow --ignore-case --exclude .git
  ```

  Note: the unrestricted variants use `-u` instead of `-E .git`.

- `FzfxFiles(U)V` is a variant of `FzfxFiles(U)`, except it searches by
  visual selection.

  https://github.com/linrongbin16/fzfx.vim/assets/6496887/cfe9f279-eb5c-4e7d-8cb2-95e168867250

- `FzfxFiles(U)W` is a variant of `FzfxFiles(U)`, except it searches by
  cursor word, e.g. `expand('<cword>')`.

### FzfxBuffers

- `FzfxBuffers` is almost the same with (`Fzf`)`Buffers`, except it's using `ctrl-d`
  to delete buffers:

  https://github.com/linrongbin16/fzfx.vim/assets/6496887/1864fde1-0cba-40d2-8e53-b72140fb7675

### FzfxLiveGrep(UVW)

- `FzfxLiveGrep(U)` is almost the same with (`Fzf`)`RG`, except:

  1. it's using rg command:

     ```bash
     rg --column -n --no-heading --color=always -S -g '!*.git/'
     # e.g.
     rg --column --line-number --no-heading --color=always --smart-case --glob '!*.git/'
     ```

     Note: the unrestricted variants use `-uu` instead of `-g '!*.git/'`.

  2. it allows user add rg's raw options by parsing `--` flag, treat the left part
     as query content, the right side as rg's raw options. A most common use case
     is searching by file type (via `--glob` or `--iglob` option):

     https://github.com/linrongbin16/fzfx.vim/assets/6496887/49c83edc-eb43-4e9c-9ea1-153e8de76f02

- `FzfxLiveGrep(U)V` is a variant of `FzfxLiveGrep(U)`, except it searches by
  visual selection:

  https://github.com/linrongbin16/fzfx.vim/assets/6496887/a7303036-e803-4e5f-a26b-92c565d37e43

- `FzfxLiveGrep(U)W` is a variant of `FzfxLiveGrep(U)`, except it searches by
  cursor word, e.g. `expand('<cword>')`.

### FzfxBranches

- `FzfxBranches` can search git branches, and use `ENTER` to switch to the
  selected branch:

  https://github.com/linrongbin16/fzfx.vim/assets/6496887/e4b3e4b9-9b38-4fd7-bb8b-b7946fc49232

## Config

There're some global variables you can speicify to config:

```vim
" live grep, grep word
let g:fzfx_grep_command="rg --column -n --no-heading --color=always -S -g '!*.git/'"
let g:fzfx_unrestricted_grep_command="rg --column -n --no-heading --color=always -S -uu"
" files
let g:fzfx_find_command="fd -cnever -tf -tl -L -E .git"
let g:fzfx_unrestricted_find_command="fd -cnever -tf -tl -L -u"
" git branches
let g:fzfx_git_branch_command="git branch -a --color"
```

## Credit

- [fzf.vim](https://github.com/junegunn/fzf.vim): Things you can do with
  [fzf](https://github.com/junegunn/fzf) and Vim.
- [fzf-lua](https://github.com/ibhagwan/fzf-lua): Improved fzf.vim written in lua.
