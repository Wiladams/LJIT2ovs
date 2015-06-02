local ffi = require("ffi")

ffi.cdef[[
struct json;
struct ovsdb_log;

typedef struct int64_t off_t;

/* Access mode for opening an OVSDB log. */
enum ovsdb_log_open_mode {
    OVSDB_LOG_READ_ONLY,        /* Open existing file, read-only. */
    OVSDB_LOG_READ_WRITE,       /* Open existing file, read/write. */
    OVSDB_LOG_CREATE            /* Create new file, read/write. */
};

struct ovsdb_error *ovsdb_log_open(const char *name, enum ovsdb_log_open_mode,
                                   int locking, struct ovsdb_log **);
void ovsdb_log_close(struct ovsdb_log *);

struct ovsdb_error *ovsdb_log_read(struct ovsdb_log *, struct json **);
void ovsdb_log_unread(struct ovsdb_log *);

struct ovsdb_error *ovsdb_log_write(struct ovsdb_log *, struct json *);
struct ovsdb_error *ovsdb_log_commit(struct ovsdb_log *);

off_t ovsdb_log_get_offset(const struct ovsdb_log *);
]]

local Lib_log = ffi.load("ovsdb")

local exports = {
	Lib_log = Lib_log;

	OVSDB_LOG_READ_ONLY = ffi.C.OVSDB_LOG_READ_ONLY;
	OVSDB_LOG_READ_WRITE = ffi.C.OVSDB_LOG_READ_WRITE;
	OVSDB_LOG_CREATE = ffi.C.OVSDB_LOG_CREATE;

	ovsdb_log_open = Lib_log.ovsdb_log_open;
	ovsdb_log_close = Lib_log.ovsdb_log_close;
	ovsdb_log_read = Lib_log.ovsdb_log_read;
	ovsdb_log_unread = Lib_log.ovsdb_log_unread;
	ovsdb_log_write = Lib_log.ovsdb_log_write;
	ovsdb_log_commit = Lib_log.ovsdb_log_commit;
	ovsdb_log_get_offset = Lib_log.ovsdb_log_get_offset;
}

return exports
