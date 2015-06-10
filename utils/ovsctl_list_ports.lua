local ffi = require("ffi")

local common = require("utils.ovsctl_common")
common();

local classes = require("classes.classes")
local OVSDBIdl = classes.OVSDBIdl;



local dry_run = false;
local wait_for_reload = false;



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
            ports:add(port.port_cfg.name)
         end
    }
--]]
    output_sorted(ports, ctx.output);

end






local function runPrerequisites(commands, idl)
    
    local success, err = idl:addTable(ovsrec_table_open_vswitch);

    if (wait_for_reload) then
        idl:addColumn(ovsrec_open_vswitch_col_cur_cfg)
    end

    for _, command in ipairs(commands) do
        if command.prerequisites then
            local ctx = {
                idl = idl;
                txn = nil;
                ovs = nil;
                symtab = nil;
                cache_valid = false;

                verified_ports = false;
                try_again = false;
            }

            command.output = dynamic_string();
            command.table = nil;
            command.prerequisites(ctx)
        end
    end

end

--[[
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
        ["table"] = nil;    
        idl = idl;
        -- struct ovsdb_idl_txn txn
        -- struct ovsdb_symbol_table symtab
        -- struct ovsrec_open_vswitch ovs
        ovs = nil;
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
--]]


local commands = {
    listports_cmd = {
        name = "list-ports", 
        min_args = 1, 
        max_args = 1, 
        arguments= "BRIDGE", 
        prerequisites = pre_get_info,
        run = cmd_list_ports,
        postprocess = nil;
        options = "",
        mode = "RO"
    },
}

local function main()

    local retry = false;
    local monitor_everything = false;
    local db = common.default_db();

    --local ctx = prolog();

    vlog_set_levels(nil, ffi.C.VLF_CONSOLE, ffi.C.VLL_WARN);
    vlog_set_levels(VLM_reconnect, ffi.C.VLF_ANY_DESTINATION, ffi.C.VLL_WARN);
    --ovsrec_init();

    --args = process_escape_args(argv);
    --VLOG(might_write_to_db(argv) ? VLL_INFO : VLL_DBG, "Called as %s", args);

    -- Parse command line.
    local local_options = shash_create();
    --parse_options(#arg, arg, local_options);
    --commands = parse_commands(argc - optind, argv + optind, &local_options, &n_commands);

    
    if (timeout) then
        time_alarm(timeout);
    end

    -- Initialize IDL.
    local idl, err = OVSDBIdl(ovsrec_idl_class, db, monitor_everything, retry);

    if not idl == nil then
        print("idl_create() failed...")
        return ;
    end

    runPrerequisites(commands, idl);

---[[
    local seqno = idl:getSeqNo();
    while (true) do
        idl:run();
        print("---- idl_run: ", seqno)

        if not idl:isAlive() then
            print("---- idl_is NOT _alive")
            local err, msg = idl:getLastError();
            vsctl_fatal("%s: database connection failed (%s)", db, msg);
        end

        if seqno ~= idl:getSeqNo() then
            print("---- need new seq_no: ", seqno)
            seqno = idl:getSeqNo();
            print("---- new seq_no: ", seqno)
            --cmd_list_ports(ctx);
            do_vsctl(args, commands, n_commands, idl)
        end

        if seqno == idl:getSeqNo() then
            print("---- waiting")
            idl:wait();
            poll_block();
        end
    end
--]]
end

main()
