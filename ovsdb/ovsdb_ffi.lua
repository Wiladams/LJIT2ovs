
local ffi = require("ffi")

--require ("compiler")
require ("ovs.lib.hmap")
require ("ovs.lib.list")
require ("ovs.lib.shash")

ffi.cdef[[
struct json;
struct ovsdb_log;
struct ovsdb_session;
struct ovsdb_txn;
struct simap;
struct uuid;
]]

ffi.cdef[[
/* Database schema. */
struct ovsdb_schema {
    char *name;
    char *version;
    char *cksum;
    struct shash tables;        /* Contains "struct ovsdb_table_schema *"s. */
};
]]

ffi.cdef[[
struct ovsdb_schema *ovsdb_schema_create(const char *name,
                                         const char *version,
                                         const char *cksum);
struct ovsdb_schema *ovsdb_schema_clone(const struct ovsdb_schema *);
void ovsdb_schema_destroy(struct ovsdb_schema *);

struct ovsdb_error *ovsdb_schema_from_file(const char *file_name,
                                           struct ovsdb_schema **);

struct ovsdb_error *ovsdb_schema_from_json(struct json *,
                                           struct ovsdb_schema **);

struct json *ovsdb_schema_to_json(const struct ovsdb_schema *);

bool ovsdb_schema_equal(const struct ovsdb_schema *,
                        const struct ovsdb_schema *);
]]

ffi.cdef[[
/* Database. */
struct ovsdb {
    struct ovsdb_schema *schema;
    struct ovs_list replicas;   /* Contains "struct ovsdb_replica"s. */
    struct shash tables;        /* Contains "struct ovsdb_table *"s. */

    /* Triggers. */
    struct ovs_list triggers;   /* Contains "struct ovsdb_trigger"s. */
    bool run_triggers;
};
]]

ffi.cdef[[
struct ovsdb *ovsdb_create(struct ovsdb_schema *);
void ovsdb_destroy(struct ovsdb *);

void ovsdb_get_memory_usage(const struct ovsdb *, struct simap *usage);

struct ovsdb_table *ovsdb_get_table(const struct ovsdb *, const char *);
]]

--[[
ffi.cdef[[
struct json *ovsdb_execute(struct ovsdb *, const struct ovsdb_session *,
                           const struct json *params,
                           long long int elapsed_msec,
                           long long int *timeout_msec);
]]
--]]

ffi.cdef[[
/* Database replication. */

struct ovsdb_replica {
    struct ovs_list node;       /* Element in "struct ovsdb" replicas list. */
    const struct ovsdb_replica_class *class;
};

struct ovsdb_replica_class {
    struct ovsdb_error *(*commit)(struct ovsdb_replica *,
                                  const struct ovsdb_txn *, bool durable);
    void (*destroy)(struct ovsdb_replica *);
};

void ovsdb_replica_init(struct ovsdb_replica *,
                        const struct ovsdb_replica_class *);

void ovsdb_add_replica(struct ovsdb *, struct ovsdb_replica *);
void ovsdb_remove_replica(struct ovsdb *, struct ovsdb_replica *);
]]



local Libovsdb = ffi.load("ovsdb")

local exports = {
  Lib_ovsdb = Libovsdb;

  ovsdb_schema_create = Libovsdb.ovsdb_schema_create;
  ovsdb_schema_clone = Libovsdb.ovsdb_schema_clone;
  ovsdb_schema_destroy = Libovsdb.ovsdb_schema_destroy;
  ovsdb_schema_from_file = Libovsdb.ovsdb_schema_from_file;
  ovsdb_schema_from_json = Libovsdb.ovsdb_schema_from_json;
  ovsdb_schema_to_json = Libovsdb.ovsdb_schema_to_json;
  ovsdb_schema_equal = Libovsdb.ovsdb_schema_equal;

  ovsdb_create = Libovsdb.ovsdb_create;
  ovsdb_destroy = Libovsdb.ovsdb_destroy;
  ovsdb_get_memory_usage = Libovsdb.ovsdb_get_memory_usage;

  ovsdb_replica_init = Libovsdb.ovsdb_replica_init;
  ovsdb_add_replica = Libovsdb.ovsdb_add_replica;
  ovsdb_remove_replica = Libovsdb.ovsdb_remove_replica;
}

return exports