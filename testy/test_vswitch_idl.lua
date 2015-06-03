local libovs = require("lib.libopenvswitch")
libovs();

ovsrec_init();
print("ovsrec_get_db_version(): ", ovsrec_get_db_version());

print(Lib_vswitch_idl.ovsrec_autoattach_columns)