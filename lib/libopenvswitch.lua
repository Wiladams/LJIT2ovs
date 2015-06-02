--libopenvswitch.lua
local ffi = require("ffi")

local Lib_openvswitch = ffi.load("openvswitch", true);

local exports = {
	Lib_openvswitch = Lib_openvswitch;
}


local function appendTable(dst, src)
	for k,v in pairs(src) do
		dst[k] = v;
		--print(k,v)
	end
end

local function import(dst, name)
	--print("==== importing: ", name, dst);

	local success, imports = pcall(function() return require(name) end)
	if success and type(imports) == "table"  then
		appendTable(dst, imports);
	else
		--print("IMPORT FAILED: ", name, imports)
	end
end


import(exports, "lib.command_line")
import(exports, "lib.dirs")
import(exports, "lib.hmap")
import(exports, "lib.json")
import(exports, "lib.jsonrpc")
import(exports, "lib.list")
import(exports, "lib.ovsdb_error")
import(exports, "lib.ovsdb_idl_provider")
import(exports, "lib.ovsdb_types")
import(exports, "lib.shash")
import(exports, "lib.table")
import(exports, "lib.unixctl")
import(exports, "lib.util")
import(exports, "lib.uuid")

setmetatable(exports, {
	__call=function(self)
		--print("==== libopenvswitch.__call() ====")
		for k,v in pairs(self) do
			_G[k] = v;
		end
	end,
	})

return exports
