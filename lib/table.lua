local ffi = require("ffi")

--require ("compiler");
local Lib_table = ffi.load("openvswitch")
local stringz = require("stringz")
local json = require("ovs.lib.json");


ffi.cdef[[
struct table_style;

/* Manipulating tables and their rows and columns. */

struct table {
    struct cell *cells;
    struct column *columns;
    size_t n_columns, allocated_columns;
    size_t n_rows, allocated_rows;
    size_t current_column;
    char *caption;
    bool timestamp;
};

void table_init(struct table *);
void table_destroy(struct table *);
void table_set_caption(struct table *, char *caption);
void table_set_timestamp(struct table *, bool timestamp);

void table_add_column(struct table *, const char *heading, ...);
void table_add_row(struct table *);
]]

ffi.cdef[[
/* Table cells. */

struct cell {
    /* Literal text. */
    char *text;

    /* JSON. */
    struct json *json;
    const struct ovsdb_type *type;
};

struct cell *table_add_cell(struct table *);
]]

ffi.cdef[[
/* Table formatting. */

enum table_format {
    TF_TABLE,                   /* 2-d table. */
    TF_LIST,                    /* One cell per line, one row per paragraph. */
    TF_HTML,                    /* HTML table. */
    TF_CSV,                     /* Comma-separated lines. */
    TF_JSON                     /* JSON. */
};

enum cell_format {
    CF_STRING,                  /* String format. */
    CF_BARE,                    /* String format without most punctuation. */
    CF_JSON                     /* JSON. */
};

struct table_style {
    enum table_format format;   /* TF_*. */
    enum cell_format cell_format; /* CF_*. */
    bool headings;              /* Include headings? */
    int json_flags;             /* CF_JSON: Flags for json_to_string(). */
};
]]


ffi.cdef[[
void table_parse_format(struct table_style *, const char *format);
void table_parse_cell_format(struct table_style *, const char *format);

void table_print(const struct table *, const struct table_style *);
]]

local TABLE_STYLE_DEFAULT = ffi.new("struct table_style", 
    ffi.C.TF_TABLE, 
    ffi.C.CF_STRING, 
    true, 
    ffi.C.JSSF_SORT);

--[[
#define TABLE_STYLE_DEFAULT { TF_TABLE, CF_STRING, true, JSSF_SORT }

#define TABLE_OPTION_ENUMS                      \
    OPT_NO_HEADINGS,                            \
    OPT_PRETTY,                                 \
    OPT_BARE

#define TABLE_LONG_OPTIONS                                      \
        {"format", required_argument, NULL, 'f'},               \
        {"data", required_argument, NULL, 'd'},                 \
        {"no-headings", no_argument, NULL, OPT_NO_HEADINGS},    \
        {"pretty", no_argument, NULL, OPT_PRETTY},              \
        {"bare", no_argument, NULL, OPT_BARE}

#define TABLE_OPTION_HANDLERS(STYLE)                \
        case 'f':                                   \
            table_parse_format(STYLE, optarg);      \
            break;                                  \
                                                    \
        case 'd':                                   \
            table_parse_cell_format(STYLE, optarg); \
            break;                                  \
                                                    \
        case OPT_NO_HEADINGS:                       \
            (STYLE)->headings = false;              \
            break;                                  \
                                                    \
        case OPT_PRETTY:                            \
            (STYLE)->json_flags |= JSSF_PRETTY;     \
            break;                                  \
                                                    \
        case OPT_BARE:                              \
            (STYLE)->format = TF_LIST;              \
            (STYLE)->cell_format = CF_BARE;         \
            (STYLE)->headings = false;              \
            break;
--]]


local ovs_table = ffi.typeof("struct table");
local ovs_table_style = ffi.typeof("struct table_style");


local OVSTable = {}
setmetatable(OVSTable, {
    __call = function(self,...)
        return self:new(...)
    end,
})

local OVSTable_mt = {
    __index = OVSTable;
}


function OVSTable.init(self, handle, caption)

    local obj = {
        Handle = handle;
    }
    setmetatable(obj, OVSTable_mt);

    obj:setCaption(caption);
    
    return obj;
end

function OVSTable.new(self, caption)
    local structSize = ffi.sizeof("struct table");
    local tblPtr = ffi.C.malloc(structSize);
    ffi.fill(tblPtr, 0, structSize);
    Lib_table.table_init(tblPtr);

    ffi.gc(tblPtr, Lib_table.table_destroy);
--    ffi.gc(tblPtr, callmelast);

    return self:init(tblPtr, caption);
end

function OVSTable.addColumn(self, heading, ...)
    Lib_table.table_add_column(self.Handle, ffi.cast("char *", heading), ...);

    return self;
end

function OVSTable.addRow(self)
    Lib_table.table_add_row(self.Handle);

    return self;
end

function OVSTable.addTextCell(self, text)
    local cell = Lib_table.table_add_cell(self.Handle);
    if cell == nil then
        return nil;
    end

    if (text and tostring(text)) then
        cell.text = stringz.strdup(tostring(text));
    end

    return cell;
end

OVSTable["print"] = function(self, style)
    style = style or ovs_table_style(ffi.C.TF_TABLE, ffi.C.CF_STRING, true, 0);

    Lib_table.table_print(self.Handle, style);

    return self;
end

function OVSTable.setCaption(self, caption)
    if type(caption) ~= "string" then
        return ;
    end

    local adup = stringz.strdup(caption);
--print("OVSTable.setCaption(), handle, adup: ", self, self.Handle, adup);

    Lib_table.table_set_caption(self.Handle, adup);

--print("OVSTable.setCaption(), 2.0");
    return self;
end



local Lib_table = ffi.load("openvswitch")

local exports = {
    -- The shared library
    Lib_table = Lib_table;

    --ovs_table = ovs_table;
    --ovs_table_cell = ffi.typeof("struct cell");
    ovs_table_style = ovs_table_style;

    table_init = Lib_table.table_init;
    table_destroy = Lib_table.table_destroy;
    
    table_set_caption = Lib_table.table_set_caption;
    table_set_timestamp = Lib_table.table_set_timestamp;
    
    table_add_column = Lib_table.table_add_column;
    table_add_row = Lib_table.table_add_row;
    table_add_cell = Lib_table.table_add_cell;

    table_parse_format = Lib_table.table_parse_format;
    table_parse_cell_format = Lib_table.table_parse_cell_format;
    table_print = Lib_table.table_print;

    -- Objects
    OVSTable = OVSTable;

    -- Oddities
    TABLE_STYLE_DEFAULT = TABLE_STYLE_DEFAULT;
}

return exports

