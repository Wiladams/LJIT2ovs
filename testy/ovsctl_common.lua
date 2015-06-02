local ffi = require("ffi")

local require("ovsdb_command_common")

ffi.cdef[[
struct vsctl_context {
    /* Read-only. */
    int argc;
    char **argv;
    struct shash options;

    /* Modifiable state. */
    struct ds output;
    struct table *table;
    struct ovsdb_idl *idl;
    struct ovsdb_idl_txn *txn;
    struct ovsdb_symbol_table *symtab;
    const struct ovsrec_open_vswitch *ovs;
    bool verified_ports;

    /* A cache of the contents of the database.
     *
     * A command that needs to use any of this information must first call
     * vsctl_context_populate_cache().  A command that changes anything that
     * could invalidate the cache must either call
     * vsctl_context_invalidate_cache() or manually update the cache to
     * maintain its correctness. */
    bool cache_valid;
    struct shash bridges;   /* Maps from bridge name to struct vsctl_bridge. */
    struct shash ports;     /* Maps from port name to struct vsctl_port. */
    struct shash ifaces;    /* Maps from port name to struct vsctl_iface. */

    /* A command may set this member to true if some prerequisite is not met
     * and the caller should wait for something to change and then retry. */
    bool try_again;
};
]]
