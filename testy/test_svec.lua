--test_svec.lua
local lib_svec = require("lib.svec")
local svec = lib_svec.svec;


local function test_print()
	print("==== test_print() ====")
	local s1 = svec();

	s1:add("Hello");
	s1:add("World!");
	s1:add("Mumbo");
	s1:add("Jumbo");

	s1:print("SVEC Title");
end

local function test_sort()
	print("==== test_sort ====")
	local s1 = svec();
	s1:add("5")
	s1:add("4")
	s1:add("3")
	s1:add("2")
	s1:add("1")
	
	print("PRESORT: ", s1:isSorted());
	s1:sort();
	s1:print("SORTED")
	print("POSTSORT: ", s1:isSorted());
end

local function test_equality()
	print("==== test_equality ====")
	local s1 = svec();
	local s2 = svec();

	print("EMPTY EQUALS: ", s1 == s2);

	s1:add("a"); s1:add("b"); s1:add("c");
	s2:add("a"); s2:add("b"); s2:add("c");
	print("THREE EQUAL ELEMENTS: ", s1 == s2)

	local s3 = svec();
	s3:add("nothing")
	print("UNEQUAL: ", s1 == s3);
end

local function test_parse()
	print("==== test_parse ====")
	local s1 = svec();
	s1:splitWords("hello to the world!")
	s1:print("PARSED")
end

local function test_concat()
	local s1 = svec();

	s1:add("the")
	s1:add("quick")
	s1:add("brown")
	s1:add("fox")
	s1:add("jumped")
	s1:add("over")
	s1:add("the")
	s1:add("lazy")
	s1:add("dogs")
	s1:add("back")

	local str = s1:concat(" ")
	print("CONCATENATED: ", str);

end

local function test_delete()
	local s1 = svec();

	s1:add("the")
	s1:add("quick")
	s1:add("brown")
	s1:add("fox")
	s1:add("jumped")
	s1:add("over")
	s1:add("the")
	s1:add("lazy")
	s1:add("dogs")
	s1:add("back")

	local success, err = s1:delete("over");

	if not success then 
		print(err)
		s1:sort();
	end

	local success, err = s1:delete("over");

	s1:print("DELETED");
end

local function test_unique()
	local s1 = svec();
	s1:add("not unique")
	s1:add("not unique")
	s1:add("not unique")
	s1:add("not unique")
	print("PRE  UNIQUE: ", s1:isUnique());
	
	s1:sort();
	s1:delete("not unique")
	print("POST UNIQUE: ", s1:isUnique());
	s1:print();

	s1:clear();
	s1:print("CLEAR")
	s1:add("a")
	s1:add("b")
	s1:add("c")
	s1:sort();
	s1:print("UNIQUE")
	print("REAL UNIQUE: ", s1:isUnique());

end

local function test_append()
	local s1 = svec("a b c");
	local s2 = svec("d e f");

	s1:print("S1");
	s2:print("S2");

	s1:append(s2);

	s1:print("APPENDED")
end

--test_print();
--test_sort();
--test_equality();
--test_parse();
--test_concat();
--test_delete();
--test_unique();
test_append();
