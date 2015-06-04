# LJIT2ovs
LuaJIT binding for Open vSwitch

The general idea is to provide the capability to interact as deeply as possible
with Open vSwitch utilizing nothing more than the lua language.  

Initially, there
are largely straight forward ffi.cdef[[]] bindings for relevant parts of libopenvswitch.so, and libovsdb.so.  The amount of ffi binding will only grow to the size necessary to use functions that are only implemented in 'C'.  Over time, some of these bindings will turn into pur lua code, where it makes better sense.

Running things
==============

Prerequisites
	You must have luajit (preferably 2.1) already installed on the machine.
	the testit.lua script is a convenient wrapper to execute your test code.

Running a simple test
	```$ ./testit.lua testy/test_json.lua
	```

