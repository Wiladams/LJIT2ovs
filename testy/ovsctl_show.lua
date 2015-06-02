local ffi = require("ffi")

local common = require("testy.ovctl_common")

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
        ["table"] = &ovsrec_table_open_vswitch,
        name_column=nil,
        columns = {&ovsrec_open_vswitch_col_manager_options,
            &ovsrec_open_vswitch_col_bridges,
            &ovsrec_open_vswitch_col_ovs_version
        },
        recurse = false
    },

    {
        ["table"] = &ovsrec_table_bridge,
        name_column = &ovsrec_bridge_col_name,
        columns = {
            &ovsrec_bridge_col_controller,
            &ovsrec_bridge_col_fail_mode,
            &ovsrec_bridge_col_ports
            },
        recurse = false
    },

    {
        ["table"] = &ovsrec_table_port,
        name_column = &ovsrec_port_col_name,
        columns = {
            &ovsrec_port_col_tag,
            &ovsrec_port_col_trunks,
            &ovsrec_port_col_interfaces},
        recurse = false
    },

    {
        ["table"] = &ovsrec_table_interface,
        name_column = &ovsrec_interface_col_name,
        columns = {
            &ovsrec_interface_col_type,
            &ovsrec_interface_col_options,
            &ovsrec_interface_col_error
        },
        recurse = false
    },

    {
        ["table"] = &ovsrec_table_controller,
        name_column = &ovsrec_controller_col_target,
        columns = {
            &ovsrec_controller_col_is_connected
        },
        recurse = false
    },

    {
        ["table"] = &ovsrec_table_manager,
        name_column = &ovsrec_manager_col_target,
        columns = {&ovsrec_manager_col_is_connected},
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

static struct cmd_show_table *
cmd_show_find_table_by_name(const char *name)
{
    struct cmd_show_table *show;

    for (show = cmd_show_tables;
         show < &cmd_show_tables[ARRAY_SIZE(cmd_show_tables)];
         show++) {
        if (!strcmp(show->table->name, name)) {
            return show;
        }
    }
    return NULL;
}

static void
cmd_show_row(struct vsctl_context *ctx, const struct ovsdb_idl_row *row,
             int level)
{
    struct cmd_show_table *show = cmd_show_find_table_by_row(row);
    size_t i;

    ds_put_char_multiple(&ctx->output, ' ', level * 4);
    if (show && show->name_column) {
        const struct ovsdb_datum *datum;

        ds_put_format(&ctx->output, "%s ", show->table->name);
        datum = ovsdb_idl_read(row, show->name_column);
        ovsdb_datum_to_string(datum, &show->name_column->type, &ctx->output);
    } else {
        ds_put_format(&ctx->output, UUID_FMT, UUID_ARGS(&row->uuid));
    }
    ds_put_char(&ctx->output, '\n');

    if (!show || show->recurse) {
        return;
    }

    show->recurse = true;
    for (i = 0; i < ARRAY_SIZE(show->columns); i++) {
        const struct ovsdb_idl_column *column = show->columns[i];
        const struct ovsdb_datum *datum;

        if (!column) {
            break;
        }

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
    show->recurse = false;
}

local function cmd_show(struct vsctl_context *ctx)

    const struct ovsdb_idl_row *row;

    local row = ovsdb_idl_first_row(ctx.idl, cmd_show_tables[1].table);
    while (row ~= nil) do
        cmd_show_row(ctx, row, 0);
        row = ovsdb_idl_next_row(row)
    end
end

local function main()
end

main();
