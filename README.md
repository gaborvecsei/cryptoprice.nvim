# Crypto Price NeoVim

There are 100000+ ways to check the price of your favourite coins. Now I made a `nvim` plugin with which you can do the
same from your `nvim` session.

> Just imagine... you are in the flow, coding your time away. You are typing a new variable name
which resembles to one of your favourite coins and you remember... you did not check the crypto price for more than 
5 minutes. Before this plugin you would have panicked, but now you just call `:lua require("cryptoprice").toggle()`
with your favourite key binding and calmness settles, you can continue your work.

# Install

## Vim-Plug

```lua
Plug 'nvim-lua/plenary.nvim'
Plug 'gaborvecsei/cryptoprice.nvim'
```

## Setup

You'll need to setup what coins you would like to see and in which currency.

- `base_currency`: E.g.: `eur` or `usd`
    - Here you can see all the valid currencies [api.coingecko.com/api/v3/simple/supported_vs_currencies](https://api.coingecko.com/api/v3/simple/supported_vs_currencies)
- `crypto_list`: This is a list with the id of the coin on CoinGecko
    - Check the available ids here: [api.coingecko.com/v3/coins/list](https://api.coingecko.com/api/v3/coins/list)
    - Usually this is the name of the coin instead of their symbol
    - e.g. `["bitcoin", "ethereum", "shiba-inu"]`

### vimscript

```lua
let g:cryptoprice_base_currency = "usd"
let g:cryptoprice_crypto_list = ["bitcoin", "ethereum"]
```

### lua

```lua
vim.g.cryptoprice_base_currency = "usd"
vim.g.cryptoprice_crypto_list = {"bitcoin", "ethereum"} 
```

### setup()

```lua
lua << EOF
require("cryptoprice").setup{
    base_currency="usd",
    crypto_list={"bitcoin", "ethereum"}
}
EOF
```

# Usage

```lua
:lua require("cryptoprice").toggle()
```

