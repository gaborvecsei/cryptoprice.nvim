local curl = require("plenary.curl")
local popup = require("plenary.popup")
local vim = vim

local M = {}

Crypto_buf = nil
Crypto_win_id = nil

function M.get_crypto_price(base_currency, coin_name)
    base_currency = base_currency or "usd"
    coin_name = coin_name or "bitcoin"
    local req_url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=" .. base_currency .. "&ids=" .. coin_name

    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }

    if response.status ~= 200 then
       error("Could not make request")
    end

    local resp_decoded = vim.fn.json_decode(response.body)
    local current_price = resp_decoded[1].current_price

    -- print("Price of 1 " .. string.upper(coin_name) .. " is: " .. tostring(current_price) .. " " .. string.upper(base_currency))
    return current_price
end

local function create_window(width, height)
    local width = width or 60
    local height = height or 10
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, false)

    local win_id, win = popup.create(bufnr, {
        title = "Crypto Prices",
        highlight = "CryptoPriceWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:CryptoPriceBorder"
    )

    return {
        bufnr = bufnr,
        win_id = win_id,
    }
end

local function close_window()
    vim.api.nvim_win_close(Crypto_win_id, true)
    Crypto_win_id = nil
    Crypto_buf = nil
end

function M.toggle_price_window()
    -- If it is already existing, then close it
    if Crypto_win_id ~= nil and vim.api.nvim_win_is_valid(Crypto_win_id) then
        close_window()
        return
    end

    local win_info = create_window()
    Crypto_win_id = win_info.win_id
    Crypto_buf = win_info.bufnr

    local base_currency = "usd"
    local cryptos = {"bitcoin", "ethereum", "tezos"}

    local contents = {}
    for k, v in ipairs(cryptos) do
        local price = M.get_crypto_price(base_currency, v)
        local text = string.upper(v) .. " is " .. tostring(price) .. " " .. string.upper(base_currency)
        contents[k] = text
    end

    vim.api.nvim_buf_set_name(Crypto_buf, "cryptoprice-menu")
    vim.api.nvim_buf_set_lines(Crypto_buf, 0, #contents, false, contents)
    vim.api.nvim_buf_set_option(Crypto_buf, "filetype", "cryptoprice")
    vim.api.nvim_buf_set_option(Crypto_buf, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(Crypto_buf, "bufhidden", "delete")

    -- TODO: this is not working...
    -- vim.api.nvim_buf_set_keymap(
    --     Crypto_buf,
    --     "n",
    --     "q",
    --     ":lua require('cryptoprice.show_crypto').toggle_price_window()<CR>",
    --     { silent = true }
    -- )
end

return M
