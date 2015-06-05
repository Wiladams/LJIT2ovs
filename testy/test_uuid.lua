
libovs = require("lib.libopenvswitch")
libovs();


local id = uuid("12345678-1234-5678-1234-5678123456781234")
local id2 = uuid();

print("from string:  ", id);
print(" from blank:  ", id2);

