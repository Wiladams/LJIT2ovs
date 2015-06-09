local ffi = require("ffi")

local common = require("testy.ovsdb_command_common")
local stringz = require("stringz")
local OptionParser = require("std.optparse") 


local OptionsSpec = [[
VERSION: v1.0


Usage: ovs_appctl.lua

NOTE: For specifying various command line flags, you MUST
have a 'comment' after the flag, or the parser will hang

Options:
    -t, --target=TARGET         pidfile or socket to contact
    -e, --execute               no argument 
    -o, --option                display some options
    -T, --timeout=SECS          wait at most SECS seconds for a response
    -V, --version               display ovs_appctr version information
    -h, --help                  display help and exit
]]

local program_name = arg[1];


--[[
#include <config.h>

#include "daemon.h"
#include "dynamic-string.h"
#include "process.h"
#include "timeval.h"
#include "util.h"
#include "openvswitch/vlog.h"
--]]


local function main()

    --set_program_name(argv[0]);

    -- Parse command line and connect to target. */
    local target = parse_command_line();
    local client = connect_to_target(target);
--[[
    -- Transact request and process reply. */
    local cmd = argv[optind++];
    local cmd_argc = argc - optind;
    local cmd_argv = nil;
    if cmd_argc ~= 0 then
        cmd_argv = argv+optind;
    end
    
    local cmd_resultp = ffi.new("char *[1]")
    local cmd_errorp = ffi.new("char *[1]")

    local err = unixctl_client_transact(client, cmd, cmd_argc, cmd_argv,
                                    cmd_resultp, cmd_errorp);
    
    local cmd_result = cmd_resultp[0];
    local cmd_error = cmd_errorp[0];

    if (err ~= 0) then
        ovs_fatal(err, "%s: transaction error", target);
    end

    if (cmd_error ~= 0) then
        jsonrpc_close(client);
        fputs(cmd_error, stderr);
        ovs_error(0, "%s: server returned an error", target);
        exit(2);
    elseif (cmd_result ~= nil) then
        fputs(cmd_result, stdout);
    else
        OVS_NOT_REACHED();
    end
--]]
    jsonrpc_close(client);
    --ffi.C.free(cmd_result);
    --ffi.C.free(cmd_error);

    return 0;
end



local function usage()

    print(string.format([[
%s, for querying and controlling Open vSwitch daemon
usage: %s [TARGET] COMMAND [ARG...]
Targets:
  -t, --target=TARGET  pidfile or socket to contact
Common commands:
  list-commands      List commands supported by the target
  version            Print version of the target
  vlog/list          List current logging levels
  vlog/set [SPEC]
      Set log levels as detailed in SPEC, which may include:
      A valid module name (all modules, by default)
      'syslog', 'console', 'file' (all destinations, by default))
      'off', 'emer', 'err', 'warn', 'info', or 'dbg' ('dbg', bydefault)
  vlog/reopen        Make the program reopen its log file
Other options:
  --timeout=SECS     wait at most SECS seconds for a response
  -h, --help         Print this helpful information
  -V, --version      Display ovs-appctl version information
]],
        program_name, program_name));

    exit(EXIT_SUCCESS);
end



--[[
    static const struct option long_options[] = {
         {"execute", no_argument, NULL, 'e'},
        {"help", no_argument, NULL, 'h'},
        {"option", no_argument, NULL, 'o'},
        {"version", no_argument, NULL, 'V'},
        {"timeout", required_argument, NULL, 'T'},
        VLOG_LONG_OPTIONS,
        {NULL, 0, NULL, 0},
    };
--]]


local function parse_command_line()

--    enum {
--        OPT_START = UCHAR_MAX + 1,
--        VLOG_OPTION_ENUMS
--    };

    local parser = OptionParser(OptionsSpec);

    parser:on('--', parser.finished)


    _G.arg, _G.opts = parser:parse (_G.arg)


    local target = nil;
    local e_options = 0;

    local actions = {
        target = function(value)
            print("==== argActions.target: ", value);
            if target ~= nil then
                ovs_fatal(0, "-t or --target may be specified only once");
            end

            target = value;
        end,

        help = function(value)
            print("==== argActions.help: ", value)
            usage();
        end,
    }


    -- Perform actions based on command line arguments
    for k,value in pairs(opts) do
        if actions[k] then
            actions[k](value);
        end
    end    


--[[
        case 'e':
            /* We ignore -e for compatibility.  Older versions specified the
             * command as the argument to -e.  Since the current version takes
             * the command as non-option arguments and we say that -e has no
             * arguments, this just works in the common case. */
            if (e_options++) {
                ovs_fatal(0, "-e or --execute may be speciifed only once");
            }
            break;


        case 'o':
            ovs_cmdl_print_options(long_options);
            exit(EXIT_SUCCESS);

        case 'T':
            time_alarm(atoi(optarg));
            break;

        case 'V':
            ovs_print_version(0, 0);
            exit(EXIT_SUCCESS);

        VLOG_OPTION_HANDLERS

        case '?':
            exit(EXIT_FAILURE);

]] 
print("TARGET:", target)

    target = target or "ovs-vswitchd";

    return target;
end



local function connect_to_target(target)

    local socket_name = nil;

--if ffi.os ~= "Windows" then
    if (target[0] ~= string.byte('/')) then
        local pidfile_name = xasprintf("%s/%s.pid", ovs_rundir(), target);
        local pid = read_pidfile(pidfile_name);
        if (pid < 0) then
            ovs_fatal(-pid, "cannot read pidfile \"%s\"", pidfile_name);
        end
        ffi.C.free(pidfile_name);
        socket_name = xasprintf("%s/%s.%ld.ctl",
                                ovs_rundir(), target, ffi.cast("long int", pid));
--else
    -- On windows, if the 'target' contains ':', we make an assumption that
    -- it is an absolute path.
--    if ( not stringz.strchr(target, ':')) then
--        socket_name = xasprintf("%s/%s.ctl", ovs_rundir(), target);
--end
    else
        socket_name = xstrdup(target);
    end

    local clientp = ffi.new("struct jsonrpc *[1]");
    local err = unixctl_client_create(socket_name, clientp);
    local client = clientp[0];

    if (err ~= 0) then
        ovs_fatal(error, "cannot connect to \"%s\"", socket_name);
    end
    ffi.C.free(socket_name);

    return client;
end


--main();
--usage();
parse_command_line();

exit();
