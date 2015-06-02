--kernel.lua
local ffi = require("ffi")

local linux = require("core.linux")


--[[
	FUNCTOR
--]]

local function Functor(func, target)
	return function(...)
		if target then
			return func(target,...)
		end

		return func(...)
	end
end


--[[
	Queue
--]]
local Queue = {}
setmetatable(Queue, {
	__call = function(self, ...)
		return self:new(...);
	end,
});

local Queue_mt = {
	__index = Queue;
}

function Queue.init(self, first, last, name)
	first = first or 1;
	last = last or 0;

	local obj = {
		first=first, 
		last=last, 
		name=name};

	setmetatable(obj, Queue_mt);

	return obj
end

function Queue.new(self, first, last, name)
	first = first or 1
	last = last or 0

	return self:init(first, last, name);
end



function Queue.enqueue(self, value)
	--self.MyList:PushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value

	return value
end

function Queue.pushFront(self,value)
	-- PushLeft
	local first = self.first - 1;
	self.first = first;
	self[first] = value;
end

function Queue.dequeue(self, value)
	-- return self.MyList:PopLeft()
	local first = self.first

	if first > self.last then
		return nil, "list is empty"
	end
	
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1

	return value	
end

function Queue.length(self)
	return self.last - self.first+1
end

-- Returns an iterator over all the current 
-- values in the queue
function Queue.Entries(self, func, param)
	local starting = self.first-1;
	local len = self:length();

	local closure = function()
		starting = starting + 1;
		return self[starting];
	end

	return closure;
end





--[[
   table.bininsert( table, value [, comp] )
   
   Inserts a given value through BinaryInsert into the table sorted by [, comp].
   
   If 'comp' is given, then it must be a function that receives
   two table elements, and returns true when the first is less
   than the second, e.g. comp = function(a, b) return a > b end,
   will give a sorted table, with the biggest value on position 1.
   [, comp] behaves as in table.sort(table, value [, comp])
   returns the index where 'value' was inserted
]]--

local floor = math.floor;
local insert = table.insert;

local fcomp_default = function( a,b ) 
   return a < b 
end

local function getIndex(t, value, fcomp)
   local fcomp = fcomp or fcomp_default

   local iStart = 1;
   local iEnd = #t;
   local iMid = 1;
   local iState = 0;

   while iStart <= iEnd do
      -- calculate middle
      iMid = floor( (iStart+iEnd)/2 );
      
      -- compare
      if fcomp( value,t[iMid] ) then
            iEnd = iMid - 1;
            iState = 0;
      else
            iStart = iMid + 1;
            iState = 1;
      end
   end

   return (iMid+iState);
end

local function binsert(t, value, fcomp)
   local idx = getIndex(t, value, fcomp);
   insert( t, idx, value);
   return idx;
end

--[[

	CLOCK

--]]

local Clock = {}
setmetatable(Clock, {
	__call = function(self, ...)
		return self:create(...);
	end;

})

local Clock_mt = {
	__index = Clock;
}

function Clock.init(self, ...)

	local obj = {
		tspec = linux.timespec();	-- used so we don't create a new one every time
		starttime = 0; 
	}
	setmetatable(obj, Clock_mt);
	obj:reset();

	return obj;
end


function Clock.create(self, ...)
	return self:init();
end

function Clock.getCurrentTime(self)
	local res = self.tspec:gettime();
	local currentTime = self.tspec:seconds();
	return currentTime;
end

function Clock.secondsElapsed(self)
	local res = self.tspec:gettime()
	local currentTime = self.tspec:seconds();
	return currentTime - self.starttime;
end

function Clock.reset(self)
	local res = self.tspec:gettime()
	self.starttime = self.tspec:seconds();
end


--[[
	ALARM
--]]
local Alarm = {
	ContinueRunning = true;
	SignalsWaitingForTime = {};
	Clock = Clock();
}

