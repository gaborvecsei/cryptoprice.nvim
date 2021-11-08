local curl = require("plenary.curl")
local popup = require("plenary.popup")
-- Just to suppress editor errors
local vim = vim

local M = {}

-- Popup window
Crypto_buf = nil
Crypto_win_id = nil


local function is_api_reachable()
    -- Healthcheck if the API is alive and well

    local req_url = "https://api.coingecko.com/api/v3/ping"

    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }

    if response.status == 200 then
        return true
    end

    return false
end

local function get_crypto_prices(base_currency, coin_names)
    -- Returns the price of the defined cryptos in the base currency

    -- Prepare the request URL
    base_currency = base_currency or "usd"
    coin_names = coin_names or {"bitcoin", "ethereum"}
    coin_names = table.concat(coin_names, "%2C")
    local req_url = "https://api.coingecko.com/api/v3/simple/price?ids=" .. coin_names .. "&vs_currencies=" .. base_currency

    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }

    if response.status ~= 200 then
       error("Could not make request for " .. coin_names .. " status code is " .. response.status)
    end

    -- Simplify the response to a table where the key is the coin name and the value is the price
    local resp_decoded = vim.fn.json_decode(response.body)
    local prices_table = {}
    for k, v in pairs(resp_decoded) do
        prices_table[k] = v[base_currency]
    end

    -- returns a table, e.g. {bitcoin=69, ethereum=420}
    return prices_table
end

local function create_window(width, height)
    width = width or 60
    height = height or 10
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

local function set_buffer_contents(buf, contents)
    -- Helper function to set the contents of the window buffer
    vim.api.nvim_buf_set_name(buf, "cryptoprice-menu")

    -- TODO: offsetting the help message from the last "real" line - I am sure there is a better way to do this
    -- Another call to vim.api.nvim_buf_set_lines did not work, there was no offset
    if #contents < 9 then
        -- While we don't fill the whole window, show the help at the bottom (last line)
        for i=1,10-#contents-1 do contents[#contents+1] = "" end
    end
    contents[#contents+1] = "(Press 'q' to close this window, 'r' to refresh prices)"
    vim.api.nvim_buf_set_lines(buf, 0, #contents, false, contents)

    vim.api.nvim_buf_set_option(buf, "filetype", "cryptoprice")
    vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "delete")
end

local function create_price_data()
    -- Gather prices of the defined coins and create the messages which we will show on the created popup window

    local contents = {}
    local req_status, prices = pcall(get_crypto_prices, vim.g.cryptoprice_base_currency, vim.g.cryptoprice_crypto_list)

    if req_status then
        local i = 1
        for k, v in pairs(prices) do
            contents[i] = "- 1 " .. string.upper(k) .. " is " .. tostring(v) .. " " .. string.upper(vim.g.cryptoprice_base_currency)
            i = i + 1
        end
    else
        contents[1] = "[ERROR] No prices found"
    end
    return contents
end

function M.refresh_prices()
    -- Gather prices and then create the messages which will be displayed

    if Crypto_win_id ~= nil and vim.api.nvim_win_is_valid(Crypto_win_id) then
        local contents = create_price_data()
        set_buffer_contents(Crypto_buf, contents)
    else
        print("Window does not exists, no price data will be shown")
    end
end

function M.toggle_price_window()
    -- If the window already exists, then close it
    if Crypto_win_id ~= nil and vim.api.nvim_win_is_valid(Crypto_win_id) then
        close_window()
        return
    end

    -- Create the window, and assign the global variables, so we can use later
    -- TODO: global variable to modify the width, height? (we should use that variable in the show_content fn as well
    -- when adding the help line at the end
    local win_info = create_window()
    Crypto_win_id = win_info.win_id
    Crypto_buf = win_info.bufnr

    -- Check if the API is reachable
    if not is_api_reachable() then
        set_buffer_contents(Crypto_buf, {"[ERROR] the API is not reachable", "Check your internet connection"})
        return
    end

    -- Show the current prices
    M.refresh_prices()

    -- Keymappings for the opened window
    vim.api.nvim_buf_set_keymap(
        Crypto_buf,
        "n",
        "q",
        ":lua require('cryptoprice.show_crypto').toggle_price_window()<CR>",
        { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        Crypto_buf,
        "n",
        "r",
        ":lua require('cryptoprice.show_crypto').refresh_prices()<CR>",
        { silent = true }
    )
end

return M
