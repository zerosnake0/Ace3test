local strfind = string.find
local tgetn = table.getn

local send_count
local recv_count
function Ace3test:CHAT_MSG_SYSTEM(...)
	assert(event == "CHAT_MSG_SYSTEM")
	assert(tgetn(arg) == 2)
	assert(arg[1] == nil)
	assert(arg[2] == "CHAT_MSG_SYSTEM")
	recv_count = recv_count + 1
	if recv_count == send_count then
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:Print("> test CHAT_MSG_SYSTEM ended")
		self:TestAceEvent2()
	end
end

function Ace3test:TestAceEvent()
	self:TestBegin("AceEvent")

	local AceEvent = assert(LibStub("AceEvent-3.0"))

	local addon = {}
	AceEvent:Embed(addon)
	
	send_count = 5
	recv_count = 0
	self:RegisterEvent("CHAT_MSG_SYSTEM", "CHAT_MSG_SYSTEM", nil)
	
	self:Print("> test CHAT_MSG_SYSTEM by /ginfo")
	for i=1,send_count do
		SlashCmdList['GUILD_INFO']()
	end
end

local msg_event_name = "Ace3test"
local no_recv_msg = "!!!This should not be received!!!"
function Ace3test:OnMessage(...)
	recv_count = recv_count + 1
	assert(tgetn(arg) == 3)
	assert(arg[1] == nil)
	assert(arg[2] == msg_event_name)
	assert(arg[3] ~= no_recv_msg)
	assert(tonumber(arg[3]) == recv_count)
	if recv_count == send_count then
		self:Print("> OnMessage Ended")
		self:UnregisterMessage(msg_event_name)
		self:TestAceEvent3()
	end
end

function Ace3test:TestAceEvent2()
	assert(recv_count == send_count)
	
	self:SendMessage(msg_event_name, 1, no_recv_msg)

	self:Print("> RegisterMessage")
	self:RegisterMessage(msg_event_name, "OnMessage", nil)
	
	self:Print("> SendMessage")
	send_count = 10
	recv_count = 0
	for i=1,send_count do
		self:SendMessage(msg_event_name, 1, i)
	end
end

function Ace3test:TestAceEvent3()
	self:SendMessage(msg_event_name, 1, no_recv_msg)
	self:TestEnd("AceEvent")
end
