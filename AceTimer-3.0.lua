local MAJOR = "AceTimer-3.0"
local AceTimer = assert(LibStub(MAJOR))

function Ace3test:TestAceTimer2()
	local obj = {}

	local ok,msg = pcall(AceTimer.ScheduleTimer, AceTimerobj, "method", 4, 1, "arg")	-- This should fail - method not defined
	self:Print(msg)
	assert(not ok)

	ok,msg = pcall(AceTimer.ScheduleTimer, obj, "method", 4, 1, "arg")	-- This should fail - method not defined
	self:Print(msg)
	assert(not ok)

	ok,msg = pcall(AceTimer.ScheduleTimer, obj, "method", 4, "arg?", "arg")	-- This should fail - argc is not a number
	self:Print(msg)
	assert(not ok)

	ok,msg = pcall(AceTimer.ScheduleTimer, obj, "method", 4, 1.5, "arg")	-- This should fail - argc is a float
	self:Print(msg)
	assert(not ok)

	obj.method = "hi, i'm NOT a function, i'm something else"

	ok,msg = pcall(AceTimer.ScheduleTimer, obj, "method", 4, 1, "arg")	-- This should fail - obj["method"] is not a function
	self:Print(msg)
	assert(not ok)

	ok,msg = pcall(AceTimer.ScheduleTimer, obj, nil, 4, 1, "arg")	-- This should fail (method is nil)
	self:Print(msg)
	assert(not ok)

	ok,msg = pcall(AceTimer.ScheduleTimer, obj, {}, 4, 1, "arg")	-- This should fail (method is table)
	self:Print(msg)
	assert(not ok)

	-- (Note: ScheduleRepeatingTimer here just to check naming)
	ok,msg = pcall(AceTimer.ScheduleRepeatingTimer, obj, 123, 4, 1, "arg")	-- This should fail too (method is integer)
	self:Print(msg)
	assert(not ok)

	ok,msg = pcall(AceTimer.CancelAllTimers, "obj")
	self:Print(msg)
	assert(not ok)

	ok,msg = pcall(AceTimer.CancelAllTimers, AceTimer)
	self:Print(msg)
	assert(not ok)

	self:TestEnd("AceTimer")
end

function Ace3test:ScheduleTimerInCallback(delay, times)
	self:Print(GetTime(),times)
	if times > 0 then
		self:ScheduleTimer("ScheduleTimerInCallback",delay,2,delay,times-1)
	else

		self:TestAceTimer2()
	end
end

function Ace3test:TimerFunc()
	self:Print(GetTime(),gcinfo())
end

function Ace3test:TestAceTimer()

	self:TestBegin("AceTimer")

	local obj={}
	AceTimer:Embed(obj)

	assert(type(obj.ScheduleTimer)=="function")
	assert(type(obj.ScheduleRepeatingTimer)=="function")
	assert(type(obj.CancelTimer)=="function")
	assert(type(obj.CancelAllTimers)=="function")

	local t1s = 0
	local t2s = 0
	local t3s = 0
	local _G = {}
	_G.t4s=0
	_G.t5s=0
	local stopped

	function obj:Timer1(arg)
		assert(not stopped)
		assert(self==obj)
		assert(arg=="t1")
		t1s = t1s + 1
		Ace3test:Print("timer1",t1s)
	end

	function Timer2(arg)
		assert(not stopped)
		assert(arg=="t2")
		t2s = t2s + 1
		assert(t2s <= t1s)
		Ace3test:Print("timer2",t2s)
	end

	function obj:Timer3()
		assert(false)	-- This should never run!
	end

	local function Timer4_5(arg)
		assert(arg=="t4s" or arg=="t5s")
		_G[arg] = _G[arg] + 1
		assert(_G.t4s <= t3s)
		assert(_G.t5s <= _G.t4s)
		Ace3test:Print("timer",arg,_G[arg])
	end
	function obj:Timer4(arg)
		assert(not stopped)
		assert(self==obj)
		Timer4_5(arg)
	end

	-- 3 repeating timers:
	local timer1 = obj:ScheduleRepeatingTimer("Timer1", 1, 1, "t1")
	local timer2 = obj:ScheduleRepeatingTimer(Timer2, 2, 1, "t2")
	local timer3 = obj:ScheduleRepeatingTimer("Timer3", 3, 1, "t3")

	-- 2 single shot timers:
	local timer4 = obj:ScheduleTimer("Timer4", 4, 1, "t4s")
	local timer5 = obj.ScheduleTimer("myObj", Timer4_5, 5, 1, "t5s")	-- string as self

	function obj:Timer3(arg) 	-- This should be the one to run, not the old Timer3
		assert(not stopped)
		assert(self==obj)
		assert(arg=="t3")
		t3s = t3s + 1
		assert(t3s <= t2s)
		Ace3test:Print("timer3",t3s)
	end

	local function timer6()
		assert(false)
	end

	function obj:timer7()
		assert(false)
	end
	local timer7 = obj:ScheduleRepeatingTimer("timer7", 2)

	local function stoptimers()
		stopped = true
		self:Print("Stoping",timer1)
		assert(obj:CancelTimer(timer1))
		self:Print("Stoping",timer2)
		assert(obj:CancelTimer(timer2))
		self:Print("Stoping",timer3)
		assert(obj:CancelTimer(timer3))
		self:Print("Stoping",timer4)
		assert(not obj:CancelTimer(timer4))
		self:Print("Stoping",timer5)
		assert(not obj:CancelTimer(timer5))
		self:Print("Stoping",timer7)
		assert(not obj:CancelTimer(timer7))
		obj:CancelAllTimers()
		self:ScheduleTimerInCallback(0.5,10)
	end

	obj:ScheduleTimer(stoptimers, 10)
	obj:ScheduleTimer(timer6, 11)
	-- Scheduling a timer on a member function that later becomes a nonfunction
	obj.timer7 = "notexist"
end
