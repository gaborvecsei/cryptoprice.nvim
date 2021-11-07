local curl = require("plenary.curl")
local popup = require("plenary.popup")
local vim = vim

local M = {}

local buf = nil
local win = nil

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

local function center(str)
  local width = vim.api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

local function open_window()
  buf = vim.api.nvim_create_buf(false, true)
  local border_buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'cryptoprice')

  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.5 - 4)
  local win_width = math.ceil(width * 0.3)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local border_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width + 2,
    height = win_height + 2,
    row = row - 1,
    col = col - 1
  }

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
  local middle_line = '║' .. string.rep(' ', win_width) .. '║'
  for i=1, win_height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
  vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

  local border_win = vim.api.nvim_open_win(border_buf, true, border_opts)
  win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

  vim.api.nvim_win_set_option(win, 'cursorline', true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { center('Crypto Prices'), '', ''})
  vim.api.nvim_buf_add_highlight(buf, -1, 'CryptoPricedHeader', 0, 0, -1)
end

local function refresh_prices()
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)

  vim.api.nvim_buf_set_lines(buf, 1, 2, false, {center("Crypto Prices")})

  local base_currency = "usd"
  local cryptos = {"bitcoin", "ethereum", "tezos"}

  for k,v in ipairs(cryptos) do
      local price = M.get_crypto_price(base_currency, v)
      local text = string.upper(v) .. " is " .. tostring(price) .. " " .. string.upper(base_currency)
      vim.api.nvim_buf_set_lines(buf, 3+k+1, -1, false, {center(text)})
  end

  vim.api.nvim_buf_add_highlight(buf, -1, 'CryptoPriceSubHeader', 1, 0, -1)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.close_window()
  vim.api.nvim_win_close(win, true)
end

function M.show_price()
    open_window()
    -- TODO: this needs fiz, not working - not closing the window, call :close
    -- vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua require("cryptoprice").close_window()<cr>', {
    --     nowait = true, noremap = true, silent = true
    -- })
    refresh_prices()
    vim.api.nvim_win_set_cursor(win, {4, 0})
end

M.show_price()

return M
