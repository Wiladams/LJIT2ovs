local ffi = require("ffi")

require("lib.ovsdb_data")
require("lib.ovsdb_idl_provider")
require("lib.smap")
require("lib.uuid")


local Lib_vswitch_idl = ffi.load("openvswitch")

local exports = {
	Lib_vswitch_idl = Lib_vswitch_idl;

}


ffi.cdef[[
/* AutoAttach table. */
struct ovsrec_autoattach {
	struct ovsdb_idl_row header_;

	/* mappings column. */
	int64_t *key_mappings;
	int64_t *value_mappings;
	size_t n_mappings;

	/* system_description column. */
	char *system_description;	/* Always nonnull. */

	/* system_name column. */
	char *system_name;	/* Always nonnull. */
};

enum {
    OVSREC_AUTOATTACH_COL_MAPPINGS,
    OVSREC_AUTOATTACH_COL_SYSTEM_DESCRIPTION,
    OVSREC_AUTOATTACH_COL_SYSTEM_NAME,
    OVSREC_AUTOATTACH_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_autoattach_columns[OVSREC_AUTOATTACH_N_COLUMNS];
]]

---[[
exports.ovsrec_autoattach_col_system_name = (Lib_vswitch_idl.ovsrec_autoattach_columns[ffi.C.OVSREC_AUTOATTACH_COL_SYSTEM_NAME])
exports.ovsrec_autoattach_col_mappings = (Lib_vswitch_idl.ovsrec_autoattach_columns[ffi.C.OVSREC_AUTOATTACH_COL_MAPPINGS])
exports.ovsrec_autoattach_col_system_description = (Lib_vswitch_idl.ovsrec_autoattach_columns[ffi.C.OVSREC_AUTOATTACH_COL_SYSTEM_DESCRIPTION])
--]]



ffi.cdef[[
const struct ovsrec_autoattach *ovsrec_autoattach_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_autoattach *ovsrec_autoattach_first(const struct ovsdb_idl *);
const struct ovsrec_autoattach *ovsrec_autoattach_next(const struct ovsrec_autoattach *);
]]

--[=[
local function OVSREC_AUTOATTACH_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_autoattach_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_autoattach_next(ROW))
local function OVSREC_AUTOATTACH_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_autoattach_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_autoattach_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_autoattach_init(struct ovsrec_autoattach *);
void ovsrec_autoattach_delete(const struct ovsrec_autoattach *);
struct ovsrec_autoattach *ovsrec_autoattach_insert(struct ovsdb_idl_txn *);

void ovsrec_autoattach_verify_mappings(const struct ovsrec_autoattach *);
void ovsrec_autoattach_verify_system_description(const struct ovsrec_autoattach *);
void ovsrec_autoattach_verify_system_name(const struct ovsrec_autoattach *);

const struct ovsdb_datum *ovsrec_autoattach_get_mappings(const struct ovsrec_autoattach *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_autoattach_get_system_description(const struct ovsrec_autoattach *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_autoattach_get_system_name(const struct ovsrec_autoattach *, enum ovsdb_atomic_type key_type);

void ovsrec_autoattach_set_mappings(const struct ovsrec_autoattach *, const int64_t *key_mappings, const int64_t *value_mappings, size_t n_mappings);
void ovsrec_autoattach_set_system_description(const struct ovsrec_autoattach *, const char *system_description);
void ovsrec_autoattach_set_system_name(const struct ovsrec_autoattach *, const char *system_name);
]]

ffi.cdef[[
/* Bridge table. */
struct ovsrec_bridge {
	struct ovsdb_idl_row header_;

	/* auto_attach column. */
	struct ovsrec_autoattach *auto_attach;

	/* controller column. */
	struct ovsrec_controller **controller;
	size_t n_controller;

	/* datapath_id column. */
	char *datapath_id;

	/* datapath_type column. */
	char *datapath_type;	/* Always nonnull. */

	/* datapath_version column. */
	char *datapath_version;	/* Always nonnull. */

	/* external_ids column. */
	struct smap external_ids;

	/* fail_mode column. */
	char *fail_mode;

	/* flood_vlans column. */
	int64_t *flood_vlans;
	size_t n_flood_vlans;

	/* flow_tables column. */
	int64_t *key_flow_tables;
	struct ovsrec_flow_table **value_flow_tables;
	size_t n_flow_tables;

	/* ipfix column. */
	struct ovsrec_ipfix *ipfix;

	/* mcast_snooping_enable column. */
	bool mcast_snooping_enable;

	/* mirrors column. */
	struct ovsrec_mirror **mirrors;
	size_t n_mirrors;

	/* name column. */
	char *name;	/* Always nonnull. */

	/* netflow column. */
	struct ovsrec_netflow *netflow;

	/* other_config column. */
	struct smap other_config;

	/* ports column. */
	struct ovsrec_port **ports;
	size_t n_ports;

	/* protocols column. */
	char **protocols;
	size_t n_protocols;

	/* rstp_enable column. */
	bool rstp_enable;

	/* rstp_status column. */
	struct smap rstp_status;

	/* sflow column. */
	struct ovsrec_sflow *sflow;

	/* status column. */
	struct smap status;

	/* stp_enable column. */
	bool stp_enable;
};
]]

ffi.cdef[[
enum {
    OVSREC_BRIDGE_COL_AUTO_ATTACH,
    OVSREC_BRIDGE_COL_CONTROLLER,
    OVSREC_BRIDGE_COL_DATAPATH_ID,
    OVSREC_BRIDGE_COL_DATAPATH_TYPE,
    OVSREC_BRIDGE_COL_DATAPATH_VERSION,
    OVSREC_BRIDGE_COL_EXTERNAL_IDS,
    OVSREC_BRIDGE_COL_FAIL_MODE,
    OVSREC_BRIDGE_COL_FLOOD_VLANS,
    OVSREC_BRIDGE_COL_FLOW_TABLES,
    OVSREC_BRIDGE_COL_IPFIX,
    OVSREC_BRIDGE_COL_MCAST_SNOOPING_ENABLE,
    OVSREC_BRIDGE_COL_MIRRORS,
    OVSREC_BRIDGE_COL_NAME,
    OVSREC_BRIDGE_COL_NETFLOW,
    OVSREC_BRIDGE_COL_OTHER_CONFIG,
    OVSREC_BRIDGE_COL_PORTS,
    OVSREC_BRIDGE_COL_PROTOCOLS,
    OVSREC_BRIDGE_COL_RSTP_ENABLE,
    OVSREC_BRIDGE_COL_RSTP_STATUS,
    OVSREC_BRIDGE_COL_SFLOW,
    OVSREC_BRIDGE_COL_STATUS,
    OVSREC_BRIDGE_COL_STP_ENABLE,
    OVSREC_BRIDGE_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_bridge_columns[OVSREC_BRIDGE_N_COLUMNS];
]]

---[[
exports.ovsrec_bridge_col_datapath_id = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_DATAPATH_ID])
exports.ovsrec_bridge_col_datapath_type = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_DATAPATH_TYPE])
exports.ovsrec_bridge_col_mirrors = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_MIRRORS])
exports.ovsrec_bridge_col_rstp_status = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_RSTP_STATUS])
exports.ovsrec_bridge_col_external_ids = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_EXTERNAL_IDS])
exports.ovsrec_bridge_col_rstp_enable = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_RSTP_ENABLE])
exports.ovsrec_bridge_col_flood_vlans = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_FLOOD_VLANS])
exports.ovsrec_bridge_col_datapath_version = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_DATAPATH_VERSION])
exports.ovsrec_bridge_col_status = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_STATUS])
exports.ovsrec_bridge_col_ipfix = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_IPFIX])
exports.ovsrec_bridge_col_controller = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_CONTROLLER])
exports.ovsrec_bridge_col_auto_attach = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_AUTO_ATTACH])
exports.ovsrec_bridge_col_mcast_snooping_enable = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_MCAST_SNOOPING_ENABLE])
exports.ovsrec_bridge_col_netflow = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_NETFLOW])
exports.ovsrec_bridge_col_protocols = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_PROTOCOLS])
exports.ovsrec_bridge_col_fail_mode = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_FAIL_MODE])
exports.ovsrec_bridge_col_name = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_NAME])
exports.ovsrec_bridge_col_sflow = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_SFLOW])
exports.ovsrec_bridge_col_other_config = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_OTHER_CONFIG])
exports.ovsrec_bridge_col_flow_tables = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_FLOW_TABLES])
exports.ovsrec_bridge_col_ports = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_PORTS])
exports.ovsrec_bridge_col_stp_enable = (Lib_vswitch_idl.ovsrec_bridge_columns[ffi.C.OVSREC_BRIDGE_COL_STP_ENABLE])
--]]

ffi.cdef[[
const struct ovsrec_bridge *ovsrec_bridge_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_bridge *ovsrec_bridge_first(const struct ovsdb_idl *);
const struct ovsrec_bridge *ovsrec_bridge_next(const struct ovsrec_bridge *);
]]

--[=[
local function OVSREC_BRIDGE_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_bridge_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_bridge_next(ROW))
local function OVSREC_BRIDGE_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_bridge_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_bridge_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_bridge_init(struct ovsrec_bridge *);
void ovsrec_bridge_delete(const struct ovsrec_bridge *);
struct ovsrec_bridge *ovsrec_bridge_insert(struct ovsdb_idl_txn *);
]]

