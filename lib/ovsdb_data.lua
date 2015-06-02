local ffi = require("ffi")


--#include "compiler.h"
require("lib.ovsdb_types")
require("lib.shash")

ffi.cdef[[
struct ds;
struct ovsdb_symbol_table;
struct smap;
]]

ffi.cdef[[
/* One value of an atomic type (given by enum ovs_atomic_type). */
union ovsdb_atom {
    int64_t integer;
    double real;
    bool boolean;
    char *string;
    struct uuid uuid;
};
]]

ffi.cdef[[
void ovsdb_atom_init_default(union ovsdb_atom *, enum ovsdb_atomic_type);
const union ovsdb_atom *ovsdb_atom_default(enum ovsdb_atomic_type);
bool ovsdb_atom_is_default(const union ovsdb_atom *, enum ovsdb_atomic_type);
void ovsdb_atom_clone(union ovsdb_atom *, const union ovsdb_atom *,
                      enum ovsdb_atomic_type);
void ovsdb_atom_swap(union ovsdb_atom *, union ovsdb_atom *);
]]

--[[
/* Returns false if ovsdb_atom_destroy() is a no-op when it is applied to an
 * initialized atom of the given 'type', true if ovsdb_atom_destroy() actually
 * does something.
 *
 * This can be used to avoid calling ovsdb_atom_destroy() for each element in
 * an array of homogeneous atoms.  (It's not worthwhile for a single atom.) */
--]]

local function ovsdb_atom_needs_destruction(dtype)
    return dtype == OVSDB_TYPE_STRING;
end

--[[
/* Frees the contents of 'atom', which must have the specified 'type'.
 *
 * This does not actually call free(atom).  If necessary, the caller must be
 * responsible for that. */
--]]
local function ovsdb_atom_destroy(atom, dtype)
    if (dtype == OVSDB_TYPE_STRING) then
        ffi.C.free(atom.string);
    end
end

ffi.cdef[[
uint32_t ovsdb_atom_hash(const union ovsdb_atom *, enum ovsdb_atomic_type,
                         uint32_t basis);

int ovsdb_atom_compare_3way(const union ovsdb_atom *,
                            const union ovsdb_atom *,
                            enum ovsdb_atomic_type);
]]

--/* Returns true if 'a' and 'b', which are both of type 'type', has the same
-- * contents, false if their contents differ.  */
local function ovsdb_atom_equals(a, b, dtype)
    return ovsdb_atom_compare_3way(a, b, dtype) == 0;
end

ffi.cdef[[
struct ovsdb_error *ovsdb_atom_from_json(union ovsdb_atom *,
                                         const struct ovsdb_base_type *,
                                         const struct json *,
                                         struct ovsdb_symbol_table *);
struct json *ovsdb_atom_to_json(const union ovsdb_atom *,
                                enum ovsdb_atomic_type);

char *ovsdb_atom_from_string(union ovsdb_atom *,
                             const struct ovsdb_base_type *, const char *,
                             struct ovsdb_symbol_table *);
void ovsdb_atom_to_string(const union ovsdb_atom *, enum ovsdb_atomic_type,
                          struct ds *);
void ovsdb_atom_to_bare(const union ovsdb_atom *, enum ovsdb_atomic_type,
                        struct ds *);

struct ovsdb_error *ovsdb_atom_check_constraints(
    const union ovsdb_atom *, const struct ovsdb_base_type *);
]]

