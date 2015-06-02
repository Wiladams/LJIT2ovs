local ffi = require("ffi")

--#include "compiler.h"

ffi.cdef[[
struct json;

struct ovsdb_error *ovsdb_error(const char *tag, const char *details, ...);
struct ovsdb_error *ovsdb_io_error(int error, const char *details, ...);
struct ovsdb_error *ovsdb_syntax_error(const struct json *, const char *tag,
                                       const char *details, ...);

struct ovsdb_error *ovsdb_wrap_error(struct ovsdb_error *error,
                                     const char *details, ...);

struct ovsdb_error *ovsdb_internal_error(struct ovsdb_error *error,
                                         const char *file, int line,
                                         const char *details, ...);
]]

--[[
#define OVSDB_BUG(MSG)                                      \
    ovsdb_internal_error(NULL, __FILE__, __LINE__, "%s", MSG)

#define OVSDB_WRAP_BUG(MSG, ERROR)                          \
    ovsdb_internal_error(ERROR, __FILE__, __LINE__, "%s", MSG)
--]]

ffi.cdef[[
void ovsdb_error_destroy(struct ovsdb_error *);
struct ovsdb_error *ovsdb_error_clone(const struct ovsdb_error *);

char *ovsdb_error_to_string(const struct ovsdb_error *);
struct json *ovsdb_error_to_json(const struct ovsdb_error *);

const char *ovsdb_error_get_tag(const struct ovsdb_error *);

void ovsdb_error_assert(struct ovsdb_error *);
]]

local Lib_ovsdb_error = ffi.load("openvswitch")

local exports = {
    Lib_ovsdb_error = Lib_ovsdb_error;

    ovsdb_error = Lib_ovsdb_error.ovsdb_error;
    ovsdb_io_error = Lib_ovsdb_error.ovsdb_io_error;
    ovsdb_syntax_error = Lib_ovsdb_error.ovsdb_syntax_error;
    ovsdb_wrap_error = Lib_ovsdb_error.ovsdb_wrap_error;
    ovsdb_internal_error = Lib_ovsdb_error.ovsdb_internal_error;
    ovsdb_error_destroy = Lib_ovsdb_error.ovsdb_error_destroy;
    ovsdb_error_clone = Lib_ovsdb_error.ovsdb_error_clone;
    ovsdb_error_to_string = Lib_ovsdb_error.ovsdb_error_to_string;
    ovsdb_error_to_json = Lib_ovsdb_error.ovsdb_error_to_json;
    ovsdb_error_get_tag = Lib_ovsdb_error.ovsdb_error_get_tag;
    ovsdb_error_assert = Lib_ovsdb_error.ovsdb_error_assert;
}

return exports
