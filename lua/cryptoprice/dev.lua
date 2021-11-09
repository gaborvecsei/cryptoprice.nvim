local reqs = require("cryptoprice.reqs")

local M = {}

function M.reload()
	require("plenary.reload").reload_module("cryptoprice")
end

function M.find_coin_id(symbol_to_find)
    -- Coingecko API works with "Coin IDs" and not their Symbols, with this helper function you can check
    -- what is the associated ID to a known symbol
    -- e.g. :lua require("cryptoprice.dev").find_coin_id("BTC") --> bitcoin

    local resp = reqs.get_coin_list()
    if not resp.success then
        print("Could not get coin IDs - check you internet connection")
    end

    local symbol_and_id_table = {}
    for k, v in ipairs(resp.json_table) do
        local i, j = string.find(v.symbol, string.lower(symbol_to_find))
        if i ~= nil and #v.symbol == #symbol_to_find then
            symbol_and_id_table[v.symbol] = v.id
            print(string.upper(v.symbol) .. " | id: " .. v.id)
        end
    end
    return symbol_and_id_table
end

return M
