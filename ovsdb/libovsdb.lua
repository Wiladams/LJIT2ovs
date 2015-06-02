--libovsdb.lua
local ffi = require("ffi")



local function appendTable(dst, src)
	for k,v in pairs(src) do
		dst[k] = v;
	end
end

local function import(dst, name)
	local success, imports = pcall(function() return require(name) end)
	if success and type(imports) == "table"  then
		appendTable(dst, imports);
	else
		print("IMPORT FAILED: ", name, imports)
	end
end

local exports = {}

import(exports, "ovs.ovsdb.log")
import(exports, "ovs.ovsdb.ovsdb_ffi")

setmetatable(exports, {
	__call=function(self)
		for k,v in pairs(self) do
			_G[k] = v;
		end
	end,
})

return exports