ffi.cdef[[
void ovsrec_bridge_verify_auto_attach(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_controller(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_datapath_id(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_datapath_type(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_datapath_version(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_external_ids(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_fail_mode(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_flood_vlans(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_flow_tables(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_ipfix(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_mcast_snooping_enable(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_mirrors(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_name(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_netflow(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_other_config(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_ports(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_protocols(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_rstp_enable(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_rstp_status(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_sflow(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_status(const struct ovsrec_bridge *);
void ovsrec_bridge_verify_stp_enable(const struct ovsrec_bridge *);
]]

ffi.cdef[[
const struct ovsdb_datum *ovsrec_bridge_get_auto_attach(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_controller(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_datapath_id(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_datapath_type(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_datapath_version(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_external_ids(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_bridge_get_fail_mode(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_flood_vlans(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_flow_tables(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_bridge_get_ipfix(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_mcast_snooping_enable(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_mirrors(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_name(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_netflow(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_other_config(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_bridge_get_ports(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_protocols(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_rstp_enable(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_rstp_status(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_bridge_get_sflow(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_bridge_get_status(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_bridge_get_stp_enable(const struct ovsrec_bridge *, enum ovsdb_atomic_type key_type);
]]

ffi.cdef[[
void ovsrec_bridge_set_auto_attach(const struct ovsrec_bridge *, const struct ovsrec_autoattach *auto_attach);
void ovsrec_bridge_set_controller(const struct ovsrec_bridge *, struct ovsrec_controller **controller, size_t n_controller);
void ovsrec_bridge_set_datapath_id(const struct ovsrec_bridge *, const char *datapath_id);
void ovsrec_bridge_set_datapath_type(const struct ovsrec_bridge *, const char *datapath_type);
void ovsrec_bridge_set_datapath_version(const struct ovsrec_bridge *, const char *datapath_version);
void ovsrec_bridge_set_external_ids(const struct ovsrec_bridge *, const struct smap *);
void ovsrec_bridge_set_fail_mode(const struct ovsrec_bridge *, const char *fail_mode);
void ovsrec_bridge_set_flood_vlans(const struct ovsrec_bridge *, const int64_t *flood_vlans, size_t n_flood_vlans);
void ovsrec_bridge_set_flow_tables(const struct ovsrec_bridge *, const int64_t *key_flow_tables, struct ovsrec_flow_table **value_flow_tables, size_t n_flow_tables);
void ovsrec_bridge_set_ipfix(const struct ovsrec_bridge *, const struct ovsrec_ipfix *ipfix);
void ovsrec_bridge_set_mcast_snooping_enable(const struct ovsrec_bridge *, bool mcast_snooping_enable);
void ovsrec_bridge_set_mirrors(const struct ovsrec_bridge *, struct ovsrec_mirror **mirrors, size_t n_mirrors);
void ovsrec_bridge_set_name(const struct ovsrec_bridge *, const char *name);
void ovsrec_bridge_set_netflow(const struct ovsrec_bridge *, const struct ovsrec_netflow *netflow);
void ovsrec_bridge_set_other_config(const struct ovsrec_bridge *, const struct smap *);
void ovsrec_bridge_set_ports(const struct ovsrec_bridge *, struct ovsrec_port **ports, size_t n_ports);
void ovsrec_bridge_set_protocols(const struct ovsrec_bridge *, const char **protocols, size_t n_protocols);
void ovsrec_bridge_set_rstp_enable(const struct ovsrec_bridge *, bool rstp_enable);
void ovsrec_bridge_set_rstp_status(const struct ovsrec_bridge *, const struct smap *);
void ovsrec_bridge_set_sflow(const struct ovsrec_bridge *, const struct ovsrec_sflow *sflow);
void ovsrec_bridge_set_status(const struct ovsrec_bridge *, const struct smap *);
void ovsrec_bridge_set_stp_enable(const struct ovsrec_bridge *, bool stp_enable);
]]

ffi.cdef[[
/* Controller table. */
struct ovsrec_controller {
	struct ovsdb_idl_row header_;

	/* connection_mode column. */
	char *connection_mode;

	/* controller_burst_limit column. */
	int64_t *controller_burst_limit;
	size_t n_controller_burst_limit;

	/* controller_rate_limit column. */
	int64_t *controller_rate_limit;
	size_t n_controller_rate_limit;

	/* enable_async_messages column. */
	bool *enable_async_messages;
	size_t n_enable_async_messages;

	/* external_ids column. */
	struct smap external_ids;

	/* inactivity_probe column. */
	int64_t *inactivity_probe;
	size_t n_inactivity_probe;

	/* is_connected column. */
	bool is_connected;

	/* local_gateway column. */
	char *local_gateway;

	/* local_ip column. */
	char *local_ip;

	/* local_netmask column. */
	char *local_netmask;

	/* max_backoff column. */
	int64_t *max_backoff;
	size_t n_max_backoff;

	/* other_config column. */
	struct smap other_config;

	/* role column. */
	char *role;

	/* status column. */
	struct smap status;

	/* target column. */
	char *target;	/* Always nonnull. */
};
]]

ffi.cdef[[
enum {
    OVSREC_CONTROLLER_COL_CONNECTION_MODE,
    OVSREC_CONTROLLER_COL_CONTROLLER_BURST_LIMIT,
    OVSREC_CONTROLLER_COL_CONTROLLER_RATE_LIMIT,
    OVSREC_CONTROLLER_COL_ENABLE_ASYNC_MESSAGES,
    OVSREC_CONTROLLER_COL_EXTERNAL_IDS,
    OVSREC_CONTROLLER_COL_INACTIVITY_PROBE,
    OVSREC_CONTROLLER_COL_IS_CONNECTED,
    OVSREC_CONTROLLER_COL_LOCAL_GATEWAY,
    OVSREC_CONTROLLER_COL_LOCAL_IP,
    OVSREC_CONTROLLER_COL_LOCAL_NETMASK,
    OVSREC_CONTROLLER_COL_MAX_BACKOFF,
    OVSREC_CONTROLLER_COL_OTHER_CONFIG,
    OVSREC_CONTROLLER_COL_ROLE,
    OVSREC_CONTROLLER_COL_STATUS,
    OVSREC_CONTROLLER_COL_TARGET,
    OVSREC_CONTROLLER_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_controller_columns[OVSREC_CONTROLLER_N_COLUMNS];
]]
exports.ovsrec_controller_columns = Lib_vswitch_idl.ovsrec_controller_columns;

---[[
exports.ovsrec_controller_col_max_backoff = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_MAX_BACKOFF])
exports.ovsrec_controller_col_status = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_STATUS])
exports.ovsrec_controller_col_target = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_TARGET])
exports.ovsrec_controller_col_local_ip = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_LOCAL_IP])
exports.ovsrec_controller_col_connection_mode = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_CONNECTION_MODE])
exports.ovsrec_controller_col_other_config = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_OTHER_CONFIG])
exports.ovsrec_controller_col_controller_rate_limit = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_CONTROLLER_RATE_LIMIT])
exports.ovsrec_controller_col_inactivity_probe = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_INACTIVITY_PROBE])
exports.ovsrec_controller_col_local_netmask = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_LOCAL_NETMASK])
exports.ovsrec_controller_col_role = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_ROLE])
exports.ovsrec_controller_col_controller_burst_limit = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_CONTROLLER_BURST_LIMIT])
exports.ovsrec_controller_col_external_ids = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_EXTERNAL_IDS])
exports.ovsrec_controller_col_local_gateway = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_LOCAL_GATEWAY])
exports.ovsrec_controller_col_is_connected = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_IS_CONNECTED])
exports.ovsrec_controller_col_enable_async_messages = (Lib_vswitch_idl.ovsrec_controller_columns[ffi.C.OVSREC_CONTROLLER_COL_ENABLE_ASYNC_MESSAGES])
--]]


ffi.cdef[[
const struct ovsrec_controller *ovsrec_controller_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_controller *ovsrec_controller_first(const struct ovsdb_idl *);
const struct ovsrec_controller *ovsrec_controller_next(const struct ovsrec_controller *);
]]

--[=[
local function OVSREC_CONTROLLER_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_controller_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_controller_next(ROW))
local function OVSREC_CONTROLLER_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_controller_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_controller_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_controller_init(struct ovsrec_controller *);
void ovsrec_controller_delete(const struct ovsrec_controller *);
struct ovsrec_controller *ovsrec_controller_insert(struct ovsdb_idl_txn *);
]]

ffi.cdef[[
void ovsrec_controller_verify_connection_mode(const struct ovsrec_controller *);
void ovsrec_controller_verify_controller_burst_limit(const struct ovsrec_controller *);
void ovsrec_controller_verify_controller_rate_limit(const struct ovsrec_controller *);
void ovsrec_controller_verify_enable_async_messages(const struct ovsrec_controller *);
void ovsrec_controller_verify_external_ids(const struct ovsrec_controller *);
void ovsrec_controller_verify_inactivity_probe(const struct ovsrec_controller *);
void ovsrec_controller_verify_is_connected(const struct ovsrec_controller *);
void ovsrec_controller_verify_local_gateway(const struct ovsrec_controller *);
void ovsrec_controller_verify_local_ip(const struct ovsrec_controller *);
void ovsrec_controller_verify_local_netmask(const struct ovsrec_controller *);
void ovsrec_controller_verify_max_backoff(const struct ovsrec_controller *);
void ovsrec_controller_verify_other_config(const struct ovsrec_controller *);
void ovsrec_controller_verify_role(const struct ovsrec_controller *);
void ovsrec_controller_verify_status(const struct ovsrec_controller *);
void ovsrec_controller_verify_target(const struct ovsrec_controller *);
]]

ffi.cdef[[
const struct ovsdb_datum *ovsrec_controller_get_connection_mode(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_controller_burst_limit(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_controller_rate_limit(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_enable_async_messages(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_external_ids(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_controller_get_inactivity_probe(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_is_connected(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_local_gateway(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_local_ip(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_local_netmask(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_max_backoff(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_other_config(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_controller_get_role(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_controller_get_status(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_controller_get_target(const struct ovsrec_controller *, enum ovsdb_atomic_type key_type);
]]

ffi.cdef[[
void ovsrec_controller_set_connection_mode(const struct ovsrec_controller *, const char *connection_mode);
void ovsrec_controller_set_controller_burst_limit(const struct ovsrec_controller *, const int64_t *controller_burst_limit, size_t n_controller_burst_limit);
void ovsrec_controller_set_controller_rate_limit(const struct ovsrec_controller *, const int64_t *controller_rate_limit, size_t n_controller_rate_limit);
void ovsrec_controller_set_enable_async_messages(const struct ovsrec_controller *, const bool *enable_async_messages, size_t n_enable_async_messages);
void ovsrec_controller_set_external_ids(const struct ovsrec_controller *, const struct smap *);
void ovsrec_controller_set_inactivity_probe(const struct ovsrec_controller *, const int64_t *inactivity_probe, size_t n_inactivity_probe);
void ovsrec_controller_set_is_connected(const struct ovsrec_controller *, bool is_connected);
void ovsrec_controller_set_local_gateway(const struct ovsrec_controller *, const char *local_gateway);
void ovsrec_controller_set_local_ip(const struct ovsrec_controller *, const char *local_ip);
void ovsrec_controller_set_local_netmask(const struct ovsrec_controller *, const char *local_netmask);
void ovsrec_controller_set_max_backoff(const struct ovsrec_controller *, const int64_t *max_backoff, size_t n_max_backoff);
void ovsrec_controller_set_other_config(const struct ovsrec_controller *, const struct smap *);
void ovsrec_controller_set_role(const struct ovsrec_controller *, const char *role);
void ovsrec_controller_set_status(const struct ovsrec_controller *, const struct smap *);
void ovsrec_controller_set_target(const struct ovsrec_controller *, const char *target);
]]

ffi.cdef[[
/* Flow_Sample_Collector_Set table. */
struct ovsrec_flow_sample_collector_set {
	struct ovsdb_idl_row header_;

	/* bridge column. */
	struct ovsrec_bridge *bridge;

	/* external_ids column. */
	struct smap external_ids;

	/* id column. */
	int64_t id;

	/* ipfix column. */
	struct ovsrec_ipfix *ipfix;
};
]]

ffi.cdef[[
enum {
    OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_BRIDGE,
    OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_EXTERNAL_IDS,
    OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_ID,
    OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_IPFIX,
    OVSREC_FLOW_SAMPLE_COLLECTOR_SET_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_flow_sample_collector_set_columns[OVSREC_FLOW_SAMPLE_COLLECTOR_SET_N_COLUMNS];
]]

---[[
exports.ovsrec_flow_sample_collector_set_col_bridge = (Lib_vswitch_idl.ovsrec_flow_sample_collector_set_columns[ffi.C.OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_BRIDGE])
exports.ovsrec_flow_sample_collector_set_col_external_ids = (Lib_vswitch_idl.ovsrec_flow_sample_collector_set_columns[ffi.C.OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_EXTERNAL_IDS])
exports.ovsrec_flow_sample_collector_set_col_id = (Lib_vswitch_idl.ovsrec_flow_sample_collector_set_columns[ffi.C.OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_ID])
exports.ovsrec_flow_sample_collector_set_col_ipfix = (Lib_vswitch_idl.ovsrec_flow_sample_collector_set_columns[ffi.C.OVSREC_FLOW_SAMPLE_COLLECTOR_SET_COL_IPFIX])
--]]



ffi.cdef[[
const struct ovsrec_flow_sample_collector_set *ovsrec_flow_sample_collector_set_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_flow_sample_collector_set *ovsrec_flow_sample_collector_set_first(const struct ovsdb_idl *);
const struct ovsrec_flow_sample_collector_set *ovsrec_flow_sample_collector_set_next(const struct ovsrec_flow_sample_collector_set *);
]]

--[=[
local function OVSREC_FLOW_SAMPLE_COLLECTOR_SET_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_flow_sample_collector_set_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_flow_sample_collector_set_next(ROW))
local function OVSREC_FLOW_SAMPLE_COLLECTOR_SET_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_flow_sample_collector_set_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_flow_sample_collector_set_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_flow_sample_collector_set_init(struct ovsrec_flow_sample_collector_set *);
void ovsrec_flow_sample_collector_set_delete(const struct ovsrec_flow_sample_collector_set *);
struct ovsrec_flow_sample_collector_set *ovsrec_flow_sample_collector_set_insert(struct ovsdb_idl_txn *);
]]

ffi.cdef[[
void ovsrec_flow_sample_collector_set_verify_bridge(const struct ovsrec_flow_sample_collector_set *);
void ovsrec_flow_sample_collector_set_verify_external_ids(const struct ovsrec_flow_sample_collector_set *);
void ovsrec_flow_sample_collector_set_verify_id(const struct ovsrec_flow_sample_collector_set *);
void ovsrec_flow_sample_collector_set_verify_ipfix(const struct ovsrec_flow_sample_collector_set *);
]]

ffi.cdef[[
const struct ovsdb_datum *ovsrec_flow_sample_collector_set_get_bridge(const struct ovsrec_flow_sample_collector_set *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_flow_sample_collector_set_get_external_ids(const struct ovsrec_flow_sample_collector_set *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_flow_sample_collector_set_get_id(const struct ovsrec_flow_sample_collector_set *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_flow_sample_collector_set_get_ipfix(const struct ovsrec_flow_sample_collector_set *, enum ovsdb_atomic_type key_type);
]]

ffi.cdef[[
void ovsrec_flow_sample_collector_set_set_bridge(const struct ovsrec_flow_sample_collector_set *, const struct ovsrec_bridge *bridge);
void ovsrec_flow_sample_collector_set_set_external_ids(const struct ovsrec_flow_sample_collector_set *, const struct smap *);
void ovsrec_flow_sample_collector_set_set_id(const struct ovsrec_flow_sample_collector_set *, int64_t id);
void ovsrec_flow_sample_collector_set_set_ipfix(const struct ovsrec_flow_sample_collector_set *, const struct ovsrec_ipfix *ipfix);
]]

ffi.cdef[[
/* Flow_Table table. */
struct ovsrec_flow_table {
	struct ovsdb_idl_row header_;

	/* external_ids column. */
	struct smap external_ids;

	/* flow_limit column. */
	int64_t *flow_limit;
	size_t n_flow_limit;

	/* groups column. */
	char **groups;
	size_t n_groups;

	/* name column. */
	char *name;

	/* overflow_policy column. */
	char *overflow_policy;

	/* prefixes column. */
	char **prefixes;
	size_t n_prefixes;
};
]]

ffi.cdef[[
enum {
    OVSREC_FLOW_TABLE_COL_EXTERNAL_IDS,
    OVSREC_FLOW_TABLE_COL_FLOW_LIMIT,
    OVSREC_FLOW_TABLE_COL_GROUPS,
    OVSREC_FLOW_TABLE_COL_NAME,
    OVSREC_FLOW_TABLE_COL_OVERFLOW_POLICY,
    OVSREC_FLOW_TABLE_COL_PREFIXES,
    OVSREC_FLOW_TABLE_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_flow_table_columns[OVSREC_FLOW_TABLE_N_COLUMNS];
]]

---[[
exports.ovsrec_flow_table_col_overflow_policy = (Lib_vswitch_idl.ovsrec_flow_table_columns[ffi.C.OVSREC_FLOW_TABLE_COL_OVERFLOW_POLICY])
exports.ovsrec_flow_table_col_name = (Lib_vswitch_idl.ovsrec_flow_table_columns[ffi.C.OVSREC_FLOW_TABLE_COL_NAME])
exports.ovsrec_flow_table_col_flow_limit = (Lib_vswitch_idl.ovsrec_flow_table_columns[ffi.C.OVSREC_FLOW_TABLE_COL_FLOW_LIMIT])
exports.ovsrec_flow_table_col_prefixes = (Lib_vswitch_idl.ovsrec_flow_table_columns[ffi.C.OVSREC_FLOW_TABLE_COL_PREFIXES])
exports.ovsrec_flow_table_col_groups = (Lib_vswitch_idl.ovsrec_flow_table_columns[ffi.C.OVSREC_FLOW_TABLE_COL_GROUPS])
exports.ovsrec_flow_table_col_external_ids = (Lib_vswitch_idl.ovsrec_flow_table_columns[ffi.C.OVSREC_FLOW_TABLE_COL_EXTERNAL_IDS])
--]]



ffi.cdef[[
const struct ovsrec_flow_table *ovsrec_flow_table_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_flow_table *ovsrec_flow_table_first(const struct ovsdb_idl *);
const struct ovsrec_flow_table *ovsrec_flow_table_next(const struct ovsrec_flow_table *);
]]

--[=[
local function OVSREC_FLOW_TABLE_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_flow_table_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_flow_table_next(ROW))
local function OVSREC_FLOW_TABLE_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_flow_table_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_flow_table_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_flow_table_init(struct ovsrec_flow_table *);
void ovsrec_flow_table_delete(const struct ovsrec_flow_table *);
struct ovsrec_flow_table *ovsrec_flow_table_insert(struct ovsdb_idl_txn *);
]]

ffi.cdef[[
void ovsrec_flow_table_verify_external_ids(const struct ovsrec_flow_table *);
void ovsrec_flow_table_verify_flow_limit(const struct ovsrec_flow_table *);
void ovsrec_flow_table_verify_groups(const struct ovsrec_flow_table *);
void ovsrec_flow_table_verify_name(const struct ovsrec_flow_table *);
void ovsrec_flow_table_verify_overflow_policy(const struct ovsrec_flow_table *);
void ovsrec_flow_table_verify_prefixes(const struct ovsrec_flow_table *);
]]

ffi.cdef[[
const struct ovsdb_datum *ovsrec_flow_table_get_external_ids(const struct ovsrec_flow_table *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_flow_table_get_flow_limit(const struct ovsrec_flow_table *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_flow_table_get_groups(const struct ovsrec_flow_table *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_flow_table_get_name(const struct ovsrec_flow_table *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_flow_table_get_overflow_policy(const struct ovsrec_flow_table *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_flow_table_get_prefixes(const struct ovsrec_flow_table *, enum ovsdb_atomic_type key_type);
]]

ffi.cdef[[
void ovsrec_flow_table_set_external_ids(const struct ovsrec_flow_table *, const struct smap *);
void ovsrec_flow_table_set_flow_limit(const struct ovsrec_flow_table *, const int64_t *flow_limit, size_t n_flow_limit);
void ovsrec_flow_table_set_groups(const struct ovsrec_flow_table *, const char **groups, size_t n_groups);
void ovsrec_flow_table_set_name(const struct ovsrec_flow_table *, const char *name);
void ovsrec_flow_table_set_overflow_policy(const struct ovsrec_flow_table *, const char *overflow_policy);
void ovsrec_flow_table_set_prefixes(const struct ovsrec_flow_table *, const char **prefixes, size_t n_prefixes);
]]

ffi.cdef[[
/* IPFIX table. */
struct ovsrec_ipfix {
	struct ovsdb_idl_row header_;

	/* cache_active_timeout column. */
	int64_t *cache_active_timeout;
	size_t n_cache_active_timeout;

	/* cache_max_flows column. */
	int64_t *cache_max_flows;
	size_t n_cache_max_flows;

	/* external_ids column. */
	struct smap external_ids;

	/* obs_domain_id column. */
	int64_t *obs_domain_id;
	size_t n_obs_domain_id;

	/* obs_point_id column. */
	int64_t *obs_point_id;
	size_t n_obs_point_id;

	/* other_config column. */
	struct smap other_config;

	/* sampling column. */
	int64_t *sampling;
	size_t n_sampling;

	/* targets column. */
	char **targets;
	size_t n_targets;
};
]]

ffi.cdef[[
enum {
    OVSREC_IPFIX_COL_CACHE_ACTIVE_TIMEOUT,
    OVSREC_IPFIX_COL_CACHE_MAX_FLOWS,
    OVSREC_IPFIX_COL_EXTERNAL_IDS,
    OVSREC_IPFIX_COL_OBS_DOMAIN_ID,
    OVSREC_IPFIX_COL_OBS_POINT_ID,
    OVSREC_IPFIX_COL_OTHER_CONFIG,
    OVSREC_IPFIX_COL_SAMPLING,
    OVSREC_IPFIX_COL_TARGETS,
    OVSREC_IPFIX_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_ipfix_columns[OVSREC_IPFIX_N_COLUMNS];
]]

---[[
exports.ovsrec_ipfix_col_obs_point_id = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_OBS_POINT_ID])
exports.ovsrec_ipfix_col_cache_active_timeout = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_CACHE_ACTIVE_TIMEOUT])
exports.ovsrec_ipfix_col_cache_max_flows = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_CACHE_MAX_FLOWS])
exports.ovsrec_ipfix_col_obs_domain_id = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_OBS_DOMAIN_ID])
exports.ovsrec_ipfix_col_other_config = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_OTHER_CONFIG])
exports.ovsrec_ipfix_col_external_ids = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_EXTERNAL_IDS])
exports.ovsrec_ipfix_col_sampling = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_SAMPLING])
exports.ovsrec_ipfix_col_targets = (Lib_vswitch_idl.ovsrec_ipfix_columns[ffi.C.OVSREC_IPFIX_COL_TARGETS])
--]]



ffi.cdef[[
const struct ovsrec_ipfix *ovsrec_ipfix_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_ipfix *ovsrec_ipfix_first(const struct ovsdb_idl *);
const struct ovsrec_ipfix *ovsrec_ipfix_next(const struct ovsrec_ipfix *);
]]

--[=[
local function OVSREC_IPFIX_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_ipfix_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_ipfix_next(ROW))
local function OVSREC_IPFIX_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_ipfix_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_ipfix_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_ipfix_init(struct ovsrec_ipfix *);
void ovsrec_ipfix_delete(const struct ovsrec_ipfix *);
struct ovsrec_ipfix *ovsrec_ipfix_insert(struct ovsdb_idl_txn *);
]]

ffi.cdef[[
void ovsrec_ipfix_verify_cache_active_timeout(const struct ovsrec_ipfix *);
void ovsrec_ipfix_verify_cache_max_flows(const struct ovsrec_ipfix *);
void ovsrec_ipfix_verify_external_ids(const struct ovsrec_ipfix *);
void ovsrec_ipfix_verify_obs_domain_id(const struct ovsrec_ipfix *);
void ovsrec_ipfix_verify_obs_point_id(const struct ovsrec_ipfix *);
void ovsrec_ipfix_verify_other_config(const struct ovsrec_ipfix *);
void ovsrec_ipfix_verify_sampling(const struct ovsrec_ipfix *);
void ovsrec_ipfix_verify_targets(const struct ovsrec_ipfix *);
]]

ffi.cdef[[
const struct ovsdb_datum *ovsrec_ipfix_get_cache_active_timeout(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ipfix_get_cache_max_flows(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ipfix_get_external_ids(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_ipfix_get_obs_domain_id(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ipfix_get_obs_point_id(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ipfix_get_other_config(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_ipfix_get_sampling(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ipfix_get_targets(const struct ovsrec_ipfix *, enum ovsdb_atomic_type key_type);
]]

ffi.cdef[[
void ovsrec_ipfix_set_cache_active_timeout(const struct ovsrec_ipfix *, const int64_t *cache_active_timeout, size_t n_cache_active_timeout);
void ovsrec_ipfix_set_cache_max_flows(const struct ovsrec_ipfix *, const int64_t *cache_max_flows, size_t n_cache_max_flows);
void ovsrec_ipfix_set_external_ids(const struct ovsrec_ipfix *, const struct smap *);
void ovsrec_ipfix_set_obs_domain_id(const struct ovsrec_ipfix *, const int64_t *obs_domain_id, size_t n_obs_domain_id);
void ovsrec_ipfix_set_obs_point_id(const struct ovsrec_ipfix *, const int64_t *obs_point_id, size_t n_obs_point_id);
void ovsrec_ipfix_set_other_config(const struct ovsrec_ipfix *, const struct smap *);
void ovsrec_ipfix_set_sampling(const struct ovsrec_ipfix *, const int64_t *sampling, size_t n_sampling);
void ovsrec_ipfix_set_targets(const struct ovsrec_ipfix *, const char **targets, size_t n_targets);
]]

ffi.cdef[[
/* Interface table. */
struct ovsrec_interface {
	struct ovsdb_idl_row header_;

	/* admin_state column. */
	char *admin_state;

	/* bfd column. */
	struct smap bfd;

	/* bfd_status column. */
	struct smap bfd_status;

	/* cfm_fault column. */
	bool *cfm_fault;
	size_t n_cfm_fault;

	/* cfm_fault_status column. */
	char **cfm_fault_status;
	size_t n_cfm_fault_status;

	/* cfm_flap_count column. */
	int64_t *cfm_flap_count;
	size_t n_cfm_flap_count;

	/* cfm_health column. */
	int64_t *cfm_health;
	size_t n_cfm_health;

	/* cfm_mpid column. */
	int64_t *cfm_mpid;
	size_t n_cfm_mpid;

	/* cfm_remote_mpids column. */
	int64_t *cfm_remote_mpids;
	size_t n_cfm_remote_mpids;

	/* cfm_remote_opstate column. */
	char *cfm_remote_opstate;

	/* duplex column. */
	char *duplex;

	/* error column. */
	char *error;

	/* external_ids column. */
	struct smap external_ids;

	/* ifindex column. */
	int64_t *ifindex;
	size_t n_ifindex;

	/* ingress_policing_burst column. */
	int64_t ingress_policing_burst;

	/* ingress_policing_rate column. */
	int64_t ingress_policing_rate;

	/* lacp_current column. */
	bool *lacp_current;
	size_t n_lacp_current;

	/* link_resets column. */
	int64_t *link_resets;
	size_t n_link_resets;

	/* link_speed column. */
	int64_t *link_speed;
	size_t n_link_speed;

	/* link_state column. */
	char *link_state;

	/* lldp column. */
	struct smap lldp;

	/* mac column. */
	char *mac;

	/* mac_in_use column. */
	char *mac_in_use;

	/* mtu column. */
	int64_t *mtu;
	size_t n_mtu;

	/* name column. */
	char *name;	/* Always nonnull. */

	/* ofport column. */
	int64_t *ofport;
	size_t n_ofport;

	/* ofport_request column. */
	int64_t *ofport_request;
	size_t n_ofport_request;

	/* options column. */
	struct smap options;

	/* other_config column. */
	struct smap other_config;

	/* statistics column. */
	char **key_statistics;
	int64_t *value_statistics;
	size_t n_statistics;

	/* status column. */
	struct smap status;

	/* type column. */
	char *type;	/* Always nonnull. */
};

enum {
    OVSREC_INTERFACE_COL_ADMIN_STATE,
    OVSREC_INTERFACE_COL_BFD,
    OVSREC_INTERFACE_COL_BFD_STATUS,
    OVSREC_INTERFACE_COL_CFM_FAULT,
    OVSREC_INTERFACE_COL_CFM_FAULT_STATUS,
    OVSREC_INTERFACE_COL_CFM_FLAP_COUNT,
    OVSREC_INTERFACE_COL_CFM_HEALTH,
    OVSREC_INTERFACE_COL_CFM_MPID,
    OVSREC_INTERFACE_COL_CFM_REMOTE_MPIDS,
    OVSREC_INTERFACE_COL_CFM_REMOTE_OPSTATE,
    OVSREC_INTERFACE_COL_DUPLEX,
    OVSREC_INTERFACE_COL_ERROR,
    OVSREC_INTERFACE_COL_EXTERNAL_IDS,
    OVSREC_INTERFACE_COL_IFINDEX,
    OVSREC_INTERFACE_COL_INGRESS_POLICING_BURST,
    OVSREC_INTERFACE_COL_INGRESS_POLICING_RATE,
    OVSREC_INTERFACE_COL_LACP_CURRENT,
    OVSREC_INTERFACE_COL_LINK_RESETS,
    OVSREC_INTERFACE_COL_LINK_SPEED,
    OVSREC_INTERFACE_COL_LINK_STATE,
    OVSREC_INTERFACE_COL_LLDP,
    OVSREC_INTERFACE_COL_MAC,
    OVSREC_INTERFACE_COL_MAC_IN_USE,
    OVSREC_INTERFACE_COL_MTU,
    OVSREC_INTERFACE_COL_NAME,
    OVSREC_INTERFACE_COL_OFPORT,
    OVSREC_INTERFACE_COL_OFPORT_REQUEST,
    OVSREC_INTERFACE_COL_OPTIONS,
    OVSREC_INTERFACE_COL_OTHER_CONFIG,
    OVSREC_INTERFACE_COL_STATISTICS,
    OVSREC_INTERFACE_COL_STATUS,
    OVSREC_INTERFACE_COL_TYPE,
    OVSREC_INTERFACE_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_interface_columns[OVSREC_INTERFACE_N_COLUMNS];
]]

---[[
exports.ovsrec_interface_col_cfm_remote_opstate = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_CFM_REMOTE_OPSTATE])
exports.ovsrec_interface_col_link_state = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_LINK_STATE])
exports.ovsrec_interface_col_cfm_fault = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_CFM_FAULT])
exports.ovsrec_interface_col_ofport_request = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_OFPORT_REQUEST])
exports.ovsrec_interface_col_ingress_policing_rate = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_INGRESS_POLICING_RATE])
exports.ovsrec_interface_col_link_resets = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_LINK_RESETS])
exports.ovsrec_interface_col_statistics = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_STATISTICS])
exports.ovsrec_interface_col_bfd = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_BFD])
exports.ovsrec_interface_col_duplex = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_DUPLEX])
exports.ovsrec_interface_col_mac_in_use = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_MAC_IN_USE])
exports.ovsrec_interface_col_bfd_status = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_BFD_STATUS])
exports.ovsrec_interface_col_type = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_TYPE])
exports.ovsrec_interface_col_lacp_current = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_LACP_CURRENT])
exports.ovsrec_interface_col_status = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_STATUS])
exports.ovsrec_interface_col_lldp = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_LLDP])
exports.ovsrec_interface_col_ingress_policing_burst = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_INGRESS_POLICING_BURST])
exports.ovsrec_interface_col_cfm_health = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_CFM_HEALTH])
exports.ovsrec_interface_col_error = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_ERROR])
exports.ovsrec_interface_col_mac = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_MAC])
exports.ovsrec_interface_col_admin_state = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_ADMIN_STATE])
exports.ovsrec_interface_col_external_ids = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_EXTERNAL_IDS])
exports.ovsrec_interface_col_ofport = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_OFPORT])
exports.ovsrec_interface_col_name = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_NAME])
exports.ovsrec_interface_col_other_config = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_OTHER_CONFIG])
exports.ovsrec_interface_col_link_speed = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_LINK_SPEED])
exports.ovsrec_interface_col_mtu = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_MTU])
exports.ovsrec_interface_col_cfm_flap_count = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_CFM_FLAP_COUNT])
exports.ovsrec_interface_col_cfm_mpid = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_CFM_MPID])
exports.ovsrec_interface_col_ifindex = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_IFINDEX])
exports.ovsrec_interface_col_options = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_OPTIONS])
exports.ovsrec_interface_col_cfm_fault_status = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_CFM_FAULT_STATUS])
exports.ovsrec_interface_col_cfm_remote_mpids = (Lib_vswitch_idl.ovsrec_interface_columns[ffi.C.OVSREC_INTERFACE_COL_CFM_REMOTE_MPIDS])
--]]

