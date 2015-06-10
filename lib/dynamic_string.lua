local ffi = require("ffi")

--#include <time.h>
--#include "compiler.h"

local Lib_dynamic_string = ffi.load("openvswitch")

ffi.cdef[[
/* A "dynamic string", that is, a buffer that can be used to construct a
 * string across a series of operations that extend or modify it.
 *
 * The 'string' member does not always point to a null-terminated string.
 * Initially it is NULL, and even when it is nonnull, some operations do not
 * ensure that it is null-terminated.  Use ds_cstr() to ensure that memory is
 * allocated for the string and that it is null-terminated. */
struct ds {
    char *string;       /* Null-terminated string. */
    size_t length;      /* Bytes used, not including null terminator. */
    size_t allocated;   /* Bytes allocated, not including null terminator. */
};
]]

--#define DS_EMPTY_INITIALIZER { NULL, 0, 0 }

ffi.cdef[[
void ds_init(struct ds *);
void ds_clear(struct ds *);
void ds_truncate(struct ds *, size_t new_length);
void ds_reserve(struct ds *, size_t min_length);
char *ds_put_uninit(struct ds *, size_t n);
void ds_put_utf8(struct ds *, int uc);
void ds_put_char_multiple(struct ds *, char, size_t n);
void ds_put_buffer(struct ds *, const char *, size_t n);
void ds_put_cstr(struct ds *, const char *);
void ds_put_and_free_cstr(struct ds *, char *);
void ds_put_format(struct ds *, const char *, ...) ;
void ds_put_format_valist(struct ds *, const char *, va_list);
void ds_put_printable(struct ds *, const char *, size_t);
void ds_put_hex_dump(struct ds *ds, const void *buf_, size_t size,
                     uintptr_t ofs, bool ascii);
int ds_get_line(struct ds *, FILE *);
int ds_get_preprocessed_line(struct ds *, FILE *, int *line_number);
int ds_get_test_line(struct ds *, FILE *);

void ds_put_strftime_msec(struct ds *, const char *format, long long int when,
			  bool utc);
char *xastrftime_msec(const char *format, long long int when, bool utc);

char *ds_cstr(struct ds *);
const char *ds_cstr_ro(const struct ds *);
char *ds_steal_cstr(struct ds *);
void ds_destroy(struct ds *);
void ds_swap(struct ds *, struct ds *);

int ds_last(const struct ds *);
void ds_chomp(struct ds *, int c);
]]

-- Inline functions. */

local function ds_put_char(ds, c)

    if (ds.length < ds.allocated) then
        ds.string[ds.length] = c;
        ds.length = ds.length + 1;
        ds.string[ds.length] = 0;   -- null terminated
    else 
        Lib_dynamic_string.ds_put_char__(ds, c);
    end
end

local function dynamic_string()
    local ptr = ffi.cast("struct ds *", ffi.C.malloc(ffi.sizeof("struct ds")));
    --ffi.fill(ptr, 0, ffi.sizeof("struct ds"));
    Lib_dynamic_string.ds_init(ptr);
    ffi.gc(ptr, Lib_dynamic_string.ds_destroy);

    return ptr;
end

local exports = {
    Lib_dynamic_string = Lib_dynamic_string;

    -- inline functions
    dynamic_string = dynamic_string;
    ds_put_char = ds_put_char;

    ds_init = Lib_dynamic_string.ds_init;
    ds_clear = Lib_dynamic_string.ds_clear;
    ds_truncate = Lib_dynamic_string.ds_truncate;
    ds_reserve = Lib_dynamic_string.ds_reserve;
    ds_put_uninit = Lib_dynamic_string.ds_put_uninit;
    
    ds_put_utf8 = Lib_dynamic_string.ds_put_utf8;
    ds_put_char_multiple = Lib_dynamic_string.ds_put_char_multiple;
    ds_put_buffer = Lib_dynamic_string.ds_put_buffer;
    ds_put_cstr = Lib_dynamic_string.ds_put_cstr;
    ds_put_and_free_cstr = Lib_dynamic_string.ds_put_and_free_cstr;
    ds_put_format = Lib_dynamic_string.ds_put_format;
    ds_put_format_valist = Lib_dynamic_string.ds_put_format_valist;
    ds_put_printable = Lib_dynamic_string.ds_put_printable;
    ds_put_hex_dump = Lib_dynamic_string.ds_put_hex_dump;
    
    ds_get_line = Lib_dynamic_string.ds_get_line;
    ds_get_preprocessed_line = Lib_dynamic_string.ds_get_preprocessed_line;
    ds_get_test_line = Lib_dynamic_string.ds_get_test_line;
    
    ds_put_strftime_msec = Lib_dynamic_string.ds_put_strftime_msec;
    xastrftime_msec = Lib_dynamic_string.xastrftime_msec;
    
    ds_cstr = function(ds ) return ffi.string(Lib_dynamic_string.ds_cstr(ds)) end;
    ds_cstr_ro = Lib_dynamic_string.ds_cstr_ro;
    ds_steal_cstr = Lib_dynamic_string.ds_steal_cstr;
    
    ds_destroy = Lib_dynamic_string.ds_destroy;
    ds_swap = Lib_dynamic_string.ds_swap;
    ds_last = Lib_dynamic_string.ds_last;
    ds_chomp = Lib_dynamic_string.ds_chomp;
}

return exports
