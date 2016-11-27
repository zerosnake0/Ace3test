Ace3test = LibStub("AceAddon-3.0"):NewAddon("Ace3test",
	"AceConsole-3.0",
	"AceComm-3.0",
	"AceEvent-3.0",
	"AceBucket-3.0"
)

local tests = {
	"TestAceConsole",
	"TestAceAddon",
	"TestAceEvent",
	"TestAceBucket",
	"TestAceConfig",
	"TestAceComm"	-- takes long time, make it last
}

local tgetn = table.getn

local ind
local cur
function Ace3test:NextTest(start)
	if not ind then
		if start and start ~= "" then
			ind = tonumber(start)
		else
			ind = 1 -- start indice
		end
	end
	if cur then
		self:Print("|cFFFFFF00The current test", tests[cur], "is not finished yet!")
		return
	elseif ind == tgetn(tests) + 1 then
		self:Print("All tests ended")
		ind = nil
		return
	end
	local name = tests[ind]
	if name then
		if not self[name] then
			self:Print("No such test:", name)
		else
			cur = ind
			if self[name](self) == false then
				cur = nil
			end
			ind = ind + 1
		end
	end
end

function Ace3test:LogError(...)
	self:Print('|cFFFF4444', unpack(arg))
end

function Ace3test:OnInitialize()
	self:Print("Ace3test", "initialized")
	self.test_initialized = true
end

function Ace3test:OnEnable()
	assert(self.test_initialized) -- this is part of the AceAddon test
	self.test_enabled = true
	self:Print("Ace3test", "enabled")

	self:RegisterChatCommand("ace3test", "NextTest")
end

function Ace3test:OnDisable()
	self.test_enabled = false
	self:Print("Ace3test", "disabled")
	self:UnregisterChatCommand("ace3test")
end

function Ace3test:TestBegin(name)
	self:Print("#####################")
	self:Print("# Test begin", name)
end

function Ace3test:TestEnd(name)
	self:Print("# Test end", name)
	self:Print("#####################")
	cur = nil
end