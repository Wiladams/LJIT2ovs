local ffi = require("ffi")

local libovs = require("lib.libopenvswitch");
libovs();   -- make things global

local libovsdb = require("ovsdb.libovsdb");
libovsdb();   -- make things global

local def_db = nil;

local function default_db()

    if (def_db == nil) then
        def_db = string.format("%s/conf.db", ffi.string(ovs_dbdir()));
    end

    return def_db;
end


local def_schema = nil;

local function default_schema(void)

    if (def_schema == nil) then
        def_schema = string.format("%s/vswitch.ovsschema", ffi.string(ovs_pkgdatadir()));
    end

    return def_schema;
end


local function check_ovsdb_error(err)

    if (err ~= nil) then
        ovs_fatal(0, "%s", ovsdb_error_to_string(error));
    end
end

return {
    default_db = default_db;
    default_schema = default_schema;
    check_ovsdb_error = check_ovsdb_error;
}