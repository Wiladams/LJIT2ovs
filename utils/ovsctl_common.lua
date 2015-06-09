local ffi = require("ffi")

local libovs = require("lib.libopenvswitch");
local libovsdb = require("ovsdb.libovsdb");



local EXIT_FAILURE = 1;
local EXIT_SUCCESS = 0;



local def_db = nil;

local function default_db()
    if (def_db == nil) then
        def_db = string.format("unix:%s/db.sock", ovs_rundir());
    end

    return def_db;
end

local def_schema = nil;

local function default_schema(void)

    if (def_schema == nil) then
        def_schema = string.format("%s/vswitch.ovsschema", ffi.string(ovs_pkgdatadir()));
    end

    return def_schema;
end

local function check_ovsdb_error(err)

    if (err ~= nil) then
        ovs_fatal(0, "%s", ovsdb_error_to_string(err));
    end
end



--[[
local obj = {
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
}
--]]


local vsctl_context = {}
setmetatable(vsctl_context, {
    __call = function(self, ...)
        return self:new(...)
    end,
})

local vsctl_context_mt = {
    __index = vsctl_context;
}

function vsctl_context.init(self, obj)
    setmetatable(obj, vsctl_context_mt);

    return obj;
end

function vsctl_context.new(self, params)
    params = params or {}
    local obj = {
        idl = params.idl;
        txn = params.txn;
        ovs = params.ovs;
        symtab = params.symtab;
        cache_valid = false;

        output = dynamic_string();
    }
    
    if self:init(obj) then
        if (params.command) then
            obj:init_command(command);
        end
    end

    return obj;
end

function vsctl_context.init_command(self, command)

    self.argc = command.argc;
    self.argv = command.argv;
    self.options = command.options;

    ds_swap(self.output, command.output);
    self.table = command.table;

    self.verified_ports = false;

    self.try_again = false;
end

function vsctl_context.done_command(self, command)
    ds_swap(self.output, command.output);
    command.table = self.table;
end

function vsctl_context.done(self, command)
    if (command ~= nil) then
        self:done_command(ctx, command);
    end
    
    self:invalidate_cache();
end

function vsctl_context.invalidate_cache(self)

    --struct shash_node *node;

    if (not self.cache_valid) then
        return;
    end

    self.cache_valid = false;
--[[
            SHASH_FOR_EACH (node, &ctx->bridges) {
                struct vsctl_bridge *bridge = node->data;
                hmap_destroy(&bridge->children);
                free(bridge->name);
                free(bridge);
            }
--]]        
    shash_destroy(self.bridges);
    shash_destroy_free_data(self.ports);
    shash_destroy_free_data(self.ifaces);
end


ffi.cdef[[
/* A command supported by ovs-vsctl. */
struct vsctl_command_syntax {
    const char *name;           /* e.g. "add-br" */
    int min_args;               /* Min number of arguments following name. */
    int max_args;               /* Max number of arguments following name. */

    /* Names that roughly describe the arguments that the command
     * uses.  These should be similar to the names displayed in the
     * man page or in the help output. */
    const char *arguments;

    /* If nonnull, calls ovsdb_idl_add_column() or ovsdb_idl_add_table() for
     * each column or table in ctx->idl that it uses. */
    void (*prerequisites)(struct vsctl_context *ctx);

    /* Does the actual work of the command and puts the command's output, if
     * any, in ctx->output or ctx->table.
     *
     * Alternatively, if some prerequisite of the command is not met and the
     * caller should wait for something to change and then retry, it may set
     * ctx->try_again to true.  (Only the "wait-until" command currently does
     * this.) */
    void (*run)(struct vsctl_context *ctx);

    /* If nonnull, called after the transaction has been successfully
     * committed.  ctx->output is the output from the "run" function, which
     * this function may modify and otherwise postprocess as needed.  (Only the
     * "create" command currently does any postprocessing.) */
    void (*postprocess)(struct vsctl_context *ctx);

    /* A comma-separated list of supported options, e.g. "--a,--b", or the
     * empty string if the command does not support any options. */
    const char *options;

    enum { RO, RW } mode;       /* Does this command modify the database? */
};

struct vsctl_command {
    /* Data that remains constant after initialization. */
    const struct vsctl_command_syntax *syntax;
    int argc;
    char **argv;
    struct shash options;

    /* Data modified by commands. */
    struct ds output;
    struct table *table;
};
]]
local vsctl_command = {}
local vsctl_command_mt = {
    __index = vsctl_command;
}

--[[
/* Prepares 'ctx', which has already been initialized with
 * vsctl_context_init(), for processing 'command'. */
--]]




function vsctl_command.init(self,params)
    params = params or {}
    local obj = {
        syntax = params.syntax;
        argc = params.argc;
        argv = params.argv;
        options = options;

        output = dynamic_string();
        table = params.table;
    }
    setmetatable(obj, vsctl_command_mt);

    return obj;
end

function vsctl_command.new(self, ...)
    return self:init(...);
end



local function vsctl_exit(status)

    if (the_idl_txn ~= nil) then
        ovsdb_idl_txn_abort(the_idl_txn);
        ovsdb_idl_txn_destroy(the_idl_txn);
    end

    ovsdb_idl_destroy(the_idl);
    
    exit(status);
