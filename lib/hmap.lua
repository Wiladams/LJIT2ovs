local ffi = require("ffi")
local bit = require("bit")
local bor, band = bit.bor, bit.band

--#include "util.h"

local exports = {}

ffi.cdef[[
/* A hash map node, to be embedded inside the data structure being mapped. */
struct hmap_node {
    size_t hash;                /* Hash value. */
    struct hmap_node *next;     /* Next in linked list. */
};
]]

-- Returns the hash value embedded in 'node'.
local function hmap_node_hash(node)
    return node.hash;
end
exports.hmap_node_hash = hmap_node_hash;

local HMAP_NODE_NULL = ffi.cast("struct hmap_node *", 1);
--#define HMAP_NODE_NULL_INITIALIZER { 0, HMAP_NODE_NULL }

--/* Returns true if 'node' has been set to null by hmap_node_nullify() and has
-- * not been un-nullified by being inserted into an hmap. */
local function hmap_node_is_null(node)
    return node.next == HMAP_NODE_NULL;
end

-- Marks 'node' with a distinctive value that can be tested with
-- hmap_node_is_null().  */
local function hmap_node_nullify(node)
    node.next = HMAP_NODE_NULL;
end

ffi.cdef[[
/* A hash map. */
struct hmap {
    struct hmap_node **buckets; /* Must point to 'one' iff 'mask' == 0. */
    struct hmap_node *one;
    size_t mask;
    size_t n;
};
]]

