# super-scrolloff.nvim

Let's apply 'scrolloff' at the EOF! This is a plugin for neovim which imitates 'scrolloff'.

## Installation & Usage

Just install it as usual. Then put `set scrolloff=0` into vimrc. (or `vim.o.scrolloff = 0`)

You can configure 'scrolloff' by setting `let g:super_scrolloff = <value>` (or `vim.g.super_scrolloff = <value`)

## Global Variables

**`let g:super_scrolloff_enable = v:true`**

Set whether super scrolloff is enabled or not

**`let g:super_scrolloff = 5`**

Set scrolloff (make sure 'scrolloff' is 0)
