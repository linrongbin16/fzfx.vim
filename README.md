# fzfx.vim

The e(x)tended fzf commands missing in fzf.vim.

- [Dependency](#dependency)
  - [Rust commands](#rust-commands)
  - [Git for Windows (for Windows)](#git-for-windows-for-windows)
- [Install](#install)
  - [vim-plug](#vim-plug)
  - [lazy.nvim](#lazy-nvim)
- [Usage](#usage)
  - [Key mapping](#key-mapping)
- [Commands](#commands)
  - [Fzfx(Unrestricted)Files](#fzfx-unrestricted-files)
  - [Fzfx(Unrestricted)LiveGrep](#fzfx-unrestricted-livegrep)
  - [Fzfx(Unrestricted)GrepWord](#fzfx-unrestricted-grepword)
  - [FzfxBranches](#fzfxbranches)

## Dependency

- [ripgrep(rg)](https://github.com/BurntSushi/ripgrep) and [fd](https://github.com/sharkdp/fd).
- (For windows) [Git for Windows](https://git-scm.com/download/win).

### Rust commands

We recommand to install [rust](https://www.rust-lang.org/) and install via cargo:

```bash
cargo install ripgrep
cargo install fd-find
```

Optionally, you can install [bat](https://github.com/sharkdp/bat) and [git-delta](https://dandavison.github.io/delta/installation.html) for better preview:

```bash
cargo install --locked bat
cargo install git-delta
```

### Git for Windows (for Windows)

Since the fzf scripts on Windows are actually implemented by forwarding
user input to linux shell scripts, so we depend on the embeded shell installed with
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

Plug 'junegunn/fzf'
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

### Key Mapping

TODO

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

### Fzfx(Unrestricted)LiveGrep

`FzfxLiveGrep` is almost the same with (`Fzf`)`RG`, except:

1. it's using rg command:

   ```bash
   rg --column -n --no-heading --color=always -S -g '!*.git/'
   # e.g.
   rg --column --line-number --no-heading --color=always --smart-case
   ```

2. it allows user add rg's raw options by parsing `--` flag, treat the left part
   as query content, the right side as rg's raw options. A most commonly used
   case is searching by file type, see below screen recording:

   https://github.com/linrongbin16/fzfx.vim/assets/6496887/57d914f9-7def-4f2d-ae25-187c9cbb8d1c

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

https://github.com/linrongbin16/fzfx.vim/assets/6496887/9717bdd3-ec64-4014-a254-533d0cae4528

### FzfxBuffers

TODO
