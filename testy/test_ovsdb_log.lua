local ffi = require("ffi")

local OVSDBLog = require("ovsdb.OVSDBLog")
local lib_util = require("lib.util")
local common = require("testy.ovsdb_command_common")


local function printf(format, ...)
    io.write(string.format(format,...));
end

local function parse_json(s)
    local json = json_from_string(s);
    if (json.type == ffi.C.JSON_STRING) then
        ovs_fatal(0, "\"%s\": %s", s, json.u.string);
    end

    return json;
end

local function print_and_free_json(json)

    local str = json_to_string(json, JSSF_SORT);
    json_destroy(json);
    print(ffi.string(str));
    free(str);
end

local strToMode = {
    ["read-only"] = OVSDBLog.mode.READ_ONLY;
    ["read/write"] = OVSDBLog.mode.READ_WRITE;
    ["create"] = OVSDBLog.mode.LOG_CREATE;
}


-- arg[1] testy/test_ovsdb_log.lua
-- arg[2] name 
-- arg[3] mode
local commandProcs = {
        ["offset"] = function(dblog, command)
            print("log offset: ", dblog:getOffset())
        end,

        ["read"] = function(dblog, command)
            json, err = dblog:read();
            if (err == nil) then
                printf("%s: read: ", name);
                if (json) then
                    --print_and_free_json(json);
                else 
                    printf("end of log\n");
                end
            end
        end,

        ["write:"] = function(dblog, command)
            local jsoninput = command:sub(7);
            print("jsoninput: ", jsoninput)
            local json = parse_json(jsoninput);
            local err = dblog:write(json);
            json_destroy(json);
        end,

        ["commit"] = function(dblog, command)
            print("==== commit ====")
            success, err = dblog:commit();
        end,
}

local function execCommand(name, dblog, command)
    local cmdProc = nil;

    -- try to get it as a 'begins-with' match
    for k, v in pairs(commandProcs) do
        local pattern = "^"..k;
        if command:find(pattern) then
            cmdProc = v;
            break;
        end
    end

    if not cmdProc then
        lib_util.ovs_fatal(0, "unknown log-io command \"%s\"", command);
        return ;
    end

    local success, err = cmdProc(dblog, command);

    if (err ~= nil) then
        local s = ovsdb_error_to_string(err);
        printf("%s: %s failed: %s\n", name, command, s);
        ovsdb_error_destroy(error);
    else
        printf("%s: %s successful\n", name, command);
    end
end

local function do_log_io()
    local name = arg[2];
    local mode_string = arg[3];

    print(string.format("mode_string: '%s'", mode_string))
    local mode = strToMode[mode_string];
    --print("mode: ", mode)

    if mode == nil then
        lib_util.ovs_fatal(0, "unknown log-io open mode \"%s\"", mode_string);
    end

    local dblog, err = OVSDBLog(name, mode, -1);
    common.check_ovsdb_error(err);
    io.write(string.format("%s: open successful\n", name));

    for i = 4, #arg do
        command = arg[i];
        print("COMMAND: ", command)
        execCommand(name, dblog, command);
    end
end

do_log_io();
