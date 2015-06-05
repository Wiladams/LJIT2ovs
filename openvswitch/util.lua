local ffi = require("ffi")

--#include <openvswitch/version.h>

local Lib_openvswitch_util = ffi.load("openvswitch")

ffi.cdef[[
void ovs_set_program_name__(const char *name, const char *version,
                            const char *date, const char *time);

const char *ovs_get_program_name(void);
const char *ovs_get_program_version(void);

]]

local function ovs_set_program_name(name, version)
    Lib_openvswitch_util.ovs_set_program_name__(name, version, os.date(), os.time());
end 

--[[
/* Expands to a string that looks like "<file>:<line>", e.g. "tmp.c:10".
 *
 * See http://c-faq.com/ansi/stringize.html for an explanation of OVS_STRINGIZE
 * and OVS_STRINGIZE2. */
#define OVS_SOURCE_LOCATOR __FILE__ ":" OVS_STRINGIZE(__LINE__)
#define OVS_STRINGIZE(ARG) OVS_STRINGIZE2(ARG)
#define OVS_STRINGIZE2(ARG) #ARG

/* Saturating multiplication of "unsigned int"s: overflow yields UINT_MAX. */
#define OVS_SAT_MUL(X, Y)                                               \
    ((Y) == 0 ? 0                                                       \
     : (X) <= UINT_MAX / (Y) ? (unsigned int) (X) * (unsigned int) (Y)  \
     : UINT_MAX)
--]]

local exports = {
	Lib_openvswitch_util = Lib_openvswitch_util;
	
	-- local routines
	ovs_set_program_name = ovs_set_program_name;

	-- library routines
	ovs_set_program_name__ = Lib_openvswitch_util.ovs_set_program_name__;
	ovs_get_program_name = Lib_openvswitch_util.ovs_get_program_name;
	ovs_get_program_version = Lib_openvswitch_util.ovs_get_program_version;
}

return exports
