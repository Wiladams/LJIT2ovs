local ffi = require("ffi")

local libovs = require("lib.libopenvswitch");
libovs();   -- make things global

local stringz = require("stringz")


local function test_table_struct()
	print("==== test_table_struct() ====");

	local t1 = ffi.C.malloc(ffi.sizeof("struct table"))
	ffi.fill(t1, 0, ffi.sizeof("struct table"));

	table_init(t1);
	table_set_caption(t1, stringz.strdup("Struct Table Heading"));

	table_add_column(t1, stringz.strdup("Column 1"));
	table_add_column(t1, stringz.strdup("Column Heading 2"));
	table_add_column(t1, stringz.strdup("Column Heading 3"));

	table_add_row(t1);

	local cell = table_add_cell(t1);
	cell.text = stringz.strdup("cell 1");

	cell = table_add_cell(t1);
	cell.text = stringz.strdup("cell 2");

	cell = table_add_cell(t1);
	cell.text = stringz.strdup("cell 3");


	local style = ovs_table_style();
	style.headings = true;
	table_print(t1, style);

	table_destroy(t1);
end

local function test_table_class()
	print("==== test_table_class() ====")
	local t1 = OVSTable("Class Table Heading");
	
	t1:addColumn("Column 1");
	t1:addColumn("Column Heading 2");
	t1:addColumn("Column Heading 3");

	t1:addRow();

	t1:addTextCell("cell1");
	t1:addTextCell("cell2");
	t1:addTextCell("cell 3");

	t1:print();
end

local function main()
	test_table_struct();
	test_table_class();
	
	exit();
end

main()

