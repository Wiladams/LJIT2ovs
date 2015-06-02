local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor
local band = bit.band
local lshift = bit.lshift


local common = require("openflow_common")
local ovstypes = require("ovs_types")

local OFP_ASSERT = common.OFP_ASSERT
local OFP_PORT_C = ovstypes.OFP_PORT_C

local exports = {}

--[[
/* Port number(s)   meaning
 * ---------------  --------------------------------------
 * 0x0000           not assigned a meaning by OpenFlow 1.0
 * 0x0001...0xfeff  "physical" ports
 * 0xff00...0xfff6  "reserved" but not assigned a meaning by OpenFlow 1.x
 * 0xfff7...0xffff  "reserved" OFPP_* ports with assigned meanings
 */
--]]


-- Ranges.
exports.OFPP_MAX        = OFP_PORT_C(0xff00) -- Max # of switch ports. 
exports.OFPP_FIRST_RESV = OFP_PORT_C(0xfff7) -- First assigned reserved port. 
exports.OFPP_LAST_RESV  = OFP_PORT_C(0xffff) -- Last assigned reserved port. 

-- Reserved output "ports". 
exports.OFPP_UNSET     = OFP_PORT_C(0xfff7) -- For OXM_OF_ACTSET_OUTPUT only. 
exports.OFPP_IN_PORT   = OFP_PORT_C(0xfff8) -- Where the packet came in. 
exports.OFPP_TABLE     = OFP_PORT_C(0xfff9) -- Perform actions in flow table. 
exports.OFPP_NORMAL    = OFP_PORT_C(0xfffa) -- Process with normal L2/L3. 
exports.OFPP_FLOOD     = OFP_PORT_C(0xfffb) -- All ports except input port and
                                            -- ports disabled by STP. 
exports.OFPP_ALL       = OFP_PORT_C(0xfffc) -- All ports except input port. 
exports.OFPP_CONTROLLER= OFP_PORT_C(0xfffd) -- Send to controller. 
exports.OFPP_LOCAL     = OFP_PORT_C(0xfffe) -- Local openflow "port". 
exports.OFPP_NONE      = OFP_PORT_C(0xffff) -- Not associated with any port. 

ffi.cdef[[
/* OpenFlow 1.0 specific capabilities supported by the datapath (struct
 * ofp_switch_features, member capabilities). */
enum ofp10_capabilities {
    OFPC10_STP            = 1 << 3,  /* 802.1d spanning tree. */
    OFPC10_RESERVED       = 1 << 4,  /* Reserved, must not be set. */
};

/* OpenFlow 1.0 specific flags to indicate behavior of the physical port.
 * These flags are used in ofp10_phy_port to describe the current
 * configuration.  They are used in the ofp10_port_mod message to configure the
 * port's behavior.
 */
enum ofp10_port_config {
    OFPPC10_NO_STP       = 1 << 1, /* Disable 802.1D spanning tree on port. */
    OFPPC10_NO_RECV_STP  = 1 << 3, /* Drop received 802.1D STP packets. */
    OFPPC10_NO_FLOOD     = 1 << 4, /* Do not include port when flooding. */

};
]]

exports.OFPPC10_ALL = bor(ffi.C.OFPPC_PORT_DOWN, ffi.C.OFPPC10_NO_STP, ffi.C.OFPPC_NO_RECV, 
                     ffi.C.OFPPC10_NO_RECV_STP, ffi.C.OFPPC10_NO_FLOOD, ffi.C.OFPPC_NO_FWD, 
                     ffi.C.OFPPC_NO_PACKET_IN)

ffi.cdef[[
/* OpenFlow 1.0 specific current state of the physical port.  These are not
 * configurable from the controller.
 */
enum ofp10_port_state {
    /* The OFPPS10_STP_* bits have no effect on switch operation.  The
     * controller must adjust OFPPC_NO_RECV, OFPPC_NO_FWD, and
     * OFPPC_NO_PACKET_IN appropriately to fully implement an 802.1D spanning
     * tree. */
    OFPPS10_STP_LISTEN  = 0 << 8, /* Not learning or relaying frames. */
    OFPPS10_STP_LEARN   = 1 << 8, /* Learning but not relaying frames. */
    OFPPS10_STP_FORWARD = 2 << 8, /* Learning and relaying frames. */
    OFPPS10_STP_BLOCK   = 3 << 8, /* Not part of spanning tree. */
    OFPPS10_STP_MASK    = 3 << 8  /* Bit mask for OFPPS10_STP_* values. */

};
]]

