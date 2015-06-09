local ffi = require("ffi")

require("lib.hmap")
require("lib.util")

ffi.cdef[[
struct sset_node {
    struct hmap_node hmap_node;
    char name[1];
};

/* A set of strings. */
struct sset {
    struct hmap map;
};
]]

--#define SSET_INITIALIZER(SSET) { HMAP_INITIALIZER(&(SSET)->map) }

ffi.cdef[[
/* Basics. */
void sset_init(struct sset *);
void sset_destroy(struct sset *);
void sset_clone(struct sset *, const struct sset *);
void sset_swap(struct sset *, struct sset *);
void sset_moved(struct sset *);
]]

ffi.cdef[[
/* Count. */
bool sset_is_empty(const struct sset *);
size_t sset_count(const struct sset *);
]]

ffi.cdef[[
/* Insertion. */
struct sset_node *sset_add(struct sset *, const char *);
struct sset_node *sset_add_and_free(struct sset *, char *);
void sset_add_assert(struct sset *, const char *);
void sset_add_array(struct sset *, char **, size_t n);
]]

ffi.cdef[[
/* Deletion. */
void sset_clear(struct sset *);
void sset_delete(struct sset *, struct sset_node *);
bool sset_find_and_delete(struct sset *, const char *);
void sset_find_and_delete_assert(struct sset *, const char *);
char *sset_pop(struct sset *);
]]

ffi.cdef[[
/* Search. */
struct sset_node *sset_find(const struct sset *, const char *);
bool sset_contains(const struct sset *, const char *);
bool sset_equals(const struct sset *, const struct sset *);
struct sset_node *sset_at_position(const struct sset *,
                                   uint32_t *bucketp, uint32_t *offsetp);
]]

--[[
/* Implementation helper macros. */

#define SSET_NODE_FROM_HMAP_NODE(HMAP_NODE) \
    CONTAINER_OF(HMAP_NODE, struct sset_node, hmap_node)
#define SSET_NAME_FROM_HMAP_NODE(HMAP_NODE) \
    HMAP_NODE == NULL                       \
    ? NULL                                  \
    : (CONST_CAST(const char *, (SSET_NODE_FROM_HMAP_NODE(HMAP_NODE)->name)))
#define SSET_NODE_FROM_NAME(NAME) CONTAINER_OF(NAME, struct sset_node, name)
#define SSET_FIRST(SSET) SSET_NAME_FROM_HMAP_NODE(hmap_first(&(SSET)->map))
#define SSET_NEXT(SSET, NAME)                                           \
    SSET_NAME_FROM_HMAP_NODE(                                           \
        hmap_next(&(SSET)->map, &SSET_NODE_FROM_NAME(NAME)->hmap_node))
--]]

--[[
/* Iteration macros. */
#define SSET_FOR_EACH(NAME, SSET)               \
    for ((NAME) = SSET_FIRST(SSET);             \
         NAME != NULL;                          \
         (NAME) = SSET_NEXT(SSET, NAME))

#define SSET_FOR_EACH_SAFE(NAME, NEXT, SSET)        \
    for ((NAME) = SSET_FIRST(SSET);                 \
         (NAME != NULL                              \
          ? (NEXT) = SSET_NEXT(SSET, NAME), true    \
          : false);                                 \
         (NAME) = (NEXT))
--]]


ffi.cdef[[
const char **sset_array(const struct sset *);
const char **sset_sort(const struct sset *);
]]



local Lib_sset = ffi.load("openvswitch")

local exports = {
    Lib_sset = Lib_sset;   

    -- library functions
    sset_init = Lib_sset.sset_init;
    sset_destroy = Lib_sset.sset_destroy;
    sset_clone = Lib_sset.sset_clone;
    sset_swap = Lib_sset.sset_swap;
    sset_moved = Lib_sset.sset_moved;
    sset_is_empty = Lib_sset.sset_is_empty;
    sset_count = Lib_sset.sset_count;
    sset_add = Lib_sset.sset_add;
    sset_add_and_free = Lib_sset.sset_add_and_free;
    sset_add_assert = Lib_sset.sset_add_assert;
    sset_add_array = Lib_sset.sset_add_array;
    sset_clear = Lib_sset.sset_clear;
    sset_delete = Lib_sset.sset_delete;
    sset_find_and_delete = Lib_sset.sset_find_and_delete;
    sset_find_and_delete_assert = Lib_sset.sset_find_and_delete_assert;
    sset_pop = Lib_sset.sset_pop;
    sset_find = Lib_sset.sset_find;
    sset_contains = Lib_sset.sset_contains;
    sset_equals = Lib_sset.sset_equals;
    sset_at_position = Lib_sset.sset_at_position;
}

return exports