--[=[
/* Initializer for an empty hash map. */
#define HMAP_INITIALIZER(HMAP) { (struct hmap_node **const) &(HMAP)->one, NULL, 0, 0 }

ffi.cdef[[
/* Initialization. */
void hmap_init(struct hmap *);
void hmap_destroy(struct hmap *);
void hmap_clear(struct hmap *);
void hmap_swap(struct hmap *a, struct hmap *b);
void hmap_moved(struct hmap *hmap);
]]

ffi.cdef[[
/* Adjusting capacity. */
void hmap_expand_at(struct hmap *, const char *where);
void hmap_shrink_at(struct hmap *, const char *where);
void hmap_reserve_at(struct hmap *, size_t capacity, const char *where);

/* Insertion and deletion. */

void hmap_node_moved(struct hmap *, struct hmap_node *, struct hmap_node *);

struct hmap_node *hmap_random_node(const struct hmap *);
]]

#define hmap_expand(HMAP) hmap_expand_at(HMAP, OVS_SOURCE_LOCATOR)
#define hmap_shrink(HMAP) hmap_shrink_at(HMAP, OVS_SOURCE_LOCATOR)
#define hmap_reserve(HMAP, CAPACITY) \
    hmap_reserve_at(HMAP, CAPACITY, OVS_SOURCE_LOCATOR)
#define hmap_insert(HMAP, NODE, HASH) \
    hmap_insert_at(HMAP, NODE, HASH, OVS_SOURCE_LOCATOR)

ffi.cdef[[

#define HMAP_FOR_EACH_WITH_HASH(NODE, MEMBER, HASH, HMAP)               \
    for (INIT_CONTAINER(NODE, hmap_first_with_hash(HMAP, HASH), MEMBER); \
         NODE != OBJECT_CONTAINING(NULL, NODE, MEMBER);                  \
         ASSIGN_CONTAINER(NODE, hmap_next_with_hash(&(NODE)->MEMBER),   \
                          MEMBER))
#define HMAP_FOR_EACH_IN_BUCKET(NODE, MEMBER, HASH, HMAP)               \
    for (INIT_CONTAINER(NODE, hmap_first_in_bucket(HMAP, HASH), MEMBER); \
         NODE != OBJECT_CONTAINING(NULL, NODE, MEMBER);                  \
         ASSIGN_CONTAINER(NODE, hmap_next_in_bucket(&(NODE)->MEMBER), MEMBER))
]]

ffi.cdef[[
bool hmap_contains(const struct hmap *, const struct hmap_node *);
]]

ffi.cdef[[
/* Iteration. */

/* Iterates through every node in HMAP. */
#define HMAP_FOR_EACH(NODE, MEMBER, HMAP)                               \
    for (INIT_CONTAINER(NODE, hmap_first(HMAP), MEMBER);                \
         NODE != OBJECT_CONTAINING(NULL, NODE, MEMBER);                  \
         ASSIGN_CONTAINER(NODE, hmap_next(HMAP, &(NODE)->MEMBER), MEMBER))

/* Safe when NODE may be freed (not needed when NODE may be removed from the
 * hash map but its members remain accessible and intact). */
#define HMAP_FOR_EACH_SAFE(NODE, NEXT, MEMBER, HMAP)                    \
    for (INIT_CONTAINER(NODE, hmap_first(HMAP), MEMBER);                \
         (NODE != OBJECT_CONTAINING(NULL, NODE, MEMBER)                  \
          ? INIT_CONTAINER(NEXT, hmap_next(HMAP, &(NODE)->MEMBER), MEMBER), 1 \
          : 0);                                                         \
         (NODE) = (NEXT))

/* Continues an iteration from just after NODE. */
#define HMAP_FOR_EACH_CONTINUE(NODE, MEMBER, HMAP)                      \
    for (ASSIGN_CONTAINER(NODE, hmap_next(HMAP, &(NODE)->MEMBER), MEMBER); \
         NODE != OBJECT_CONTAINING(NULL, NODE, MEMBER);                  \
         ASSIGN_CONTAINER(NODE, hmap_next(HMAP, &(NODE)->MEMBER), MEMBER))
]]

ffi.cdef[[
struct hmap_node *hmap_at_position(const struct hmap *,
                                   uint32_t *bucket, uint32_t *offset);
]]

-- Returns the number of nodes currently in 'hmap'. */
--static inline size_t
local function hmap_count(const struct hmap *hmap)
    return hmap.n;
end

-- Returns the maximum number of nodes that 'hmap' may hold before it should be
-- rehashed.
--static inline size_t
local function hmap_capacity(const struct hmap *hmap)
    return hmap.mask * 2 + 1;
end

--[[
/* Returns true if 'hmap' currently contains no nodes,
 * false otherwise.
 * Note: While hmap in general is not thread-safe without additional locking,
 * hmap_is_empty() is. */
--]]
--static inline bool
local function hmap_is_empty(const struct hmap *hmap)
    return hmap.n == 0;
end

--/* Inserts 'node', with the given 'hash', into 'hmap'.  'hmap' is never
-- * expanded automatically. */
--static inline void
local function hmap_insert_fast(struct hmap *hmap, struct hmap_node *node, size_t hash)

    struct hmap_node **bucket = &hmap->buckets[hash & hmap->mask];
    node->hash = hash;
    node->next = *bucket;
    *bucket = node;
    hmap->n++;
end

--[[
/* Inserts 'node', with the given 'hash', into 'hmap', and expands 'hmap' if
 * necessary to optimize search performance.
 *
 * ('where' is used in debug logging.  Commonly one would use hmap_insert() to
 * automatically provide the caller's source file and line number for
 * 'where'.) */
--]]
--static inline void
local function hmap_insert_at(struct hmap *hmap, struct hmap_node *node, size_t hash,
               const char *where)

    hmap_insert_fast(hmap, node, hash);
    if ((hmap.n / 2) > hmap.mask) then
        hmap_expand_at(hmap, where);
    end
end

--/* Removes 'node' from 'hmap'.  Does not shrink the hash table; call
-- * hmap_shrink() directly if desired. */
--static inline void
local function hmap_remove(struct hmap *hmap, struct hmap_node *node)
    struct hmap_node **bucket = &hmap->buckets[node->hash & hmap->mask];
    while (*bucket ~= node) do
        bucket = &(*bucket)->next;
    end
    *bucket = node.next;
    hmap.n = hmap.n - 1;
end

--[[
/* Puts 'new_node' in the position in 'hmap' currently occupied by 'old_node'.
 * The 'new_node' must hash to the same value as 'old_node'.  The client is
 * responsible for ensuring that the replacement does not violate any
 * client-imposed invariants (e.g. uniqueness of keys within a map).
 *
 * Afterward, 'old_node' is not part of 'hmap', and the client is responsible
 * for freeing it (if this is desirable). */
--]]
--static inline void
local function hmap_replace(struct hmap *hmap,
             const struct hmap_node *old_node, struct hmap_node *new_node)

    struct hmap_node **bucket = &hmap->buckets[old_node->hash & hmap->mask];
    while (*bucket ~= old_node) do
        bucket = &(*bucket).next;
    end
    *bucket = new_node;
    new_node.hash = old_node.hash;
    new_node.next = old_node.next;
end
--]=]

