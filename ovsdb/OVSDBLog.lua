local ffi = require("ffi")

local log = require("ovsdb.log")

local OVSDBLog = {
	mode = {
		READ_ONLY = log.OVSDB_LOG_READ_ONLY;
		READ_WRITE = log.OVSDB_LOG_READ_WRITE;
		LOG_CREATE = log.OVSDB_LOG_CREATE;
	};
}
setmetatable(OVSDBLog, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

local OVSDBLog_mt = {
	__index = OVSDBLog;
}

function OVSDBLog.init(self, handle)
	local obj = {
		Handle = handle;
	}
	setmetatable(obj, OVSDBLog_mt);

	return obj;
end

function OVSDBLog.new(self, name, mode, locking)
	local logp = ffi.new("struct ovsdb_log*[1]");
	local err = log.ovsdb_log_open(name, mode, locking, logp);

	if err ~= nil then
		return nil, err;
	end

	local handle = logp[0];
	ffi.gc(handle, log.ovsdb_log_close);

	return self:init(handle);
end

function OVSDBLog.read(self)
	local resp = ffi.new("struct json * [1]")
	local err = log.ovsdb_log_read(self.Handle, resp);

	if err ~= nil then
		return false, err;
	end

	local res = resp[0];

	return res;
end

function OVSDBLog.unread(self)
	log.ovsdb_log_unread(self.Handle);
end

-- data - struct json
function OVSDBLog.write(self, data, andCommit)
	local err = ovsdb_log_write(self.Handle, data);

	if andCommit then
		return self:commit();
	end

	return err == nil;
end

function OVSDBLog.commit(self)
	local err = log.ovsdb_log_commit(self.Handle);
	return err == nil;
end

function OVSDBLog.getOffset(self)
	local offset = log.ovsdb_log_get_offset(self.Handle);
	
	return tonumber(offset);
end


return OVSDBLog

