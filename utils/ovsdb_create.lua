--#!/usr/local/bin/luajit 

package.path = package.path..";../?.lua"

local ffi = require("ffi")

local common = require("testy.ovsdb_command_common")


--print(common.default_db());
--print(common.default_schema());
--print("args: ", arg[0], arg[1], arg[2], arg[3])

local function main()
    local db_file_name = arg[2] or common.default_db();
    local schema_file_name = arg[3] or common.default_schema();

print("db_file_name: ", db_file_name);
print("schema_file_name: ", schema_file_name);

    local schemap = ffi.new("struct ovsdb_schema *[1]");
    local logp = ffi.new("struct ovsdb_log *[1]")
 
    -- Read schema from file and convert to JSON.
    common.check_ovsdb_error(ovsdb_schema_from_file(schema_file_name, schemap));
    local schema = schemap[0];
    local json = ovsdb_schema_to_json(schema);
    ovsdb_schema_destroy(schema);

    -- Create database file.
    common.check_ovsdb_error(ovsdb_log_open(db_file_name, OVSDB_LOG_CREATE, -1, logp));
    local log = logp[0];
    common.check_ovsdb_error(ovsdb_log_write(log, json));
    common.check_ovsdb_error(ovsdb_log_commit(log));
    ovsdb_log_close(log);

    json_destroy(json);

    exit()
end

main();

