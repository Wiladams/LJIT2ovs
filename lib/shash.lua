local ffi = require("ffi")


require("lib.hmap")

local exports = {}


ffi.cdef[[
struct shash_node {
    struct hmap_node node;
    char *name;
    void *data;
};

struct shash {
    struct hmap map;
};
]]

--[[
#define SHASH_INITIALIZER(SHASH) { HMAP_INITIALIZER(&(SHASH)->map) }

#define SHASH_FOR_EACH(SHASH_NODE, SHASH) \
    HMAP_FOR_EACH (SHASH_NODE, node, &(SHASH)->map)

#define SHASH_FOR_EACH_SAFE(SHASH_NODE, NEXT, SHASH) \
    HMAP_FOR_EACH_SAFE (SHASH_NODE, NEXT, node, &(SHASH)->map)
--]]

ffi.cdef[[
void shash_init(struct shash *);
void shash_destroy(struct shash *);
void shash_destroy_free_data(struct shash *);
void shash_swap(struct shash *, struct shash *);
void shash_moved(struct shash *);
void shash_clear(struct shash *);
void shash_clear_free_data(struct shash *);
bool shash_is_empty(const struct shash *);
size_t shash_count(const struct shash *);
struct shash_node *shash_add(struct shash *, const char *, const void *);
struct shash_node *shash_add_nocopy(struct shash *, char *, const void *);
bool shash_add_once(struct shash *, const char *, const void *);
void shash_add_assert(struct shash *, const char *, const void *);
void *shash_replace(struct shash *, const char *, const void *data);
void shash_delete(struct shash *, struct shash_node *);
char *shash_steal(struct shash *, struct shash_node *);
struct shash_node *shash_find(const struct shash *, const char *);
struct shash_node *shash_find_len(const struct shash *, const char *, size_t);
void *shash_find_data(const struct shash *, const char *);
void *shash_find_and_delete(struct shash *, const char *);
void *shash_find_and_delete_assert(struct shash *, const char *);
struct shash_node *shash_first(const struct shash *);
const struct shash_node **shash_sort(const struct shash *);
bool shash_equal_keys(const struct shash *, const struct shash *);
struct shash_node *shash_random_node(struct shash *);
]]

local Lib_shash = ffi.load("openvswitch")

local exports = {
	Lib_shash = Lib_shash;

	shash_init = Lib_shash.shash_init;
	shash_destroy = Lib_shash.shash_destroy;
	shash_destroy_free_data = Lib_shash.shash_destroy_free_data;
	shash_swap = Lib_shash.shash_swap;
	shash_moved = Lib_shash.shash_moved;
	shash_clear = Lib_shash.shash_clear;
	shash_clear_free_data = Lib_shash.shash_clear_free_data;
	shash_is_empty = Lib_shash.shash_is_empty;
	shash_count = Lib_shash.shash_count;
	shash_add = Lib_shash.shash_add;
	shash_add_nocopy = Lib_shash.shash_add_nocopy;
	shash_add_once = Lib_shash.shash_add_once;
	shash_add_assert = Lib_shash.shash_add_assert;
	shash_replace = Lib_shash.shash_replace;
	shash_delete = Lib_shash.shash_delete;
	shash_steal = Lib_shash.shash_steal;
	shash_find = Lib_shash.shash_find;
	shash_find_len = Lib_shash.shash_find_len;
	shash_find_data = Lib_shash.shash_find_data;
	shash_find_and_delete = Lib_shash.shash_find_and_delete;
	shash_find_and_delete_assert = Lib_shash.shash_find_and_delete_assert;
	shash_first = Lib_shash.shash_first;
	shash_sort = Lib_shash.shash_sort;
	shash_equal_keys = Lib_shash.shash_equal_keys;
	shash_random_node = Lib_shash.shash_random_node;

}

return exports;
