local ffi = require("ffi")

local ovs_table = require("lib.table")
local Lib_table = ovs_table.Lib_table;
local stringz = require("stringz")


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

return OVSTable