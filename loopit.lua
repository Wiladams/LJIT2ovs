#!/usr/bin/env luajit

package.path = package.path..";../?.lua;../core/?.lua;"

local Kernel = require("core.kernel")
Kernel:globalize();

if (arg[1] ~= nil) then
	local f, err = loadfile(arg[1])
	
	if not f then
		print("Error loading file: ", arg[1], err)
		return false, err;
	end
	
	run(f);
end

