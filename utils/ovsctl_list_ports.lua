local ffi = require("ffi")

local common = require("testy.ovsctl_common")
common();
local classes = require("classes.classes")
local OVSDBIdl = classes.OVSDBIdl;



local dry_run = false;
local wait_for_reload = false;


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

struct vsctl_port {
    struct ovs_list ports_node;  /* In struct vsctl_bridge's 'ports' list. */
    struct ovs_list ifaces;      /* Contains "struct vsctl_iface"s. */
    struct ovsrec_port *port_cfg;
    struct vsctl_bridge *bridge;
};
]]




local function pre_get_info(ctx)

    ctx.idl:addColumn(ovsrec_open_vswitch_col_bridges);

    ctx.idl:addColumn(ovsrec_bridge_col_name);
    ctx.idl:addColumn(ovsrec_bridge_col_controller);
    ctx.idl:addColumn(ovsrec_bridge_col_fail_mode);
    ctx.idl:addColumn(ovsrec_bridge_col_ports);

    ctx.idl:addColumn(ovsrec_port_col_name);
    ctx.idl:addColumn(ovsrec_port_col_fake_bridge);
    ctx.idl:addColumn(ovsrec_port_col_tag);
    ctx.idl:addColumn(ovsrec_port_col_interfaces);

    ctx.idl:addColumn(ovsrec_interface_col_name);

    ctx.idl:addColumn(ovsrec_interface_col_ofport);
end


local function find_bridge(ctx, name, must_exist)

    --ovs_assert(ctx.cache_valid);

    local br = ffi.cast("struct vsctl_bridge *", shash_find_data(ctx.bridges, name));
    if (must_exist and nil == br) then
        vsctl_fatal("no bridge named %s", name);
    end


    --struct ovsrec_open_vswitch * ctx.ovs
    ovsrec_open_vswitch_verify_bridges(ctx.ovs);
    
    return br;
end

local function cmd_list_ports(ctx)
    --struct vsctl_bridge *br;
    --struct vsctl_port *port;
    --struct svec ports;

    vsctl_context_populate_cache(ctx);
    local br = find_bridge(ctx, ctx.argv[1], true);
    if br.br_cfg then
        ovsrec_bridge_verify_ports(br.br_cfg)
    else
        ovsrec_bridge_verify_ports(br.parent.br_cfg);
    end

    local ports = svec();
--[[
    LIST_FOR_EACH (port, ports_node, &br->ports) {
        if (strcmp(port->port_cfg->name, br->name)) then
            svec_add(&ports, port->port_cfg->name);
        end
    }

    output_sorted(ports, ctx.output);
--]=]
end




local listports_cmd = {
    name = "list-ports", 
    min_args = 1, 
    max_args = 1, 
    arguments= "BRIDGE", 
    prerequisites = pre_get_info,
    run = cmd_list_ports,
    postprocess = nil;
    options = "",
    mode = "RO"
}

local function runPrerequisites(ctx)
     local success, err = ctx.idl:addTable(ovsrec_table_open_vswitch);

    if (wait_for_reload) then
        ctx.idl:addColumn(ovsrec_open_vswitch_col_cur_cfg)
    end

    pre_get_info(ctx);
end


local function prolog()
    -- create an in-memory instance
    local retry = false;
    local monitor_everything = false;
    local db = common.default_db();

    -- set_program_name(arg[1])
    vlog_set_levels(nil, ffi.C.VLF_CONSOLE, ffi.C.VLL_WARN);
    vlog_set_levels(VLM_reconnect, ffi.C.VLF_ANY_DESTINATION, ffi.C.VLL_WARN);

    --local_options = shash();
    --parse_options(argc, argv, local_options);

    local idl, err = OVSDBIdl(ovsrec_idl_class, db, monitor_everything, retry);

    if not idl == nil then
        print("idl_create() failed...")
        return ;
    end

    local ctx = {
        argc = 0;
        argv = arg;
        --struct shash options;

        -- modifiable state
        output = dynamic_string();
        --struct table *table;        
        idl = idl;
        -- struct ovsdb_idl_txn txn
        -- struct ovsdb_symbol_table symtab
        -- struct ovsrec_open_vswitch ovs
        verified_ports = false;

        cache_valid = false;
        --shash bridges;
        -- shash ports;
        -- shash ifaces;

        try_again = false;
    }

    runPrerequisites(ctx);

    return ctx;
end

--[[
    local ctx = {
        ovs;
        bridges;
        arg
    }
--]]

local function main()


    local ctx = prolog();

    local seqno = ctx.idl:getSeqNo();
    while (true) do
        ctx.idl:run();
        print("---- idl_run: ", seqno)

        if not ctx.idl:isAlive() then
            print("---- idl_is NOT _alive")
            local err, msg = ctx.idl:getLastError();
            vsctl_fatal("%s: database connection failed (%s)", db, msg);
        end

        if seqno ~= ctx.idl:getSeqNo() then
            print("---- need new seq_no: ", seqno)
            seqno = ctx.idl:getSeqNo();
            print("---- new seq_no: ", seqno)
            cmd_list_ports(ctx);
        end

        if seqno == ctx.idl:getSeqNo() then
            print("---- waiting")
            ctx.idl:wait();
            poll_block();
        end
    end
end

main()