setmetatable(Alarm, {
	__call = function(self, params)
		params = params or {}
		self.Kernel = params.Kernel;
		if params.exportglobal then
			self:globalize();
		end

		self:run();

		return self;
	end;
})

local function compareDueTime(task1, task2)
	if task1.DueTime < task2.DueTime then
		return true
	end
	
	return false;
end


function Alarm.waitUntilTime(self, atime)
	-- create a signal
	local taskID = self.Kernel:getCurrentTaskID();
	local signalName = "sleep-"..tostring(taskID);
	local fiber = {DueTime = atime, SignalName = signalName};

	-- put time/signal into list so watchdog will pick it up
	binsert(self.SignalsWaitingForTime, fiber, compareDueTime)

	-- put the current task to wait on signal
	self.Kernel:waitForSignal(signalName);
end

function Alarm.sleep(self, millis)
	-- figure out the time in the future
	local currentTime = self.Clock:getCurrentTime();
	local futureTime = currentTime + (millis / 1000);
	return self:waitUntilTime(futureTime);
end

function Alarm.delay(self, func, millis)
	millis = millis or 1000

	local function closure()
		self:sleep(millis)
		func();
	end

	return self.Kernel:spawn(closure)
end

function Alarm.periodic(self, func, millis)
	millis = millis or 1000

	local function closure()
		while true do
			self:sleep(millis)
			func();
		end
	end

	return self.Kernel:spawn(closure)
end

-- The routine task which checks the list of waiting tasks to see
-- if any of them need to be signaled to wakeup
function Alarm.watchdog(self)
	while (self.ContinueRunning) do
		local currentTime = self.Clock:getCurrentTime();
		-- traverse through the fibers that are waiting
		-- on time
		local nAwaiting = #self.SignalsWaitingForTime;
		--print("Timer Events Waiting: ", nAwaiting)
		for i=1,nAwaiting do

			local fiber = self.SignalsWaitingForTime[1];
			if fiber.DueTime <= currentTime then
				self.Kernel:signalOne(fiber.SignalName);

				table.remove(self.SignalsWaitingForTime, 1);

			else
				break;
			end
		end		
		self.Kernel:yield();
	end
end


function Alarm.run(self)
	self.Kernel:spawn(Functor(Alarm.watchdog, Alarm))
end


function Alarm.globalize(self)
	_G["delay"] = Functor(Alarm.delay, Alarm);
	_G["periodic"] = Functor(Alarm.periodic, Alarm);
	_G["sleep"] = Functor(Alarm.sleep, Alarm);

	return self;
end



--[[
	ASYNCIO
--]]
local AsyncIO = {
	EventQuanta = 1;
	ContinueRunning = true;
	EPollSet = linux.epollset();
	MaxEvents = 100;		-- number of events we'll ask per quanta

	READ = 1;
	WRITE = 2;
	CONNECT = 3;
}

setmetatable(AsyncIO, {
	__call = function(self, params)
		params = params or {}
		self.Kernel = params.Kernel
		self.Events = ffi.new("struct epoll_event[?]", self.MaxEvents);

		if params.exportglobal then
			self:globalize();
		end
		
		if self.Kernel and params.AutoStart ~= false then
			self.Kernel:spawn(Functor(AsyncIO.watchdog, AsyncIO))
		end

		return self;
	end,
})


local function sigNameFromEvent(event, title)
	title = title or "";
	local fdesc = ffi.cast("filedesc *", event.data.ptr);
	--print("sigNameFromEvent, fdesc: ", fdesc)
	local fd = fdesc.fd;
	--print("  fd: ", fd);

	local str = "waitforio-"..fd;
	
	return str;
end


function AsyncIO.setEventQuanta(self, quanta)
	self.EventQuanta = quanta;
end

function AsyncIO.getNextOperationId(self)
	self.OperationId = self.OperationId + 1;
	return self.OperationId;
end

function AsyncIO.watchForIOEvents(self, fdesc, event)
	return self.EPollSet:add(fdesc.fd, event);
