local M = {}

function M.reload()
	require("plenary.reload").reload_module("cryptoprice")
end

function M.find_coin_id(symbol_to_find)
    -- Coingecko API works with "Coin IDs" and not their Symbols, with this helper function you can check
    -- what is the associated ID to a known symbol
    -- e.g. :lua require("cryptoprice.dev").find_coin_id("BTC") --> bitcoin

    local curl = require("plenary.curl")

    local req_url = "https://api.coingecko.com/api/v3/coins/list"

    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }

    if response.status ~= 200 then
        print("Could not get coin IDs")
    end

    local symbol_and_id_table = {}
    local resp_decoded = vim.fn.json_decode(response.body)
    for k, v in ipairs(resp_decoded) do
        local i, j = string.find(v.symbol, string.lower(symbol_to_find))
        if i ~= nil and #v.symbol == #symbol_to_find then
            symbol_and_id_table[v.symbol] = v.id
            print(string.upper(v.symbol) .. " | id: " .. v.id)
        end
    end
    return symbol_and_id_table
end

return M
