local ffi = require("ffi")



require("openflow_1_1")

local common = require("openflow_common")
local OFP_ASSERT = common.OFP_ASSERT

local exports = {}

-- Error type for experimenter error messages.
exports.OFPET12_EXPERIMENTER = 0xffff

ffi.cdef[[
/* The VLAN id is 12-bits, so we can use the entire 16 bits to indicate
 * special conditions.
 */
enum ofp12_vlan_id {
    OFPVID12_PRESENT = 0x1000, /* Bit that indicate that a VLAN id is set */
    OFPVID12_NONE    = 0x0000, /* No VLAN id was set. */
};

/* Bit definitions for IPv6 Extension Header pseudo-field. */
enum ofp12_ipv6exthdr_flags {
    OFPIEH12_NONEXT = 1 << 0,   /* "No next header" encountered. */
    OFPIEH12_ESP    = 1 << 1,   /* Encrypted Sec Payload header present. */
    OFPIEH12_AUTH   = 1 << 2,   /* Authentication header present. */
    OFPIEH12_DEST   = 1 << 3,   /* 1 or 2 dest headers present. */
    OFPIEH12_FRAG   = 1 << 4,   /* Fragment header present. */
    OFPIEH12_ROUTER = 1 << 5,   /* Router header present. */
    OFPIEH12_HOP    = 1 << 6,   /* Hop-by-hop header present. */
    OFPIEH12_UNREP  = 1 << 7,   /* Unexpected repeats encountered. */
    OFPIEH12_UNSEQ  = 1 << 8    /* Unexpected sequencing encountered. */
};
]]

ffi.cdef[[
/* Header for OXM experimenter match fields. */
struct ofp12_oxm_experimenter_header {
    ovs_be32 oxm_header;   /* oxm_class = OFPXMC_EXPERIMENTER */
    ovs_be32 experimenter; /* Experimenter ID which takes the same
                              form as in struct ofp11_experimenter_header. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp12_oxm_experimenter_header") == 8);

ffi.cdef[[
enum ofp12_controller_max_len {
    OFPCML12_MAX       = 0xffe5, /* maximum max_len value which can be used
                                  * to request a specific byte length. */
    OFPCML12_NO_BUFFER = 0xffff  /* indicates that no buffering should be
                                  * applied and the whole packet is to be
                                  * sent to the controller. */
};

/* OpenFlow 1.2 specific flags
 * (struct ofp12_flow_mod, member flags). */
enum ofp12_flow_mod_flags {
    OFPFF12_RESET_COUNTS  = 1 << 2   /* Reset flow packet and byte counts. */
};

/* OpenFlow 1.2 specific capabilities
 * (struct ofp_switch_features, member capabilities). */
enum ofp12_capabilities {
    OFPC12_PORT_BLOCKED   = 1 << 8   /* Switch will block looping ports. */
};
]]

