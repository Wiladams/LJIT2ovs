local ffi = require("ffi")

local libovs = require("lib.libopenvswitch");
libovs();   -- make things global


local function test_dirs()

    print("ovs_sysconfdir:", ovs_sysconfdir());
    print("ovs_pkgdatadir:",ovs_pkgdatadir());
    print("    ovs_rundir:",ovs_rundir());
    print("    ovs_logdir:",ovs_logdir());
    print("     ovs_dbdir:",ovs_dbdir());
    print("    ovs_bindir:", ovs_bindir());
end

test_dirs()

exit();