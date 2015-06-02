--unixctl.lua

local ffi = require("ffi")

local jsonrpc = require("ovs.lib.jsonrpc");

local Lib_unixctl = ffi.load("openvswitch");

ffi.cdef[[
/* Server for Unix domain socket control connection. */
struct unixctl_server;

int unixctl_server_create(const char *path, struct unixctl_server **);
void unixctl_server_run(struct unixctl_server *);
void unixctl_server_wait(struct unixctl_server *);
void unixctl_server_destroy(struct unixctl_server *);

/* Client for Unix domain socket control connection. */
struct jsonrpc;
int unixctl_client_create(const char *path, struct jsonrpc **client);
int unixctl_client_transact(struct jsonrpc *client,
                            const char *command,
                            int argc, char *argv[],
                            char **result, char **error);

/* Command registration. */
struct unixctl_conn;
typedef void unixctl_cb_func(struct unixctl_conn *,
                             int argc, const char *argv[], void *aux);

void unixctl_command_register(const char *name, const char *usage,
                              int min_args, int max_args,
                              unixctl_cb_func *cb, void *aux);
void unixctl_command_reply_error(struct unixctl_conn *, const char *error);
void unixctl_command_reply(struct unixctl_conn *, const char *body);
]]


local exports = {
	Lib_unixctl = Lib_unixctl;

	unixctl_server_create = Lib_unixctl.unixctl_server_create;
	unixctl_server_run = Lib_unixctl.unixctl_server_run;
	unixctl_server_wait = Lib_unixctl.unixctl_server_wait;
	unixctl_server_destroy = Lib_unixctl.unixctl_server_destroy;

	unixctl_client_create = Lib_unixctl.unixctl_client_create;
	unixctl_client_transact = Lib_unixctl.unixctl_client_transact;

	unixctl_command_register = Lib_unixctl.unixctl_command_register;
	unixctl_command_reply_error = Lib_unixctl.unixctl_command_reply_error;
	unixctl_command_reply = Lib_unixctl.unixctl_command_reply;
}

return exports