ffi.cdef[[
const struct ovsrec_interface *ovsrec_interface_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_interface *ovsrec_interface_first(const struct ovsdb_idl *);
const struct ovsrec_interface *ovsrec_interface_next(const struct ovsrec_interface *);
]]

--[=[
local function OVSREC_INTERFACE_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_interface_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_interface_next(ROW))
local function OVSREC_INTERFACE_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_interface_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_interface_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_interface_init(struct ovsrec_interface *);
void ovsrec_interface_delete(const struct ovsrec_interface *);
struct ovsrec_interface *ovsrec_interface_insert(struct ovsdb_idl_txn *);

void ovsrec_interface_verify_admin_state(const struct ovsrec_interface *);
void ovsrec_interface_verify_bfd(const struct ovsrec_interface *);
void ovsrec_interface_verify_bfd_status(const struct ovsrec_interface *);
void ovsrec_interface_verify_cfm_fault(const struct ovsrec_interface *);
void ovsrec_interface_verify_cfm_fault_status(const struct ovsrec_interface *);
void ovsrec_interface_verify_cfm_flap_count(const struct ovsrec_interface *);
void ovsrec_interface_verify_cfm_health(const struct ovsrec_interface *);
void ovsrec_interface_verify_cfm_mpid(const struct ovsrec_interface *);
void ovsrec_interface_verify_cfm_remote_mpids(const struct ovsrec_interface *);
void ovsrec_interface_verify_cfm_remote_opstate(const struct ovsrec_interface *);
void ovsrec_interface_verify_duplex(const struct ovsrec_interface *);
void ovsrec_interface_verify_error(const struct ovsrec_interface *);
void ovsrec_interface_verify_external_ids(const struct ovsrec_interface *);
void ovsrec_interface_verify_ifindex(const struct ovsrec_interface *);
void ovsrec_interface_verify_ingress_policing_burst(const struct ovsrec_interface *);
void ovsrec_interface_verify_ingress_policing_rate(const struct ovsrec_interface *);
void ovsrec_interface_verify_lacp_current(const struct ovsrec_interface *);
void ovsrec_interface_verify_link_resets(const struct ovsrec_interface *);
void ovsrec_interface_verify_link_speed(const struct ovsrec_interface *);
void ovsrec_interface_verify_link_state(const struct ovsrec_interface *);
void ovsrec_interface_verify_lldp(const struct ovsrec_interface *);
void ovsrec_interface_verify_mac(const struct ovsrec_interface *);
void ovsrec_interface_verify_mac_in_use(const struct ovsrec_interface *);
void ovsrec_interface_verify_mtu(const struct ovsrec_interface *);
void ovsrec_interface_verify_name(const struct ovsrec_interface *);
void ovsrec_interface_verify_ofport(const struct ovsrec_interface *);
void ovsrec_interface_verify_ofport_request(const struct ovsrec_interface *);
void ovsrec_interface_verify_options(const struct ovsrec_interface *);
void ovsrec_interface_verify_other_config(const struct ovsrec_interface *);
void ovsrec_interface_verify_statistics(const struct ovsrec_interface *);
void ovsrec_interface_verify_status(const struct ovsrec_interface *);
void ovsrec_interface_verify_type(const struct ovsrec_interface *);

const struct ovsdb_datum *ovsrec_interface_get_admin_state(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_bfd(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_bfd_status(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_cfm_fault(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_cfm_fault_status(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_cfm_flap_count(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_cfm_health(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_cfm_mpid(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_cfm_remote_mpids(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_cfm_remote_opstate(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_duplex(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_error(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_external_ids(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_ifindex(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_ingress_policing_burst(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_ingress_policing_rate(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_lacp_current(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_link_resets(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_link_speed(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_link_state(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_lldp(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_mac(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_mac_in_use(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_mtu(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_name(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_ofport(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_ofport_request(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_interface_get_options(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_other_config(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_statistics(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_status(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_interface_get_type(const struct ovsrec_interface *, enum ovsdb_atomic_type key_type);

void ovsrec_interface_set_admin_state(const struct ovsrec_interface *, const char *admin_state);
void ovsrec_interface_set_bfd(const struct ovsrec_interface *, const struct smap *);
void ovsrec_interface_set_bfd_status(const struct ovsrec_interface *, const struct smap *);
void ovsrec_interface_set_cfm_fault(const struct ovsrec_interface *, const bool *cfm_fault, size_t n_cfm_fault);
void ovsrec_interface_set_cfm_fault_status(const struct ovsrec_interface *, const char **cfm_fault_status, size_t n_cfm_fault_status);
void ovsrec_interface_set_cfm_flap_count(const struct ovsrec_interface *, const int64_t *cfm_flap_count, size_t n_cfm_flap_count);
void ovsrec_interface_set_cfm_health(const struct ovsrec_interface *, const int64_t *cfm_health, size_t n_cfm_health);
void ovsrec_interface_set_cfm_mpid(const struct ovsrec_interface *, const int64_t *cfm_mpid, size_t n_cfm_mpid);
void ovsrec_interface_set_cfm_remote_mpids(const struct ovsrec_interface *, const int64_t *cfm_remote_mpids, size_t n_cfm_remote_mpids);
void ovsrec_interface_set_cfm_remote_opstate(const struct ovsrec_interface *, const char *cfm_remote_opstate);
void ovsrec_interface_set_duplex(const struct ovsrec_interface *, const char *duplex);
void ovsrec_interface_set_error(const struct ovsrec_interface *, const char *error);
void ovsrec_interface_set_external_ids(const struct ovsrec_interface *, const struct smap *);
void ovsrec_interface_set_ifindex(const struct ovsrec_interface *, const int64_t *ifindex, size_t n_ifindex);
void ovsrec_interface_set_ingress_policing_burst(const struct ovsrec_interface *, int64_t ingress_policing_burst);
void ovsrec_interface_set_ingress_policing_rate(const struct ovsrec_interface *, int64_t ingress_policing_rate);
void ovsrec_interface_set_lacp_current(const struct ovsrec_interface *, const bool *lacp_current, size_t n_lacp_current);
void ovsrec_interface_set_link_resets(const struct ovsrec_interface *, const int64_t *link_resets, size_t n_link_resets);
void ovsrec_interface_set_link_speed(const struct ovsrec_interface *, const int64_t *link_speed, size_t n_link_speed);
void ovsrec_interface_set_link_state(const struct ovsrec_interface *, const char *link_state);
void ovsrec_interface_set_lldp(const struct ovsrec_interface *, const struct smap *);
void ovsrec_interface_set_mac(const struct ovsrec_interface *, const char *mac);
void ovsrec_interface_set_mac_in_use(const struct ovsrec_interface *, const char *mac_in_use);
void ovsrec_interface_set_mtu(const struct ovsrec_interface *, const int64_t *mtu, size_t n_mtu);
void ovsrec_interface_set_name(const struct ovsrec_interface *, const char *name);
void ovsrec_interface_set_ofport(const struct ovsrec_interface *, const int64_t *ofport, size_t n_ofport);
void ovsrec_interface_set_ofport_request(const struct ovsrec_interface *, const int64_t *ofport_request, size_t n_ofport_request);
void ovsrec_interface_set_options(const struct ovsrec_interface *, const struct smap *);
void ovsrec_interface_set_other_config(const struct ovsrec_interface *, const struct smap *);
void ovsrec_interface_set_statistics(const struct ovsrec_interface *, const char **key_statistics, const int64_t *value_statistics, size_t n_statistics);
void ovsrec_interface_set_status(const struct ovsrec_interface *, const struct smap *);
void ovsrec_interface_set_type(const struct ovsrec_interface *, const char *type);
]]

ffi.cdef[[
/* Manager table. */
struct ovsrec_manager {
	struct ovsdb_idl_row header_;

	/* connection_mode column. */
	char *connection_mode;

	/* external_ids column. */
	struct smap external_ids;

	/* inactivity_probe column. */
	int64_t *inactivity_probe;
	size_t n_inactivity_probe;

	/* is_connected column. */
	bool is_connected;

	/* max_backoff column. */
	int64_t *max_backoff;
	size_t n_max_backoff;

	/* other_config column. */
	struct smap other_config;

	/* status column. */
	struct smap status;

	/* target column. */
	char *target;	/* Always nonnull. */
};

enum {
    OVSREC_MANAGER_COL_CONNECTION_MODE,
    OVSREC_MANAGER_COL_EXTERNAL_IDS,
    OVSREC_MANAGER_COL_INACTIVITY_PROBE,
    OVSREC_MANAGER_COL_IS_CONNECTED,
    OVSREC_MANAGER_COL_MAX_BACKOFF,
    OVSREC_MANAGER_COL_OTHER_CONFIG,
    OVSREC_MANAGER_COL_STATUS,
    OVSREC_MANAGER_COL_TARGET,
    OVSREC_MANAGER_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_manager_columns[OVSREC_MANAGER_N_COLUMNS];
]]

---[[
exports.ovsrec_manager_col_max_backoff = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_MAX_BACKOFF])
exports.ovsrec_manager_col_status = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_STATUS])
exports.ovsrec_manager_col_target = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_TARGET])
exports.ovsrec_manager_col_connection_mode = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_CONNECTION_MODE])
exports.ovsrec_manager_col_other_config = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_OTHER_CONFIG])
exports.ovsrec_manager_col_inactivity_probe = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_INACTIVITY_PROBE])
exports.ovsrec_manager_col_external_ids = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_EXTERNAL_IDS])
exports.ovsrec_manager_col_is_connected = (Lib_vswitch_idl.ovsrec_manager_columns[ffi.C.OVSREC_MANAGER_COL_IS_CONNECTED])
--]]

ffi.cdef[[
const struct ovsrec_manager *ovsrec_manager_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_manager *ovsrec_manager_first(const struct ovsdb_idl *);
const struct ovsrec_manager *ovsrec_manager_next(const struct ovsrec_manager *);
]]

--[=[
local function OVSREC_MANAGER_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_manager_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_manager_next(ROW))
local function OVSREC_MANAGER_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_manager_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_manager_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_manager_init(struct ovsrec_manager *);
void ovsrec_manager_delete(const struct ovsrec_manager *);
struct ovsrec_manager *ovsrec_manager_insert(struct ovsdb_idl_txn *);

void ovsrec_manager_verify_connection_mode(const struct ovsrec_manager *);
void ovsrec_manager_verify_external_ids(const struct ovsrec_manager *);
void ovsrec_manager_verify_inactivity_probe(const struct ovsrec_manager *);
void ovsrec_manager_verify_is_connected(const struct ovsrec_manager *);
void ovsrec_manager_verify_max_backoff(const struct ovsrec_manager *);
void ovsrec_manager_verify_other_config(const struct ovsrec_manager *);
void ovsrec_manager_verify_status(const struct ovsrec_manager *);
void ovsrec_manager_verify_target(const struct ovsrec_manager *);

const struct ovsdb_datum *ovsrec_manager_get_connection_mode(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_manager_get_external_ids(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_manager_get_inactivity_probe(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_manager_get_is_connected(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_manager_get_max_backoff(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_manager_get_other_config(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_manager_get_status(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_manager_get_target(const struct ovsrec_manager *, enum ovsdb_atomic_type key_type);

void ovsrec_manager_set_connection_mode(const struct ovsrec_manager *, const char *connection_mode);
void ovsrec_manager_set_external_ids(const struct ovsrec_manager *, const struct smap *);
void ovsrec_manager_set_inactivity_probe(const struct ovsrec_manager *, const int64_t *inactivity_probe, size_t n_inactivity_probe);
void ovsrec_manager_set_is_connected(const struct ovsrec_manager *, bool is_connected);
void ovsrec_manager_set_max_backoff(const struct ovsrec_manager *, const int64_t *max_backoff, size_t n_max_backoff);
void ovsrec_manager_set_other_config(const struct ovsrec_manager *, const struct smap *);
void ovsrec_manager_set_status(const struct ovsrec_manager *, const struct smap *);
void ovsrec_manager_set_target(const struct ovsrec_manager *, const char *target);
]]

ffi.cdef[[
/* Mirror table. */
struct ovsrec_mirror {
	struct ovsdb_idl_row header_;

	/* external_ids column. */
	struct smap external_ids;

	/* name column. */
	char *name;	/* Always nonnull. */

	/* output_port column. */
	struct ovsrec_port *output_port;

	/* output_vlan column. */
	int64_t *output_vlan;
	size_t n_output_vlan;

	/* select_all column. */
	bool select_all;

	/* select_dst_port column. */
	struct ovsrec_port **select_dst_port;
	size_t n_select_dst_port;

	/* select_src_port column. */
	struct ovsrec_port **select_src_port;
	size_t n_select_src_port;

	/* select_vlan column. */
	int64_t *select_vlan;
	size_t n_select_vlan;

	/* statistics column. */
	char **key_statistics;
	int64_t *value_statistics;
	size_t n_statistics;
};

enum {
    OVSREC_MIRROR_COL_EXTERNAL_IDS,
    OVSREC_MIRROR_COL_NAME,
    OVSREC_MIRROR_COL_OUTPUT_PORT,
    OVSREC_MIRROR_COL_OUTPUT_VLAN,
    OVSREC_MIRROR_COL_SELECT_ALL,
    OVSREC_MIRROR_COL_SELECT_DST_PORT,
    OVSREC_MIRROR_COL_SELECT_SRC_PORT,
    OVSREC_MIRROR_COL_SELECT_VLAN,
    OVSREC_MIRROR_COL_STATISTICS,
    OVSREC_MIRROR_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_mirror_columns[OVSREC_MIRROR_N_COLUMNS];
]]

---[[
exports.ovsrec_mirror_col_output_port = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_OUTPUT_PORT])
exports.ovsrec_mirror_col_select_src_port = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_SELECT_SRC_PORT])
exports.ovsrec_mirror_col_statistics = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_STATISTICS])
exports.ovsrec_mirror_col_name = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_NAME])
exports.ovsrec_mirror_col_select_all = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_SELECT_ALL])
exports.ovsrec_mirror_col_select_dst_port = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_SELECT_DST_PORT])
exports.ovsrec_mirror_col_external_ids = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_EXTERNAL_IDS])
exports.ovsrec_mirror_col_output_vlan = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_OUTPUT_VLAN])
exports.ovsrec_mirror_col_select_vlan = (Lib_vswitch_idl.ovsrec_mirror_columns[ffi.C.OVSREC_MIRROR_COL_SELECT_VLAN])
--]]

ffi.cdef[[
const struct ovsrec_mirror *ovsrec_mirror_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_mirror *ovsrec_mirror_first(const struct ovsdb_idl *);
const struct ovsrec_mirror *ovsrec_mirror_next(const struct ovsrec_mirror *);
]]

--[=[
local function OVSREC_MIRROR_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_mirror_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_mirror_next(ROW))
local function OVSREC_MIRROR_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_mirror_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_mirror_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_mirror_init(struct ovsrec_mirror *);
void ovsrec_mirror_delete(const struct ovsrec_mirror *);
struct ovsrec_mirror *ovsrec_mirror_insert(struct ovsdb_idl_txn *);

void ovsrec_mirror_verify_external_ids(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_name(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_output_port(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_output_vlan(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_select_all(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_select_dst_port(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_select_src_port(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_select_vlan(const struct ovsrec_mirror *);
void ovsrec_mirror_verify_statistics(const struct ovsrec_mirror *);

const struct ovsdb_datum *ovsrec_mirror_get_external_ids(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_mirror_get_name(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_mirror_get_output_port(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_mirror_get_output_vlan(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_mirror_get_select_all(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_mirror_get_select_dst_port(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_mirror_get_select_src_port(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_mirror_get_select_vlan(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_mirror_get_statistics(const struct ovsrec_mirror *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);

void ovsrec_mirror_set_external_ids(const struct ovsrec_mirror *, const struct smap *);
void ovsrec_mirror_set_name(const struct ovsrec_mirror *, const char *name);
void ovsrec_mirror_set_output_port(const struct ovsrec_mirror *, const struct ovsrec_port *output_port);
void ovsrec_mirror_set_output_vlan(const struct ovsrec_mirror *, const int64_t *output_vlan, size_t n_output_vlan);
void ovsrec_mirror_set_select_all(const struct ovsrec_mirror *, bool select_all);
void ovsrec_mirror_set_select_dst_port(const struct ovsrec_mirror *, struct ovsrec_port **select_dst_port, size_t n_select_dst_port);
void ovsrec_mirror_set_select_src_port(const struct ovsrec_mirror *, struct ovsrec_port **select_src_port, size_t n_select_src_port);
void ovsrec_mirror_set_select_vlan(const struct ovsrec_mirror *, const int64_t *select_vlan, size_t n_select_vlan);
void ovsrec_mirror_set_statistics(const struct ovsrec_mirror *, const char **key_statistics, const int64_t *value_statistics, size_t n_statistics);
]]

ffi.cdef[[
/* NetFlow table. */
struct ovsrec_netflow {
	struct ovsdb_idl_row header_;

	/* active_timeout column. */
	int64_t active_timeout;

	/* add_id_to_interface column. */
	bool add_id_to_interface;

	/* engine_id column. */
	int64_t *engine_id;
	size_t n_engine_id;

	/* engine_type column. */
	int64_t *engine_type;
	size_t n_engine_type;

	/* external_ids column. */
	struct smap external_ids;

	/* targets column. */
	char **targets;
	size_t n_targets;
};

enum {
    OVSREC_NETFLOW_COL_ACTIVE_TIMEOUT,
    OVSREC_NETFLOW_COL_ADD_ID_TO_INTERFACE,
    OVSREC_NETFLOW_COL_ENGINE_ID,
    OVSREC_NETFLOW_COL_ENGINE_TYPE,
    OVSREC_NETFLOW_COL_EXTERNAL_IDS,
    OVSREC_NETFLOW_COL_TARGETS,
    OVSREC_NETFLOW_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_netflow_columns[OVSREC_NETFLOW_N_COLUMNS];
]]

---[[
exports.ovsrec_netflow_col_engine_id = (Lib_vswitch_idl.ovsrec_netflow_columns[ffi.C.OVSREC_NETFLOW_COL_ENGINE_ID])
exports.ovsrec_netflow_col_active_timeout = (Lib_vswitch_idl.ovsrec_netflow_columns[ffi.C.OVSREC_NETFLOW_COL_ACTIVE_TIMEOUT])
exports.ovsrec_netflow_col_add_id_to_interface = (Lib_vswitch_idl.ovsrec_netflow_columns[ffi.C.OVSREC_NETFLOW_COL_ADD_ID_TO_INTERFACE])
exports.ovsrec_netflow_col_external_ids = (Lib_vswitch_idl.ovsrec_netflow_columns[ffi.C.OVSREC_NETFLOW_COL_EXTERNAL_IDS])
exports.ovsrec_netflow_col_targets = (Lib_vswitch_idl.ovsrec_netflow_columns[ffi.C.OVSREC_NETFLOW_COL_TARGETS])
exports.ovsrec_netflow_col_engine_type = (Lib_vswitch_idl.ovsrec_netflow_columns[ffi.C.OVSREC_NETFLOW_COL_ENGINE_TYPE])
--]]


ffi.cdef[[
const struct ovsrec_netflow *ovsrec_netflow_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_netflow *ovsrec_netflow_first(const struct ovsdb_idl *);
const struct ovsrec_netflow *ovsrec_netflow_next(const struct ovsrec_netflow *);
]]

--[=[
local function OVSREC_NETFLOW_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_netflow_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_netflow_next(ROW))
local function OVSREC_NETFLOW_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_netflow_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_netflow_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_netflow_init(struct ovsrec_netflow *);
void ovsrec_netflow_delete(const struct ovsrec_netflow *);
struct ovsrec_netflow *ovsrec_netflow_insert(struct ovsdb_idl_txn *);

void ovsrec_netflow_verify_active_timeout(const struct ovsrec_netflow *);
void ovsrec_netflow_verify_add_id_to_interface(const struct ovsrec_netflow *);
void ovsrec_netflow_verify_engine_id(const struct ovsrec_netflow *);
void ovsrec_netflow_verify_engine_type(const struct ovsrec_netflow *);
void ovsrec_netflow_verify_external_ids(const struct ovsrec_netflow *);
void ovsrec_netflow_verify_targets(const struct ovsrec_netflow *);

const struct ovsdb_datum *ovsrec_netflow_get_active_timeout(const struct ovsrec_netflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_netflow_get_add_id_to_interface(const struct ovsrec_netflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_netflow_get_engine_id(const struct ovsrec_netflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_netflow_get_engine_type(const struct ovsrec_netflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_netflow_get_external_ids(const struct ovsrec_netflow *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_netflow_get_targets(const struct ovsrec_netflow *, enum ovsdb_atomic_type key_type);

void ovsrec_netflow_set_active_timeout(const struct ovsrec_netflow *, int64_t active_timeout);
void ovsrec_netflow_set_add_id_to_interface(const struct ovsrec_netflow *, bool add_id_to_interface);
void ovsrec_netflow_set_engine_id(const struct ovsrec_netflow *, const int64_t *engine_id, size_t n_engine_id);
void ovsrec_netflow_set_engine_type(const struct ovsrec_netflow *, const int64_t *engine_type, size_t n_engine_type);
void ovsrec_netflow_set_external_ids(const struct ovsrec_netflow *, const struct smap *);
void ovsrec_netflow_set_targets(const struct ovsrec_netflow *, const char **targets, size_t n_targets);
]]

ffi.cdef[[
/* Open_vSwitch table. */
struct ovsrec_open_vswitch {
	struct ovsdb_idl_row header_;

	/* bridges column. */
	struct ovsrec_bridge **bridges;
	size_t n_bridges;

	/* cur_cfg column. */
	int64_t cur_cfg;

	/* datapath_types column. */
	char **datapath_types;
	size_t n_datapath_types;

	/* db_version column. */
	char *db_version;

	/* external_ids column. */
	struct smap external_ids;

	/* iface_types column. */
	char **iface_types;
	size_t n_iface_types;

	/* manager_options column. */
	struct ovsrec_manager **manager_options;
	size_t n_manager_options;

	/* next_cfg column. */
	int64_t next_cfg;

	/* other_config column. */
	struct smap other_config;

	/* ovs_version column. */
	char *ovs_version;

	/* ssl column. */
	struct ovsrec_ssl *ssl;

	/* statistics column. */
	struct smap statistics;

	/* system_type column. */
	char *system_type;

	/* system_version column. */
	char *system_version;
};

enum {
    OVSREC_OPEN_VSWITCH_COL_BRIDGES,
    OVSREC_OPEN_VSWITCH_COL_CUR_CFG,
    OVSREC_OPEN_VSWITCH_COL_DATAPATH_TYPES,
    OVSREC_OPEN_VSWITCH_COL_DB_VERSION,
    OVSREC_OPEN_VSWITCH_COL_EXTERNAL_IDS,
    OVSREC_OPEN_VSWITCH_COL_IFACE_TYPES,
    OVSREC_OPEN_VSWITCH_COL_MANAGER_OPTIONS,
    OVSREC_OPEN_VSWITCH_COL_NEXT_CFG,
    OVSREC_OPEN_VSWITCH_COL_OTHER_CONFIG,
    OVSREC_OPEN_VSWITCH_COL_OVS_VERSION,
    OVSREC_OPEN_VSWITCH_COL_SSL,
    OVSREC_OPEN_VSWITCH_COL_STATISTICS,
    OVSREC_OPEN_VSWITCH_COL_SYSTEM_TYPE,
    OVSREC_OPEN_VSWITCH_COL_SYSTEM_VERSION,
    OVSREC_OPEN_VSWITCH_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_open_vswitch_columns[OVSREC_OPEN_VSWITCH_N_COLUMNS];
]]

---[[
exports.ovsrec_open_vswitch_col_db_version = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_DB_VERSION])
exports.ovsrec_open_vswitch_col_statistics = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_STATISTICS])
exports.ovsrec_open_vswitch_col_datapath_types = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_DATAPATH_TYPES])
exports.ovsrec_open_vswitch_col_iface_types = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_IFACE_TYPES])
exports.ovsrec_open_vswitch_col_next_cfg = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_NEXT_CFG])
exports.ovsrec_open_vswitch_col_ovs_version = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_OVS_VERSION])
exports.ovsrec_open_vswitch_col_other_config = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_OTHER_CONFIG])
exports.ovsrec_open_vswitch_col_ssl = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_SSL])
exports.ovsrec_open_vswitch_col_bridges = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_BRIDGES])
exports.ovsrec_open_vswitch_col_external_ids = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_EXTERNAL_IDS])
exports.ovsrec_open_vswitch_col_system_type = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_SYSTEM_TYPE])
exports.ovsrec_open_vswitch_col_system_version = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_SYSTEM_VERSION])
exports.ovsrec_open_vswitch_col_cur_cfg = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_CUR_CFG])
exports.ovsrec_open_vswitch_col_manager_options = (Lib_vswitch_idl.ovsrec_open_vswitch_columns[ffi.C.OVSREC_OPEN_VSWITCH_COL_MANAGER_OPTIONS])
--]]

ffi.cdef[[
const struct ovsrec_open_vswitch *ovsrec_open_vswitch_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_open_vswitch *ovsrec_open_vswitch_first(const struct ovsdb_idl *);
const struct ovsrec_open_vswitch *ovsrec_open_vswitch_next(const struct ovsrec_open_vswitch *);
]]

--[=[
local function OVSREC_OPEN_VSWITCH_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_open_vswitch_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_open_vswitch_next(ROW))
local function OVSREC_OPEN_VSWITCH_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_open_vswitch_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_open_vswitch_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_open_vswitch_init(struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_delete(const struct ovsrec_open_vswitch *);
struct ovsrec_open_vswitch *ovsrec_open_vswitch_insert(struct ovsdb_idl_txn *);
]]

ffi.cdef[[
void ovsrec_open_vswitch_verify_bridges(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_cur_cfg(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_datapath_types(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_db_version(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_external_ids(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_iface_types(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_manager_options(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_next_cfg(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_other_config(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_ovs_version(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_ssl(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_statistics(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_system_type(const struct ovsrec_open_vswitch *);
void ovsrec_open_vswitch_verify_system_version(const struct ovsrec_open_vswitch *);
]]

exports.ovsrec_open_vswitch_verify_bridges = Lib_vswitch_idl.ovsrec_open_vswitch_verify_bridges;

ffi.cdef[[
const struct ovsdb_datum *ovsrec_open_vswitch_get_bridges(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_cur_cfg(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_datapath_types(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_db_version(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_external_ids(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_iface_types(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_manager_options(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_next_cfg(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_other_config(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_ovs_version(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_ssl(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_statistics(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_system_type(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_open_vswitch_get_system_version(const struct ovsrec_open_vswitch *, enum ovsdb_atomic_type key_type);
]]

ffi.cdef[[
void ovsrec_open_vswitch_set_bridges(const struct ovsrec_open_vswitch *, struct ovsrec_bridge **bridges, size_t n_bridges);
void ovsrec_open_vswitch_set_cur_cfg(const struct ovsrec_open_vswitch *, int64_t cur_cfg);
void ovsrec_open_vswitch_set_datapath_types(const struct ovsrec_open_vswitch *, const char **datapath_types, size_t n_datapath_types);
void ovsrec_open_vswitch_set_db_version(const struct ovsrec_open_vswitch *, const char *db_version);
void ovsrec_open_vswitch_set_external_ids(const struct ovsrec_open_vswitch *, const struct smap *);
void ovsrec_open_vswitch_set_iface_types(const struct ovsrec_open_vswitch *, const char **iface_types, size_t n_iface_types);
void ovsrec_open_vswitch_set_manager_options(const struct ovsrec_open_vswitch *, struct ovsrec_manager **manager_options, size_t n_manager_options);
void ovsrec_open_vswitch_set_next_cfg(const struct ovsrec_open_vswitch *, int64_t next_cfg);
void ovsrec_open_vswitch_set_other_config(const struct ovsrec_open_vswitch *, const struct smap *);
void ovsrec_open_vswitch_set_ovs_version(const struct ovsrec_open_vswitch *, const char *ovs_version);
void ovsrec_open_vswitch_set_ssl(const struct ovsrec_open_vswitch *, const struct ovsrec_ssl *ssl);
void ovsrec_open_vswitch_set_statistics(const struct ovsrec_open_vswitch *, const struct smap *);
void ovsrec_open_vswitch_set_system_type(const struct ovsrec_open_vswitch *, const char *system_type);
void ovsrec_open_vswitch_set_system_version(const struct ovsrec_open_vswitch *, const char *system_version);
]]

ffi.cdef[[
/* Port table. */
struct ovsrec_port {
	struct ovsdb_idl_row header_;

	/* bond_active_slave column. */
	char *bond_active_slave;

	/* bond_downdelay column. */
	int64_t bond_downdelay;

	/* bond_fake_iface column. */
	bool bond_fake_iface;

	/* bond_mode column. */
	char *bond_mode;

	/* bond_updelay column. */
	int64_t bond_updelay;

	/* external_ids column. */
	struct smap external_ids;

	/* fake_bridge column. */
	bool fake_bridge;

	/* interfaces column. */
	struct ovsrec_interface **interfaces;
	size_t n_interfaces;

	/* lacp column. */
	char *lacp;

	/* mac column. */
	char *mac;

	/* name column. */
	char *name;	/* Always nonnull. */

	/* other_config column. */
	struct smap other_config;

	/* qos column. */
	struct ovsrec_qos *qos;

	/* rstp_statistics column. */
	char **key_rstp_statistics;
	int64_t *value_rstp_statistics;
	size_t n_rstp_statistics;

	/* rstp_status column. */
	struct smap rstp_status;

	/* statistics column. */
	char **key_statistics;
	int64_t *value_statistics;
	size_t n_statistics;

	/* status column. */
	struct smap status;

	/* tag column. */
	int64_t *tag;
	size_t n_tag;

	/* trunks column. */
	int64_t *trunks;
	size_t n_trunks;

	/* vlan_mode column. */
	char *vlan_mode;
};

enum {
    OVSREC_PORT_COL_BOND_ACTIVE_SLAVE,
    OVSREC_PORT_COL_BOND_DOWNDELAY,
    OVSREC_PORT_COL_BOND_FAKE_IFACE,
    OVSREC_PORT_COL_BOND_MODE,
    OVSREC_PORT_COL_BOND_UPDELAY,
    OVSREC_PORT_COL_EXTERNAL_IDS,
    OVSREC_PORT_COL_FAKE_BRIDGE,
    OVSREC_PORT_COL_INTERFACES,
    OVSREC_PORT_COL_LACP,
    OVSREC_PORT_COL_MAC,
    OVSREC_PORT_COL_NAME,
    OVSREC_PORT_COL_OTHER_CONFIG,
    OVSREC_PORT_COL_QOS,
    OVSREC_PORT_COL_RSTP_STATISTICS,
    OVSREC_PORT_COL_RSTP_STATUS,
    OVSREC_PORT_COL_STATISTICS,
    OVSREC_PORT_COL_STATUS,
    OVSREC_PORT_COL_TAG,
    OVSREC_PORT_COL_TRUNKS,
    OVSREC_PORT_COL_VLAN_MODE,
    OVSREC_PORT_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_port_columns[OVSREC_PORT_N_COLUMNS];
]]

---[[
exports.ovsrec_port_col_status = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_STATUS])
exports.ovsrec_port_col_statistics = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_STATISTICS])
exports.ovsrec_port_col_qos = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_QOS])
exports.ovsrec_port_col_name = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_NAME])
exports.ovsrec_port_col_bond_downdelay = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_BOND_DOWNDELAY])
exports.ovsrec_port_col_interfaces = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_INTERFACES])
exports.ovsrec_port_col_other_config = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_OTHER_CONFIG])
exports.ovsrec_port_col_bond_fake_iface = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_BOND_FAKE_IFACE])
exports.ovsrec_port_col_mac = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_MAC])
exports.ovsrec_port_col_bond_active_slave = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_BOND_ACTIVE_SLAVE])
exports.ovsrec_port_col_lacp = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_LACP])
exports.ovsrec_port_col_rstp_status = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_RSTP_STATUS])
exports.ovsrec_port_col_rstp_statistics = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_RSTP_STATISTICS])
exports.ovsrec_port_col_tag = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_TAG])
exports.ovsrec_port_col_trunks = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_TRUNKS])
exports.ovsrec_port_col_vlan_mode = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_VLAN_MODE])
exports.ovsrec_port_col_external_ids = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_EXTERNAL_IDS])
exports.ovsrec_port_col_fake_bridge = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_FAKE_BRIDGE])
exports.ovsrec_port_col_bond_updelay = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_BOND_UPDELAY])
exports.ovsrec_port_col_bond_mode = (Lib_vswitch_idl.ovsrec_port_columns[ffi.C.OVSREC_PORT_COL_BOND_MODE])
--]]

