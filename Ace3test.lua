Ace3test = LibStub("AceAddon-3.0"):NewAddon("Ace3test", "AceConsole-3.0", "AceComm-3.0")

function Ace3test:Test()
	self:TestAceConsole()
	self:TestAceAddon()
	self:TestAceComm()
end

function Ace3test:Test2()
	-- continue to test after TestAceComm

end

function Ace3test:OnInitialize()
	self:Print("Ace3test", "initialized")
	self.test_initialized = true
end

function Ace3test:OnEnable()
	assert(self.test_initialized) -- this is part of the AceAddon test
	self.test_enabled = true
	self:Print("Ace3test", "enabled")
	self:RegisterChatCommand("ace3test", "Test")
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
	
	if name == "AceComm" then
		self:Test2()
	end
end