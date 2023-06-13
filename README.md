# fzfx.vim

The e(x)tended fzf commands missing in fzf.vim.

## Dependency

- [ripgrep(rg)](https://github.com/BurntSushi/ripgrep).
- [fd](https://github.com/sharkdp/fd).

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

- `FzfxFiles` is almost the same with (`Fzf`)`Files`, except it's
  using fd command:

  ```bash
  # short version
  fd -cnever -tf -tl -L -E .git
  # e.g.
  fd --color=never --type f --type symlink --follow --exclude .git
  ```

- `FzfxUnrestrictedFiles` is a variant version, it also searches the hidden and
  ignored files with `--unrestricted`:

  ```bash
  # short version
  fd -cnever -tf -tl -L -u
  # e.g.
  fd --color=never --type f --type symlink --follow --unrestricted
  ```

### `Fzfx(Unrestricted)LiveGrep`

- `FzfxLiveGrep` is almost the same with (`Fzf`)`RG`, except:

  1. it's using rg command:

     ```bash
     rg --column -n --no-heading --color=always -S -g '!*.git/'
     # e.g.
     rg --column --line-number --no-heading --color=always --smart-case
     ```

  2. it allows user add rg's raw options by parsing `--` flag, treat the left part
     as query content, the right side as rg's raw options. A most commonly used
     case is searching by file type, see below screen recording:

- `FzfxUnrestrictedLiveGrep` is a variant version, it also searches the hidden and
  ignored files with `--unrestricted --hidden`:

  ```bash
  # short version
  rg --column -n --no-heading --color=always -S -uu
  # e.g.
  rg --column --line-number --no-heading --color=always --smart-case --unrestricted --hidden
  ```

### (TODO) `FzfxBuffers`

### (TODO) `FzfxGitBranches`
