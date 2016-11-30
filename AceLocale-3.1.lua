local AceLocale = assert(LibStub("AceLocale-3.1"))

local err

local function reset()
	wipe(AceLocale.apps)
	wipe(AceLocale.appnames)
	wipe(AceLocale.appmodes)
	wipe(AceLocale.applocales)
	err = nil
end

local handler = function()
	return function(msg) err=msg end
end
local function switcherrhandler()
	_G.geterrorhandler, handler = handler, _G.geterrorhandler
end

local game_locale = GetLocale()
function Ace3test:TestAceLocale31()
	self:TestBegin("AceLocale-3.1")

	local succ, msg, L

	self:Print("> Test NewLocale before NewLocale")
	reset()
	assert(not AceLocale:GetLocale("loc", true))
	succ, err = pcall(AceLocale.GetLocale, AceLocale, "loc")
	assert(not succ)

	self:Print("> Test SetLocale after NewLocale")
	reset()
	assert(AceLocale:NewLocale("loc", "enUS", true))
	succ, msg = pcall(AceLocale.SetLocale, AceLocale, "loc", "enUS")
	assert(not succ)

	self:Print("> Test SetLocale before NewLocale")
	reset()
	AceLocale:SetLocale("loc", "abcd")
	assert(AceLocale:NewLocale("loc", "abcd"))

	self:Print("> Test SetMode before NewLocale WARN_ON_MISSING")
	reset()
	AceLocale:SetLocale("loc", "fghi")
	AceLocale:SetMode("loc", "WARN_ON_MISSING")
	L = assert(AceLocale:NewLocale("loc", "abcd", true))
	L["test"] = true
	L["test2"] = true
	L = assert(AceLocale:NewLocale("loc", "fghi"))
	L["test"] = "TEST"
	L = assert(AceLocale:GetLocale("loc"))
	assert(L["test"] == "TEST")
	assert(L["test2"] == "test2")
	switcherrhandler()
	assert(L["test3"] == "test3")
	switcherrhandler()
	assert(err)

	self:Print("> Test SetMode after NewLocale NIL_ON_MISSING")
	reset()
	AceLocale:SetLocale("loc", "fghi")
	L = assert(AceLocale:NewLocale("loc", "abcd", true))
	L["test"] = true
	L["test2"] = true
	L = assert(AceLocale:NewLocale("loc", "fghi"))
	L["test"] = "TEST"
	L = assert(AceLocale:GetLocale("loc"))
	AceLocale:SetMode("loc", "NIL_ON_MISSING")
	assert(L["test"] == "TEST")
	assert(L["test2"] == "test2")
	assert(L["test3"] == nil)

	self:TestEnd("AceLocale-3.1")
end