local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local lshift = bit.lshift


local common = require("openflow_common")
require("openflow_1_3")

local ovstypes = require("ovs_types")

local OFP_ASSERT = common.OFP_ASSERT
local OFP11_PORT_C = ovstypes.OFP11_PORT_C

local exports = {}




ffi.cdef[[
/* ## ---------- ## */
/* ## ofp14_port ## */
/* ## ---------- ## */

/* Port description property types. */
enum ofp_port_desc_prop_type {
    OFPPDPT14_ETHERNET          = 0,      /* Ethernet property. */
    OFPPDPT14_OPTICAL           = 1,      /* Optical property. */
    OFPPDPT14_EXPERIMENTER      = 0xFFFF, /* Experimenter property. */
};
]]

ffi.cdef[[
/* Ethernet port description property. */
struct ofp14_port_desc_prop_ethernet {
    ovs_be16         type;    /* OFPPDPT14_ETHERNET. */
    ovs_be16         length;  /* Length in bytes of this property. */
    uint8_t          pad[4];  /* Align to 64 bits. */
    /* Bitmaps of OFPPF_* that describe features.  All bits zeroed if
     * unsupported or unavailable. */
    ovs_be32 curr;          /* Current features. */
    ovs_be32 advertised;    /* Features being advertised by the port. */
    ovs_be32 supported;     /* Features supported by the port. */
    ovs_be32 peer;          /* Features advertised by peer. */

    ovs_be32 curr_speed;    /* Current port bitrate in kbps. */
    ovs_be32 max_speed;     /* Max port bitrate in kbps */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_port_desc_prop_ethernet") == 32);

ffi.cdef[[
struct ofp14_port {
    ovs_be32 port_no;
    ovs_be16 length;
    uint8_t pad[2];
    uint8_t hw_addr[OFP_ETH_ALEN];
    uint8_t pad2[2];                  /* Align to 64 bits. */
    char name[OFP_MAX_PORT_NAME_LEN]; /* Null-terminated */

    ovs_be32 config;        /* Bitmap of OFPPC_* flags. */
    ovs_be32 state;         /* Bitmap of OFPPS_* flags. */

    /* Followed by 0 or more OFPPDPT14_* properties. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_port") == 40);

ffi.cdef[[
/* ## -------------- ## */
/* ## ofp14_port_mod ## */
/* ## -------------- ## */

enum ofp14_port_mod_prop_type {
    OFPPMPT14_ETHERNET          = 0,      /* Ethernet property. */
    OFPPMPT14_OPTICAL           = 1,      /* Optical property. */
    OFPPMPT14_EXPERIMENTER      = 0xFFFF, /* Experimenter property. */
};
]]

ffi.cdef[[
/* Ethernet port mod property. */
struct ofp14_port_mod_prop_ethernet {
    ovs_be16      type;       /* OFPPMPT14_ETHERNET. */
    ovs_be16      length;     /* Length in bytes of this property. */
    ovs_be32      advertise;  /* Bitmap of OFPPF_*.  Zero all bits to prevent
                                 any action taking place. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_port_mod_prop_ethernet") == 8);

ffi.cdef[[
struct ofp14_port_mod {
    ovs_be32 port_no;
    uint8_t pad[4];
    uint8_t hw_addr[OFP_ETH_ALEN];
    uint8_t pad2[2];
    ovs_be32 config;        /* Bitmap of OFPPC_* flags. */
    ovs_be32 mask;          /* Bitmap of OFPPC_* flags to be changed. */
    /* Followed by 0 or more OFPPMPT14_* properties. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_port_mod") == 24);

ffi.cdef[[
/* ## --------------- ## */
/* ## ofp14_table_mod ## */
/* ## --------------- ## */

enum ofp14_table_mod_prop_type {
    OFPTMPT14_EVICTION               = 0x2,    /* Eviction property. */
    OFPTMPT14_VACANCY                = 0x3,    /* Vacancy property. */
    OFPTMPT14_EXPERIMENTER           = 0xFFFF, /* Experimenter property. */
};

enum ofp14_table_mod_prop_eviction_flag {
    OFPTMPEF14_OTHER           = 1 << 0,     /* Using other factors. */
    OFPTMPEF14_IMPORTANCE      = 1 << 1,     /* Using flow entry importance. */
    OFPTMPEF14_LIFETIME        = 1 << 2,     /* Using flow entry lifetime. */
};
]]

ffi.cdef[[
struct ofp14_table_mod_prop_eviction {
    ovs_be16         type;    /* OFPTMPT14_EVICTION. */
    ovs_be16         length;  /* Length in bytes of this property. */
    ovs_be32         flags;   /* Bitmap of OFPTMPEF14_* flags */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_table_mod_prop_eviction") == 8);

ffi.cdef[[
struct ofp14_table_mod_prop_vacancy {
    ovs_be16         type;   /* OFPTMPT14_VACANCY. */
    ovs_be16         length; /* Length in bytes of this property. */
    uint8_t vacancy_down;    /* Vacancy threshold when space decreases (%). */
    uint8_t vacancy_up;      /* Vacancy threshold when space increases (%). */
    uint8_t vacancy;      /* Current vacancy (%) - only in ofp14_table_desc. */
    uint8_t pad[1];          /* Align to 64 bits. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_table_mod_prop_vacancy") == 8);

ffi.cdef[[
struct ofp14_table_mod {
    uint8_t table_id;     /* ID of the table, OFPTT_ALL indicates all tables */
    uint8_t pad[3];         /* Pad to 32 bits */
    ovs_be32 config;        /* Bitmap of OFPTC_* flags */
    /* Followed by 0 or more OFPTMPT14_* properties. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_table_mod") == 8);

ffi.cdef[[
/* ## ---------------- ## */
/* ## ofp14_port_stats ## */
/* ## ---------------- ## */

enum ofp14_port_stats_prop_type {
    OFPPSPT14_ETHERNET          = 0,      /* Ethernet property. */
    OFPPSPT14_OPTICAL           = 1,      /* Optical property. */
    OFPPSPT14_EXPERIMENTER      = 0xFFFF, /* Experimenter property. */
};

struct ofp14_port_stats_prop_ethernet {
    ovs_be16         type;    /* OFPPSPT14_ETHERNET. */
    ovs_be16         length;  /* Length in bytes of this property. */
    uint8_t          pad[4];  /* Align to 64 bits. */

    ovs_be64 rx_frame_err;   /* Number of frame alignment errors. */
    ovs_be64 rx_over_err;    /* Number of packets with RX overrun. */
    ovs_be64 rx_crc_err;     /* Number of CRC errors. */
    ovs_be64 collisions;     /* Number of collisions. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_port_stats_prop_ethernet") == 40);

ffi.cdef[[
struct ofp14_port_stats {
    ovs_be16 length;         /* Length of this entry. */
    uint8_t pad[2];          /* Align to 64 bits. */
    ovs_be32 port_no;
    ovs_be32 duration_sec;   /* Time port has been alive in seconds. */
    ovs_be32 duration_nsec;  /* Time port has been alive in nanoseconds beyond
                                duration_sec. */
    ovs_be64 rx_packets;     /* Number of received packets. */
    ovs_be64 tx_packets;     /* Number of transmitted packets. */
    ovs_be64 rx_bytes;       /* Number of received bytes. */
    ovs_be64 tx_bytes;       /* Number of transmitted bytes. */

    ovs_be64 rx_dropped;     /* Number of packets dropped by RX. */
    ovs_be64 tx_dropped;     /* Number of packets dropped by TX. */
    ovs_be64 rx_errors;      /* Number of receive errors.  This is a super-set
                                of more specific receive errors and should be
                                greater than or equal to the sum of all
                                rx_*_err values in properties. */
    ovs_be64 tx_errors;      /* Number of transmit errors.  This is a super-set
                                of more specific transmit errors and should be
                                greater than or equal to the sum of all
                                tx_*_err values (none currently defined.) */
    /* Followed by 0 or more OFPPSPT14_* properties. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_port_stats") == 80);

ffi.cdef[[
/* ## ----------------- ## */
/* ## ofp14_queue_stats ## */
/* ## ----------------- ## */

struct ofp14_queue_stats {
    ovs_be16 length;         /* Length of this entry. */
    uint8_t pad[6];          /* Align to 64 bits. */
    struct ofp13_queue_stats qs;
    /* Followed by 0 or more properties (none yet defined). */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_queue_stats") == 48);

ffi.cdef[[
/* ## -------------- ## */
/* ## Miscellaneous. ## */
/* ## -------------- ## */

/* Common header for all async config Properties */
struct ofp14_async_config_prop_header {
    ovs_be16    type;       /* One of OFPACPT_*. */
    ovs_be16    length;     /* Length in bytes of this property. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_async_config_prop_header") == 4);

ffi.cdef[[
/* Asynchronous message configuration.
 * OFPT_GET_ASYNC_REPLY or OFPT_SET_ASYNC.
 */
struct ofp14_async_config {
    struct ofp_header header;
    /* Async config Property list - 0 or more */
    struct ofp14_async_config_prop_header properties[0];
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_async_config") == 8);

ffi.cdef[[
/* Async Config property types.
* Low order bit cleared indicates a property for the slave role.
* Low order bit set indicates a property for the master/equal role.
*/
enum ofp14_async_config_prop_type {
    OFPACPT_PACKET_IN_SLAVE       = 0, /* Packet-in mask for slave. */
    OFPACPT_PACKET_IN_MASTER      = 1, /* Packet-in mask for master. */
    OFPACPT_PORT_STATUS_SLAVE     = 2, /* Port-status mask for slave. */
    OFPACPT_PORT_STATUS_MASTER    = 3, /* Port-status mask for master. */
    OFPACPT_FLOW_REMOVED_SLAVE    = 4, /* Flow removed mask for slave. */
    OFPACPT_FLOW_REMOVED_MASTER   = 5, /* Flow removed mask for master. */
    OFPACPT_ROLE_STATUS_SLAVE     = 6, /* Role status mask for slave. */
    OFPACPT_ROLE_STATUS_MASTER    = 7, /* Role status mask for master. */
    OFPACPT_TABLE_STATUS_SLAVE    = 8, /* Table status mask for slave. */
    OFPACPT_TABLE_STATUS_MASTER   = 9, /* Table status mask for master. */
    OFPACPT_REQUESTFORWARD_SLAVE  = 10, /* RequestForward mask for slave. */
    OFPACPT_REQUESTFORWARD_MASTER = 11, /* RequestForward mask for master. */
    OFPTFPT_EXPERIMENTER_SLAVE    = 0xFFFE, /* Experimenter for slave. */
    OFPTFPT_EXPERIMENTER_MASTER   = 0xFFFF, /* Experimenter for master. */
};

/* Various reason based properties */
struct ofp14_async_config_prop_reasons {
    /* 'type' is one of OFPACPT_PACKET_IN_*, OFPACPT_PORT_STATUS_*,
     * OFPACPT_FLOW_REMOVED_*, OFPACPT_ROLE_STATUS_*,
     * OFPACPT_TABLE_STATUS_*, OFPACPT_REQUESTFORWARD_*. */
    ovs_be16    type;
    ovs_be16    length; /* Length in bytes of this property. */
    ovs_be32    mask;   /* Bitmasks of reason values. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_async_config_prop_reasons") == 8);

ffi.cdef[[
/* Experimenter async config property */
struct ofp14_async_config_prop_experimenter {
    ovs_be16        type;       /* One of OFPTFPT_EXPERIMENTER_SLAVE,
                                   OFPTFPT_EXPERIMENTER_MASTER. */
    ovs_be16        length;     /* Length in bytes of this property. */
    ovs_be32        experimenter;  /* Experimenter ID which takes the same
                                      form as in struct
                                      ofp_experimenter_header. */
    ovs_be32        exp_type;      /* Experimenter defined. */
    /* Followed by:
     *   - Exactly (length - 12) bytes containing the experimenter data, then
     *   - Exactly (length + 7)/8*8 - (length) (between 0 and 7)
     *     bytes of all-zero bytes */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_async_config_prop_experimenter") == 12);

ffi.cdef[[
/* Common header for all Role Properties */
struct ofp14_role_prop_header {
    ovs_be16 type;   /* One of OFPRPT_*. */
    ovs_be16 length; /* Length in bytes of this property. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_role_prop_header") == 4);

ffi.cdef[[
/* Role status event message. */
struct ofp14_role_status {
    ovs_be32 role;              /* One of OFPCR_ROLE_*. */
    uint8_t  reason;            /* One of OFPCRR_*. */
    uint8_t  pad[3];            /* Align to 64 bits. */
    ovs_be64 generation_id;     /* Master Election Generation Id */

    /* Followed by a list of struct ofp14_role_prop_header */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_role_status") == 16);

ffi.cdef[[
/* What changed about the controller role */
enum ofp14_controller_role_reason {
    OFPCRR_MASTER_REQUEST = 0,  /* Another controller asked to be master. */
    OFPCRR_CONFIG         = 1,  /* Configuration changed on the switch. */
    OFPCRR_EXPERIMENTER   = 2,  /* Experimenter data changed. */
};

/* Role property types.
*/
enum ofp14_role_prop_type {
    OFPRPT_EXPERIMENTER         = 0xFFFF, /* Experimenter property. */
};

/* Experimenter role property */
struct ofp14_role_prop_experimenter {
    ovs_be16        type;       /* One of OFPRPT_EXPERIMENTER. */
    ovs_be16        length;     /* Length in bytes of this property. */
    ovs_be32        experimenter; /* Experimenter ID which takes the same
                                     form as in struct
                                     ofp_experimenter_header. */
    ovs_be32        exp_type;     /* Experimenter defined. */
    /* Followed by:
     *   - Exactly (length - 12) bytes containing the experimenter data, then
     *   - Exactly (length + 7)/8*8 - (length) (between 0 and 7)
     *     bytes of all-zero bytes */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_role_prop_experimenter") == 12);

ffi.cdef[[
/* Bundle control message types */
enum ofp14_bundle_ctrl_type {
    OFPBCT_OPEN_REQUEST    = 0,
    OFPBCT_OPEN_REPLY      = 1,
    OFPBCT_CLOSE_REQUEST   = 2,
    OFPBCT_CLOSE_REPLY     = 3,
    OFPBCT_COMMIT_REQUEST  = 4,
    OFPBCT_COMMIT_REPLY    = 5,
    OFPBCT_DISCARD_REQUEST = 6,
    OFPBCT_DISCARD_REPLY   = 7,
};

/* Bundle configuration flags. */
enum ofp14_bundle_flags {
    OFPBF_ATOMIC  = 1 << 0,  /* Execute atomically. */
    OFPBF_ORDERED = 1 << 1,  /* Execute in specified order. */
};

/* Message structure for OFPT_BUNDLE_CONTROL and OFPT_BUNDLE_ADD_MESSAGE. */
struct ofp14_bundle_ctrl_msg {
    ovs_be32 bundle_id;     /* Identify the bundle. */
    ovs_be16 type;          /* OFPT_BUNDLE_CONTROL: one of OFPBCT_*.
                             * OFPT_BUNDLE_ADD_MESSAGE: not used. */
    ovs_be16 flags;         /* Bitmap of OFPBF_* flags. */
    /* Followed by:
     * - For OFPT_BUNDLE_ADD_MESSAGE only, an encapsulated OpenFlow message,
     *   beginning with an ofp_header whose xid is identical to this message's
     *   outer xid.
     * - For OFPT_BUNDLE_ADD_MESSAGE only, and only if at least one property is
     *   present, 0 to 7 bytes of padding to align on a 64-bit boundary.
     * - Zero or more properties (see struct ofp14_bundle_prop_header). */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_bundle_ctrl_msg") == 8);

ffi.cdef[[
/* Body for ofp14_multipart_request of type OFPMP_FLOW_MONITOR.
 *
 * The OFPMP_FLOW_MONITOR request's body consists of an array of zero or more
 * instances of this structure. The request arranges to monitor the flows
 * that match the specified criteria, which are interpreted in the same way as
 * for OFPMP_FLOW.
 *
 * 'id' identifies a particular monitor for the purpose of allowing it to be
 * canceled later with OFPFMC_DELETE. 'id' must be unique among
 * existing monitors that have not already been canceled.
 */
struct ofp14_flow_monitor_request {
    ovs_be32 monitor_id;        /* Controller-assigned ID for this monitor. */
    ovs_be32 out_port;          /* Required output port, if not OFPP_ANY. */
    ovs_be32 out_group;         /* Required output port, if not OFPG_ANY. */
    ovs_be16 flags;             /* OFPMF14_*. */
    uint8_t table_id;           /* One table's ID or OFPTT_ALL (all tables). */
    uint8_t command;            /* One of OFPFMC14_*. */
    /* Followed by an ofp11_match structure. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp14_flow_monitor_request") == 16);

ffi.cdef[[
/* Flow monitor commands */
enum ofp14_flow_monitor_command {
    OFPFMC14_ADD = 0, /* New flow monitor. */
    OFPFMC14_MODIFY = 1, /* Modify existing flow monitor. */
    OFPFMC14_DELETE = 2, /* Delete/cancel existing flow monitor. */
};

/* 'flags' bits in struct of_flow_monitor_request. */
enum ofp14_flow_monitor_flags {
    /* When to send updates. */
    /* Common to NX and OpenFlow 1.4 */
    OFPFMF14_INITIAL = 1 << 0,     /* Initially matching flows. */
    OFPFMF14_ADD = 1 << 1,         /* New matching flows as they are added. */
    OFPFMF14_REMOVED = 1 << 2,     /* Old matching flows as they are removed. */
    OFPFMF14_MODIFY = 1 << 3,      /* Matching flows as they are changed. */

    /* What to include in updates. */
    /* Common to NX and OpenFlow 1.4 */
    OFPFMF14_INSTRUCTIONS = 1 << 4, /* If set, instructions are included. */
    OFPFMF14_NO_ABBREV = 1 << 5,    /* If set, include own changes in full. */
    /* OpenFlow 1.4 */
    OFPFMF14_ONLY_OWN = 1 << 6,     /* If set, don't include other controllers.
                                     */
};
]]

return exports