exports.OFPPS10_ALL = bor(ffi.C.OFPPS_LINK_DOWN, ffi.C.OFPPS10_STP_MASK)


ffi.cdef[[
/* OpenFlow 1.0 specific features of physical ports available in a datapath. */
enum ofp10_port_features {
    OFPPF10_COPPER     = 1 << 7,  /* Copper medium. */
    OFPPF10_FIBER      = 1 << 8,  /* Fiber medium. */
    OFPPF10_AUTONEG    = 1 << 9,  /* Auto-negotiation. */
    OFPPF10_PAUSE      = 1 << 10, /* Pause. */
    OFPPF10_PAUSE_ASYM = 1 << 11  /* Asymmetric pause. */
};
]]

ffi.cdef[[
/* Description of a physical port */
struct ofp10_phy_port {
    ovs_be16 port_no;
    uint8_t hw_addr[OFP_ETH_ALEN];
    char name[OFP_MAX_PORT_NAME_LEN]; /* Null-terminated */

    ovs_be32 config;        /* Bitmap of OFPPC_* and OFPPC10_* flags. */
    ovs_be32 state;         /* Bitmap of OFPPS_* and OFPPS10_* flags. */

    /* Bitmaps of OFPPF_* and OFPPF10_* that describe features.  All bits
     * zeroed if unsupported or unavailable. */
    ovs_be32 curr;          /* Current features. */
    ovs_be32 advertised;    /* Features being advertised by the port. */
    ovs_be32 supported;     /* Features supported by the port. */
    ovs_be32 peer;          /* Features advertised by peer. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_phy_port") == 48);

ffi.cdef[[
/* Modify behavior of the physical port */
struct ofp10_port_mod {
    ovs_be16 port_no;
    uint8_t hw_addr[OFP_ETH_ALEN]; /* The hardware address is not
                                      configurable.  This is used to
                                      sanity-check the request, so it must
                                      be the same as returned in an
                                      ofp10_phy_port struct. */

    ovs_be32 config;        /* Bitmap of OFPPC_* flags. */
    ovs_be32 mask;          /* Bitmap of OFPPC_* flags to be changed. */

    ovs_be32 advertise;     /* Bitmap of "ofp_port_features"s.  Zero all
                               bits to prevent any action taking place. */
    uint8_t pad[4];         /* Pad to 64-bits. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_port_mod") == 24);

ffi.cdef[[
struct ofp10_packet_queue {
    ovs_be32 queue_id;          /* id for the specific queue. */
    ovs_be16 len;               /* Length in bytes of this queue desc. */
    uint8_t pad[2];             /* 64-bit alignment. */
    /* Followed by any number of queue properties expressed using
     * ofp_queue_prop_header, to fill out a total of 'len' bytes. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_packet_queue") == 8);

ffi.cdef[[
/* Query for port queue configuration. */
struct ofp10_queue_get_config_request {
    ovs_be16 port;          /* Port to be queried. Should refer
                               to a valid physical port (i.e. < OFPP_MAX) */
    uint8_t pad[2];
    /* 32-bit alignment. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_queue_get_config_request") == 4);

ffi.cdef[[
/* Queue configuration for a given port. */
struct ofp10_queue_get_config_reply {
    ovs_be16 port;
    uint8_t pad[6];
    /* struct ofp10_packet_queue queues[0]; List of configured queues. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_queue_get_config_reply") == 8);

ffi.cdef[[
/* Packet received on port (datapath -> controller). */
struct ofp10_packet_in {
    ovs_be32 buffer_id;     /* ID assigned by datapath. */
    ovs_be16 total_len;     /* Full length of frame. */
    ovs_be16 in_port;       /* Port on which frame was received. */
    uint8_t reason;         /* Reason packet is being sent (one of OFPR_*) */
    uint8_t pad;
    uint8_t data[0];        /* Ethernet frame, halfway through 32-bit word,
                               so the IP header is 32-bit aligned.  The
                               amount of data is inferred from the length
                               field in the header.  Because of padding,
                               offsetof(struct ofp_packet_in, data) ==
                               sizeof(struct ofp_packet_in) - 2. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_packet_in") == 12);

ffi.cdef[[
/* Send packet (controller -> datapath). */
struct ofp10_packet_out {
    ovs_be32 buffer_id;           /* ID assigned by datapath or UINT32_MAX. */
    ovs_be16 in_port;             /* Packet's input port (OFPP_NONE if none). */
    ovs_be16 actions_len;         /* Size of action array in bytes. */
    /* Followed by:
     *   - Exactly 'actions_len' bytes (possibly 0 bytes, and always a multiple
     *     of 8) containing actions.
     *   - If 'buffer_id' == UINT32_MAX, packet data to fill out the remainder
     *     of the message length.
     */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_packet_out") == 8);

ffi.cdef[[
/* Flow wildcards. */
enum ofp10_flow_wildcards {
    OFPFW10_IN_PORT    = 1 << 0,  /* Switch input port. */
    OFPFW10_DL_VLAN    = 1 << 1,  /* VLAN vid. */
    OFPFW10_DL_SRC     = 1 << 2,  /* Ethernet source address. */
    OFPFW10_DL_DST     = 1 << 3,  /* Ethernet destination address. */
    OFPFW10_DL_TYPE    = 1 << 4,  /* Ethernet frame type. */
    OFPFW10_NW_PROTO   = 1 << 5,  /* IP protocol. */
    OFPFW10_TP_SRC     = 1 << 6,  /* TCP/UDP source port. */
    OFPFW10_TP_DST     = 1 << 7,  /* TCP/UDP destination port. */

    /* IP source address wildcard bit count.  0 is exact match, 1 ignores the
     * LSB, 2 ignores the 2 least-significant bits, ..., 32 and higher wildcard
     * the entire field.  This is the *opposite* of the usual convention where
     * e.g. /24 indicates that 8 bits (not 24 bits) are wildcarded. */
    OFPFW10_NW_SRC_SHIFT = 8,
    OFPFW10_NW_SRC_BITS = 6,
    OFPFW10_NW_SRC_MASK = (((1 << OFPFW10_NW_SRC_BITS) - 1)
                           << OFPFW10_NW_SRC_SHIFT),
    OFPFW10_NW_SRC_ALL = 32 << OFPFW10_NW_SRC_SHIFT,

    /* IP destination address wildcard bit count.  Same format as source. */
    OFPFW10_NW_DST_SHIFT = 14,
    OFPFW10_NW_DST_BITS = 6,
    OFPFW10_NW_DST_MASK = (((1 << OFPFW10_NW_DST_BITS) - 1)
                           << OFPFW10_NW_DST_SHIFT),
    OFPFW10_NW_DST_ALL = 32 << OFPFW10_NW_DST_SHIFT,

    OFPFW10_DL_VLAN_PCP = 1 << 20, /* VLAN priority. */
    OFPFW10_NW_TOS = 1 << 21, /* IP ToS (DSCP field, 6 bits). */

    /* Wildcard all fields. */
    OFPFW10_ALL = ((1 << 22) - 1)
};
]]

-- The wildcards for ICMP type and code fields use the transport source
-- and destination port fields, respectively.
exports.OFPFW10_ICMP_TYPE = ffi.C.OFPFW10_TP_SRC
exports.OFPFW10_ICMP_CODE = ffi.C.OFPFW10_TP_DST

--[[
/* The VLAN id is 12-bits, so we can use the entire 16 bits to indicate
 * special conditions.  All ones indicates that 802.1Q header is not present.
 */
 --]]
exports.OFP10_VLAN_NONE      = 0xffff

ffi.cdef[[
/* Fields to match against flows */
struct ofp10_match {
    ovs_be32 wildcards;        /* Wildcard fields. */
    ovs_be16 in_port;          /* Input switch port. */
    uint8_t dl_src[OFP_ETH_ALEN]; /* Ethernet source address. */
    uint8_t dl_dst[OFP_ETH_ALEN]; /* Ethernet destination address. */
    ovs_be16 dl_vlan;          /* Input VLAN. */
    uint8_t dl_vlan_pcp;       /* Input VLAN priority. */
    uint8_t pad1[1];           /* Align to 64-bits. */
    ovs_be16 dl_type;          /* Ethernet frame type. */
    uint8_t nw_tos;            /* IP ToS (DSCP field, 6 bits). */
    uint8_t nw_proto;          /* IP protocol or lower 8 bits of
                                  ARP opcode. */
    uint8_t pad2[2];           /* Align to 64-bits. */
    ovs_be32 nw_src;           /* IP source address. */
    ovs_be32 nw_dst;           /* IP destination address. */
    ovs_be16 tp_src;           /* TCP/UDP source port. */
    ovs_be16 tp_dst;           /* TCP/UDP destination port. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_match") == 40);

ffi.cdef[[
enum ofp10_flow_mod_flags {
    OFPFF10_EMERG       = 1 << 2 /* Part of "emergency flow cache". */
};
]]

ffi.cdef[[
/* Flow setup and teardown (controller -> datapath). */
struct ofp10_flow_mod {
    struct ofp10_match match;    /* Fields to match */
    ovs_be64 cookie;             /* Opaque controller-issued identifier. */

    /* Flow actions. */
    ovs_be16 command;             /* One of OFPFC_*. */
    ovs_be16 idle_timeout;        /* Idle time before discarding (seconds). */
    ovs_be16 hard_timeout;        /* Max time before discarding (seconds). */
    ovs_be16 priority;            /* Priority level of flow entry. */
    ovs_be32 buffer_id;           /* Buffered packet to apply to (or -1).
                                     Not meaningful for OFPFC_DELETE*. */
    ovs_be16 out_port;            /* For OFPFC_DELETE* commands, require
                                     matching entries to include this as an
                                     output port.  A value of OFPP_NONE
                                     indicates no restriction. */
    ovs_be16 flags;               /* One of OFPFF_*. */

    /* Followed by OpenFlow actions whose length is inferred from the length
     * field in the OpenFlow header. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_flow_mod") == 64);

ffi.cdef[[
/* Flow removed (datapath -> controller). */
struct ofp10_flow_removed {
    struct ofp10_match match; /* Description of fields. */
    ovs_be64 cookie;          /* Opaque controller-issued identifier. */

    ovs_be16 priority;        /* Priority level of flow entry. */
    uint8_t reason;           /* One of OFPRR_*. */
    uint8_t pad[1];           /* Align to 32-bits. */

    ovs_be32 duration_sec;    /* Time flow was alive in seconds. */
    ovs_be32 duration_nsec;   /* Time flow was alive in nanoseconds beyond
                                 duration_sec. */
    ovs_be16 idle_timeout;    /* Idle timeout from original flow mod. */
    uint8_t pad2[2];          /* Align to 64-bits. */
    ovs_be64 packet_count;
    ovs_be64 byte_count;
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_flow_removed") == 80);

ffi.cdef[[
/* Statistics request or reply message. */
struct ofp10_stats_msg {
    struct ofp_header header;
    ovs_be16 type;              /* One of the OFPST_* constants. */
    ovs_be16 flags;             /* Requests: always 0.
                                 * Replies: 0 or OFPSF_REPLY_MORE. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_stats_msg") == 12);

ffi.cdef[[
/* Stats request of type OFPST_AGGREGATE or OFPST_FLOW. */
struct ofp10_flow_stats_request {
    struct ofp10_match match; /* Fields to match. */
    uint8_t table_id;         /* ID of table to read (from ofp_table_stats)
                                 or 0xff for all tables. */
    uint8_t pad;              /* Align to 32 bits. */
    ovs_be16 out_port;        /* Require matching entries to include this
                                 as an output port.  A value of OFPP_NONE
                                 indicates no restriction. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_flow_stats_request") == 44);

ffi.cdef[[
/* Body of reply to OFPST_FLOW request. */
struct ofp10_flow_stats {
    ovs_be16 length;          /* Length of this entry. */
    uint8_t table_id;         /* ID of table flow came from. */
    uint8_t pad;
    struct ofp10_match match; /* Description of fields. */
    ovs_be32 duration_sec;    /* Time flow has been alive in seconds. */
    ovs_be32 duration_nsec;   /* Time flow has been alive in nanoseconds
                                 beyond duration_sec. */
    ovs_be16 priority;        /* Priority of the entry. Only meaningful
                                 when this is not an exact-match entry. */
    ovs_be16 idle_timeout;    /* Number of seconds idle before expiration. */
    ovs_be16 hard_timeout;    /* Number of seconds before expiration. */
    uint8_t pad2[6];          /* Align to 64 bits. */
    ovs_32aligned_be64 cookie;       /* Opaque controller-issued identifier. */
    ovs_32aligned_be64 packet_count; /* Number of packets in flow. */
    ovs_32aligned_be64 byte_count;   /* Number of bytes in flow. */
    /* Followed by OpenFlow actions whose length is inferred from 'length'. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_flow_stats") == 88);

ffi.cdef[[
/* Body of reply to OFPST_TABLE request. */
struct ofp10_table_stats {
    uint8_t table_id;        /* Identifier of table.  Lower numbered tables
                                are consulted first. */
    uint8_t pad[3];          /* Align to 32-bits. */
    char name[OFP_MAX_TABLE_NAME_LEN];
    ovs_be32 wildcards;      /* Bitmap of OFPFW10_* wildcards that are
                                supported by the table. */
    ovs_be32 max_entries;    /* Max number of entries supported. */
    ovs_be32 active_count;   /* Number of active entries. */
    ovs_32aligned_be64 lookup_count;  /* # of packets looked up in table. */
    ovs_32aligned_be64 matched_count; /* Number of packets that hit table. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_table_stats") == 64);

ffi.cdef[[
/* Stats request of type OFPST_PORT. */
struct ofp10_port_stats_request {
    ovs_be16 port_no;        /* OFPST_PORT message may request statistics
                                for a single port (specified with port_no)
                                or for all ports (port_no == OFPP_NONE). */
    uint8_t pad[6];
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_port_stats_request") == 8);

ffi.cdef[[
/* Body of reply to OFPST_PORT request. If a counter is unsupported, set
 * the field to all ones. */
struct ofp10_port_stats {
    ovs_be16 port_no;
    uint8_t pad[6];          /* Align to 64-bits. */
    ovs_32aligned_be64 rx_packets;     /* Number of received packets. */
    ovs_32aligned_be64 tx_packets;     /* Number of transmitted packets. */
    ovs_32aligned_be64 rx_bytes;       /* Number of received bytes. */
    ovs_32aligned_be64 tx_bytes;       /* Number of transmitted bytes. */
    ovs_32aligned_be64 rx_dropped;     /* Number of packets dropped by RX. */
    ovs_32aligned_be64 tx_dropped;     /* Number of packets dropped by TX. */
    ovs_32aligned_be64 rx_errors; /* Number of receive errors.  This is a
                                     super-set of receive errors and should be
                                     great than or equal to the sum of all
                                     rx_*_err values. */
    ovs_32aligned_be64 tx_errors; /* Number of transmit errors.  This is a
                                     super-set of transmit errors. */
    ovs_32aligned_be64 rx_frame_err; /* Number of frame alignment errors. */
    ovs_32aligned_be64 rx_over_err;  /* Number of packets with RX overrun. */
    ovs_32aligned_be64 rx_crc_err;   /* Number of CRC errors. */
    ovs_32aligned_be64 collisions;   /* Number of collisions. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_port_stats") == 104);

-- All ones is used to indicate all queues in a port (for stats retrieval). */
exports.OFPQ_ALL    =  0xffffffff

ffi.cdef[[
/* Body for stats request of type OFPST_QUEUE. */
struct ofp10_queue_stats_request {
    ovs_be16 port_no;        /* All ports if OFPP_ALL. */
    uint8_t pad[2];          /* Align to 32-bits. */
    ovs_be32 queue_id;       /* All queues if OFPQ_ALL. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_queue_stats_request") == 8);

ffi.cdef[[
/* Body for stats reply of type OFPST_QUEUE consists of an array of this
 * structure type. */
struct ofp10_queue_stats {
    ovs_be16 port_no;
    uint8_t pad[2];          /* Align to 32-bits. */
    ovs_be32 queue_id;       /* Queue id. */
    ovs_32aligned_be64 tx_bytes;   /* Number of transmitted bytes. */
    ovs_32aligned_be64 tx_packets; /* Number of transmitted packets. */
    ovs_32aligned_be64 tx_errors;  /* # of packets dropped due to overrun. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_queue_stats") == 32);

ffi.cdef[[
/* Vendor extension stats message. */
struct ofp10_vendor_stats_msg {
    struct ofp10_stats_msg osm; /* Type OFPST_VENDOR. */
    ovs_be32 vendor;            /* Vendor ID:
                                 * - MSB 0: low-order bytes are IEEE OUI.
                                 * - MSB != 0: defined by OpenFlow
                                 *   consortium. */
    /* Followed by vendor-defined arbitrary additional data. */
};
]]

OFP_ASSERT(ffi.sizeof("struct ofp10_vendor_stats_msg") == 16);


return exports
