local ffi = require("ffi")


ffi.cdef[[
const char *ovs_sysconfdir(void); /* /usr/local/etc */
const char *ovs_pkgdatadir(void); /* /usr/local/share/openvswitch */
const char *ovs_rundir(void);     /* /usr/local/var/run/openvswitch */
const char *ovs_logdir(void);     /* /usr/local/var/log/openvswitch */
const char *ovs_dbdir(void);      /* /usr/local/etc/openvswitch */
const char *ovs_bindir(void);     /* /usr/local/bin */
]]

local dirslib = ffi.load("openvswitch")

local exports = {
    -- The shared library
    dirslib = dirslib;

    ovs_sysconfdir 	= function() return ffi.string(dirslib.ovs_sysconfdir()) end;
    ovs_pkgdatadir 	= function() return ffi.string(dirslib.ovs_pkgdatadir()) end;
    ovs_rundir 		= function() return ffi.string(dirslib.ovs_rundir()) end;
    ovs_logdir 		= function() return ffi.string(dirslib.ovs_logdir()) end;
    ovs_dbdir 		= function() return ffi.string(dirslib.ovs_dbdir()) end;
    ovs_bindir 		= function() return ffi.string(dirslib.ovs_bindir()) end;
}

return exports;
