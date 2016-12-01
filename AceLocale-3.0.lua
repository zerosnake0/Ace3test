local AceCore = assert(LibStub("AceCore-3.0"))
local _G = AceCore._G
local wipe = AceCore.wipe
local AceLocale = assert(LibStub("AceLocale-3.0"))

local function reset()
	wipe(AceLocale.apps)
end

function Ace3test:TestAceLocale30()
	self:TestBegin("AceLocale-3.0")

	GAME_LOCALE = "enUS"

	local AceLocale = assert(LibStub("AceLocale-3.0"))

	self:Print("> Test locale")
	reset()

	local loc = AceLocale:NewLocale("test", "enUS")
	loc["a"] = "A"
	loc["c"] = "C"

	local loc = AceLocale:NewLocale("test", "deDE", true)
	loc["a"] = "aa"
	loc["b"] = "bb"
	loc["c"] = "cc"

	local loc = AceLocale:NewLocale("test", "frFR")
	assert(loc == nil)

	local test = AceLocale:GetLocale("test")

	assert(test["a"] == "A")
	assert(test["b"] == "bb")
	assert(test["c"] == "C")

	self:Print("> Test requesting an unknown string")
	local oldgeterrorhandler = geterrorhandler
	local errors=0
	_G.geterrorhandler = function() return function() errors=errors+1 end end
	assert(test["thisdoesntexist"]=="thisdoesntexist")
	assert(errors==1)
	_G.geterrorhandler=oldgeterrorhandler

	------------------------------------------------
	self:Print("> Test the silent flag working")
	reset()

	local loc = AceLocale:NewLocale("test2", "enUS", true, true) -- silent flag set on first locale to be registered
	loc["This Exists"]=true
	assert(not AceLocale:NewLocale("test2", "deDE"))
	assert(not AceLocale:NewLocale("test2", "frFR"))

	local test2=AceLocale:GetLocale("test2")
	assert(test2["thisdoesntexist"]=="thisdoesntexist")
	assert(test2["This Exists"]=="This Exists")


	------------------------------------------------
	self:Print("> Test the silent flag working even if the default locale is registered second")
	reset()

	assert(not AceLocale:NewLocale("test3", "deDE", false, true))	-- silent flag set on first locale to be registered
	assert(AceLocale:NewLocale("test3", "enUS", true))
	assert(not AceLocale:NewLocale("test3", "frFR"))

	local test3=AceLocale:GetLocale("test3")
	assert(test3["thisdoesntexist"]=="thisdoesntexist")
	assert(test3["This Exists"]=="This Exists")

	------------------------------------------------
	self:Print("> Test the silent flag warning when using it on nonfirst")
	reset()

	local oldgeterrorhandler = geterrorhandler
	local errors=0
	_G.geterrorhandler = function() return function() errors=errors+1 end end

	assert(not AceLocale:NewLocale("test3a", "deDE"))
	assert(AceLocale:NewLocale("test3a", "enUS", true, true))
	assert(not AceLocale:NewLocale("test3a", "frFR"))

	assert(errors==1)
	_G.geterrorhandler=oldgeterrorhandler

	------------------------------------------------
	self:Print('> Test silent="raw" working')
	reset()

	local loc = assert(AceLocale:NewLocale("test4", "enUS", true, "raw"))
	loc["This Exists"]=true
	assert(not AceLocale:NewLocale("test4", "deDE"))
	assert(not AceLocale:NewLocale("test4", "frFR"))

	local test4=AceLocale:GetLocale("test4")
	assert(test4["thisdoesntexist"]==nil)
	assert(test4["This Exists"]=="This Exists")

	------------------------------------------------
	self:Print("> Test that we can re-get an already-created locale so we can write more to it")
	reset()

	local loc = assert(AceLocale:NewLocale("test5", "enUS"))
	loc["orig1"]=true
	loc["orig2"]="orig2"
	loc["orig3"]=true
	loc["orig4"]="orig4"

	local loc = assert(AceLocale:NewLocale("unrelatedLocale", "enUS"))  -- touch something else in between to make extra sure

	local loc = assert(AceLocale:NewLocale("test5", "enUS"))
	loc["orig3"]="NEWorig3"
	loc["orig4"]="NEWorig4"
	loc["orig5"]="thisneverexisted"

	local test5 = assert(AceLocale:GetLocale("test5"))
	assert(test5["orig1"]=="orig1")
	assert(test5["orig2"]=="orig2")
	assert(test5["orig3"]=="NEWorig3")
	assert(test5["orig4"]=="NEWorig4")
	assert(test5["orig5"]=="thisneverexisted")

	-------------------------------------------
	self:Print("> Test enUS locale")
	reset()

	local L = assert(AceLocale:NewLocale("Loc1", "enUS", true))
	L["foo1"] = true

	local L = assert(AceLocale:NewLocale("Loc1", "enUS", true))	-- should be ok to add more!
	L["foo1"] = "this should not overwrite foo1 since this a default locale"
	L["foo2"] = "manual foo2"
	L["foo2"] = "this should not overwrite foo2 since this a default locale"


	local x="untouched"
	ok, msg = pcall(function() x = L["i can't read from write proxies"] end)
	assert(not ok, "got: "..tostring(ok))
	assert(x=="untouched", "got: "..tostring(x))
	assert(strfind(msg, "assertion failed"), "got: "..tostring(msg))


	local L = assert(AceLocale:GetLocale("Loc1"))
	assert(L["foo1"] == "foo1")
	assert(L["foo2"] == "manual foo2")

	-- test warning system for nonexistant strings
	local errormsg
	local oldgeterrorhandler = geterrorhandler
	_G.geterrorhandler = function() return function(msg) errormsg=msg end end

	assert(L["this doesn't exist"]=="this doesn't exist")
	assert(errormsg=="AceLocale-3.0: Loc1: Missing entry for 'this doesn't exist'", "got: "..errormsg)

	-- we shouldnt get warnings for the same string twice
	errormsg="no error"

	assert(L["this doesn't exist"]=="this doesn't exist")
	assert(errormsg=="no error")

	_G.geterrorhandler = oldgeterrorhandler

	-- (don't) create deDE locale
	local L = AceLocale:NewLocale("Loc1", "deDE")
	assert(not L)

	-------------------------------------------
	self:Print("> Test Get locale for nonexisting app")
	reset()

	-- silent
	local L = AceLocale:GetLocale("Loc2", true)
	assert(not L)

	-- nonsilent - should error
	local ok, msg = pcall(function() return AceLocale:GetLocale("Loc2") end)
	assert(not ok, "got: "..tostring(ok))
	assert(msg=="Usage: GetLocale(application[, silent]): 'application' - No locales registered for 'Loc2'", "got: "..tostring(msg))

	---------------------------------------------------------------
	self:Print("> Test german client")
	reset()

	GAME_LOCALE = "deDE"

	assert( not AceLocale:NewLocale("Loc1", "frFR") )  -- no, we're still not french

	-- Register deDE

	local L = assert(AceLocale:NewLocale("Loc1", "deDE"))
	L["yes"]="jawohl"
	L["no"]="nein"


	---------------------------------------------------------------
	-- Register enUS (default)

	local L = assert(AceLocale:NewLocale("Loc1", "enUS", true))
	L["yes"]=true
	L["no"]="no"
	L["untranslated"]="untranslated"

	---------------------------------------------------------------
	-- Test deDE

	local L = assert(AceLocale:GetLocale("Loc1"))
	assert(L["yes"]=="jawohl")
	assert(L["no"]=="nein")
	assert(L["untranslated"]=="untranslated")

	---------------------------------------------------------------
	self:Print("> Test Test overriding with GAME_LOCALE")

	GAME_LOCALE = "frFR"

	assert(not AceLocale:NewLocale("Loc1", "deDE"))		-- shouldn't be krauts anymore now

	local L = assert(AceLocale:NewLocale("Loc1", "frFR"))	-- we're frog eaters!
	L["yes"] = "oui"

	local L = assert(AceLocale:GetLocale("Loc1"))
	assert(L["yes"] == "oui")	-- should have been overwritten
	assert(L["no"] == "nein") -- should be left from kraut days

	self:TestEnd("AceLocale")
end