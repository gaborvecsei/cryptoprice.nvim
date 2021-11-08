# Crypto Price NeoVim

There are 100000+ ways to check the price of your favourite coins. Now I made a `nvim` plugin with which you can do the
same from your `nvim` session.

Just imagine... you are in the flow, coding your time away. You are typing a new variable name
which resembles to one of your favourite coins and you remember... you did not check the crypto price for more than 
5 minutes. Before this plugin you would have panicked, but now you just call `:lua require("cryptoprice").toggle()`
with your favourite key binding and calmness settles, you can continue your work.

# Install

## Vim-Plug

```
Plug 'nvim-lua/plenary.nvim'
Plug 'gaborvecsei/cryptoprice.nvim'
```

## Setup

### vimscript

```
let g:cryptoprice_base_currency = "usd"
let g:cryptoprice_crypto_list = ["bitcoin", "ethereum"]
```

### lua

```
vim.g.cryptoprice_base_currency = "usd"
vim.g.cryptoprice_crypto_list = {"bitcoin", "ethereum"} 
```

### setup()

```
lua << EOF
require("cryptoprice").setup{
    base_currency="usd",
    crypto_list={"bitcoin", "ethereum"}
}
EOF
```

# Usage

```
:lua require("cryptoprice").toggle()
```

