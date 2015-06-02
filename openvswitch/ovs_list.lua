local ffi = require("ffi")

ffi.cdef[[
/* Doubly linked list head or element. */
struct ovs_list {
    struct ovs_list *prev;     /* Previous list element. */
    struct ovs_list *next;     /* Next list element. */
};
]]

--#define OVS_LIST_INITIALIZER(LIST) { LIST, LIST }