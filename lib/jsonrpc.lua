local ffi = require("ffi")

--#include "openvswitch/types.h"

local Lib_jsonrpc = ffi.load("openvswitch")

ffi.cdef[[
struct json;
struct jsonrpc_msg;
struct pstream;
struct reconnect_stats;
struct stream;

/* API for a JSON-RPC stream. */


int jsonrpc_stream_open(const char *name, struct stream **, uint8_t dscp);
int jsonrpc_pstream_open(const char *name, struct pstream **, uint8_t dscp);

struct jsonrpc *jsonrpc_open(struct stream *);
void jsonrpc_close(struct jsonrpc *);

void jsonrpc_run(struct jsonrpc *);
void jsonrpc_wait(struct jsonrpc *);

int jsonrpc_get_status(const struct jsonrpc *);
size_t jsonrpc_get_backlog(const struct jsonrpc *);
unsigned int jsonrpc_get_received_bytes(const struct jsonrpc *);
const char *jsonrpc_get_name(const struct jsonrpc *);

int jsonrpc_send(struct jsonrpc *, struct jsonrpc_msg *);
int jsonrpc_recv(struct jsonrpc *, struct jsonrpc_msg **);
void jsonrpc_recv_wait(struct jsonrpc *);

int jsonrpc_send_block(struct jsonrpc *, struct jsonrpc_msg *);
int jsonrpc_recv_block(struct jsonrpc *, struct jsonrpc_msg **);
int jsonrpc_transact_block(struct jsonrpc *, struct jsonrpc_msg *,
                           struct jsonrpc_msg **);

/* Messages. */
enum jsonrpc_msg_type {
    JSONRPC_REQUEST,           /* Request. */
    JSONRPC_NOTIFY,            /* Notification. */
    JSONRPC_REPLY,             /* Successful reply. */
    JSONRPC_ERROR              /* Error reply. */
};

struct jsonrpc_msg {
    enum jsonrpc_msg_type type;
    char *method;               /* Request or notification only. */
    struct json *params;        /* Request or notification only. */
    struct json *result;        /* Successful reply only. */
    struct json *error;         /* Error reply only. */
    struct json *id;            /* Request or reply only. */
};

struct jsonrpc_msg *jsonrpc_create_request(const char *method,
                                           struct json *params,
                                           struct json **idp);
struct jsonrpc_msg *jsonrpc_create_notify(const char *method,
                                          struct json *params);
struct jsonrpc_msg *jsonrpc_create_reply(struct json *result,
                                         const struct json *id);
struct jsonrpc_msg *jsonrpc_create_error(struct json *error,
                                         const struct json *id);

const char *jsonrpc_msg_type_to_string(enum jsonrpc_msg_type);
char *jsonrpc_msg_is_valid(const struct jsonrpc_msg *);
void jsonrpc_msg_destroy(struct jsonrpc_msg *);

char *jsonrpc_msg_from_json(struct json *, struct jsonrpc_msg **);
struct json *jsonrpc_msg_to_json(struct jsonrpc_msg *);

/* A JSON-RPC session with reconnection. */

struct jsonrpc_session *jsonrpc_session_open(const char *name, bool retry);
struct jsonrpc_session *jsonrpc_session_open_unreliably(struct jsonrpc *,
                                                        uint8_t);
void jsonrpc_session_close(struct jsonrpc_session *);

void jsonrpc_session_run(struct jsonrpc_session *);
void jsonrpc_session_wait(struct jsonrpc_session *);

size_t jsonrpc_session_get_backlog(const struct jsonrpc_session *);
const char *jsonrpc_session_get_name(const struct jsonrpc_session *);

int jsonrpc_session_send(struct jsonrpc_session *, struct jsonrpc_msg *);
struct jsonrpc_msg *jsonrpc_session_recv(struct jsonrpc_session *);
void jsonrpc_session_recv_wait(struct jsonrpc_session *);

bool jsonrpc_session_is_alive(const struct jsonrpc_session *);
bool jsonrpc_session_is_connected(const struct jsonrpc_session *);
unsigned int jsonrpc_session_get_seqno(const struct jsonrpc_session *);
int jsonrpc_session_get_status(const struct jsonrpc_session *);
int jsonrpc_session_get_last_error(const struct jsonrpc_session *);
void jsonrpc_session_get_reconnect_stats(const struct jsonrpc_session *,
                                         struct reconnect_stats *);

void jsonrpc_session_enable_reconnect(struct jsonrpc_session *);
void jsonrpc_session_force_reconnect(struct jsonrpc_session *);

void jsonrpc_session_set_max_backoff(struct jsonrpc_session *,
                                     int max_backofF);
void jsonrpc_session_set_probe_interval(struct jsonrpc_session *,
                                        int probe_interval);
void jsonrpc_session_set_dscp(struct jsonrpc_session *,
                              uint8_t dscp);
]]

local exports = {
    Lib_jsonrpc = Lib_jsonrpc,

    OVSDB_OLD_PORT = 6632;
    OVSDB_PORT = 6640;

}

return exports;