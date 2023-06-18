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
  - [Fzfx(Unrestricted)Files](#fzfxunrestrictedfiles)
  - [FzfxBuffers](#fzfxbuffers)
  - [Fzfx(Unrestricted)LiveGrep](#fzfxunrestrictedlivegrep)
  - [Fzfx(Unrestricted)GrepWord](#fzfxunrestrictedgrepword)
  - [FzfxBranches](#fzfxbranches)

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
nmap <space>f FzfxFiles
nmap <space>uf FzfxUnrestrictedFiles
nmap <space>b FzfxBuffers
nmap <space>l FzfxLiveGrep
xmap <space>l FzfxLiveGrep
nmap <space>ul FzfxUnrestrictedLiveGrep
xmap <space>ul FzfxUnrestrictedLiveGrep
nmap <space>w FzfxGrepWord
nmap <space>uw FzfxUnrestrictedGrepWord
nmap <space>gb FzfxBranches
```

For Neovim:

```lua
vim.keymap.set({'n'}, '<space>f', '<cmd>FzfxFiles<cr>', {silent=true, noremap=true, desc="Search files"})
vim.keymap.set({'n'}, '<space>uf', '<cmd>FzfxUnrestrictedFiles<cr>', {silent=true, noremap=true, desc="Unrestricted search files"})
vim.keymap.set({'n'}, '<space>b', '<cmd>FzfxBuffers<cr>', {silent=true, noremap=true, desc="Search buffers"})
vim.keymap.set({'n', 'x'}, '<space>l', '<cmd>FzfxLiveGrep<cr>', {silent=true, noremap=true, desc="Live grep"})
vim.keymap.set({'n', 'x'}, '<space>ul', '<cmd>FzfxUnrestrictedLiveGrep<cr>', {silent=true, noremap=true, desc="Unrestricted live grep"})
vim.keymap.set({'n'}, '<space>w', '<cmd>FzfxGrepWord<cr>', {silent=true, noremap=true, desc="Grep word under cursor"})
vim.keymap.set({'n'}, '<space>uw', '<cmd>FzfxUnrestrictedGrepWord<cr>', {silent=true, noremap=true, desc="Unrestricted grep word under cursor"})
vim.keymap.set({'n'}, '<space>gb', '<cmd>FzfxBranches<cr>', {silent=true, noremap=true, desc="Search git branches"})
```

## Commands

### Fzfx(Unrestricted)Files

`FzfxFiles` is almost the same with (`Fzf`)`Files`, except it's using fd command:

```bash
# short version
fd -cnever -tf -tl -L -E .git
# e.g.
fd --color=never --type f --type symlink --follow --exclude .git
```

`FzfxUnrestrictedFiles` is a variant of `FzfxFiles`, it also searches the hidden
and ignored files with `--unrestricted`:

```bash
# short version
fd -cnever -tf -tl -L -u
# e.g.
fd --color=never --type f --type symlink --follow --unrestricted
```

### FzfxBuffers

`FzfxBuffers` is almost the same with (`Fzf`)`Buffers`, except it's using `ctrl-d`
to delete buffers:

https://github.com/linrongbin16/fzfx.vim/assets/6496887/1864fde1-0cba-40d2-8e53-b72140fb7675

### Fzfx(Unrestricted)LiveGrep

`FzfxLiveGrep` is almost the same with (`Fzf`)`RG`, except:

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

3. it allows user search visual selections by character and line (block-visual
   not support).

`FzfxUnrestrictedLiveGrep` is a variant of `FzfxLiveGrep`, it also searches the
hidden and ignored files with `--unrestricted --hidden`:

```bash
# short version
rg --column -n --no-heading --color=always -S -uu
# e.g.
rg --column --line-number --no-heading --color=always --smart-case --unrestricted --hidden
```

### Fzfx(Unrestricted)GrepWord

`FzfxGrepWord` is a variant of `FzfxLiveGrep`, except it searches by word under cursor,
e.g. `expand('<cword>')`.

`FzfxUnrestrictedGrepWord` is a variant of `FzfxUnrestrictedLiveGrep`, except it
searches by word under cursor, e.g. `expand('<cword>')`.

### FzfxBranches

`FzfxBranches` can search git branches, and use `ENTER` to switch to the
selected branch:

https://github.com/linrongbin16/fzfx.vim/assets/6496887/e4b3e4b9-9b38-4fd7-bb8b-b7946fc49232
