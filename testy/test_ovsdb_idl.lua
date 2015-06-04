--[[
    This is a relatively simple test case to see if we can
    instantiate an in memory database (idl), and read the
    tables.  It is roughly the equivalent of ovs-vsctl show

    Assumes a database server is already running on the 
    machine.
--]]

local ffi = require("ffi")

common = require("testy.ovsdb_command_common")

local stringz = require("core.stringz")



local db = common.default_db();
local idl = nil;
local wait_for_reload = true;


local cmd_show_tables = {
    {
        ["table"] = ovsrec_table_open_vswitch,
        name_column=nil,
        columns = {
            ovsrec_open_vswitch_col_manager_options,
            ovsrec_open_vswitch_col_bridges,
            ovsrec_open_vswitch_col_ovs_version
        },
        recurse = false
    },

    {
        ["table"] = ovsrec_table_bridge,
        name_column = ovsrec_bridge_col_name,
        columns = {
            ovsrec_bridge_col_controller,
            ovsrec_bridge_col_fail_mode,
            ovsrec_bridge_col_ports
            },
        recurse = false
    },

    {
        ["table"] = ovsrec_table_port,
        name_column = ovsrec_port_col_name,
        columns = {
            ovsrec_port_col_tag,
            ovsrec_port_col_trunks,
            ovsrec_port_col_interfaces},
        recurse = false
    },

    {
        ["table"] = ovsrec_table_interface,
        name_column = ovsrec_interface_col_name,
        columns = {
            ovsrec_interface_col_type,
            ovsrec_interface_col_options,
            ovsrec_interface_col_error
        },
        recurse = false
    },

    {
        ["table"] = ovsrec_table_controller,
        name_column = ovsrec_controller_col_target,
        columns = {
            ovsrec_controller_col_is_connected
        },
        recurse = false
    },

    {
        ["table"] = ovsrec_table_manager,
        name_column = ovsrec_manager_col_target,
        columns = {ovsrec_manager_col_is_connected},
        recurse = false
    },
};

local function pre_cmd_show()
	print("==== pre_cmd_show ====")
    for idx, show in ipairs(cmd_show_tables) do

        local  i=0;

        -- first add the table to be watched
        ovsdb_idl_add_table(idl, show.table);
        print("add_table: ", ffi.string(show.table.name));

        -- add the column
        if (show.name_column ~= nil) then
            print("add_column, name_column: ", ffi.string(show.name_column.name));
            ovsdb_idl_add_column(idl, show.name_column);
        end

        for _, column in ipairs(show.columns) do
            print(" ",ffi.string(column.name))
            ovsdb_idl_add_column(idl, column);
            --print("LAST ERROR, add_column: ", ovsdb_idl_get_last_error(idl));
        end
    end
end

local function cmd_show()
	print("==== cmd_show ====")
    local row = ovsdb_idl_first_row(idl, cmd_show_tables[1].table);
    print("FIRST ROW: ", row);
    
    while (row ~= nil) do
    	print("ROW: ", row)
        --cmd_show_row(ctx, row, 0);
        row = ovsdb_idl_next_row(row)
    end
end


local function prolog()
	-- create an in-memory instance
	local retry = true;
	local monitor_everything = false;

	--print("Lib_ovs: ", common.Lib_ovs);

	--local success, controller_columns = pcall(function() return common.Lib_ovs.Lib_openvswitch["ovsrec_controller_columns"] end);
	--print("controller_columns: ", success, controller_columns);

	--local success, idl_class = pcall(function() return common.Lib_ovs.Lib_openvswitch.ovsrec_idl_class end);
	--print("ovsrec_idl: ", success, idl_class)


	--if not success then 
	--	print("do not have idl_class")
	--	return 
	--end
    --common.Lib_ovs.Lib_openvswitch.ovsrec_idl_class 
    --print("ovsrec_idl_class: ", ovsrec_idl_class);
	
    idl = ovsdb_idl_create(db,ovsrec_idl_class,monitor_everything,retry);	
	--print("idl: ", idl);

	if not idl == nil then
		print("idl_create() failed...")
		return ;
	end

    ovsdb_idl_add_table(idl, ovsrec_table_open_vswitch);
    local retval = ovsdb_idl_get_last_error(idl);
    print("LAST ERROR, add_table: ", retval);

    if wait_for_reload then
        ovsdb_idl_add_column(idl, ovsrec_open_vswitch_col_cur_cfg);
        print("LAST ERROR, add_column: ", ovsdb_idl_get_last_error(idl));
    end

	return true;
end

local function epilog()
	ovsdb_idl_destroy(idl);
end




local function vsctl_fatal(format, ...)
    error(string.format(format,...))
end

local function main()
	print("==== main ====")
	if not prolog() then
		print("prolog failed: ")
		return ;
	end

	pre_cmd_show()


    local seqno = ovsdb_idl_get_seqno(idl);
    while (true) do
        ovsdb_idl_run(idl);
        if (ovsdb_idl_is_alive(idl) == 0) then
            local retval = ovsdb_idl_get_last_error(idl);
            vsctl_fatal("%s: database connection failed (%s)",
                        db, ovs_retval_to_string(retval));
        end

        if (seqno ~= ovsdb_idl_get_seqno(idl)) then
            seqno = ovsdb_idl_get_seqno(idl);
            cmd_show();
            --do_vsctl(args, commands, n_commands, idl);
        end

        if (seqno == ovsdb_idl_get_seqno(idl)) then
            ovsdb_idl_wait(idl);
            poll_block();
        end
    end

	--cmd_show();
end

main()