--[[
/* An instance of an OVSDB type (given by struct ovsdb_type).
 *
 * - The 'keys' must be unique and in sorted order.  Most functions that modify
 *   an ovsdb_datum maintain these invariants.  Functions that don't maintain
 *   the invariants have names that end in "_unsafe".  Use ovsdb_datum_sort()
 *   to check and restore these invariants.
 *
 * - 'n' is constrained by the ovsdb_type's 'n_min' and 'n_max'.
 *
 *   If 'n' is nonzero, then 'keys' points to an array of 'n' atoms of the type
 *   specified by the ovsdb_type's 'key_type'.  (Otherwise, 'keys' should be
 *   null.)
 *
 *   If 'n' is nonzero and the ovsdb_type's 'value_type' is not
 *   OVSDB_TYPE_VOID, then 'values' points to an array of 'n' atoms of the type
 *   specified by the 'value_type'.  (Otherwise, 'values' should be null.)
 *
 *   Thus, for 'n' > 0, 'keys' will always be nonnull and 'values' will be
 *   nonnull only for "map" types.
 */
--]]
ffi.cdef[[
struct ovsdb_datum {
    unsigned int n;             /* Number of 'keys' and 'values'. */
    union ovsdb_atom *keys;     /* Each of the ovsdb_type's 'key_type'. */
    union ovsdb_atom *values;   /* Each of the ovsdb_type's 'value_type'. */
};
]]

ffi.cdef[[
/* Basics. */
void ovsdb_datum_init_empty(struct ovsdb_datum *);
void ovsdb_datum_init_default(struct ovsdb_datum *, const struct ovsdb_type *);
bool ovsdb_datum_is_default(const struct ovsdb_datum *,
                            const struct ovsdb_type *);
const struct ovsdb_datum *ovsdb_datum_default(const struct ovsdb_type *);
void ovsdb_datum_clone(struct ovsdb_datum *, const struct ovsdb_datum *,
                       const struct ovsdb_type *);
void ovsdb_datum_destroy(struct ovsdb_datum *, const struct ovsdb_type *);
void ovsdb_datum_swap(struct ovsdb_datum *, struct ovsdb_datum *);
]]

ffi.cdef[[
/* Checking and maintaining invariants. */
struct ovsdb_error *ovsdb_datum_sort(struct ovsdb_datum *,
                                     enum ovsdb_atomic_type key_type);

void ovsdb_datum_sort_assert(struct ovsdb_datum *,
                             enum ovsdb_atomic_type key_type);

size_t ovsdb_datum_sort_unique(struct ovsdb_datum *,
                               enum ovsdb_atomic_type key_type,
                               enum ovsdb_atomic_type value_type);

struct ovsdb_error *ovsdb_datum_check_constraints(
    const struct ovsdb_datum *, const struct ovsdb_type *);
]]

ffi.cdef[[
/* Type conversion. */
struct ovsdb_error *ovsdb_datum_from_json(struct ovsdb_datum *,
                                          const struct ovsdb_type *,
                                          const struct json *,
                                          struct ovsdb_symbol_table *);
struct json *ovsdb_datum_to_json(const struct ovsdb_datum *,
                                 const struct ovsdb_type *);

char *ovsdb_datum_from_string(struct ovsdb_datum *,
                              const struct ovsdb_type *, const char *,
                              struct ovsdb_symbol_table *);
void ovsdb_datum_to_string(const struct ovsdb_datum *,
                           const struct ovsdb_type *, struct ds *);
void ovsdb_datum_to_bare(const struct ovsdb_datum *,
                         const struct ovsdb_type *, struct ds *);

void ovsdb_datum_from_smap(struct ovsdb_datum *, struct smap *);
]]

ffi.cdef[[
/* Comparison. */
uint32_t ovsdb_datum_hash(const struct ovsdb_datum *,
                          const struct ovsdb_type *, uint32_t basis);
int ovsdb_datum_compare_3way(const struct ovsdb_datum *,
                             const struct ovsdb_datum *,
                             const struct ovsdb_type *);
bool ovsdb_datum_equals(const struct ovsdb_datum *,
                        const struct ovsdb_datum *,
                        const struct ovsdb_type *);
]]

ffi.cdef[[
/* Search. */
unsigned int ovsdb_datum_find_key(const struct ovsdb_datum *,
                                  const union ovsdb_atom *key,
                                  enum ovsdb_atomic_type key_type);
unsigned int ovsdb_datum_find_key_value(const struct ovsdb_datum *,
                                        const union ovsdb_atom *key,
                                        enum ovsdb_atomic_type key_type,
                                        const union ovsdb_atom *value,
                                        enum ovsdb_atomic_type value_type);
]]

