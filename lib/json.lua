local ffi = require("ffi")

require ("ovs.lib.shash")

ffi.cdef[[
struct ds;

/* Type of a JSON value. */
enum json_type {
    JSON_NULL,                  /* null */
    JSON_FALSE,                 /* false */
    JSON_TRUE,                  /* true */
    JSON_OBJECT,                /* {"a": b, "c": d, ...} */
    JSON_ARRAY,                 /* [1, 2, 3, ...] */
    JSON_INTEGER,               /* 123. */
    JSON_REAL,                  /* 123.456. */
    JSON_STRING,                /* "..." */
    JSON_N_TYPES
};

const char *json_type_to_string(enum json_type);

/* A JSON array. */
struct json_array {
    size_t n, n_allocated;
    struct json **elems;
};

/* A JSON value. */
struct json {
    enum json_type type;
    union {
        struct shash *object;   /* Contains "struct json *"s. */
        struct json_array array;
        long long int integer;
        double real;
        char *string;
    } u;
};
]]

ffi.cdef[[
struct json *json_null_create(void);
struct json *json_boolean_create(bool);
struct json *json_string_create(const char *);
struct json *json_string_create_nocopy(char *);
struct json *json_integer_create(long long int);
struct json *json_real_create(double);

struct json *json_array_create_empty(void);
void json_array_add(struct json *, struct json *element);
void json_array_trim(struct json *);
struct json *json_array_create(struct json **, size_t n);
struct json *json_array_create_1(struct json *);
struct json *json_array_create_2(struct json *, struct json *);
struct json *json_array_create_3(struct json *, struct json *, struct json *);

struct json *json_object_create(void);
void json_object_put(struct json *, const char *name, struct json *value);
void json_object_put_string(struct json *,
                            const char *name, const char *value);

const char *json_string(const struct json *);
struct json_array *json_array(const struct json *);
struct shash *json_object(const struct json *);
bool json_boolean(const struct json *);
double json_real(const struct json *);
int64_t json_integer(const struct json *);

struct json *json_clone(const struct json *);
void json_destroy(struct json *);

size_t json_hash(const struct json *, size_t basis);
bool json_equal(const struct json *, const struct json *);
]]

ffi.cdef[[
/* Parsing JSON. */
enum {
    JSPF_TRAILER = 1 << 0       /* Check for garbage following input.  */
};

struct json_parser *json_parser_create(int flags);
size_t json_parser_feed(struct json_parser *, const char *, size_t);
bool json_parser_is_done(const struct json_parser *);
struct json *json_parser_finish(struct json_parser *);
void json_parser_abort(struct json_parser *);

struct json *json_from_string(const char *string);
struct json *json_from_file(const char *file_name);
//struct json *json_from_stream(FILE *stream);
]]

ffi.cdef[[
/* Serializing JSON. */

enum {
    JSSF_PRETTY = 1 << 0,       /* Multiple lines with indentation, if true. */
    JSSF_SORT = 1 << 1          /* Object members in sorted order, if true. */
};
char *json_to_string(const struct json *, int flags);
void json_to_ds(const struct json *, int flags, struct ds *);
]]

ffi.cdef[[
/* JSON string formatting operations. */

bool json_string_unescape(const char *in, size_t in_len, char **outp);
]]

local jsonlib = ffi.load("openvswitch")

local exports = {
    -- The shared library
    Lib_json = jsonlib;

    -- Enums
    JSON_NULL = ffi.C.JSON_NULL,
    JSON_FALSE = ffi.C.JSON_FALSE,
    JSON_TRUE = ffi.C.JSON_TRUE,
    JSON_OBJECT = ffi.C.JSON_OBJECT,
    JSON_ARRAY = ffi.C.JSON_ARRAY,
    JSON_INTEGER = ffi.C.JSON_INTEGER,
    JSON_REAL = ffi.C.JSON_REAL,
    JSON_STRING = ffi.C.JSON_STRING,
    JSON_N_TYPES = ffi.C.JSON_N_TYPES;

    JSSF_PRETTY = ffi.C.JSSF_PRETTY;
    JSSF_SORT = ffi.C.JSSF_SORT;
    

    -- Functions
    json_type_to_string = jsonlib.json_type_to_string;
    json_null_create = jsonlib.json_null_create;
    json_boolean_create = jsonlib.json_boolean_create;
    json_string_create = jsonlib.json_string_create;
    json_string_create_nocopy = jsonlib.json_string_create_nocopy;
    json_integer_create = jsonlib.json_integer_create;
    json_real_create = jsonlib.json_real_create;

    json_array_create_empty = jsonlib.json_array_create_empty;
    json_array_add = jsonlib.json_array_add;
    json_array_trim = jsonlib.json_array_trim;
    json_array_create = jsonlib.json_array_create;
    json_array_create_1 = jsonlib.json_array_create_1;
    json_array_create_2 = jsonlib.json_array_create_2;
    json_array_create_3 = jsonlib.json_array_create_3;

    json_object_create = jsonlib.json_object_create;
    json_object_put = jsonlib.json_object_put;
    json_object_put_string = jsonlib.json_object_put_string;

    json_string = jsonlib.json_string;
    json_array = jsonlib.json_array;
    json_object = jsonlib.json_object;
    json_boolean = jsonlib.json_boolean;
    json_real = jsonlib.json_real;
    json_integer = jsonlib.json_integer;

    json_clone = jsonlib.json_clone;
    json_destroy = jsonlib.json_destroy;

    json_hash = jsonlib.json_hash;
    json_equal = jsonlib.json_equal;

    json_parser_create = jsonlib.json_parser_create;
    json_parser_feed = jsonlib.json_parser_feed;
    json_parser_is_done = jsonlib.json_parser_is_done;
    json_parser_finish = jsonlib.json_parser_finish;
    json_parser_abort = jsonlib.json_parser_abort;

    json_from_string = jsonlib.json_from_string;
    json_from_file = jsonlib.json_from_file;

    json_to_string = jsonlib.json_to_string;
    json_to_ds = jsonlib.json_to_ds;
    json_string_unescape = jsonlib.json_string_unescape;

}

return exports
