local ffi = require("ffi")
local bit = require("bit")

local rshift, band = bit.rshift, bit.band


--#include "util.h"



local function BUILD_ASSERT_DECL(...)
    assert(...);
end

local UUID_BIT = 128;            -- Number of bits in a UUID. */
local UUID_OCTET = (UUID_BIT / 8); -- Number of bytes in a UUID. */

ffi.cdef[[
/* A Universally Unique IDentifier (UUID) compliant with RFC 4122.
 *
 * Each of the parts is stored in host byte order, but the parts themselves are
 * ordered from left to right.  That is, (parts[0] >> 24) is the first 8 bits
 * of the UUID when output in the standard form, and (parts[3] & 0xff) is the
 * final 8 bits. */
struct uuid {
    uint32_t parts[4];
};
]]

BUILD_ASSERT_DECL(ffi.sizeof("struct uuid") == UUID_OCTET);

--[[
/* Formats a UUID as a string, in the conventional format.
 *
 * Example:
 *   struct uuid uuid = ...;
 *   printf("This UUID is "UUID_FMT"\n", UUID_ARGS(&uuid));
 *
 */
--]]

local UUID_LEN = 36;
local UUID_FMT = "%08x-%04x-%04x-%04x-%04x%08x";

local function UUID_ARGS(UUID)                             
    return (((UUID).parts[0])),            
    (rshift(UUID.parts[1], 16)),      
    (band(UUID.parts[1], 0xffff)),   
    (rshift(UUID.parts[2], 16)),      
    (band(UUID.parts[2], 0xffff)),   
    ((UUID.parts[3]))
end


--[[
/* Returns a hash value for 'uuid'.  This hash value is the same regardless of
 * whether we are running on a 32-bit or 64-bit or big-endian or little-endian
 * architecture. */
--]]
local function uuid_hash(uuid)
    return uuid.parts[0];
end

-- Returns true if 'a == b', false otherwise. */
local function uuid_equals(a, b)

    return (a.parts[0] == b.parts[0]
            and a.parts[1] == b.parts[1]
            and a.parts[2] == b.parts[2]
            and a.parts[3] == b.parts[3]);
end


  
ffi.cdef[[
void uuid_init(void);
void uuid_generate(struct uuid *);
void uuid_zero(struct uuid *);
bool uuid_is_zero(const struct uuid *);
int uuid_compare_3way(const struct uuid *, const struct uuid *);
bool uuid_from_string(struct uuid *, const char *);
bool uuid_from_string_prefix(struct uuid *, const char *);
]]

local uuidlib = ffi.load("openvswitch")

-- initialize uuid routines
uuidlib.uuid_init();

local exports = {
    Lib_uuid = uuidlib;

    UUID_FMT = UUID_FMT;

    uuid_init = uuidlib.uuid_init;
    uuid_generate = uuidlib.uuid_generate;
    uuid_zero = uuidlib.uuid_zero;
    uuid_is_zero = uuidlib.uuid_is_zero;
    uuid_compare_3way = uuidlib.uuid_compare_3way;
    uuid_from_string = uuidlib.uuid_from_string;
    uuid_from_string_prefix = uuidlib.uuid_from_string_prefix;
}

return exports
