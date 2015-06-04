local ffi = require("ffi")

local common = require("testy.ovctl_common")
local stringz = require("core.stringz")

--[[
struct cmd_show_table {
    const struct ovsdb_idl_table_class *table;
    const struct ovsdb_idl_column *name_column;
    const struct ovsdb_idl_column *columns[3];
    bool recurse;
};
--]]

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


local function pre_cmd_show(struct vsctl_context *ctx)

    for idx, show in ipairs(cmd_show_tables) do

        local  i=0;

        ovsdb_idl_add_table(ctx.idl, show.table);
        if (show.name_column ~= nil) then
            ovsdb_idl_add_column(ctx.idl, show.name_column);
        end

        for _, column in ipairs(show.columns) do
            ovsdb_idl_add_column(ctx.idl, column);
        end
    end
end

local function cmd_show_find_table_by_row(const struct ovsdb_idl_row *row)

    for _, show in ipairs(cmd_show_tables) do
        if (show.table == row.table.class) then
            return show;
        end
    end

    return nil;
end


local function cmd_show_find_table_by_name(name)


    for _, show in ipairs(cmd_show_tables) do

        if (stringz.strcmp(show.table.name, name) == 0) then
            return show;
        end
    end

    return nil;
end

static void
local function cmd_show_row(struct vsctl_context *ctx, const struct ovsdb_idl_row *row, int level)

    local show = cmd_show_find_table_by_row(row);
    size_t i;

    ds_put_char_multiple(&ctx.output, ' ', level * 4);
    if (show and show.name_column) then
        const struct ovsdb_datum *datum;

        ds_put_format(&ctx.output, "%s ", show.table.name);
        datum = ovsdb_idl_read(row, show.name_column);
        ovsdb_datum_to_string(datum, &show.name_column.type, &ctx.output);
    else 
        ds_put_format(&ctx.output, UUID_FMT, UUID_ARGS(&row.uuid));
    end
    
    ds_put_char(&ctx.output, '\n');

    if (not show or show.recurse) then
        return;
    end

    show.recurse = true;
    for (i = 0; i < ARRAY_SIZE(show.columns); i++) {
        const struct ovsdb_idl_column *column = show->columns[i];
        const struct ovsdb_datum *datum;

        if (not column) then
            break;
        end

        datum = ovsdb_idl_read(row, column);
        if (column->type.key.type == OVSDB_TYPE_UUID &&
            column->type.key.u.uuid.refTableName) {
            struct cmd_show_table *ref_show;
            size_t j;

            ref_show = cmd_show_find_table_by_name(
                column->type.key.u.uuid.refTableName);
            if (ref_show) {
                for (j = 0; j < datum->n; j++) {
                    const struct ovsdb_idl_row *ref_row;

                    ref_row = ovsdb_idl_get_row_for_uuid(ctx->idl,
                                                         ref_show->table,
                                                         &datum->keys[j].uuid);
                    if (ref_row) {
                        cmd_show_row(ctx, ref_row, level + 1);
                    }
                }
                continue;
            }
        }

        if (!ovsdb_datum_is_default(datum, &column->type)) {
            ds_put_char_multiple(&ctx->output, ' ', (level + 1) * 4);
            ds_put_format(&ctx->output, "%s: ", column->name);
            ovsdb_datum_to_string(datum, &column->type, &ctx->output);
            ds_put_char(&ctx->output, '\n');
        }
    }
    show.recurse = false;
end



local function cmd_show(struct vsctl_context *ctx)
    local row = ovsdb_idl_first_row(ctx.idl, cmd_show_tables[1].table);
    while (row ~= nil) do
        cmd_show_row(ctx, row, 0);
        row = ovsdb_idl_next_row(row)
    end
end

local commands = {
    show = {
        name = "show", 
        min_args = 0, 
        max_args = 0, 
        arguments = "", 
        prerequisites = pre_cmd_show, 
        run = cmd_show, 
        postprocess = nil, 
        options = "", 
        mode = ffi.C.RO
    };
}

local function mini_main()
    local cmd = {
        syntax = commands.show;
        argc = #arg - 1;
        argv = arg;
        options = {};

        -- Data modified by commands. */
        output = dynamic_string();
        --struct table *table;
    };
end

ffi.cdef[[
    extern struct vlog_module VLM_reconnect;
]]

local function main()

    struct ovsdb_idl *idl;
    struct vsctl_command *commands;
    struct shash local_options;
    unsigned int seqno;
    size_t n_commands;
    char *args;

    --set_program_name(argv[0]);
    --fatal_ignore_sigpipe();
    vlog_set_levels(nil, ffi.C.VLF_CONSOLE, ffi.C.VLL_WARN);
    --vlog_set_levels(&VLM_reconnect, ffi.C.VLF_ANY_DESTINATION, ffi.C.VLL_WARN);
    ovsrec_init();

    -- Log our arguments.  This is often valuable for debugging systems. */
    --args = process_escape_args(argv);
    --VLOG(might_write_to_db(argv) ? VLL_INFO : VLL_DBG, "Called as %s", args);

    /* Parse command line. */
    shash_init(&local_options);
    parse_options(argc, argv, &local_options);
    commands = parse_commands(argc - optind, argv + optind, &local_options,
                              &n_commands);

    --if (timeout) {
    --    time_alarm(timeout);
    --}

    /* Initialize IDL. */
    local idl = ovsdb_idl_create(db, &ovsrec_idl_class, false, retry);
    the_idl = idl;

    run_prerequisites(commands, n_commands, idl);

--[[
    /* Execute the commands.
     *
     * 'seqno' is the database sequence number for which we last tried to
     * execute our transaction.  There's no point in trying to commit more than
     * once for any given sequence number, because if the transaction fails
     * it's because the database changed and we need to obtain an up-to-date
     * view of the database before we try the transaction again. */
--]]
    local seqno = ovsdb_idl_get_seqno(idl);
    while (true) do
        ovsdb_idl_run(idl);
        if (ovsdb_idl_is_alive(idl) == 0) then
            int retval = ovsdb_idl_get_last_error(idl);
            vsctl_fatal("%s: database connection failed (%s)",
                        db, ovs_retval_to_string(retval));
        end

        if (seqno ~= ovsdb_idl_get_seqno(idl)) then
            seqno = ovsdb_idl_get_seqno(idl);
            do_vsctl(args, commands, n_commands, idl);
        end

        if (seqno == ovsdb_idl_get_seqno(idl)) then
            ovsdb_idl_wait(idl);
            poll_block();
        end
    end

end

main();
