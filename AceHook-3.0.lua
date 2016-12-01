local Ace3test = Ace3test
local tgetn = table.getn

local argc
local hooked
local called

function AceHookTest(...)
	assert(tgetn(arg) == argc)
	Ace3test:Print("AceHookTest",unpack(arg))
	called = true
end

function Ace3test:TestAceHook_Hook2(...)
	if hooked then
		assert(tgetn(arg) == argc)
		self:Print("TestAceHook_Hook2",unpack(arg))
	else
		assert(false)
	end
end

function Ace3test:TestAceHook()
	self:TestBegin("AceHook")

	local testobj = {}

	-- Test 1

	function testobj:test1(...)
		Ace3test:Print("test1",unpack(arg))
		assert(tgetn(arg) == argc)
		called = true
	end

	local function hook1(...)
		if hooked then
			assert(tgetn(arg) == argc+1)
			assert(arg[1] == testobj)
			Ace3test:Print("hook1",unpack(arg))
		else
			assert(false)
		end
	end

	self:Hook(testobj, "test1", hook1)
	assert(self:IsHooked(testobj, "test1"))
	hooked = true
	argc = 3
	called = false
	testobj:test1(11,22,33)
	assert(called)

	self:Unhook(testobj, "test1")
	assert(not self:IsHooked(testobj, "test1"))
	hooked = false
	argc = 2
	called = false
	testobj:test1(44,55)
	assert(called)

	-- Test 2

	self:Hook("AceHookTest", "TestAceHook_Hook2")
	assert(self:IsHooked("AceHookTest"))
	hooked = true
	argc = 4
	called = false
	AceHookTest(12,34,56,78)
	assert(called)

	self:Unhook("AceHookTest")
	assert(not self:IsHooked("AceHookTest"))
	hooked = false
	argc = 3
	called = false
	AceHookTest(nil,nil,nil)
	assert(called)

	-- Test 3

	function testobj:test3(...)
		assert(tgetn(arg) == argc)
		called = true
		if hooked then
			assert(false)
		end
	end

	local function hook3(...)
		if hooked then
			assert(tgetn(arg) == argc+1)
			assert(arg[1] == testobj)
			Ace3test:Print("hook3",unpack(arg))
		else
			assert(false)
		end
	end

	self:RawHook(testobj, "test3", hook3)
	assert(self:IsHooked(testobj, "test3"))
	hooked = true
	argc = 1
	called = false
	testobj:test3("yes")
	assert(called == false)

	self:Unhook(testobj, "test3")
	assert(not self:IsHooked(testobj, "test3"))
	hooked = false
	argc = 2
	called = false
	testobj:test3("no", "way")
	assert(called == true)

	-- Test 4

	function testobj:test4(...)
		assert(tgetn(arg) == argc)
		Ace3test:Print("test4",unpack(arg))
		called = true
	end

	local function hook4(...)
		if hooked then
			assert(tgetn(arg) == argc+1)
			assert(arg[1] == testobj)
			Ace3test:Print("hook4",unpack(arg))
		else
			assert(false)
		end
	end

	self:SecureHook(testobj, "test4", hook4)
	assert(self:IsHooked(testobj, "test4"))
	hooked = true
	argc = 2
	called = false
	testobj:test4("a",nil)
	assert(called)

	self:Unhook(testobj, "test4")
	assert(not self:IsHooked(testobj, "test4"))
	hooked = false
	argc = 1
	called = false
	testobj:test4(nil)
	assert(called)

	-- Test 5 (Test by hand)

	--local function hook5(...)
	--	Ace3test:Print("hook5", event, arg1, arg2, arg3, arg4, arg5)
	--end
	--
	--self:HookScript(DEFAULT_CHAT_FRAME, "OnEvent", hook5)
	--self:RawHookScript(DEFAULT_CHAT_FRAME, "OnEvent", hook5)
	--self:SecureHookScript(DEFAULT_CHAT_FRAME, "OnEvent", hook5)

	self:TestEnd("AceHook")
end