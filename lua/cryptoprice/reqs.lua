local curl = require("plenary.curl")

local M = {}

local function get_request(req_url, decode_body_as_json)
    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }

    if response.status ~= 200 then
        return {success=false, json_table={}}
    end

    local response_decoded = vim.fn.json_decode(response.body)
    return {success=true, json_table=response_decoded}
end

function M.get_coin_list()
    local req_url = "https://api.coingecko.com/api/v3/coins/list"
    return get_request(req_url, true)
end

function M.ping_api()
    local req_url = "https://api.coingecko.com/api/v3/ping"
    return get_request(req_url, false).success
end

function M.get_prices(coin_names, base_currency)
    local req_url = "https://api.coingecko.com/api/v3/simple/price?ids=" .. coin_names .. "&vs_currencies=" .. base_currency
end

return M
