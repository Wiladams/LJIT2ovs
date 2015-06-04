local ffi = require("ffi")

common = require("testy.ovsdb_command_common")



local stringz = require("core.stringz")



local db = common.default_db();
local idl = nil;

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

        ovsdb_idl_add_table(idl, show.table);
        if (show.name_column ~= nil) then
            ovsdb_idl_add_column(idl, show.name_column);
        end

        for _, column in ipairs(show.columns) do
            ovsdb_idl_add_column(idl, column);
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

	idl = ovsdb_idl_create(db,ovsrec_idl_class,monitor_everything,retry);	
	--print("idl: ", idl);

	if not idl == nil then
		print("idl_create() failed...")
		return ;
	end

	return true;
end

local function epilog()
	ovsdb_idl_destroy(idl);
end





local function main()
	print("==== main ====")
	if not prolog() then
		print("prolog failed: ")
		return ;
	end

	pre_cmd_show()
	cmd_show();
end

main()


