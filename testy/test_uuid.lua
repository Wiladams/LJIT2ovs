
local ffi = require("ffi")
local bit = require("bit")
local band, rshift = bit.band, bit.rshift

local uuid = require("lib.uuid")
local ds = require("lib.dynamic_string")

local id1 = ffi.new("struct uuid");



--local success = uuid.uuid_from_string(id1,      "00000000-1111-2222-3333-4444444444444444")
local success = uuid.uuid_from_string_prefix(id1, "12345678-1234-5678-1234-5678123456781234")
print("SUCCESS: ", success);


print("ARGS: ", uuid.UUID_ARGS(id1));
print("FMT:", uuid.UUID_FMT); 
local output = ds.dynamic_string();
ds.ds_put_format(output, uuid.UUID_FMT, uuid.UUID_ARGS(id1))
--ds.ds_put_format(output, uuid.UUID_FMT, ARGS(id1))

print("OUTPUT: ", ds.ds_cstr(output));


print("STRING: ", string.format(uuid.UUID_FMT, uuid.UUID_ARGS(id1)))