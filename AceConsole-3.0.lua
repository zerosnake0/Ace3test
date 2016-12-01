local AceCore = assert(LibStub("AceCore-3.0"))
local _G = AceCore._G

function Ace3test:TestAceConsole()

	self:TestBegin("AceConsole")

	local AceConsole = assert(LibStub("AceConsole-3.0"))

	-- Called from library
	self:Print("> AceConsole:Print(1,2,3,4,5,6,7,8,9,10)")
	AceConsole:Print(1,2,3,4,5,6,7,8,9,10)
	self:Print("> AceConsole:Printf(DEFAULT_CHAT_FRAME,1,2,3,4,5,6,7,8,9,10)")
	AceConsole:Print(DEFAULT_CHAT_FRAME,1,2,3,4,5,6,7,8,9,10)

	self:Print("> AceConsole:Printf(\"%s %d\",1,2")
	AceConsole:Printf("%s %d",1,2)
	self:Print("> AceConsole:Printf(DEFAULT_CHAT_FRAME,\"%s %d\",1,2")
	AceConsole:Printf(DEFAULT_CHAT_FRAME,"%s %d",1,2)

	-- Called from self
	self:Print("> Ace3test:Print(1,2,3,4,5,6,7,8,9,10)")
	self:Print(1,2,3,4,5,6,7,8,9,10)
	self:Print("> Ace3test:Print(DEFAULT_CHAT_FRAME,1,2,3,4,5,6,7,8,9,10)")
	self:Print(DEFAULT_CHAT_FRAME,1,2,3,4,5,6,7,8,9,10)

	self:Print("> Ace3test:Printf(\"%s %d\",1,2)")
	self:Printf("%s %d",1,2)
	self:Print("> Ace3test:Printf(DEFAULT_CHAT_FRAME,\"%s %d\",1,2)")
	self:Printf(DEFAULT_CHAT_FRAME,"%s %d",1,2)

	-- String format test
	self:Print("> String format test")
	AceConsole:Printf("%%s %%10q Hello => %s %q", "Hello", "Hello")
	AceConsole:Printf("%%c 65 => %c", 65)
	AceConsole:Printf("%%(d|i) 1.5,-1.5 => %d %i", 1.5, -1.5)
	AceConsole:Printf("%%f %%g pi => %f %g", math.pi, math.pi)
	AceConsole:Printf("%%e %%E pi => %e %E", math.pi, math.pi)
	AceConsole:Printf("%%u %%o %%x %%X -1 => %u %o %x %X", -1, -1, -1, -1)

	-- Special format
	AceConsole:Printf("%%05(d|i) 1 => %05d", 1.1)
	AceConsole:Printf("%%+(d|i) 1.5,-1.5 => %+d %+i", 1.5, -1.5)
	AceConsole:Printf("%%10.5f 12345.6789 => %10.5f", 12345.6789)
	AceConsole:Printf("%%10.5g 12345.6789 => %10.5g", 12345.6789)
	AceConsole:Printf("a\\nb => a\nb")

	local function donothing() end
	local cmd_name = "donothing"
	-- RegisterChatCommand
	self:Print("> RegisterChatCommand")
	AceConsole:RegisterChatCommand(cmd_name, donothing)
	local found = false
	for k,v in AceConsole:IterateChatCommands() do
		if k == "donothing" then
			assert(v == 'ACECONSOLE_DONOTHING', "The registered function is uncorrect")
			found = true
			break
		end
	end
	assert(found, "Unable to found registered command")
	assert(SlashCmdList["ACECONSOLE_DONOTHING"], "\"ACECONSOLE_DONOTHING\" not found in SlashCmdList")
	assert(_G["SLASH_ACECONSOLE_DONOTHING1"], "\"SLASH_ACECONSOLE_DONOTHING1\" not found in global")

	local found = false
	for k,v in AceConsole:IterateChatCommands() do
		if k == cmd_name then found = true break end
	end
	assert(found, "The command is not registered")

	-- UnregisterChatCommand
	self:Print("> UnregisterChatCommand")
	AceConsole:UnregisterChatCommand(cmd_name)
	for k,v in AceConsole:IterateChatCommands() do
		assert(k ~= "donothing", "The command is not unregistered")
	end
	assert(SlashCmdList["ACECONSOLE_DONOTHING"] == nil, "\"ACECONSOLE_DONOTHING\" still in SlashCmdList")
	assert(_G["SLASH_ACECONSOLE_DONOTHING1"] == nil, "\"SLASH_ACECONSOLE_DONOTHING1\" still in global")

	local found = false
	for k,v in AceConsole:IterateChatCommands() do
		assert(k ~= cmd_name, "The command is not unregistered")
	end

	-- GetArgs
	self:Print("> GetArgs")
	local a1,a2,a3,a4
	a1,a2 = AceConsole:GetArgs("")	-- empty
	assert(a1 == nil and a2 == 1e9)
	a1,a2 = AceConsole:GetArgs("  ")	-- no arg
	assert(a1 == nil and a2 == 1e9)
	a1,a2 = AceConsole:GetArgs("a1")	-- no arg
	assert(a1 == "a1" and a2 == 1e9)
	a1,a2 = AceConsole:GetArgs("a1", 0)	-- fetch 0 arg
	assert(a1 == 1 and a2 == nil)
	a1,a2 = AceConsole:GetArgs("  a1", 0)	-- fetch 0 arg, leading space
	assert(a1 == 3 and a2 == nil)
	a1,a2 = AceConsole:GetArgs("a1 a2")	-- first arg and nextpos
	assert(a1 == "a1" and a2 == 4)
	a1,a2 = AceConsole:GetArgs("a1   a2")	-- first arg and nextpos
	assert(a1 == "a1" and a2 == 6)
	a1,a2,a3 = AceConsole:GetArgs("a1 a2",2)	-- 2 args
	assert(a1 == "a1" and a2 == "a2" and a3 == 1e9)
	a1,a2,a3 = AceConsole:GetArgs("   a1     a2 ",2)	-- surplous spaces
	assert(a1 == "a1" and a2 == "a2" and a3 == 1e9)
	a1,a2,a3 = AceConsole:GetArgs("   a1      ",2)	-- missing arg2
	assert(a1 == "a1" and a2 == nil and a3 == 1e9)

	-- Test quoting
	a1,a2 = AceConsole:GetArgs([["a1"]])	-- simple quote
	assert(a1=="a1" and a2==1e9)

	a1,a2 = AceConsole:GetArgs([["a 1"]])	-- quote with space in it
	assert(a1=="a 1" and a2==1e9)

	a1,a2 = AceConsole:GetArgs([[" a 1 "]]) -- quote with space at beginning and end
	assert(a1==" a 1 " and a2==1e9)

	a1,a2 = AceConsole:GetArgs([['a 1']])		-- single quote
	assert(a1=="a 1" and a2==1e9)

	a1,a2,a3 = AceConsole:GetArgs([["a 1" "a 2"]], 2)	-- 2 args
	assert(a1=="a 1" and a2=="a 2" and a3==1e9)

	a1,a2,a3 = AceConsole:GetArgs([["a 1" 'a 2']], 2)	-- mixed quoting
	assert(a1=="a 1" and a2=="a 2" and a3==1e9)

	a1,a2,a3 = AceConsole:GetArgs([[  "a 1"  'a 2' ]], 2)	-- surplous spacing between quotes
	assert(a1=="a 1" and a2=="a 2" and a3==1e9)

	a1,a2,a3 = AceConsole:GetArgs([["foo'bar" 'foo"bar']], 2)	-- don't break on nonmatching quote
	assert(a1=="foo'bar" and a2=='foo"bar' and a3==1e9)

	a1,a2 = AceConsole:GetArgs([[  "unfinished quote]], 1)  -- missing " at end
	assert(a1=="unfinished quote" and a2==1e9)

	-- Hyperlinks and combos
	a1,a2,a3,a4 = AceConsole:GetArgs("simple |Cff112233|Hitem:0:0:0:0|hand here's a text with \"s and stuff|h|r", 3)
	assert(a1=="simple" and a2=="|Cff112233|Hitem:0:0:0:0|hand here's a text with \"s and stuff|h|r" and a3==nil and a4==1e9)

	a1,a2,a3,a4 = AceConsole:GetArgs("simple '|Cff112233|Hitem:0:0:0:0|hand here's a text with \"s and stuff|h|r'", 3)
	assert(a1=="simple" and a2=="|Cff112233|Hitem:0:0:0:0|hand here's a text with \"s and stuff|h|r" and a3==nil and a4==1e9)

	a1,a2,a3,a4 = AceConsole:GetArgs("simple \"|Cff112233|Hitem:0:0:0:0|hand here's a text with \"s and stuff|h|r\" 'bar'", 3)
	assert(a1=="simple" and a2=="|Cff112233|Hitem:0:0:0:0|hand here's a text with \"s and stuff|h|r" and a3=="bar" and a4==1e9)

	a1,a2,a3,a4 = AceConsole:GetArgs("simple |H|ha 1|h|H|ha 1|h", 3)
	assert(a1=="simple" and a2=="|H|ha 1|h|H|ha 1|h" and a3==nil and a4==1e9)

	a1,a2,a3,a4 = AceConsole:GetArgs("simple ||H|ha 1|h|H|ha 1|h", 3)	-- note double ||
	assert(a1=="simple" and a2=="||H|ha" and a3=="1|h|H|ha 1|h" and a4==1e9)

	a1,a2,a3,a4 = AceConsole:GetArgs("simple |||H|ha 1|h|H|ha 1|h", 3)	-- note double || followed by |H
	assert(a1=="simple" and a2=="|||H|ha 1|h|H|ha 1|h" and a3==nil and a4==1e9)

	self:TestEnd("AceConsole")
end