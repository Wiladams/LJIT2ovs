local ffi = require("ffi")

require("lib.hmap")

ffi.cdef[[
struct json;

/* A map from string to string. */
struct smap {
    struct hmap map;           /* Contains "struct smap_node"s. */
};

struct smap_node {
    struct hmap_node node;     /* In struct smap's 'map' hmap. */
    char *key;
    char *value;
};
]]

--[[
#define SMAP_INITIALIZER(SMAP) { HMAP_INITIALIZER(&(SMAP)->map) }

#define SMAP_FOR_EACH(SMAP_NODE, SMAP) \
    HMAP_FOR_EACH (SMAP_NODE, node, &(SMAP)->map)

#define SMAP_FOR_EACH_SAFE(SMAP_NODE, NEXT, SMAP) \
    HMAP_FOR_EACH_SAFE (SMAP_NODE, NEXT, node, &(SMAP)->map)
--]]

ffi.cdef[[
void smap_init(struct smap *);
void smap_destroy(struct smap *);

struct smap_node *smap_add(struct smap *, const char *, const char *);
struct smap_node *smap_add_nocopy(struct smap *, char *, char *);
bool smap_add_once(struct smap *, const char *, const char *);
void smap_add_format(struct smap *, const char *key, const char *, ...);
void smap_replace(struct smap *, const char *, const char *);

void smap_remove(struct smap *, const char *);
void smap_remove_node(struct smap *, struct smap_node *);
void smap_steal(struct smap *, struct smap_node *, char **keyp, char **valuep);
void smap_clear(struct smap *);

const char *smap_get(const struct smap *, const char *);
struct smap_node *smap_get_node(const struct smap *, const char *);
bool smap_get_bool(const struct smap *smap, const char *key, bool def);
int smap_get_int(const struct smap *smap, const char *key, int def);

bool smap_is_empty(const struct smap *);
size_t smap_count(const struct smap *);

void smap_clone(struct smap *dst, const struct smap *src);
const struct smap_node **smap_sort(const struct smap *);

void smap_from_json(struct smap *, const struct json *);
struct json *smap_to_json(const struct smap *);
]]

local Lib_smap = ffi.load("openvswitch")

local exports = {
	Lib_smap = Lib_smap;

	smap_init = Lib_smap.smap_init;
	smap_destroy = Lib_smap.smap_destroy;
	smap_add = Lib_smap.smap_add;
	smap_add_nocopy = Lib_smap.smap_add_nocopy;
	smap_add_once = Lib_smap.smap_add_once;
	smap_add_format = Lib_smap.smap_add_format;
	smap_replace = Lib_smap.smap_replace;
	smap_remove = Lib_smap.smap_remove;
	smap_remove_node = Lib_smap.smap_remove_node;
	smap_steal = Lib_smap.smap_steal;
	smap_clear = Lib_smap.smap_clear;
	smap_get = Lib_smap.smap_get;
	smap_get_node = Lib_smap.smap_get_node;
	smap_get_bool = Lib_smap.smap_get_bool;
	smap_get_int = Lib_smap.smap_get_int;
	smap_is_empty = Lib_smap.smap_is_empty;
	smap_count = Lib_smap.smap_count;
	smap_clone = Lib_smap.smap_clone;
	smap_sort = Lib_smap.smap_sort;
	smap_from_json = Lib_smap.smap_from_json;
	smap_to_json = Lib_smap.smap_to_json;
}

return exports
