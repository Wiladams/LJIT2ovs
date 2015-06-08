local ffi = require("ffi")
local ovsdb_idl = require("lib.ovsdb_idl")
local Lib = ovsdb_idl.Lib_ovsdb_idl;
local util = require("lib.util")


local OVSDBIdl = {}
setmetatable(OVSDBIdl, {
    __call = function(self, ...)
        return self:new(...);
    end,
});
local OVSDBIdl_mt = {
    __index = OVSDBIdl;
}

function OVSDBIdl.init(self, handle)
    local obj = {
        Handle = handle;
    }
    setmetatable(obj, OVSDBIdl_mt);

    return obj;
end

function OVSDBIdl.new(self, idlclass, dbname, monitor_everything, retry)
    local handle = Lib.ovsdb_idl_create(dbname, idlclass, monitor_everything, retry);

    if handle == nil then
        return nil;
    end

    ffi.gc(handle, Lib.ovsdb_idl_destroy);

    return self:init(handle);
end

function OVSDBIdl.addTable(self, tableclass)
    Lib.ovsdb_idl_add_table(self.Handle, tableclass);

    local err, msg = self:getLastError();
    return err == false, msg;
end

function OVSDBIdl.addColumn(self, column)
    Lib.ovsdb_idl_add_column(self.Handle, column);

    local err, msg = self:getLastError();
    return err == false, msg;
end

function OVSDBIdl.getLastError(self)
    local err = Lib.ovsdb_idl_get_last_error(self.Handle);

    if err == 0 then
        return false;
    end

    return err, ffi.string(util.ovs_retval_to_string(err));
end

function OVSDBIdl.getSeqNo(self)
   local seqno = Lib.ovsdb_idl_get_seqno(self.Handle);
   
   return seqno;
end

function OVSDBIdl.isAlive(self)
    return Lib.ovsdb_idl_is_alive(self.Handle);
end

function OVSDBIdl.run(self)
    Lib.ovsdb_idl_run(self.Handle);

    local err, msg = self:getLastError();
    return err == false, msg;
end

function OVSDBIdl.wait(self)
    ovsdb_idl_wait(self.Handle);

    local err, msg = self:getLastError();
    return err == false, msg;
end

return OVSDBIdl;
