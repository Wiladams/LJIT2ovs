local ffi = require("ffi")



-- Utilities for command-line parsing.

--require ("ovs.lib.compiler")

ffi.cdef[[
struct option;

/* Command handler context */
struct ovs_cmdl_context {
    int argc;   /* number of command line arguments */
    char **argv;/* array of command line arguments */
    void *pvt;  /* private context data defined by the API user */
};

typedef void (*ovs_cmdl_handler)(struct ovs_cmdl_context *);

struct ovs_cmdl_command {
    const char *name;
    const char *usage;
    int min_args;
    int max_args;
    ovs_cmdl_handler handler;
};
]]

ffi.cdef[[
char *ovs_cmdl_long_options_to_short_options(const struct option *options);
void ovs_cmdl_print_options(const struct option *options);
void ovs_cmdl_print_commands(const struct ovs_cmdl_command *commands);
void ovs_cmdl_run_command(struct ovs_cmdl_context *, const struct ovs_cmdl_command[]);

void ovs_cmdl_proctitle_init(int argc, char **argv);
void ovs_cmdl_proctitle_restore(void);
]]


if ffi.os == "freebsd" or ffi.os == "netbsd" then
--#define ovs_cmdl_proctitle_set setproctitle
else
--void ovs_cmdl_proctitle_set(const char *, ...)
--    OVS_PRINTF_FORMAT(1, 2);
end


local Lib_command_line = ffi.load("openvswitch")

local exports = {
	Lib_command_line = Lib_command_line;

	ovs_cmdl_long_options_to_short_options = Lib_command_line.ovs_cmdl_long_options_to_short_options;
	ovs_cmdl_print_options = Lib_command_line.ovs_cmdl_print_options;
	ovs_cmdl_print_commands = Lib_command_line.ovs_cmdl_print_commands;
	ovs_cmdl_run_command = Lib_command_line.ovs_cmdl_run_command;
	ovs_cmdl_proctitle_init = Lib_command_line.ovs_cmdl_proctitle_init;
	ovs_cmdl_proctitle_restore = Lib_command_line.ovs_cmdl_proctitle_restore;
}

return exports
