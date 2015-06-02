local ffi = require("ffi")
local vconn_ffi = require("vconn_ffi")


local VConn = {}
setmetatable(VConn, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local VConn_mt = {
	__index = VConn;
}

function VConn.init(vconnptr)
	local obj = {
		Handle = vconnptr;
	}
	setmetatable(obj, VConn_mt);

	return obj;
end

function VConn.new(self, name, allowed_versions, dscp)
	allowed_versions = allowed_versions or 0;
	dscp = dscp or 0;

	local vconnp = ffi.new("struct vconn*[1]");
	local res = ffi.C.vconn_open(name, allowed_versions, dscp, vconnp);

	if (res ~= 0) then
		return false, res;
	end

	return self:init(vconnp[0]);
end
