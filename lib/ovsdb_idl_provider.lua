local ffi = require("ffi")

#include "hmap.h"
#include "list.h"
#include "ovsdb-idl.h"
#include "ovsdb-types.h"
#include "shash.h"
#include "uuid.h"

ffi.cdef[[
struct ovsdb_idl_row {
    struct hmap_node hmap_node; /* In struct ovsdb_idl_table's 'rows'. */
    struct uuid uuid;           /* Row "_uuid" field. */
    struct ovs_list src_arcs;   /* Forward arcs (ovsdb_idl_arc.src_node). */
    struct ovs_list dst_arcs;   /* Backward arcs (ovsdb_idl_arc.dst_node). */
    struct ovsdb_idl_table *table; /* Containing table. */
    struct ovsdb_datum *old;    /* Committed data (null if orphaned). */

    /* Transactional data. */
    struct ovsdb_datum *new;    /* Modified data (null to delete row). */
    unsigned long int *prereqs; /* Bitmap of columns to verify in "old". */
    unsigned long int *written; /* Bitmap of columns from "new" to write. */
    struct hmap_node txn_node;  /* Node in ovsdb_idl_txn's list. */
};

struct ovsdb_idl_column {
    char *name;
    struct ovsdb_type type;
    bool mutable;
    void (*parse)(struct ovsdb_idl_row *, const struct ovsdb_datum *);
    void (*unparse)(struct ovsdb_idl_row *);
};

struct ovsdb_idl_table_class {
    char *name;
    bool is_root;
    const struct ovsdb_idl_column *columns;
    size_t n_columns;
    size_t allocation_size;
    void (*row_init)(struct ovsdb_idl_row *);
};

struct ovsdb_idl_table {
    const struct ovsdb_idl_table_class *class;
    unsigned char *modes;    /* OVSDB_IDL_* bitmasks, indexed by column. */
    bool need_table;         /* Monitor table even if no columns? */
    struct shash columns;    /* Contains "const struct ovsdb_idl_column *"s. */
    struct hmap rows;        /* Contains "struct ovsdb_idl_row"s. */
    struct ovsdb_idl *idl;   /* Containing idl. */
};

struct ovsdb_idl_class {
    const char *database;       /* <db-name> for this database. */
    const struct ovsdb_idl_table_class *tables;
    size_t n_tables;
};

struct ovsdb_idl_row *ovsdb_idl_get_row_arc(
    struct ovsdb_idl_row *src,
    struct ovsdb_idl_table_class *dst_table,
    const struct uuid *dst_uuid);
]]

ffi.cdef[[
void ovsdb_idl_txn_verify(const struct ovsdb_idl_row *, const struct ovsdb_idl_column *);

struct ovsdb_idl_txn *ovsdb_idl_txn_get(const struct ovsdb_idl_row *);
]]

local Lib_ovsdb_idl_provider = ffi.load("openvswitch")

local exports = {
    Lib_ovsdb_idl_provider = Lib_ovsdb_idl_provider;

    ovsdb_idl_txn_verify = Lib_ovsdb_idl_provider.ovsdb_idl_txn_verify;
    ovsdb_idl_txn = Lib_ovsdb_idl_provider.ovsdb_idl_txn;
}

return exports


