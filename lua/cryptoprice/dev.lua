local M = {}

function M.reload()
	require("plenary.reload").reload_module("cryptoprice")
end

return M
