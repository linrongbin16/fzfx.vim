# fzfx.vim

The e(x)tended fzf commands missing in fzf.vim.

## Dependency

- Performant modern rust commands:
  [ripgrep(rg)](https://github.com/BurntSushi/ripgrep) and [fd](https://github.com/sharkdp/fd).
- For Windows: [Git for Windows](https://git-scm.com/download/win).

### Install Git for Windows

Since the implementation of fzf providers on Windows are actually forwarding
user input to shell scripts, so we depend on the embeded shell installed with
[Git for Windows](https://git-scm.com/download/win).

Install Git for Windows Setup with the below 3 options:

1. In **Select Components**, select **Associate .sh files to be run with Bash**.

2. In **Adjusting your PATH environment**, select **Use Git and optional Unix
   tools from the Command Prompt**.

3. In **Configuring the terminal emulator to use with Git Bash**, select **Use
   Windows's default console window**.

After this step, git.exe and Linux built-in commands(such as sh.exe, cp.exe,
mv.exe, ls.exe) will be available in **%PATH%**.

## Install

For [vim-plug](https://github.com/junegunn/vim-plug):

```vim
call plug#begin()

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'linrongbin16/fzfx.vim'

call plug#end()
```

For [lazy.nvim](https://github.com/folke/lazy.nvim):

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

### `Fzfx(Unrestricted)Files`

`FzfxFiles` is almost the same with (`Fzf`)`Files`, except it's using fd command:

```bash
# short version
fd -cnever -tf -tl -L -E .git
# e.g.
fd --color=never --type f --type symlink --follow --exclude .git
```

`FzfxUnrestrictedFiles` is a variant of `FzfxFiles`, it also searches the hidden and
ignored files with `--unrestricted`:

```bash
# short version
fd -cnever -tf -tl -L -u
# e.g.
fd --color=never --type f --type symlink --follow --unrestricted
```

### `Fzfx(Unrestricted)LiveGrep` and `Fzfx(Unrestricted)GrepWord`

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

### `Fzfx(Unrestricted)GrepWord`

`FzfxGrepWord` is a variant of `FzfxLiveGrep`, except it searches by word under cursor,
e.g. `expand('<cword>')`.

`FzfxUnrestrictedGrepWord` is a variant of `FzfxUnrestrictedLiveGrep`, except it
searches by word under cursor, e.g. `expand('<cword>')`.

### (TODO) `FzfxBuffers`

### (TODO) `FzfxGitBranches`