end

function AsyncIO.waitForIOEvent(self, fdesc, event, title)
	local success, err = self.EPollSet:modify(fdesc.fd, event);
	local sigName = sigNameFromEvent(event, title);

--print("\nAsyncIO.waitForIOEvent(), waiting for: ", sigName)

	success, err = self.Kernel:waitForSignal(sigName);

	return success, err;
end


-- The watchdog() routine is the regular task that will
-- always be calling epoll_wait when it gets a chance
-- and signaling the appropriate tasks when they have events
function AsyncIO.watchdog(self)
	while self.ContinueRunning do
		local available, err = self.EPollSet:wait(self.Events, self.MaxEvents, self.EventQuanta);


		if available then
			if available > 0 then
			    for idx=0,available-1 do
			    	local ptr = ffi.cast("struct epoll_event *", ffi.cast("char *", self.Events)+ffi.sizeof("struct epoll_event")*idx);
			    	--print("watchdog, ptr.data.ptr: ", ptr, ptr.data.ptr);
				    local sigName = sigNameFromEvent(ptr);
				    self.Kernel:signalAll(sigName, self.Events[idx].events);
			    end
			else
				--print("NO EVENTS AVAILABLE")
			end
		else 
			print("AsyncIO.watchdog, error from EPollSet:wait(): ", available, err)
		end

		self.Kernel:yield();
	end
end


function AsyncIO.globalize(self)
	_G["waitForIOEvent"] = Functor(AsyncIO.waitForIOEvent, AsyncIO);
	_G["watchForIOEvents"] = Functor(AsyncIO.watchForIOEvents, AsyncIO);

	return self;
end

--[[
	PREDICATE
--]]
local Predicate = {}
setmetatable(Predicate, {
	__call = function(self, params)
		params = params or {}
		self.Kernel = params.Kernel;
		if params.exportglobal then
			self:globalize();
		end
		return self;
	end;
})

function Predicate.signalOnPredicate(self, pred, signalName)
	local function closure()
		local res = nil;
		repeat
			res = pred();
			if res == true then 
				return self.Kernel:signalAll(signalName) 
			end;

			self.Kernel:yield();
		until res == nil
	end

	return self.Kernel:spawn(closure)
end

function Predicate.waitForPredicate(self, pred)
	local signalName = "predicate-"..tostring(self.Kernel:getCurrentTaskID());
	self:signalOnPredicate(pred, signalName);
	return self.Kernel:waitForSignal(signalName);
end

function Predicate.when(self, pred, func)
	local function closure(lpred, lfunc)
		self:waitForPredicate(lpred)
		lfunc()
	end

	return self.Kernel:spawn(closure, pred, func)
end

function Predicate.whenever(self, pred, func)

	local function closure(lpred, lfunc)
		local signalName = "whenever-"..tostring(self.Kernel:getCurrentTaskID());
		local res = true;
		repeat
			self:signalOnPredicate(lpred, signalName);
			res = self.Kernel:waitForSignal(signalName);
			lfunc()
		until false
	end

	return self.Kernel:spawn(closure, pred, func)
end

function Predicate.globalize(self)
	_G["signalOnPredicate"] = Functor(Predicate.signalOnPredicate, Predicate);
	_G["waitForPredicate"] = Functor(Predicate.waitForPredicate, Predicate);
	_G["when"] = Functor(Predicate.when, Predicate);
	_G["whenever"] = Functor(Predicate.whenever, Predicate);

end


--[[
	SCHEDULER
--]]

local Scheduler = {}
setmetatable(Scheduler, {
	__call = function(self, ...)
		return self:new(...)
	end,
})
local Scheduler_mt = {
	__index = Scheduler,
}

function Scheduler.init(self, ...)
	--print("==== Scheduler.init ====")
	local obj = {
		TasksReadyToRun = Queue();
	}
	setmetatable(obj, Scheduler_mt)
	
	return obj;
