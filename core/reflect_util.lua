--local ffi = require("ffi");
--local reflect = require("reflect");


local structForm = {}
setmetatable(structForm, {
	__call = function(self, ...)
		return self:new(...);
	end,
})

function structForm.new(self, atype, depth, parent)
	depth = depth or 1;
	depth = depth - 1;

--print("WHAT: ", atype.what, depth);

	local func = structForm[atype.what];
	if not func then
		return false, "structForm.new: no function found for: "..atype.what;
	end

	local str, err = func(atype, depth, parent);
	
	return str, err;
end

function structForm.array(ref, depth, parent)
	return string.format("%s %s[%d]", structForm(ref.element_type, 1), parent.name, ref.size);
end

function structForm.field(ref, depth, parent)
	return string.format("%s", structForm(ref.type, depth, ref));
end

function structForm.float(ref, depth, parent)
	if ref.size == 4 then
		return "float";
	elseif ref.size == 8 then
		return "double";
	end

	return false, "unknown float size";
end

function structForm.func(ref, depth, parent)

	local str = structForm(ref.return_type, 1, ref);
	str = str..' '..ref.name;
	str = str..'(';
	for i=1,ref.nargs do
		if i>1 then
			str = str..', ';
		end

		str = str..structForm(ref:argument(i), 0, ref);
		--print("ARG: ", ref:argument(i));
	end
	str = str..');';

	return str;
end

function structForm.int(ref, depth, parent)
	local str="";
	
	if ref.const then
		str = str.."const ";
	end
	
	if ref.bool then
		return str..'bool';
	end

	if ref.unsigned then
		str = str.."u";
	end
	

	return str..string.format("int%d_t", ref.size*8);
end

function structForm.ptr(ref, depth, parent)
	local str = structForm(ref.element_type, depth);
	if not str then
		return false;
	end

	return str..' *';
end

function structForm.struct(ref, depth, parent)
	local res = {};
	table.insert(res, string.format("typedef struct %s {\n", ref.name));
	for member in ref:members() do
		local str = "  "..structForm(member)..';\n';
		if str then
			table.insert(res, str);
		end
	end
	table.insert(res, string.format("} %s;\n", ref.name));

	return table.concat(res);
end

function structForm.union(ref, depth, parent)
	local res = {};
	table.insert(res, string.format("typedef union %s {\n", ref.name));
	for member in ref:members() do
		local str = "  "..structForm(member)..';\n';
		if str then
			table.insert(res, str);
		end
	end
	table.insert(res, string.format("} %s;\n", ref.name));

	return table.concat(res);
end

function structForm.void(ref, depth, parent)
	return 'void';
end

return structForm;
