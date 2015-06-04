local ffi = require("ffi")

local libovs = require("lib.libopenvswitch")
libovs();

local ds = dynamic_string();

ds_put_cstr(ds, "hello");
ds_put_cstr(ds, ", World");
ds_put_char(ds, string.byte('!'));

print("RESULT: ", ds_cstr(ds));
