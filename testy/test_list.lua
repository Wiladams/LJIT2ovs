--test_list.lua
local libovs = require("lib.libopenvswitch")
libovs();

local function test_empty()
	print("==== test_empty ====")
	local head = ovs_list();
	list_init(head);

	print("EMPTY: ", list_is_empty(head));
end

local function test_singleton()
	print("==== test_singleton ====")
	local head = ovs_list();

	local e1 = ovs_list();
	list_push_back(head, e1)

	print("SINGLETON (true, 1): ", list_is_singleton(head), list_size(head));

	local e2 = ovs_list();
	list_push_back(head, e2);

	print("NOT SINGLETON: ", list_is_singleton(head));

end

local function test_iterate()
	local head = ovs_list();
	list_push_back(head, ovs_list());
	list_push_back(head, ovs_list());
	list_push_back(head, ovs_list());
	list_push_back(head, ovs_list());
	list_push_back(head, ovs_list());

	print("HEAD: ", head);
	for e in list_entries(head) do
		print(e);
	end
end

local function test_append()
	print("==== test_append ====")
	local head = ovs_list();

	local e1 = ovs_list();

	list_push_back(head, e1);


	local e2 = ovs_list();

	list_push_back(head, e2);

	print("COUNT (2): ", list_size(head))
end

test_append();
--test_empty();
test_singleton();
--test_iterate();