ffi.cdef[[
/* Set operations. */
bool ovsdb_datum_includes_all(const struct ovsdb_datum *,
                              const struct ovsdb_datum *,
                              const struct ovsdb_type *);
bool ovsdb_datum_excludes_all(const struct ovsdb_datum *,
                              const struct ovsdb_datum *,
                              const struct ovsdb_type *);
void ovsdb_datum_union(struct ovsdb_datum *,
                       const struct ovsdb_datum *,
                       const struct ovsdb_type *,
                       bool replace);
void ovsdb_datum_subtract(struct ovsdb_datum *a,
                          const struct ovsdb_type *a_type,
                          const struct ovsdb_datum *b,
                          const struct ovsdb_type *b_type);

/* Raw operations that may not maintain the invariants. */
void ovsdb_datum_remove_unsafe(struct ovsdb_datum *, size_t idx,
                               const struct ovsdb_type *);
void ovsdb_datum_add_unsafe(struct ovsdb_datum *,
                            const union ovsdb_atom *key,
                            const union ovsdb_atom *value,
                            const struct ovsdb_type *);
]]

-- Type checking.
local function ovsdb_datum_conforms_to_type(datum, dtype)
    return datum.n >= dtype.n_min and datum.n <= dtype.n_max;
end

ffi.cdef[[
/* A table mapping from names to data items.  Currently the data items are
 * always UUIDs; perhaps this will be expanded in the future. */

struct ovsdb_symbol_table {
    struct shash sh;            /* Maps from name to struct ovsdb_symbol *. */
};

struct ovsdb_symbol {
    struct uuid uuid;           /* The UUID that the symbol represents. */
    bool created;               /* Already used to create row? */
    bool strong_ref;            /* Parsed a strong reference to this row? */
    bool weak_ref;              /* Parsed a weak reference to this row? */
};
]]

ffi.cdef[[
struct ovsdb_symbol_table *ovsdb_symbol_table_create(void);
void ovsdb_symbol_table_destroy(struct ovsdb_symbol_table *);
struct ovsdb_symbol *ovsdb_symbol_table_get(const struct ovsdb_symbol_table *,
                                            const char *name);
struct ovsdb_symbol *ovsdb_symbol_table_put(struct ovsdb_symbol_table *,
                                            const char *name,
                                            const struct uuid *, bool used);
struct ovsdb_symbol *ovsdb_symbol_table_insert(struct ovsdb_symbol_table *,
                                               const char *name);
]]

ffi.cdef[[
/* Tokenization
 *
 * Used by ovsdb_atom_from_string() and ovsdb_datum_from_string(). */

char *ovsdb_token_parse(const char **, char **outp);
bool ovsdb_token_is_delim(unsigned char);
]]

local Lib_ovsdb_data = ffi.load("openvswitch")

local exports = {
  Lib_ovsdb_data = Lib_ovsdb_data;

  -- local functions
  ovsdb_atom_needs_destruction = ovsdb_atom_needs_destruction;
  ovsdb_atom_destroy = ovsdb_atom_destroy;
  ovsdb_atom_equals = ovsdb_atom_equals;
  ovsdb_datum_conforms_to_type = ovsdb_datum_conforms_to_type;

  -- shared library functions
  ovsdb_symbol_table_create = Lib_ovsdb_data.ovsdb_symbol_table_create;
  ovsdb_symbol_table_destroy = Lib_ovsdb_data.ovsdb_symbol_table_destroy;
  ovsdb_symbol_table_get = Lib_ovsdb_data.ovsdb_symbol_table_get;
  ovsdb_symbol_table_put = Lib_ovsdb_data.ovsdb_symbol_table_put;
  ovsdb_symbol_table_insert = Lib_ovsdb_data.ovsdb_symbol_table_insert;

  ovsdb_token_parse = Lib_ovsdb_data.ovsdb_token_parse;
  ovsdb_token_is_delim = Lib_ovsdb_data.ovsdb_token_is_delim;
}

return exports