end

function Scheduler.new(self, ...)
	return self:init(...)
end


function Scheduler.tasksPending(self)
	return self.TasksReadyToRun:length();
end


--[[
	Task Handling
--]]
function Scheduler.scheduleTask(self, task, params)
	--print("Scheduler.scheduleTask: ", task, params)
	params = params or {}
	
	if not task then
		return false, "no task specified"
	end

	task:setParams(params);
	self.TasksReadyToRun:enqueue(task);	
	task.state = "readytorun"

	return task;
end



function Scheduler.removeFiber(self, fiber)
	--print("REMOVING DEAD FIBER: ", fiber);
	return true;
end

function Scheduler.inMainFiber(self)
	return coroutine.running() == nil; 
end

function Scheduler.getCurrentTask(self)
	return self.CurrentFiber;
end

function Scheduler.suspendCurrentFiber(self, ...)
	self.CurrentFiber.state = "suspended"
end

function Scheduler.step(self)
	-- Now check the regular fibers
	local task = self.TasksReadyToRun:dequeue()

	-- If no fiber in ready queue, then just return
	if task == nil then
		--print("Scheduler.step: NO TASK")
		return true
	end

	if task:getStatus() == "dead" then
		self:removeFiber(task)

		return true;
	end

	if task.state == "suspended" then
		--print("suspended task wants to run")
		return true;
	end

	-- If we have gotten this far, then the task truly is ready to 
	-- run, and it should be set as the currentFiber, and its coroutine
	-- is resumed.
	self.CurrentFiber = task;
	local results = {task:resume()};

	local success = results[1];
	table.remove(results,1);

--print("PCALL, RESUME: ", pcallsuccess, success)

	-- no task is currently executing
	self.CurrentFiber = nil;


	if not success then
		print("RESUME ERROR")
		print(unpack(results));
	end

	-- Again, check to see if the task is dead after
	-- the most recent resume.  If it's dead, then don't
	-- bother putting it back into the readytorun queue
	-- just remove the task from the list of tasks
	if task:getStatus() == "dead" then
		self:removeFiber(task)

		return true;
	end

	-- The only way the task will get back onto the readylist
	-- is if it's state is 'readytorun', otherwise, it will
	-- stay out of the readytorun list.
	if task.state == "readytorun" then
		self:scheduleTask(task, results);
	end
end

--[[
	Fiber, contains stuff related to a running fiber
--]]
local Task = {}