ffi.cdef[[
/* Full description for a queue. */
struct ofp12_packet_queue {
    ovs_be32 queue_id;     /* id for the specific queue. */
    ovs_be32 port;         /* Port this queue is attached to. */
    ovs_be16 len;          /* Length in bytes of this queue desc. */
    uint8_t pad[6];        /* 64-bit alignment. */
    /* Followed by any number of queue properties expressed using
     * ofp_queue_prop_header, to fill out a total of 'len' bytes. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp12_packet_queue") == 16);

ffi.cdef[[
/* Body of reply to OFPST_TABLE request. */
struct ofp12_table_stats {
    uint8_t table_id;        /* Identifier of table.  Lower numbered tables
                                are consulted first. */
    uint8_t pad[7];          /* Align to 64-bits. */
    char name[OFP_MAX_TABLE_NAME_LEN];
    ovs_be64 match;          /* Bitmap of (1 << OFPXMT_*) that indicate the
                                fields the table can match on. */
    ovs_be64 wildcards;      /* Bitmap of (1 << OFPXMT_*) wildcards that are
                                supported by the table. */
    ovs_be32 write_actions;  /* Bitmap of OFPAT_* that are supported
                                by the table with OFPIT_WRITE_ACTIONS. */
    ovs_be32 apply_actions;  /* Bitmap of OFPAT_* that are supported
                                by the table with OFPIT_APPLY_ACTIONS. */
    ovs_be64 write_setfields;/* Bitmap of (1 << OFPXMT_*) header fields that
                                can be set with OFPIT_WRITE_ACTIONS. */
    ovs_be64 apply_setfields;/* Bitmap of (1 << OFPXMT_*) header fields that
                                can be set with OFPIT_APPLY_ACTIONS. */
    ovs_be64 metadata_match; /* Bits of metadata table can match. */
    ovs_be64 metadata_write; /* Bits of metadata table can write. */
    ovs_be32 instructions;   /* Bitmap of OFPIT_* values supported. */
    ovs_be32 config;         /* Bitmap of OFPTC_* values */
    ovs_be32 max_entries;    /* Max number of entries supported. */
    ovs_be32 active_count;   /* Number of active entries. */
    ovs_be64 lookup_count;   /* Number of packets looked up in table. */
    ovs_be64 matched_count;  /* Number of packets that hit table. */
};
]]
OFP_ASSERT(ffi.sizeof("struct ofp12_table_stats") == 128);


ffi.cdef[[
/* Number of types of groups supported by ofp12_group_features_stats. */
static const int OFPGT12_N_TYPES = 4;

/* Body of reply to OFPST12_GROUP_FEATURES request. Group features. */
struct ofp12_group_features_stats {
    ovs_be32  types;           /* Bitmap of OFPGT11_* values supported. */
    ovs_be32  capabilities;    /* Bitmap of OFPGFC12_* capability supported. */

    /* Each element in the following arrays corresponds to the group type with
     * the same number, e.g. max_groups[0] is the maximum number of OFPGT11_ALL
     * groups, actions[2] is the actions supported by OFPGT11_INDIRECT
     * groups. */
    ovs_be32  max_groups[OFPGT12_N_TYPES]; /* Max number of groups. */
    ovs_be32  actions[OFPGT12_N_TYPES];    /* Bitmaps of supported OFPAT_*. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp12_group_features_stats") == 40);

ffi.cdef[[
/* Group configuration flags */
enum ofp12_group_capabilities {
    OFPGFC12_SELECT_WEIGHT   = 1 << 0, /* Support weight for select groups */
    OFPGFC12_SELECT_LIVENESS = 1 << 1, /* Support liveness for select groups */
    OFPGFC12_CHAINING        = 1 << 2, /* Support chaining groups */
    OFPGFC12_CHAINING_CHECKS = 1 << 3, /* Check chaining for loops and delete */
};
]]

ffi.cdef[[
/* Body for ofp12_stats_request/reply of type OFPST_EXPERIMENTER. */
struct ofp12_experimenter_stats_header {
    ovs_be32 experimenter;    /* Experimenter ID which takes the same form
                                 as in struct ofp_experimenter_header. */
    ovs_be32 exp_type;        /* Experimenter defined. */
    /* Experimenter-defined arbitrary additional data. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp12_experimenter_stats_header") == 8);

ffi.cdef[[
/* Role request and reply message. */
struct ofp12_role_request {
    ovs_be32 role;            /* One of OFPCR12_ROLE_*. */
    uint8_t pad[4];           /* Align to 64 bits. */
    ovs_be64 generation_id;   /* Master Election Generation Id */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp12_role_request") == 16);

ffi.cdef[[
/* Controller roles. */
enum ofp12_controller_role {
    OFPCR12_ROLE_NOCHANGE,    /* Don't change current role. */
    OFPCR12_ROLE_EQUAL,       /* Default role, full access. */
    OFPCR12_ROLE_MASTER,      /* Full access, at most one master. */
    OFPCR12_ROLE_SLAVE,       /* Read-only access. */
};
]]

ffi.cdef[[
/* Packet received on port (datapath -> controller). */
struct ofp12_packet_in {
    ovs_be32 buffer_id;     /* ID assigned by datapath. */
    ovs_be16 total_len;     /* Full length of frame. */
    uint8_t reason;         /* Reason packet is being sent (one of OFPR_*) */
    uint8_t table_id;       /* ID of the table that was looked up */
    /* Followed by:
     *   - Match
     *   - Exactly 2 all-zero padding bytes, then
     *   - An Ethernet frame whose length is inferred from header.length.
     * The padding bytes preceding the Ethernet frame ensure that the IP
     * header (if any) following the Ethernet header is 32-bit aligned.
     */
    /* struct ofp12_match match; */
    /* uint8_t pad[2];         Align to 64 bit + 16 bit */
    /* uint8_t data[0];        Ethernet frame */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp12_packet_in") == 8);

ffi.cdef[[
/* Flow removed (datapath -> controller). */
struct ofp12_flow_removed {
    ovs_be64 cookie;          /* Opaque controller-issued identifier. */

    ovs_be16 priority;        /* Priority level of flow entry. */
    uint8_t reason;           /* One of OFPRR_*. */
    uint8_t table_id;         /* ID of the table */

    ovs_be32 duration_sec;    /* Time flow was alive in seconds. */
    ovs_be32 duration_nsec;   /* Time flow was alive in nanoseconds beyond
                                 duration_sec. */
    ovs_be16 idle_timeout;    /* Idle timeout from original flow mod. */
    ovs_be16 hard_timeout;    /* Hard timeout from original flow mod. */
    ovs_be64 packet_count;
    ovs_be64 byte_count;
    /* struct ofp12_match match;  Description of fields. Variable size. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp12_flow_removed") == 40);

