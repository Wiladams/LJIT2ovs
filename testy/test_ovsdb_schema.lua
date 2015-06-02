local ffi = require("ffi")
local libovs = require("lib.libopenvswitch");
local libovsdb = require("lib.libovsdb")

libovs();	-- make things global
libovsdb();