setmetatable(Task, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local Task_mt = {
	__index = Task,
}

function Task.init(self, aroutine, ...)

	local obj = {
		routine = coroutine.create(aroutine), 
	}
	setmetatable(obj, Task_mt);
	
	obj:setParams({...});

	return obj
end

function Task.create(self, aroutine, ...)
	-- The 'aroutine' should be something that is callable
	-- either a function, or a table with a meta '__call'
	-- implementation.  
	-- Checking with type == 'function'
	-- is not good enough as it will miss the meta __call cases

	return self:init(aroutine, ...)
end


function Task.getStatus(self)
	return coroutine.status(self.routine);
end

-- A function that can be used as a predicate
function Task.isFinished(self)
	return task:getStatus() == "dead"
end


function Task.setParams(self, params)
	self.params = params

	return self;
end

function Task.resume(self)
--print("Task, RESUMING: ", unpack(self.params));
	return coroutine.resume(self.routine, unpack(self.params));
end

function Task.yield(self, ...)
	return coroutine.yield(...)
end

--[[
	Kernel

	The glue of the system.  The kernel pulls all the constituent
	parts together.  I specifies the scheduler, creates tasks, and 
	handles signals.

--]]
Kernel = {
	ContinueRunning = true;
	TaskID = 0;
	Scheduler = Scheduler();
	TasksSuspendedForSignal = {};

	Functor = Functor;
}
--[[
setmetatable(Kernel, {
    __call = function(self, params)
    	params = params or {}
    	params.Scheduler = params.Scheduler or self.Scheduler
    	
    	if params.exportglobal then
    		self:globalize();
    	end

    	self.Scheduler = params.Scheduler;

    	return self;
    end,
})
--]]

function Kernel.getNewTaskID(self)
	self.TaskID = self.TaskID + 1;
	return self.TaskID;
end

function Kernel.getCurrentTaskID(self)
	return self:getCurrentTask().TaskID;
end

function Kernel.getCurrentTask(self)
	return self.Scheduler:getCurrentTask();
end

function Kernel.spawn(self, func, ...)
	local task = Task(func, ...)
	task.TaskID = self:getNewTaskID();
	self.Scheduler:scheduleTask(task, {...});
	
	return task;
end

function Kernel.suspend(self, ...)
	self.Scheduler:suspendCurrentFiber();
	return self:yield(...)
end

function Kernel.yield(self, ...)
	return coroutine.yield(...);
end


function Kernel.signalOne(self, eventName, ...)
	if not self.TasksSuspendedForSignal[eventName] then
		return false, "event not registered", eventName
	end

	local nTasks = #self.TasksSuspendedForSignal[eventName]
	if nTasks < 1 then
		return false, "no tasks waiting for event"
	end

	local suspended = self.TasksSuspendedForSignal[eventName][1];

	self.Scheduler:scheduleTask(suspended,{...});
	table.remove(self.TasksSuspendedForSignal[eventName], 1);

	return true;
end

function Kernel.signalAll(self, eventName, ...)
	if not self.TasksSuspendedForSignal[eventName] then
		return false, "event not registered"
	end

	local nTasks = #self.TasksSuspendedForSignal[eventName]
	if nTasks < 1 then
		return false, "no tasks waiting for event"
	end

	for i=1,nTasks do
		self.Scheduler:scheduleTask(self.TasksSuspendedForSignal[eventName][1],{...});
		table.remove(self.TasksSuspendedForSignal[eventName], 1);
	end

	return true;
end

function Kernel.waitForSignal(self, eventName)
	local currentFiber = self.Scheduler:getCurrentTask();

	if currentFiber == nil then
		return false, "not currently in a running task"
	end

	if not self.TasksSuspendedForSignal[eventName] then
		self.TasksSuspendedForSignal[eventName] = {}
	end

	table.insert(self.TasksSuspendedForSignal[eventName], currentFiber);

	return self:suspend()
end

function Kernel.onSignal(self, func, eventName)
	local function closure()
		self:waitForSignal(eventName)
		func();
	end

	return self:spawn(closure)
end



function Kernel.run(self, func, ...)

	if func ~= nil then
		self:spawn(func, ...)
	end

	while (self.ContinueRunning) do
		self.Scheduler:step();		
	end
end

function Kernel.halt(self)
	self.ContinueRunning = false;
end

function Kernel.globalize(self)

	exit = Functor(Kernel.halt, Kernel);
    getCurrentTaskID = Functor(Kernel.getCurrentTaskID, Kernel);

	halt = Functor(Kernel.halt, Kernel);
    onSignal = Functor(Kernel.onSignal, Kernel);

    run = Functor(Kernel.run, Kernel);

    signalAll = Functor(Kernel.signalAll, Kernel);
    signalOne = Functor(Kernel.signalOne, Kernel);

    spawn = Functor(Kernel.spawn, Kernel);
    suspend = Functor(Kernel.suspend, Kernel);

    waitForSignal = Functor(Kernel.waitForSignal, Kernel);

    yield = Functor(Kernel.yield, Kernel);
end

Kernel.Clock = Clock;
Kernel.Functor = Functor;



Predicate({Kernel = Kernel, exportglobal=true})
Alarm {Kernel=Kernel, exportglobal=true}
AsyncIO{Kernel=Kernel, exportglobal = true}

--Kernel:globalize()


return Kernel;