end

local function vsctl_fatal(format, ...)
    local message = xasprintf(format, ...);
 
    --vlog_set_levels(&VLM_vsctl, VLF_CONSOLE, VLL_OFF);
    --VLOG_ERR("%s", message);
    ovs_error(0, "%s", message);
    vsctl_exit(-1);     -- EXIT_FAILURE
end

local function vsctl_context_populate_cache(ctx)

    local ovs = ctx.ovs;
    struct sset bridges, ports;
    size_t i;

    if (ctx.cache_valid) then
        -- Cache is already populated.
        return;
    end

    ctx.cache_valid = true;
    shash_init(ctx->bridges);
    shash_init(ctx->ports);
    shash_init(ctx->ifaces);

    sset_init(&bridges);
    sset_init(&ports);
    for (i = 0; i < ovs->n_bridges; i++) {
        struct ovsrec_bridge *br_cfg = ovs->bridges[i];
        struct vsctl_bridge *br;
        size_t j;

        if (!sset_add(&bridges, br_cfg->name)) {
            VLOG_WARN("%s: database contains duplicate bridge name",
                      br_cfg->name);
            continue;
        }
        br = add_bridge_to_cache(ctx, br_cfg, br_cfg->name, NULL, 0);
        if (!br) {
            continue;
        }

        for (j = 0; j < br_cfg->n_ports; j++) {
            struct ovsrec_port *port_cfg = br_cfg->ports[j];

            if (!sset_add(&ports, port_cfg->name)) {
                /* Duplicate port name.  (We will warn about that later.) */
                continue;
            }

            if (port_is_fake_bridge(port_cfg)
                && sset_add(&bridges, port_cfg->name)) {
                add_bridge_to_cache(ctx, NULL, port_cfg->name, br,
                                    *port_cfg->tag);
            }
        }
    }
    sset_destroy(&bridges);
    sset_destroy(&ports);

    sset_init(&bridges);
    for (i = 0; i < ovs->n_bridges; i++) {
        struct ovsrec_bridge *br_cfg = ovs->bridges[i];
        struct vsctl_bridge *br;
        size_t j;

        if (!sset_add(&bridges, br_cfg->name)) {
            continue;
        }
        br = shash_find_data(&ctx->bridges, br_cfg->name);
        for (j = 0; j < br_cfg->n_ports; j++) {
            struct ovsrec_port *port_cfg = br_cfg->ports[j];
            struct vsctl_port *port;
            size_t k;

            port = shash_find_data(&ctx->ports, port_cfg->name);
            if (port) {
                if (port_cfg == port->port_cfg) {
                    VLOG_WARN("%s: port is in multiple bridges (%s and %s)",
                              port_cfg->name, br->name, port->bridge->name);
                } else {
                    /* Log as an error because this violates the database's
                     * uniqueness constraints, so the database server shouldn't
                     * have allowed it. */
                    VLOG_ERR("%s: database contains duplicate port name",
                             port_cfg->name);
                }
                continue;
            }

            if (port_is_fake_bridge(port_cfg)
                && !sset_add(&bridges, port_cfg->name)) {
                continue;
            }

            port = add_port_to_cache(ctx, br, port_cfg);
            for (k = 0; k < port_cfg->n_interfaces; k++) {
                struct ovsrec_interface *iface_cfg = port_cfg->interfaces[k];
                struct vsctl_iface *iface;

                iface = shash_find_data(&ctx->ifaces, iface_cfg->name);
                if (iface) {
                    if (iface_cfg == iface->iface_cfg) {
                        VLOG_WARN("%s: interface is in multiple ports "
                                  "(%s and %s)",
                                  iface_cfg->name,
                                  iface->port->port_cfg->name,
                                  port->port_cfg->name);
                    } else {
                        /* Log as an error because this violates the database's
                         * uniqueness constraints, so the database server
                         * shouldn't have allowed it. */
                        VLOG_ERR("%s: database contains duplicate interface "
                                 "name", iface_cfg->name);
                    }
                    continue;
                }

                add_iface_to_cache(ctx, port, iface_cfg);
            }
        }
    }
    sset_destroy(&bridges);
}


local function output_sorted(svec, output)

    const char *name;

    svec:sort();
    SVEC_FOR_EACH (i, name, svec) {
        ds_put_format(output, "%s\n", name);
    }
end

local exports = {
    Lib_ovsdb = libovsdb;
    Lib_ovs = libovs;

    -- constant values
    EXIT_FAILURE = EXIT_FAILURE;
    EXIT_SUCCESS = EXIT_SUCCESS;

    -- table structures
    vsctl_context = vsctl_context;
    vsctl_command = vsctl_command;

    -- local functions
    default_db = default_db;
    default_schema = default_schema;
    check_ovsdb_error = check_ovsdb_error;

    vsctl_context_populate_cache = vsctl_context_populate_cache;
    vsctl_fatal = vsctl_fatal;
    vsctl_exit = vsctl_exit;
}

setmetatable(exports, {
    __call = function(self)
        for k,v in pairs(self) do
            _G[k] = v;
        end
        
        libovs();   -- make things global
        libovsdb();   -- make things global
    end,
});

return exports
