local ffi = require("ffi")

local common = require("testy.ovctl_command_common")


struct cmd_show_table {
    const struct ovsdb_idl_table_class *table;
    const struct ovsdb_idl_column *name_column;
    const struct ovsdb_idl_column *columns[3];
    bool recurse;
};

static struct cmd_show_table cmd_show_tables[] = {
    {&ovsrec_table_open_vswitch,
     NULL,
     {&ovsrec_open_vswitch_col_manager_options,
      &ovsrec_open_vswitch_col_bridges,
      &ovsrec_open_vswitch_col_ovs_version},
     false},

    {&ovsrec_table_bridge,
     &ovsrec_bridge_col_name,
     {&ovsrec_bridge_col_controller,
      &ovsrec_bridge_col_fail_mode,
      &ovsrec_bridge_col_ports},
     false},

    {&ovsrec_table_port,
     &ovsrec_port_col_name,
     {&ovsrec_port_col_tag,
      &ovsrec_port_col_trunks,
      &ovsrec_port_col_interfaces},
     false},

    {&ovsrec_table_interface,
     &ovsrec_interface_col_name,
     {&ovsrec_interface_col_type,
      &ovsrec_interface_col_options,
      &ovsrec_interface_col_error},
     false},

    {&ovsrec_table_controller,
     &ovsrec_controller_col_target,
     {&ovsrec_controller_col_is_connected,
      NULL,
      NULL},
     false},

    {&ovsrec_table_manager,
     &ovsrec_manager_col_target,
     {&ovsrec_manager_col_is_connected,
      NULL,
      NULL},
     false},
};

static void
pre_cmd_show(struct vsctl_context *ctx)
{
    struct cmd_show_table *show;

    for (show = cmd_show_tables;
         show < &cmd_show_tables[ARRAY_SIZE(cmd_show_tables)];
         show++) {
        size_t i;

        ovsdb_idl_add_table(ctx->idl, show->table);
        if (show->name_column) {
            ovsdb_idl_add_column(ctx->idl, show->name_column);
        }
        for (i = 0; i < ARRAY_SIZE(show->columns); i++) {
            const struct ovsdb_idl_column *column = show->columns[i];
            if (column) {
                ovsdb_idl_add_column(ctx->idl, column);
            }
        }
    }
}

static struct cmd_show_table *
cmd_show_find_table_by_row(const struct ovsdb_idl_row *row)
{
    struct cmd_show_table *show;

    for (show = cmd_show_tables;
         show < &cmd_show_tables[ARRAY_SIZE(cmd_show_tables)];
         show++) {
        if (show->table == row->table->class) {
            return show;
        }
    }
    return NULL;
}

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

static void
cmd_show(struct vsctl_context *ctx)
{
    const struct ovsdb_idl_row *row;

    for (row = ovsdb_idl_first_row(ctx->idl, cmd_show_tables[0].table);
         row; row = ovsdb_idl_next_row(row)) {
        cmd_show_row(ctx, row, 0);
    }
}
