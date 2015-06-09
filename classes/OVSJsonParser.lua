local ffi = require("ffi")

local json = require("lib.json")

local OVSJsonParser = {}
setmetatable(OVSJsonParser, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local OVSJsonParser_mt = {
	__index = OVSJsonParser;
}

function OVSJsonParser.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, OVSJsonParser_mt);

	return obj;
end

function OVSJsonParser.new(self, handle, flags)

	flags = flags or JSPF_TRAILER

	local parser = json_parser_create(flags);
	if parser == nil then 
		return false, "could not json_parser_create"
	end

	ffi.gc(parser, ffi.C.free);

	return self:init(parser);
end

function OVSJsonParser.parse(self, str)
    json_parser_feed(self.Handle, str, #str);
    res = json_parser_finish(self.Handle);

    return res;
end