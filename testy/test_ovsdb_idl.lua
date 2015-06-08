--[[
    This is a relatively simple test case to see if we can
    instantiate an in memory database (idl), and read the
    tables.  It is roughly the equivalent of ovs-vsctl show

    Assumes a database server is already running on the 
    machine.
--]]

local ffi = require("ffi")

local common = require("testy.ovsdb_command_common")
local OVSDBIdl = require("classes.OVSDBIdl");
local stringz = require("core.stringz")

local wait_for_reload = true;
--VLOG_DEFINE_THIS_MODULE(vsctl);


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

local function pre_cmd_show(ctx)
	print("==== pre_cmd_show ====")
    for idx, show in ipairs(cmd_show_tables) do
        -- first add the table to be watched
        --ovsdb_idl_add_table(idl, show.table);
        ctx.idl:addTable(show.table);
        print("add_table: ", ffi.string(show.table.name));

        -- add the column
        if (show.name_column ~= nil) then
            --print("add_column, name_column: ", ffi.string(show.name_column.name));
            --ovsdb_idl_add_column(idl, show.name_column);
            ctx.idl:addColumn(show.name_column);
        end

        for _, column in ipairs(show.columns) do
            --print(" ",ffi.string(column.name))
            --ovsdb_idl_add_column(idl, column);
            ctx.idl:addColumn(column);
            --print("LAST ERROR, add_column: ", ovsdb_idl_get_last_error(idl));
        end
    end
    print("---- pre_cmd_show - END ----")
end

local function cmd_show_find_table_by_row(row)
print("==== cmd_show_find_table_by_row ====")
    for _, show in ipairs(cmd_show_tables) do
        print("show.table, row.table.class: ", show.table, row.table.class)
        if (show.table == row.table.class) then
            return show;
        end
    end

    return nil;
end


local function cmd_show_row(ctx, row, level)
    print("==== cmd_show_row: ", row)
    local show = cmd_show_find_table_by_row(row);

    ds_put_char_multiple(ctx.output, string.byte(' '), level * 4);
    if (show and show.name_column) then
        ds_put_format(ctx.output, "%s ", ffi.string(show.table.name));
        local datum = ovsdb_idl_read(row, show.name_column);
        ovsdb_datum_to_string(datum, show.name_column.type, ctx.output);
    else 
        ds_put_format(ctx.output, UUID_FMT, UUID_ARGS(row.uuid));
    end
    
    ds_put_char(ctx.output, string.byte('\n'));

    if (not show or show.recurse) then
        return;
    end

    show.recurse = true;

    for _, column in ipairs(show.columns) do
        print("COLUMN: ", ffi.string(column.name));
        local datum = ovsdb_idl_read(row, column);
        print("  DATUM: ", datum, datum.n);

        if (column.type.key.type == OVSDB_TYPE_UUID and
            column.type.key.u.uuid.refTableName ~= nil) then
            print("    OVSDB_TYPE_UUID")
            local ref_show = cmd_show_find_table_by_name(
                column.type.key.u.uuid.refTableName);
            if (ref_show ~= nil) then
                for j = 0, datum.n-1 do
                    local ref_row = ovsdb_idl_get_row_for_uuid(ctx.idl.Handle,
                                                         ref_show.table,
                                                         datum.keys[j].uuid);
                    if (ref_row ~= nil) then
                        cmd_show_row(ctx, ref_row, level + 1);
                    end
                end
                --continue;
            end
        end

        local isdefault = ovsdb_datum_is_default(datum, column.type);
        print("  DEFAULT: ", isdefault)
        if (not isdefault) then
            print("NOT DEFAULT DATA")
            ds_put_char_multiple(ctx.output, string.byte(' '), (level + 1) * 4);
            ds_put_format(ctx.output, "%s: ", column.name);
            ovsdb_datum_to_string(datum, column.type, ctx.output);
            ds_put_char(ctx.output, string.byte('\n'));
        end

    end
    print("---- cmd_show_row() - END");
    print(ds_cstr(ctx.output));

    show.recurse = false;
end


local function cmd_show(ctx)
	print("==== cmd_show ====")
    local row = ovsdb_idl_first_row(ctx.idl.Handle, cmd_show_tables[1].table);
    print("FIRST ROW: ", row);
    
    while (row ~= nil) do
    	print("ROW: ", row)
        cmd_show_row(ctx, row, 0);
        row = ovsdb_idl_next_row(row)
    end
end


local function prolog()
	-- create an in-memory instance
	local retry = false;
	local monitor_everything = false;
    local db = common.default_db();

    vlog_set_levels(nil, ffi.C.VLF_CONSOLE, ffi.C.VLL_WARN);
    vlog_set_levels(VLM_reconnect, ffi.C.VLF_ANY_DESTINATION, ffi.C.VLL_WARN);

    --local idl, err = ovsdb_idl_create(db,ovsrec_idl_class,monitor_everything,retry);	
    local idl, err = OVSDBIdl(ovsrec_idl_class, db, monitor_everything, retry);

	if not idl == nil then
		print("idl_create() failed...")
		return ;
	end

    --ovsdb_idl_add_table(idl, ovsrec_table_open_vswitch);
    success, err = idl:addTable(ovsrec_table_open_vswitch);


    if wait_for_reload then
        --ovsdb_idl_add_column(idl, ovsrec_open_vswitch_col_cur_cfg);
        success, err = idl:addColumn(ovsrec_open_vswitch_col_cur_cfg);
        --print("LAST ERROR, add_column: ", ovsdb_idl_get_last_error(idl));
    end

    return {
        idl = idl;
        output = dynamic_string();
        --struct table *table;
    }
end

local function epilog(ctx)
	--ovsdb_idl_destroy(idl);
end




local function vsctl_fatal(format, ...)
    error(string.format(format,...))
end




local function main()
	print("==== main ====")
	local ctx = prolog();

    if not ctx then
		print("prolog failed: ")
		return ;
	end

	pre_cmd_show(ctx)


    --local seqno = ovsdb_idl_get_seqno(ctx.idl);
    local seqno = ctx.idl:getSeqNo();
    print("seqno START - ", seqno);

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
            cmd_show(ctx);
        end

        if seqno == ctx.idl:getSeqNo() then
            print("---- waiting")
            ctx.idl:wait();
            poll_block();
        end
    end
end

main()


