local cryptoprice = require("cryptoprice.show_crypto")

local M = {}

-- Just a dummy function, so it's cleaner to call
function M.toggle()
    cryptoprice.toggle_price_window()
end

function M.setup(opts)
    local function set_default(opt, default)
		if vim.g["cryptoprice_" .. opt] ~= nil then
			return
		elseif opts[opt] ~= nil then
			vim.g["cryptoprice_" .. opt] = opts[opt]
		else
			vim.g["cryptoprice_" .. opt] = default
		end
	end

    set_default("crypto_list", {"bitcoin", "ethereum", "tezos", "dogecoin"})
    set_default("base_currency", "usd")
    set_default("window_width", 60)
    set_default("window_height", 10)
end

-- Default config setup
M.setup({})

return M
