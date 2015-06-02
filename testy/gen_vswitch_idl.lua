--test_json.lua
-- ovsdb-idlc python script does this

local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;

local concat, insert = table.concat, table.insert


local libovs = require("lib.libopenvswitch");
libovs();	-- make things global

local dkjson = require("core.dkjson")

local res = {}


local function getprettyjson(filename)

	local j = json_from_file(filename);
--	print(j);
--	print("==== JSON RECODE ====")
	local str = json_to_string(j, bor(JSSF_PRETTY,JSSF_SORT));
	if str ~= nil then
		return ffi.string(str)
	else
		print("JSON SERIALIZATION FAILED...")
	end
end

local basetypes = {
	["integer"] = function()return "int64_t" end;
	["string"] = function() return "char *" end;
	["boolean"] = function() return "bool" end;
}

local function stringfrombasetype(basetype)
	if basetypes[basetype] then
		return basetypes[basetype]();
	end

	return "UNKNOWN BASE TYPE"..basetype;
end

--[[
          "type": {
            "max": 1,
            "min": 0,
            "key": {
              "type": "boolean"}}},

          bool *enable_async_messages;
	      size_t n_enable_async_messages;
--]]
local function gencomplexcolumn(columnname, complextype)
	print("gencomplexcolumn: ", columnname)
	local btype = ""
	if type(complextype.type.key) == "string" then
		btype = stringfrombasetype(complextype.type.key)
	else
		--btype = stringfrombasetype(complextype.type.key.type)
	end

	local modifier = "";

	if complextype.min == 0 and complextype.max == 1 then
		modifier = " *";
	end

	insert(res, string.format("    %s%s %s;", basetype, modifier, columnname))
	insert(res, string.format("    size_t n_%s;\n", columnname))
end


local function gencolumn(columnname, columnmeta)
	if type(columnmeta.type) ~= "table" then
		insert(res, string.format("    %s %s;\n", stringfrombasetype(columnmeta.type), columnname))
		return ;
	end

	gencomplexcolumn(columnname, columnmeta)

end

local function genColumns(meta, tbl, tablename)
	for columnname, columnmeta in pairs(tbl.columns) do
		insert(res, string.format("    /* %s column */", columnname))
		gencolumn(columnname, columnmeta)
	end
end

local function genTable(meta, tableinfo, tablename)
	--print("==== getTable: ", name)
	insert(res,string.format([[
/* %s table */
struct %s%s {
    struct ovsdb_idl_row header_;
]], tablename, meta.idlPrefix, tablename:lower()));

	genColumns(meta, tableinfo, tablename)

	insert(res,[[};]])
	insert(res,"\n");
end

local function genProlog()
	insert(res, [[
#include "ovsdb-data.h"
#include "ovsdb-idl-provider.h"
#include "smap.h"
#include "uuid.h"
]]);
end

local function genEpilog()
	insert(res,"\n");
end

local function main()
	local filename = arg[2]
	if not filename then
		return 
	end

	local prettyjson = getprettyjson(filename)
	local jsontable = dkjson.decode(prettyjson);

	genProlog();

	for tablename, value in pairs(jsontable.tables) do
		genTable(jsontable, value, tablename)
	end

	genEpilog();

	local output = concat(res, "\n");

	print(output)
end

main()
