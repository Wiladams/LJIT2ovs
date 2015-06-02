--libopenvswitch.lua
local ffi = require("ffi")

local Lib_openvswitch = ffi.load("openvswitch", true);

local exports = {
	Lib_openvswitch = Lib_openvswitch
}


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
		--print("IMPORT FAILED: ", name, imports)
	end
end


import(exports, "ovs.lib.command_line")
import(exports, "ovs.lib.dirs")
import(exports, "ovs.lib.hmap")
import(exports, "ovs.lib.json")
import(exports, "ovs.lib.jsonrpc")
import(exports, "ovs.lib.list")
import(exports, "ovs.lib.ovsdb_error")
import(exports, "ovs.lib.ovsdb_idl_provider")
import(exports, "ovs.lib.ovsdb_types")
import(exports, "ovs.lib.shash")
import(exports, "ovs.lib.table")
import(exports, "ovs.lib.unixctl")
import(exports, "ovs.lib.util")
import(exports, "ovs.lib.uuid")

setmetatable(exports, {
	__call=function(self)
		for k,v in pairs(self) do
			_G[k] = v;
		end
	end,
	})

return exports
