local ffi = require("ffi")

ffi.cdef[[
struct svec {
    char **names;
    size_t n;
    size_t allocated;
};
]]

--#define SVEC_EMPTY_INITIALIZER { NULL, 0, 0 }

ffi.cdef[[
void svec_init(struct svec *);
void svec_clone(struct svec *, const struct svec *);
void svec_destroy(struct svec *);
void svec_clear(struct svec *);
bool svec_is_empty(const struct svec *);
void svec_add(struct svec *, const char *);
void svec_add_nocopy(struct svec *, char *);
void svec_del(struct svec *, const char *);
void svec_append(struct svec *, const struct svec *);
void svec_terminate(struct svec *);
void svec_sort(struct svec *);
void svec_sort_unique(struct svec *);
void svec_unique(struct svec *);
void svec_compact(struct svec *);
void svec_diff(const struct svec *a, const struct svec *b,
               struct svec *a_only, struct svec *both, struct svec *b_only);
bool svec_contains(const struct svec *, const char *);
size_t svec_find(const struct svec *, const char *);
bool svec_is_sorted(const struct svec *);
bool svec_is_unique(const struct svec *);
const char *svec_get_duplicate(const struct svec *);
void svec_swap(struct svec *a, struct svec *b);
void svec_print(const struct svec *svec, const char *title);
void svec_parse_words(struct svec *svec, const char *words);
bool svec_equal(const struct svec *, const struct svec *);
char *svec_join(const struct svec *,
                const char *delimiter, const char *terminator);
const char *svec_back(const struct svec *);
void svec_pop_back(struct svec *);
]]

--[[
/* Iterates over the names in SVEC, assigning each name in turn to NAME and its
 * index to INDEX. */
#define SVEC_FOR_EACH(INDEX, NAME, SVEC)        \
    for ((INDEX) = 0;                           \
         ((INDEX) < (SVEC)->n                   \
          ? (NAME) = (SVEC)->names[INDEX], 1    \
          : 0);                                 \
         (INDEX)++)
--]]

local Lib_svec = ffi.load("openvswitch")

local svec = ffi.typeof("struct svec")
local svec_mt = {
    __new = function(ct, ...)
        local obj = ffi.new(ct, ...);
        Lib_svec.svec_init(obj);
        
        return obj;
    end;

    __gc = function(self)
        -- memory of self is handled by lua
        -- in this case, so we just call the 
        -- svec_destroy to deal with the internal cleanup
        Lib_svec.svec_destroy(self);
    end;

    __index = {
        clear = function(self)
          Lib_svec.clear(self);
        end,

        sort = function(self)
            Lib_svec.sort(self);
        end,
    };
}
ffi.metatype(svec, svec_mt);

local exports = {
    Lib_svec = Lib_svec;

    -- Types
    svec = svec;

    -- library functions
    svec_init = Lib_svec.svec_init;
    svec_clone = Lib_svec.svec_clone;
    svec_destroy = Lib_svec.svec_destroy;
    svec_clear = Lib_svec.svec_clear;
    svec_is_empty = Lib_svec.svec_is_empty;
    svec_add = Lib_svec.svec_add;
    svec_add_nocopy = Lib_svec.svec_add_nocopy;
    svec_del = Lib_svec.svec_del;
    svec_append = Lib_svec.svec_append;
    svec_terminate = Lib_svec.svec_terminate;
    svec_sort = Lib_svec.svec_sort;
    svec_sort_unique = Lib_svec.svec_sort_unique;
    svec_unique = Lib_svec.svec_unique;
    svec_compact = Lib_svec.svec_compact;
    svec_diff = Lib_svec.svec_diff;
    svec_contains = Lib_svec.svec_contains;
    svec_find = Lib_svec.svec_find;
    svec_is_sorted = Lib_svec.svec_is_sorted;
    svec_is_unique = Lib_svec.svec_is_unique;
    svec_get_duplicate = Lib_svec.svec_get_duplicate;
    svec_swap = Lib_svec.svec_swap;
    svec_print = Lib_svec.svec_print;
    svec_parse_words = Lib_svec.svec_parse_words;
    svec_equal = Lib_svec.svec_equal;
    svec_join = Lib_svec.svec_join;
    svec_back = Lib_svec.svec_back;
    svec_pop_back = Lib_svec.svec_pop_back;
}

return exports;