--static inline struct hmap_node *
local function hmap_next_with_hash__(node, hash)
    while (node ~= nil and node.hash ~= hash) do
        node = node.next;
    end

    return node;    -- CONST_CAST(struct hmap_node *, node);
end

--/* Returns the first node in 'hmap' with the given 'hash', or a null pointer if
-- * no nodes have that hash value. */
--static inline struct hmap_node *
local function hmap_first_with_hash(hmap, hash)
    return hmap_next_with_hash__(hmap.buckets[band(hash, hmap.mask)], hash);
end

--/* Returns the first node in 'hmap' in the bucket in which the given 'hash'
-- * would land, or a null pointer if that bucket is empty. */
--static inline struct hmap_node *
local function hmap_first_in_bucket(hmap, hash)
    return hmap.buckets[band(hash, hmap.mask)];
end

--[[
/* Returns the next node in the same bucket as 'node', or a null pointer if
 * there are no more nodes in that bucket.
 *
 * If the hash map has been reallocated since 'node' was visited, some nodes
 * may be skipped; if new nodes with the same hash value have been added, they
 * will be skipped.  (Removing 'node' from the hash map does not prevent
 * calling this function, since node->next is preserved, although freeing
 * 'node' of course does.) */
--]]
--static inline struct hmap_node *
local function hmap_next_in_bucket(node)
    return node.next;
end

--[[
/* Returns the next node in the same hash map as 'node' with the same hash
 * value, or a null pointer if no more nodes have that hash value.
 *
 * If the hash map has been reallocated since 'node' was visited, some nodes
 * may be skipped; if new nodes with the same hash value have been added, they
 * will be skipped.  (Removing 'node' from the hash map does not prevent
 * calling this function, since node->next is preserved, although freeing
 * 'node' of course does.) */
--]]
--static inline struct hmap_node *
local function hmap_next_with_hash(node)
    return hmap_next_with_hash__(node.next, node.hash);
end

--static inline struct hmap_node *
local function hmap_next__(hmap, start)
    for i = start, hmap.mask do
        local node = hmap.buckets[i];
        if (node ~= nil) then
            return node;
        end
    end

    return nil;
end

--/* Returns the first node in 'hmap', in arbitrary order, or a null pointer if
-- * 'hmap' is empty. */
--static inline struct hmap_node *
local function hmap_first(hmap)
    return hmap_next__(hmap, 0);
end

--[[
/* Returns the next node in 'hmap' following 'node', in arbitrary order, or a
 * null pointer if 'node' is the last node in 'hmap'.
 *
 * If the hash map has been reallocated since 'node' was visited, some nodes
 * may be skipped or visited twice.  (Removing 'node' from the hash map does
 * not prevent calling this function, since node->next is preserved, although
 * freeing 'node' of course does.) */
--]]
--static inline struct hmap_node *
local function hmap_next(hmap, node)
    if node.next ~= nil then return node.next end

    return hmap_next__(hmap, band(node.hash, hmap.mask) + 1)
end