ffi.cdef[[
const struct ovsrec_port *ovsrec_port_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_port *ovsrec_port_first(const struct ovsdb_idl *);
const struct ovsrec_port *ovsrec_port_next(const struct ovsrec_port *);
]]

--[=[
local function OVSREC_PORT_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_port_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_port_next(ROW))
local function OVSREC_PORT_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_port_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_port_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_port_init(struct ovsrec_port *);
void ovsrec_port_delete(const struct ovsrec_port *);
struct ovsrec_port *ovsrec_port_insert(struct ovsdb_idl_txn *);

void ovsrec_port_verify_bond_active_slave(const struct ovsrec_port *);
void ovsrec_port_verify_bond_downdelay(const struct ovsrec_port *);
void ovsrec_port_verify_bond_fake_iface(const struct ovsrec_port *);
void ovsrec_port_verify_bond_mode(const struct ovsrec_port *);
void ovsrec_port_verify_bond_updelay(const struct ovsrec_port *);
void ovsrec_port_verify_external_ids(const struct ovsrec_port *);
void ovsrec_port_verify_fake_bridge(const struct ovsrec_port *);
void ovsrec_port_verify_interfaces(const struct ovsrec_port *);
void ovsrec_port_verify_lacp(const struct ovsrec_port *);
void ovsrec_port_verify_mac(const struct ovsrec_port *);
void ovsrec_port_verify_name(const struct ovsrec_port *);
void ovsrec_port_verify_other_config(const struct ovsrec_port *);
void ovsrec_port_verify_qos(const struct ovsrec_port *);
void ovsrec_port_verify_rstp_statistics(const struct ovsrec_port *);
void ovsrec_port_verify_rstp_status(const struct ovsrec_port *);
void ovsrec_port_verify_statistics(const struct ovsrec_port *);
void ovsrec_port_verify_status(const struct ovsrec_port *);
void ovsrec_port_verify_tag(const struct ovsrec_port *);
void ovsrec_port_verify_trunks(const struct ovsrec_port *);
void ovsrec_port_verify_vlan_mode(const struct ovsrec_port *);

const struct ovsdb_datum *ovsrec_port_get_bond_active_slave(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_bond_downdelay(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_bond_fake_iface(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_bond_mode(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_bond_updelay(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_external_ids(const struct ovsrec_port *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_port_get_fake_bridge(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_interfaces(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_lacp(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_mac(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_name(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_other_config(const struct ovsrec_port *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_port_get_qos(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_rstp_statistics(const struct ovsrec_port *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_port_get_rstp_status(const struct ovsrec_port *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_port_get_statistics(const struct ovsrec_port *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_port_get_status(const struct ovsrec_port *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_port_get_tag(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_trunks(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_port_get_vlan_mode(const struct ovsrec_port *, enum ovsdb_atomic_type key_type);

void ovsrec_port_set_bond_active_slave(const struct ovsrec_port *, const char *bond_active_slave);
void ovsrec_port_set_bond_downdelay(const struct ovsrec_port *, int64_t bond_downdelay);
void ovsrec_port_set_bond_fake_iface(const struct ovsrec_port *, bool bond_fake_iface);
void ovsrec_port_set_bond_mode(const struct ovsrec_port *, const char *bond_mode);
void ovsrec_port_set_bond_updelay(const struct ovsrec_port *, int64_t bond_updelay);
void ovsrec_port_set_external_ids(const struct ovsrec_port *, const struct smap *);
void ovsrec_port_set_fake_bridge(const struct ovsrec_port *, bool fake_bridge);
void ovsrec_port_set_interfaces(const struct ovsrec_port *, struct ovsrec_interface **interfaces, size_t n_interfaces);
void ovsrec_port_set_lacp(const struct ovsrec_port *, const char *lacp);
void ovsrec_port_set_mac(const struct ovsrec_port *, const char *mac);
void ovsrec_port_set_name(const struct ovsrec_port *, const char *name);
void ovsrec_port_set_other_config(const struct ovsrec_port *, const struct smap *);
void ovsrec_port_set_qos(const struct ovsrec_port *, const struct ovsrec_qos *qos);
void ovsrec_port_set_rstp_statistics(const struct ovsrec_port *, const char **key_rstp_statistics, const int64_t *value_rstp_statistics, size_t n_rstp_statistics);
void ovsrec_port_set_rstp_status(const struct ovsrec_port *, const struct smap *);
void ovsrec_port_set_statistics(const struct ovsrec_port *, const char **key_statistics, const int64_t *value_statistics, size_t n_statistics);
void ovsrec_port_set_status(const struct ovsrec_port *, const struct smap *);
void ovsrec_port_set_tag(const struct ovsrec_port *, const int64_t *tag, size_t n_tag);
void ovsrec_port_set_trunks(const struct ovsrec_port *, const int64_t *trunks, size_t n_trunks);
void ovsrec_port_set_vlan_mode(const struct ovsrec_port *, const char *vlan_mode);
]]

ffi.cdef[[
/* QoS table. */
struct ovsrec_qos {
	struct ovsdb_idl_row header_;

	/* external_ids column. */
	struct smap external_ids;

	/* other_config column. */
	struct smap other_config;

	/* queues column. */
	int64_t *key_queues;
	struct ovsrec_queue **value_queues;
	size_t n_queues;

	/* type column. */
	char *type;	/* Always nonnull. */
};

enum {
    OVSREC_QOS_COL_EXTERNAL_IDS,
    OVSREC_QOS_COL_OTHER_CONFIG,
    OVSREC_QOS_COL_QUEUES,
    OVSREC_QOS_COL_TYPE,
    OVSREC_QOS_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_qos_columns[OVSREC_QOS_N_COLUMNS];
]]

---[[
exports.ovsrec_qos_col_external_ids = (Lib_vswitch_idl.ovsrec_qos_columns[ffi.C.OVSREC_QOS_COL_EXTERNAL_IDS])
exports.ovsrec_qos_col_other_config = (Lib_vswitch_idl.ovsrec_qos_columns[ffi.C.OVSREC_QOS_COL_OTHER_CONFIG])
exports.ovsrec_qos_col_type = (Lib_vswitch_idl.ovsrec_qos_columns[ffi.C.OVSREC_QOS_COL_TYPE])
exports.ovsrec_qos_col_queues = (Lib_vswitch_idl.ovsrec_qos_columns[ffi.C.OVSREC_QOS_COL_QUEUES])
--]]

ffi.cdef[[
const struct ovsrec_qos *ovsrec_qos_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_qos *ovsrec_qos_first(const struct ovsdb_idl *);
const struct ovsrec_qos *ovsrec_qos_next(const struct ovsrec_qos *);
]]

--[=[
local function OVSREC_QOS_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_qos_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_qos_next(ROW))
local function OVSREC_QOS_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_qos_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_qos_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_qos_init(struct ovsrec_qos *);
void ovsrec_qos_delete(const struct ovsrec_qos *);
struct ovsrec_qos *ovsrec_qos_insert(struct ovsdb_idl_txn *);

void ovsrec_qos_verify_external_ids(const struct ovsrec_qos *);
void ovsrec_qos_verify_other_config(const struct ovsrec_qos *);
void ovsrec_qos_verify_queues(const struct ovsrec_qos *);
void ovsrec_qos_verify_type(const struct ovsrec_qos *);

const struct ovsdb_datum *ovsrec_qos_get_external_ids(const struct ovsrec_qos *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_qos_get_other_config(const struct ovsrec_qos *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_qos_get_queues(const struct ovsrec_qos *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_qos_get_type(const struct ovsrec_qos *, enum ovsdb_atomic_type key_type);

void ovsrec_qos_set_external_ids(const struct ovsrec_qos *, const struct smap *);
void ovsrec_qos_set_other_config(const struct ovsrec_qos *, const struct smap *);
void ovsrec_qos_set_queues(const struct ovsrec_qos *, const int64_t *key_queues, struct ovsrec_queue **value_queues, size_t n_queues);
void ovsrec_qos_set_type(const struct ovsrec_qos *, const char *type);
]]

ffi.cdef[[
/* Queue table. */
struct ovsrec_queue {
	struct ovsdb_idl_row header_;

	/* dscp column. */
	int64_t *dscp;
	size_t n_dscp;

	/* external_ids column. */
	struct smap external_ids;

	/* other_config column. */
	struct smap other_config;
};

enum {
    OVSREC_QUEUE_COL_DSCP,
    OVSREC_QUEUE_COL_EXTERNAL_IDS,
    OVSREC_QUEUE_COL_OTHER_CONFIG,
    OVSREC_QUEUE_N_COLUMNS
};

extern struct ovsdb_idl_column ovsrec_queue_columns[OVSREC_QUEUE_N_COLUMNS];
]]

---[[
exports.ovsrec_queue_col_external_ids = (Lib_vswitch_idl.ovsrec_queue_columns[ffi.C.OVSREC_QUEUE_COL_EXTERNAL_IDS])
exports.ovsrec_queue_col_other_config = (Lib_vswitch_idl.ovsrec_queue_columns[ffi.C.OVSREC_QUEUE_COL_OTHER_CONFIG])
exports.ovsrec_queue_col_dscp = (Lib_vswitch_idl.ovsrec_queue_columns[ffi.C.OVSREC_QUEUE_COL_DSCP])
--]]

ffi.cdef[[
const struct ovsrec_queue *ovsrec_queue_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_queue *ovsrec_queue_first(const struct ovsdb_idl *);
const struct ovsrec_queue *ovsrec_queue_next(const struct ovsrec_queue *);
]]

--[=[
local function OVSREC_QUEUE_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_queue_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_queue_next(ROW))
local function OVSREC_QUEUE_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_queue_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_queue_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
]=]

ffi.cdef[[
void ovsrec_queue_init(struct ovsrec_queue *);
void ovsrec_queue_delete(const struct ovsrec_queue *);
struct ovsrec_queue *ovsrec_queue_insert(struct ovsdb_idl_txn *);

void ovsrec_queue_verify_dscp(const struct ovsrec_queue *);
void ovsrec_queue_verify_external_ids(const struct ovsrec_queue *);
void ovsrec_queue_verify_other_config(const struct ovsrec_queue *);

const struct ovsdb_datum *ovsrec_queue_get_dscp(const struct ovsrec_queue *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_queue_get_external_ids(const struct ovsrec_queue *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_queue_get_other_config(const struct ovsrec_queue *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);

void ovsrec_queue_set_dscp(const struct ovsrec_queue *, const int64_t *dscp, size_t n_dscp);
void ovsrec_queue_set_external_ids(const struct ovsrec_queue *, const struct smap *);
void ovsrec_queue_set_other_config(const struct ovsrec_queue *, const struct smap *);
]]

ffi.cdef[[
/* SSL table. */
struct ovsrec_ssl {
	struct ovsdb_idl_row header_;

	/* bootstrap_ca_cert column. */
	bool bootstrap_ca_cert;

	/* ca_cert column. */
	char *ca_cert;	/* Always nonnull. */

	/* certificate column. */
	char *certificate;	/* Always nonnull. */

	/* external_ids column. */
	struct smap external_ids;

	/* private_key column. */
	char *private_key;	/* Always nonnull. */
};

enum {
    OVSREC_SSL_COL_BOOTSTRAP_CA_CERT,
    OVSREC_SSL_COL_CA_CERT,
    OVSREC_SSL_COL_CERTIFICATE,
    OVSREC_SSL_COL_EXTERNAL_IDS,
    OVSREC_SSL_COL_PRIVATE_KEY,
    OVSREC_SSL_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_ssl_columns[OVSREC_SSL_N_COLUMNS];
]]

---[[
exports.ovsrec_ssl_col_ca_cert = (Lib_vswitch_idl.ovsrec_ssl_columns[ffi.C.OVSREC_SSL_COL_CA_CERT])
exports.ovsrec_ssl_col_private_key = (Lib_vswitch_idl.ovsrec_ssl_columns[ffi.C.OVSREC_SSL_COL_PRIVATE_KEY])
exports.ovsrec_ssl_col_bootstrap_ca_cert = (Lib_vswitch_idl.ovsrec_ssl_columns[ffi.C.OVSREC_SSL_COL_BOOTSTRAP_CA_CERT])
exports.ovsrec_ssl_col_external_ids = (Lib_vswitch_idl.ovsrec_ssl_columns[ffi.C.OVSREC_SSL_COL_EXTERNAL_IDS])
exports.ovsrec_ssl_col_certificate = (Lib_vswitch_idl.ovsrec_ssl_columns[ffi.C.OVSREC_SSL_COL_CERTIFICATE])
--]]



ffi.cdef[[
const struct ovsrec_ssl *ovsrec_ssl_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_ssl *ovsrec_ssl_first(const struct ovsdb_idl *);
const struct ovsrec_ssl *ovsrec_ssl_next(const struct ovsrec_ssl *);
]]

--[=[
local function OVSREC_SSL_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_ssl_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_ssl_next(ROW))
local function OVSREC_SSL_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_ssl_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_ssl_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_ssl_init(struct ovsrec_ssl *);
void ovsrec_ssl_delete(const struct ovsrec_ssl *);
struct ovsrec_ssl *ovsrec_ssl_insert(struct ovsdb_idl_txn *);

void ovsrec_ssl_verify_bootstrap_ca_cert(const struct ovsrec_ssl *);
void ovsrec_ssl_verify_ca_cert(const struct ovsrec_ssl *);
void ovsrec_ssl_verify_certificate(const struct ovsrec_ssl *);
void ovsrec_ssl_verify_external_ids(const struct ovsrec_ssl *);
void ovsrec_ssl_verify_private_key(const struct ovsrec_ssl *);

const struct ovsdb_datum *ovsrec_ssl_get_bootstrap_ca_cert(const struct ovsrec_ssl *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ssl_get_ca_cert(const struct ovsrec_ssl *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ssl_get_certificate(const struct ovsrec_ssl *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_ssl_get_external_ids(const struct ovsrec_ssl *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_ssl_get_private_key(const struct ovsrec_ssl *, enum ovsdb_atomic_type key_type);

void ovsrec_ssl_set_bootstrap_ca_cert(const struct ovsrec_ssl *, bool bootstrap_ca_cert);
void ovsrec_ssl_set_ca_cert(const struct ovsrec_ssl *, const char *ca_cert);
void ovsrec_ssl_set_certificate(const struct ovsrec_ssl *, const char *certificate);
void ovsrec_ssl_set_external_ids(const struct ovsrec_ssl *, const struct smap *);
void ovsrec_ssl_set_private_key(const struct ovsrec_ssl *, const char *private_key);
]]

ffi.cdef[[
/* sFlow table. */
struct ovsrec_sflow {
	struct ovsdb_idl_row header_;

	/* agent column. */
	char *agent;

	/* external_ids column. */
	struct smap external_ids;

	/* header column. */
	int64_t *header;
	size_t n_header;

	/* polling column. */
	int64_t *polling;
	size_t n_polling;

	/* sampling column. */
	int64_t *sampling;
	size_t n_sampling;

	/* targets column. */
	char **targets;
	size_t n_targets;
};

enum {
    OVSREC_SFLOW_COL_AGENT,
    OVSREC_SFLOW_COL_EXTERNAL_IDS,
    OVSREC_SFLOW_COL_HEADER,
    OVSREC_SFLOW_COL_POLLING,
    OVSREC_SFLOW_COL_SAMPLING,
    OVSREC_SFLOW_COL_TARGETS,
    OVSREC_SFLOW_N_COLUMNS
};
]]

ffi.cdef[[
extern struct ovsdb_idl_column ovsrec_sflow_columns[OVSREC_SFLOW_N_COLUMNS];
]]

---[[
exports.ovsrec_sflow_col_agent = (Lib_vswitch_idl.ovsrec_sflow_columns[ffi.C.OVSREC_SFLOW_COL_AGENT])
exports.ovsrec_sflow_col_sampling = (Lib_vswitch_idl.ovsrec_sflow_columns[ffi.C.OVSREC_SFLOW_COL_SAMPLING])
exports.ovsrec_sflow_col_header = (Lib_vswitch_idl.ovsrec_sflow_columns[ffi.C.OVSREC_SFLOW_COL_HEADER])
exports.ovsrec_sflow_col_polling = (Lib_vswitch_idl.ovsrec_sflow_columns[ffi.C.OVSREC_SFLOW_COL_POLLING])
exports.ovsrec_sflow_col_external_ids = (Lib_vswitch_idl.ovsrec_sflow_columns[ffi.C.OVSREC_SFLOW_COL_EXTERNAL_IDS])
exports.ovsrec_sflow_col_targets = (Lib_vswitch_idl.ovsrec_sflow_columns[ffi.C.OVSREC_SFLOW_COL_TARGETS])
--]]



ffi.cdef[[
const struct ovsrec_sflow *ovsrec_sflow_get_for_uuid(const struct ovsdb_idl *, const struct uuid *);
const struct ovsrec_sflow *ovsrec_sflow_first(const struct ovsdb_idl *);
const struct ovsrec_sflow *ovsrec_sflow_next(const struct ovsrec_sflow *);
]]

--[=[
local function OVSREC_SFLOW_FOR_EACH(ROW, IDL) \
        for ((ROW) = ovsrec_sflow_first(IDL); \
             (ROW); \
             (ROW) = ovsrec_sflow_next(ROW))
local function OVSREC_SFLOW_FOR_EACH_SAFE(ROW, NEXT, IDL) \
        for ((ROW) = ovsrec_sflow_first(IDL); \
             (ROW) ? ((NEXT) = ovsrec_sflow_next(ROW), 1) : 0; \
             (ROW) = (NEXT))
--]=]

ffi.cdef[[
void ovsrec_sflow_init(struct ovsrec_sflow *);
void ovsrec_sflow_delete(const struct ovsrec_sflow *);
struct ovsrec_sflow *ovsrec_sflow_insert(struct ovsdb_idl_txn *);

void ovsrec_sflow_verify_agent(const struct ovsrec_sflow *);
void ovsrec_sflow_verify_external_ids(const struct ovsrec_sflow *);
void ovsrec_sflow_verify_header(const struct ovsrec_sflow *);
void ovsrec_sflow_verify_polling(const struct ovsrec_sflow *);
void ovsrec_sflow_verify_sampling(const struct ovsrec_sflow *);
void ovsrec_sflow_verify_targets(const struct ovsrec_sflow *);

const struct ovsdb_datum *ovsrec_sflow_get_agent(const struct ovsrec_sflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_sflow_get_external_ids(const struct ovsrec_sflow *, enum ovsdb_atomic_type key_type, enum ovsdb_atomic_type value_type);
const struct ovsdb_datum *ovsrec_sflow_get_header(const struct ovsrec_sflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_sflow_get_polling(const struct ovsrec_sflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_sflow_get_sampling(const struct ovsrec_sflow *, enum ovsdb_atomic_type key_type);
const struct ovsdb_datum *ovsrec_sflow_get_targets(const struct ovsrec_sflow *, enum ovsdb_atomic_type key_type);

void ovsrec_sflow_set_agent(const struct ovsrec_sflow *, const char *agent);
void ovsrec_sflow_set_external_ids(const struct ovsrec_sflow *, const struct smap *);
void ovsrec_sflow_set_header(const struct ovsrec_sflow *, const int64_t *header, size_t n_header);
void ovsrec_sflow_set_polling(const struct ovsrec_sflow *, const int64_t *polling, size_t n_polling);
void ovsrec_sflow_set_sampling(const struct ovsrec_sflow *, const int64_t *sampling, size_t n_sampling);
void ovsrec_sflow_set_targets(const struct ovsrec_sflow *, const char **targets, size_t n_targets);
]]

ffi.cdef[[
enum {
    OVSREC_TABLE_AUTOATTACH,
    OVSREC_TABLE_BRIDGE,
    OVSREC_TABLE_CONTROLLER,
    OVSREC_TABLE_FLOW_SAMPLE_COLLECTOR_SET,
    OVSREC_TABLE_FLOW_TABLE,
    OVSREC_TABLE_IPFIX,
    OVSREC_TABLE_INTERFACE,
    OVSREC_TABLE_MANAGER,
    OVSREC_TABLE_MIRROR,
    OVSREC_TABLE_NETFLOW,
    OVSREC_TABLE_OPEN_VSWITCH,
    OVSREC_TABLE_PORT,
    OVSREC_TABLE_QOS,
    OVSREC_TABLE_QUEUE,
    OVSREC_TABLE_SSL,
    OVSREC_TABLE_SFLOW,
    OVSREC_N_TABLES
};
]]


ffi.cdef[[
extern struct ovsdb_idl_table_class ovsrec_table_classes[OVSREC_N_TABLES];

extern struct ovsdb_idl_class ovsrec_idl_class;
]]
exports.ovsrec_idl_class = Lib_vswitch_idl.ovsrec_idl_class;

exports.ovsrec_table_bridge = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_BRIDGE])
exports.ovsrec_table_qos = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_QOS])
exports.ovsrec_table_sflow = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_SFLOW])
exports.ovsrec_table_flow_sample_collector_set = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_FLOW_SAMPLE_COLLECTOR_SET])
exports.ovsrec_table_ipfix = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_IPFIX])
exports.ovsrec_table_open_vswitch = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_OPEN_VSWITCH])
exports.ovsrec_table_autoattach = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_AUTOATTACH])
exports.ovsrec_table_controller = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_CONTROLLER])
exports.ovsrec_table_flow_table = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_FLOW_TABLE])
exports.ovsrec_table_queue = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_QUEUE])
exports.ovsrec_table_ssl = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_SSL])
exports.ovsrec_table_manager = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_MANAGER])
exports.ovsrec_table_mirror = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_MIRROR])
exports.ovsrec_table_interface = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_INTERFACE])
exports.ovsrec_table_netflow = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_NETFLOW])
exports.ovsrec_table_port = (Lib_vswitch_idl.ovsrec_table_classes[ffi.C.OVSREC_TABLE_PORT])



ffi.cdef[[
void ovsrec_init(void);

const char * ovsrec_get_db_version(void);
]]




exports.ovsrec_init = Lib_vswitch_idl.ovsrec_init;
exports.ovsrec_get_db_version = function() return ffi.string(Lib_vswitch_idl.ovsrec_get_db_version()) end;

Lib_vswitch_idl.ovsrec_init();

return exports
