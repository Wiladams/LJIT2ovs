local ffi = require("ffi")

--#include <poll.h>
require ("lib.util")


ffi.cdef[[
void poll_fd_wait_at(int fd, short int events, const char *where);
void poll_timer_wait_at(long long int msec, const char *where);
void poll_timer_wait_until_at(long long int msec, const char *where);
void poll_immediate_wake_at(const char *where);
]]

--[[
#ifdef _WIN32
#define poll_wevent_wait(wevent) poll_wevent_wait_at(wevent, OVS_SOURCE_LOCATOR)
#endif /* _WIN32 */
--]]

--[[
#define poll_fd_wait(fd, events) poll_fd_wait_at(fd, events, OVS_SOURCE_LOCATOR)
#define poll_timer_wait(msec) poll_timer_wait_at(msec, OVS_SOURCE_LOCATOR)
#define poll_immediate_wake() poll_immediate_wake_at(OVS_SOURCE_LOCATOR)
#define poll_timer_wait_until(msec) poll_timer_wait_until_at(msec, OVS_SOURCE_LOCATOR)
--]]

ffi.cdef[[
/* Wait until an event occurs. */
void poll_block(void);
]]

local Lib_poll_loop = ffi.load("openvswitch")
local exports = {
	Lib_poll_loop = Lib_poll_loop;

	poll_block = Lib_poll_loop.poll_block;
}

return exports;
