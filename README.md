# fzfx.vim

E(x)tended fzf commands missing in fzf.vim.

**Thanks to [fzf.vim](https://github.com/junegunn/fzf.vim) and
[fzf-lua](https://github.com/ibhagwan/fzf-lua), everything I learned and copied
is from them.**

- [Dependency](#dependency)
  - [Rust commands](#rust-commands)
  - [Git (for Windows)](#git-for-windows)
- [Install](#install)
  - [vim-plug](#vim-plug)
  - [lazy.nvim](#lazynvim)
- [Usage](#usage)
  - [Key mapping](#key-mapping)
- [Commands](#commands)
  - [Fzfx(Unrestricted)Files](#fzfxunrestrictedfiles)
  - [FzfxBuffers](#fzfxbuffers)
  - [Fzfx(Unrestricted)LiveGrep(Visual)](#fzfxunrestrictedlivegrepvisual)
  - [Fzfx(Unrestricted)GrepWord](#fzfxunrestrictedgrepword)
  - [FzfxBranches](#fzfxbranches)
- [Config](#config)

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
nnoremap <space>uf :\<C-U>FzfxUnrestrictedFiles<CR>
" buffers
nnoremap <space>b :\<C-U>FzfxBuffers<CR>
" live grep
nnoremap <space>l :\<C-U>FzfxLiveGrep<CR>
xnoremap <space>l :\<C-U>FzfxLiveGrepVisual<CR>
nnoremap <space>ul :\<C-U>FzfxUnrestrictedLiveGrep<CR>
xnoremap <space>ul :\<C-U>FzfxUnrestrictedLiveGrepVisual<CR>
" grep word
nnoremap <space>w :\<C-U>FzfxGrepWord<CR>
nnoremap <space>uw :\<C-U>FzfxUnrestrictedGrepWord<CR>
" resume live grep
nnoremap <space>r :\<C-U>FzfxResumeLiveGrep<CR>
" git branches
nnoremap <space>gb :\<C-U>FzfxBranches<CR>
```

For Neovim:

```lua
-- files
vim.keymap.set('n', '<space>f', '<cmd>FzfxFiles<cr>',
        {silent=true, noremap=true, desc="Search files"})
vim.keymap.set('n', '<space>uf', '<cmd>FzfxUnrestrictedFiles<cr>',
        {silent=true, noremap=true, desc="Unrestricted search files"})
-- buffers
vim.keymap.set('n', '<space>b', '<cmd>FzfxBuffers<cr>',
        {silent=true, noremap=true, desc="Search buffers"})

-- live grep
vim.keymap.set('n', '<space>l',
        '<cmd>FzfxLiveGrep<cr>',
        {silent=true, noremap=true, desc="Live grep"})
vim.keymap.set('n', '<space>ul',
        '<cmd>FzfxUnrestrictedLiveGrep<cr>',
        {silent=true, noremap=true, desc="Unrestricted live grep"})

-- warning: to support visual mode, you must use below methods to let visual
-- selection working correctly:
--
-- method-1: speicify `vim.cmd('execute "normal \\<ESC>"')` to exit visual mode first
-- see: https://github.com/neovim/neovim/discussions/24055#discussioncomment-6213580
vim.keymap.set('x', '<space>l',
        function()
            vim.cmd('execute "normal \\<ESC>"')
            vim.cmd("FzfxLiveGrepVisual")
        end,
        {silent=true, noremap=true, desc="Live grep"})
vim.keymap.set('x', '<space>ul',
        function()
            vim.cmd('execute "normal \\<ESC>"')
            vim.cmd("FzfxUnrestrictedLiveGrepVisual")
        end,
        {silent=true, noremap=true, desc="Live grep"})
-- method-2: specify `:\<C-U>`
vim.keymap.set('x', '<space>l',
        ':<C-U>FzfxLiveGrepVisual<CR>',
        {silent=true, noremap=true, desc="Live grep"})
vim.keymap.set('x', '<space>ul',
        ':<C-U>FzfxUnrestrictedLiveGrepVisual<CR>',
        {silent=true, noremap=true, desc="Unrestricted live grep"})

-- grep word
vim.keymap.set('n', '<space>w', '<cmd>FzfxGrepWord<cr>',
        {silent=true, noremap=true, desc="Grep word under cursor"})
vim.keymap.set('n', '<space>uw', '<cmd>FzfxUnrestrictedGrepWord<cr>',
        {silent=true, noremap=true, desc="Unrestricted grep word under cursor"})

-- resume (unrestricted) live grep (include (unrestricted) grep word)
vim.keymap.set('n', '<space>r', '<cmd>FzfxResumeLiveGrep<cr>',
        {silent=true, noremap=true, desc="Resume live grep (include grep word)"})

-- git branches
vim.keymap.set('n', '<space>gb', '<cmd>FzfxBranches<cr>',
        {silent=true, noremap=true, desc="Search git branches"})
```

## Commands

### Fzfx(Unrestricted)Files

- `FzfxFiles` is almost the same with (`Fzf`)`Files`, except it's using fd command:

  ```bash
  # short version
  fd -cnever -tf -tl -L -E .git
  # e.g.
  fd --color=never --type f --type symlink --follow --exclude .git
  ```

- `FzfxUnrestrictedFiles` is a variant of `FzfxFiles`, it also searches the hidden
  and ignored files with `--unrestricted`:

  ```bash
  # short version
  fd -cnever -tf -tl -L -u
  # e.g.
  fd --color=never --type f --type symlink --follow --unrestricted
  ```

### FzfxBuffers

- `FzfxBuffers` is almost the same with (`Fzf`)`Buffers`, except it's using `ctrl-d`
  to delete buffers:

  https://github.com/linrongbin16/fzfx.vim/assets/6496887/1864fde1-0cba-40d2-8e53-b72140fb7675

### Fzfx(Unrestricted)LiveGrep(Visual)

- `FzfxLiveGrep` is almost the same with (`Fzf`)`RG`, except:

  1. it's using rg command:

     ```bash
     rg --column -n --no-heading --color=always -S -g '!*.git/'
     # e.g.
     rg --column --line-number --no-heading --color=always --smart-case
     ```

  2. it allows user add rg's raw options by parsing `--` flag, treat the left part
     as query content, the right side as rg's raw options. A most common use case
     is searching by file type (via `--glob` or `--iglob` option):

     https://github.com/linrongbin16/fzfx.vim/assets/6496887/49c83edc-eb43-4e9c-9ea1-153e8de76f02

- `FzfxLiveGrepVisual` is a variant of `FzfxLiveGrep`, it allows user searching
  visual selections:

  https://github.com/linrongbin16/fzfx.vim/assets/6496887/a7303036-e803-4e5f-a26b-92c565d37e43

- `FzfxUnrestrictedLiveGrep` is a variant of `FzfxLiveGrep`, it also searches the
  hidden and ignored files with `--unrestricted --hidden`:

  ```bash
  # short version
  rg --column -n --no-heading --color=always -S -uu
  # e.g.
  rg --column --line-number --no-heading --color=always --smart-case --unrestricted --hidden
  ```

- `FzfxUnrestrictedLiveGrepVisual` is a variant of `FzfxUnrestrictedLiveGrep`, it
  allows user searching visual selection.

### Fzfx(Unrestricted)GrepWord

- `FzfxGrepWord` is a variant of `FzfxLiveGrep`, except it searches by word
  under cursor, e.g. `expand('<cword>')`.

- `FzfxUnrestrictedGrepWord` is a variant of `FzfxUnrestrictedLiveGrep`, except it
  searches by word under cursor, e.g. `expand('<cword>')`.

### FzfxResumeLiveGrep

- `FzfxResumeLiveGrep` resumes the last live grep. It include unrestricted,
  visual select and grep word variants.

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
