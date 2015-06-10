local ffi = require("ffi")

local libovs = require("lib.libopenvswitch");
local libovsdb = require("ovsdb.libovsdb");



local EXIT_FAILURE = 1;
local EXIT_SUCCESS = 0;


ffi.cdef[[
struct vsctl_bridge {
    struct ovsrec_bridge *br_cfg;
    char *name;
    struct ovs_list ports;      /* Contains "struct vsctl_port"s. */

    /* VLAN ("fake") bridge support.
     *
     * Use 'parent != NULL' to detect a fake bridge, because 'vlan' can be 0
     * in either case. */
    struct hmap children;        /* VLAN bridges indexed by 'vlan'. */
    struct hmap_node children_node; /* Node in parent's 'children' hmap. */
    struct vsctl_bridge *parent; /* Real bridge, or NULL. */
    int vlan;                    /* VLAN VID (0...4095), or 0. */
};
]]

ffi.cdef[[
struct vsctl_port {
    struct ovs_list ports_node;  /* In struct vsctl_bridge's 'ports' list. */
    struct ovs_list ifaces;      /* Contains "struct vsctl_iface"s. */
    struct ovsrec_port *port_cfg;
    struct vsctl_bridge *bridge;
};
]]






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
]]

ffi.cdef[[
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
setmetatable(vsctl_command, {
    __call = function(self, ...)
        return self:new(...);
    end,
});
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
        syntax = params.syntax;     -- struct vsctl_command_syntax
        argc = params.argc;         -- count of argv
        argv = params.argv;         -- 
        options = options;          -- struct shash options

        output = dynamic_string();  -- struct ds output
        table = params.table;       -- struct table *
    }
    setmetatable(obj, vsctl_command_mt);

    return obj;
end

function vsctl_command.new(self, ...)
    return self:init(...);
end


--[[
    Helpful Functions
--]]

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


local function find_vlan_bridge(parent, vlan)
--[[
    struct vsctl_bridge *child;

    HMAP_FOR_EACH_IN_BUCKET (child, children_node, hash_int(vlan, 0),
                             parent.children) do
        if (child.vlan == vlan) then
            return child;
        end
    end
--]]
    return nil;
end

local function add_bridge_to_cache(ctx,br_cfg, name,parent, vlan)
--[[
    struct vsctl_bridge *br = ffi.cast("struct vsctl_bridge", xmalloc(ffi.sizeof("struct vsctl_bridge"));
    br.br_cfg = br_cfg;
    br.name = xstrdup(name);
    list_init(br.ports);
    br.parent = parent;
    br.vlan = vlan;
    hmap_init(br.children);

    if (parent ~= nil) then
        conflict = find_vlan_bridge(parent, vlan);
        if (conflict) {
            VLOG_WARN("%s: bridge has multiple VLAN bridges (%s and %s) "
                      "for VLAN %d, but only one is allowed",
                      parent->name, name, conflict->name, vlan);
        else
            hmap_insert(&parent->children, &br->children_node,
                        hash_int(vlan, 0));
        end
    end

    shash_add(ctx.bridges, br.name, br);
--]]
    return br;
end

local function vsctl_context_populate_cache(ctx)
--[[
    local ovs = ctx.ovs;
    struct sset bridges, ports;
    size_t i;

    if (ctx.cache_valid) then
        -- Cache is already populated.
        return;
    end

    ctx.cache_valid = true;
    shash_init(ctx.bridges);
    shash_init(ctx.ports);
    shash_init(ctx.ifaces);

    sset_init(bridges);
    sset_init(ports);
    for i = 0, ovs.n_bridges-1 do
        br_cfg = ovs.bridges[i];
        struct vsctl_bridge *br;
        size_t j;

        if (not sset_add(bridges, br_cfg.name)) then
            VLOG_WARN("%s: database contains duplicate bridge name",
                      br_cfg.name);
        else
            br = add_bridge_to_cache(ctx, br_cfg, br_cfg.name, nil, 0);
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
        end
    end
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
--]]
end


local function output_sorted(sv, output)
    sv:sort();
    for name in sv:entries() do
        ds_put_format(output, "%s\n", name);
    end
end

local function post_db_reload_check_init()
    n_neoteric_ifaces = 0;
end

local function do_vsctl(args, commands, n_commands, idl)
    --struct ovsdb_idl_txn *txn;
    --enum ovsdb_idl_txn_status status;
    --struct ovsdb_symbol_table *symtab;
    --struct vsctl_context ctx;
    --struct vsctl_command *c;
    --struct shash_node *node;
    --int64_t next_cfg = 0;
    --char *error = NULL;

    local txn = ovsdb_idl_txn_create(idl.Handle);
    the_idl_txn = txn;

    if (dry_run) then
        ovsdb_idl_txn_set_dry_run(txn);
    end

    ovsdb_idl_txn_add_comment(txn, "ovs-vsctl: %s", args);

    local ovs = ovsrec_open_vswitch_first(idl.Handle);

    if (nil == ovs) then
        -- XXX add verification that table is empty
        ovs = ovsrec_open_vswitch_insert(txn);
    end


    if (wait_for_reload) then
        ovsdb_idl_txn_increment(txn, ovs.header_, ovsrec_open_vswitch_col_next_cfg);
    end

    post_db_reload_check_init();
    local symtab = ovsdb_symbol_table_create();

    for _, c in ipairs(commands) do
        ds_init(c.output);
        c.table = nil;
    end

    local ctx = vsctl_context({command = nil, idl = idl, txn = txn, ovs = ovs, symtab=symtab});


    --vsctl_context_init(&ctx, NULL, idl, txn, ovs, symtab);
--[[
    for (c = commands; c < &commands[n_commands]; c++) {
        vsctl_context_init_command(&ctx, c);
        if (c->syntax->run) {
            (c->syntax->run)(&ctx);
        }
        vsctl_context_done_command(&ctx, c);

        if (ctx.try_again) {
            vsctl_context_done(&ctx, NULL);
            goto try_again;
        }
    }
--]]
--[[
    vsctl_context_done(&ctx, NULL);

    SHASH_FOR_EACH (node, &symtab->sh) {
        struct ovsdb_symbol *symbol = node->data;
        if (!symbol->created) {
            vsctl_fatal("row id \"%s\" is referenced but never created (e.g. "
                        "with \"-- --id=%s create ...\")",
                        node->name, node->name);
        }
        if (!symbol->strong_ref) {
            if (!symbol->weak_ref) {
                VLOG_WARN("row id \"%s\" was created but no reference to it "
                          "was inserted, so it will not actually appear in "
                          "the database", node->name);
            } else {
                VLOG_WARN("row id \"%s\" was created but only a weak "
                          "reference to it was inserted, so it will not "
                          "actually appear in the database", node->name);
            }
        }
    }

    status = ovsdb_idl_txn_commit_block(txn);
    if (wait_for_reload && status == TXN_SUCCESS) {
        next_cfg = ovsdb_idl_txn_get_increment_new_value(txn);
    }
    if (status == TXN_UNCHANGED || status == TXN_SUCCESS) {
        for (c = commands; c < &commands[n_commands]; c++) {
            if (c->syntax->postprocess) {
                struct vsctl_context ctx;

                vsctl_context_init(&ctx, c, idl, txn, ovs, symtab);
                (c->syntax->postprocess)(&ctx);
                vsctl_context_done(&ctx, c);
            }
        }
    }
    error = xstrdup(ovsdb_idl_txn_get_error(txn));

    switch (status) {
    case TXN_UNCOMMITTED:
    case TXN_INCOMPLETE:
        OVS_NOT_REACHED();

    case TXN_ABORTED:
        /* Should not happen--we never call ovsdb_idl_txn_abort(). */
        vsctl_fatal("transaction aborted");

    case TXN_UNCHANGED:
    case TXN_SUCCESS:
        break;

    case TXN_TRY_AGAIN:
        goto try_again;

    case TXN_ERROR:
        vsctl_fatal("transaction error: %s", error);

    case TXN_NOT_LOCKED:
        /* Should not happen--we never call ovsdb_idl_set_lock(). */
        vsctl_fatal("database not locked");

    default:
        OVS_NOT_REACHED();
    }
    free(error);

    ovsdb_symbol_table_destroy(symtab);

    for (c = commands; c < &commands[n_commands]; c++) {
        struct ds *ds = &c->output;

        if (c->table) {
            table_print(c->table, &table_style);
        } else if (oneline) {
            size_t j;

            ds_chomp(ds, '\n');
            for (j = 0; j < ds->length; j++) {
                int ch = ds->string[j];
                switch (ch) {
                case '\n':
                    fputs("\\n", stdout);
                    break;

                case '\\':
                    fputs("\\\\", stdout);
                    break;

                default:
                    putchar(ch);
                }
            }
            putchar('\n');
        } else {
            fputs(ds_cstr(ds), stdout);
        }
        ds_destroy(&c->output);
        table_destroy(c->table);
        free(c->table);

        shash_destroy_free_data(&c->options);
    }
    free(commands);

    if (wait_for_reload && status != TXN_UNCHANGED) {
        /* Even, if --retry flag was not specified, ovs-vsctl still
         * has to retry to establish OVSDB connection, if wait_for_reload
         * was set.  Otherwise, ovs-vsctl would end up waiting forever
         * until cur_cfg would be updated. */
        ovsdb_idl_enable_reconnect(idl);
        for (;;) {
            ovsdb_idl_run(idl);
            OVSREC_OPEN_VSWITCH_FOR_EACH (ovs, idl) {
                if (ovs->cur_cfg >= next_cfg) {
                    post_db_reload_do_checks(&ctx);
                    goto done;
                }
            }
            ovsdb_idl_wait(idl);
            poll_block();
        }
    done: ;
    }
    ovsdb_idl_txn_destroy(txn);
    ovsdb_idl_destroy(idl);

    exit(EXIT_SUCCESS);

try_again:
    /* Our transaction needs to be rerun, or a prerequisite was not met.  Free
     * resources and return so that the caller can try again. */
    if (txn) {
        ovsdb_idl_txn_abort(txn);
        ovsdb_idl_txn_destroy(txn);
        the_idl_txn = NULL;
    }
    ovsdb_symbol_table_destroy(symtab);
    for (c = commands; c < &commands[n_commands]; c++) {
        ds_destroy(&c->output);
        table_destroy(c->table);
        free(c->table);
    }
    free(error);
--]]
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
    do_vsctl = do_vsctl;
    check_ovsdb_error = check_ovsdb_error;
    output_sorted = output_sorted;

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
