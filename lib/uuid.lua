local ffi = require("ffi")
local bit = require("bit")

local rshift, band = bit.rshift, bit.band

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


local UUID_LEN = 36;
local UUID_FMT = "%08x-%04x-%04x-%04x-%04x%08x";

local function UUID_ARGS(UUID)                             
    return ffi.cast("unsigned int", (UUID.parts[0])),
        ffi.cast("unsigned int", rshift(UUID.parts[1], 16)),
        ffi.cast("unsigned int", band(UUID.parts[1], 0xffff)),
        ffi.cast("unsigned int", rshift(UUID.parts[2], 16)),
        ffi.cast("unsigned int", band(UUID.parts[2], 0xffff)),
        ffi.cast("unsigned int", UUID.parts[3])
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

local Lib_uuid = ffi.load("openvswitch")

-- initialize uuid routines
Lib_uuid.uuid_init();

local exports = {
    Lib_uuid = Lib_uuid;

    UUID_BIT = UUID_BIT;
    UUID_OCTET = UUID_OCTET;
    UUID_FMT = UUID_FMT;
    UUID_ARGS = UUID_ARGS;

    -- inline routines
    uuid_hash = uuid_hash;
    uuid_equals = uuid_equals;

    uuid_init = Lib_uuid.uuid_init;
    uuid_generate = Lib_uuid.uuid_generate;
    uuid_zero = Lib_uuid.uuid_zero;
    uuid_is_zero = Lib_uuid.uuid_is_zero;
    uuid_compare_3way = Lib_uuid.uuid_compare_3way;
    uuid_from_string = Lib_uuid.uuid_from_string;
    uuid_from_string_prefix = Lib_uuid.uuid_from_string_prefix;
}

return exports
