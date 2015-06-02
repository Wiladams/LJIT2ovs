local ffi = require("ffi")



local exports = {}

ffi.cdef[[
/* The ovs_be<N> types indicate that an object is in big-endian, not
 * native-endian, byte order.  They are otherwise equivalent to uint<N>_t. */
typedef uint16_t  ovs_be16;
typedef uint32_t  ovs_be32;
typedef uint64_t  ovs_be64;
]]

exports.OVS_BE16_MAX = ffi.cast("ovs_be16", 0xffff);
exports.OVS_BE32_MAX = ffi.cast("ovs_be32", 0xffffffff);
exports.OVS_BE64_MAX = ffi.cast("ovs_be64", 0xffffffffffffffffULL);

--[[
/* These types help with a few funny situations:
 *
 *   - The Ethernet header is 14 bytes long, which misaligns everything after
 *     that.  One can put 2 "shim" bytes before the Ethernet header, but this
 *     helps only if there is exactly one Ethernet header.  If there are two,
 *     as with GRE and VXLAN (and if the inner header doesn't use this
 *     trick--GRE and VXLAN don't) then you have the choice of aligning the
 *     inner data or the outer data.  So it seems better to treat 32-bit fields
 *     in protocol headers as aligned only on 16-bit boundaries.
 *
 *   - ARP headers contain misaligned 32-bit fields.
 *
 *   - Netlink and OpenFlow contain 64-bit values that are only guaranteed to
 *     be aligned on 32-bit boundaries.
 *
 * lib/unaligned.h has helper functions for accessing these. */
--]]

--[[
    A 32-bit value, in host byte order, that is only aligned on a 16-bit
    boundary.  
--]]
if ffi.abi("be") then
ffi.cdef[[
typedef struct {
    uint16_t hi, lo;
} ovs_16aligned_u32;
]]
else
ffi.cdef[[
typedef struct {
    uint16_t lo, hi;
} ovs_16aligned_u32;
]]
end



ffi.cdef[[
/* A 32-bit value, in network byte order, that is only aligned on a 16-bit
 * boundary. */
typedef struct {
        ovs_be16 hi, lo;
} ovs_16aligned_be32;
]]

if ffi.abi("be") then
ffi.cdef[[
/* A 64-bit value, in host byte order, that is only aligned on a 32-bit
 * boundary.  */
typedef struct {
    uint32_t lo, hi;
} ovs_32aligned_u64;
]]
else
ffi.cdef[[
typedef struct {
    uint32_t hi, lo;
} ovs_32aligned_u64;
]]
end

ffi.cdef[[
typedef union {
    uint32_t u32[4];
    struct {
        uint64_t lo, hi;
    } u64;
} ovs_u128;
]]

-- Returns non-zero if the parameters have equal value.
--local function ovs_u128_equal(const ovs_u128 *a, const ovs_u128 *b)
local function ovs_u128_equal(a, b)
    return (a.u64.hi == b.u64.hi) and (a.u64.lo == b.u64.lo);
end
exports.ovs_u128_equal = ovs_u128_equal;

ffi.cdef[[
/* A 64-bit value, in network byte order, that is only aligned on a 32-bit
 * boundary. */
typedef struct {
        ovs_be32 hi, lo;
} ovs_32aligned_be64;
]]

--[[
/* ofp_port_t represents the port number of a OpenFlow switch.
 * odp_port_t represents the port number on the datapath.
 * ofp11_port_t represents the OpenFlow-1.1 port number. */
--]]
ffi.cdef[[
typedef uint16_t  ofp_port_t;
typedef uint32_t  odp_port_t;
typedef uint32_t  ofp11_port_t;
]]

local ofp_port_t = ffi.typeof("ofp_port_t")
local odp_port_t = ffi.typeof("odp_port_t")
local ofp11_port_t = ffi.typeof("ofp11_port_t")

exports.ofp_port_t = ofp_port_t;
exports.odp_port_t = odp_port_t;
exports.ofp11_port_t = ofp11_port_t;

-- Macro functions that cast int types to ofp/odp/ofp11 types.
exports.OFP_PORT_C = function(X) return ofp_port_t(X) end
exports.ODP_PORT_C = function(X) return odp_port_t(X) end
exports.OFP11_PORT_C = function(X) return ofp11_port_t(X) end
--]]

return exports;
