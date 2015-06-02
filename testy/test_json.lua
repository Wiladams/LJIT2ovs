--test_json.lua
local ffi = require("ffi")
local libovs = require("lib.libopenvswitch");
libovs();	-- make things global

local jsonsample1 = [[
{
    "glossary": {
        "title": "example glossary",
		"GlossDiv": {
            "title": "S",
			"GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
					"Acronym": "SGML",
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", "XML"]
                    },
					"GlossSee": "markup"
                }
            }
        }
    }
}
]]


local function printJsonType(atype)
	atype = atype or JSON_NULL;

	local tstr = json_type_to_string(atype);

	print("==== JSON TYPE: ", tonumber(atype))
	if (tstr ~= nil) then
		print(ffi.string(tstr));
	else
		print("UNKNOWN TYPE")
	end
end

local function test_json_type()
	printJsonType(JSON_NULL)
	printJsonType(JSON_FALSE)
	printJsonType(JSON_TRUE)
	printJsonType(JSON_OBJECT)
	printJsonType(JSON_ARRAY)
	printJsonType(JSON_INTEGER)
	printJsonType(JSON_REAL)
	printJsonType(JSON_STRING)
	printJsonType(JSON_N_TYPES)
end

local function test_jsonfromstring()

	local j = json_from_string(jsonsample1);
	print(j);
	print("==== JSON RECODE ====")
	local str = json_to_string(j, JSSF_PRETTY);
	if str ~= nil then
		print(ffi.string(str))
	else
		print("JSON SERIALIZATION FAILED...")
	end
end



--test_json_type();
test_jsonfromstring();

halt();
