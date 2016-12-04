local Ace3test = Ace3test
local assert, error = assert, error
local floor = math.floor
local tgetn = table.getn
local strlen, strsub, strbyte = string.len, string.sub, string.byte
local random, mod, floor = math.random, math.mod, math.floor
local function print(...)
	Ace3test:Print(unpack(arg))
end

-- the char '|'(\124) is not allowed in the addon message
local function randchar(b,e)
	if b == 124 and e == 124 then
		return nil
	end
	local i = 124
	while i == 124 do
		i = random(b,e)
	end
	return string.char(i)
end

local myname = UnitName("Player")
local prefix_raid = "RaidTest"
local prefix_party = "PartyTest"
local middle_text = "Ace3"
local no_recv_msg = "!!!This should not be received!!!"
local data

local party_total_count
local party_send_count
local party_recv_count
local party_test_end
local function party_callbask(i, sent, textlen)
	assert(sent <= textlen)
	if sent < textlen then
		assert(party_send_count == i-1)
		return
	end
	party_send_count = party_send_count + 1
	assert(party_send_count == i)
	assert(party_send_count + 1 + strlen(middle_text) == textlen)
	assert(party_send_count >= party_recv_count)
	assert(party_send_count <= party_total_count)
	if mod(party_send_count,20) < 1 then
		Ace3test:Print("PARTY", ">>", party_send_count, '/', party_total_count)
	end
	-- This can only be tested after modification of CTL
	--error("callback error test, should not affect the final result")
end
function Ace3test:OnCommReceivedParty(prefix,msg,channel,sender)
	if msg == no_recv_msg then
		self:LogError(msg)
		return
	end
	if party_test_end then
		self:LogError("PARTY", "test already ended")
		return
	end
	if prefix == prefix_party then
		if channel == "PARTY" then
			if sender == myname then
				party_recv_count = party_recv_count + 1
				local l = strlen(msg)
				local el = party_recv_count + strlen(middle_text) + 1
				if l == el then
					local ctl = strbyte(strsub(msg,1,1))
					el = floor(mod(party_recv_count-1,32))+1
					if ctl == el then
						if mod(party_recv_count,20) < 1 then
							self:Print("PARTY", "<<", party_recv_count, '/', party_send_count)
						end
						if party_recv_count <= party_send_count then
							if party_recv_count < party_total_count then
								return
							else
								self:Print("PARTY", "test end")
								party_test_end = true
							end
						else
							self:LogError("PARTY", "received", party_recv_count, "more than sent", party_send_count)
						end
					else
						self:LogError("PARTY", "control", ctl, "instead of", el)
					end
				else
					self:LogError("PARTY", "length", l, "instead of", el)
				end
			else
				self:LogError("PARTY", "received from", sender, "instead of", myname)
			end
		else
			self:LogError("received from", channel, "instead of", "PARTY")
		end
	else
		self:LogError("received prefix", prefix, "instead of", prefix_party)
	end
	self:TestAceComm2()
end

local raid_total_count
local raid_send_count
local raid_recv_count
local raid_test_end
local function raid_callbask(_, sent, textlen)
	assert(sent <= textlen)
	if sent < textlen then
		assert(raid_send_count == textlen-1)
		return
	end
	raid_send_count = raid_send_count + 1
	assert(raid_send_count == textlen)
	assert(raid_send_count >= raid_recv_count)
	assert(raid_send_count <= raid_total_count)
	if mod(raid_send_count,20) < 1 then
		Ace3test:Print("RAID", ">>", raid_send_count, '/', raid_total_count)
	end
	-- This can only be tested after modification of CTL
	--error("callback error test, should not affect the final result")
end
function Ace3test:OnCommReceivedRaid(prefix,msg,channel,sender)
	if msg == no_recv_msg then
		self:LogError(msg)
		return
	end
	if raid_test_end then
		self:LogError("RAID", "test already ended")
		return
	end
	if prefix == prefix_raid then
		if channel == "RAID" then
			if sender == myname then
				raid_recv_count = raid_recv_count + 1
				local l = strlen(msg)
				if l == raid_recv_count then
					if mod(raid_recv_count,20) < 1 then
						self:Print("RAID", "<<", raid_recv_count, '/', raid_send_count)
					end
					if raid_recv_count <= raid_send_count then
						if raid_recv_count < raid_total_count then
							return
						else
							self:Print("RAID", "test end")
							raid_test_end = true
						end
					else
						self:LogError("RAID", "received", raid_recv_count, "more than sent", raid_send_count)
					end
				else
					self:LogError("RAID", "length", l, "instead of", raid_recv_count)
				end
			else
				self:LogError("RAID", "received from", sender, "instead of", myname)
			end
		else
			self:LogError("received from", channel, "instead of", "RAID")
		end
	else
		self:LogError("received prefix", prefix, "instead of", prefix_raid)
	end
	self:TestAceComm2()
end

local received1
local received2
local AceComm
function Ace3test:TestAceComm()
	if GetNumRaidMembers() == 0 then
		self:LogError("You must be in a raid to test AceComm!")
		return false
	end

	self:TestBegin("AceComm")
	AceComm = assert(LibStub("AceComm-3.0"))
	local VERBOSE = 1

	do
		self:Print("> RegisterComm")
		self:RegisterComm(prefix_raid,"OnCommReceivedRaid")
		self:RegisterComm(prefix_party,"OnCommReceivedParty")

		local MSGS=255*4  -- length 1..1000, covers all of: Single, First+Last, First+Next+Last, First+Next+Next+Last
		data=randchar(10, 255)
		for i = 1,MSGS do
			data = data .. randchar(1, 255)
		end

		party_test_end = nil
		party_total_count = MSGS
		party_recv_count = 0
		party_send_count = 0

		raid_test_end = nil
		raid_total_count = MSGS
		raid_recv_count = 0
		raid_send_count = 0

		-- First send a boatload of data without pumping OnUpdates to CTL
		self:Print("> SendCommMessage")
		for i = 1,MSGS do
			if VERBOSE and VERBOSE>=2 then print("Sending len "..i) end
			local s = strsub(data,1,i)

			AceComm:SendCommMessage(prefix_raid, s, "RAID", nil, "ALERT", raid_callbask)

			local j = floor(mod(i-1,32))+1
			local control = string.char(j)
			AceComm:SendCommMessage(prefix_party, control..middle_text..s, "PARTY", nil, "BULK", party_callbask, i)
		end
		self:Print("> SendCommMessage over")
	end
end

function Ace3test:TestAceComm2()
	if not party_test_end then
		self:Print("> Still waiting for party test to be end")
		return
	end
	if not raid_test_end then
		self:Print("> Still waiting for raid test to be end")
		return
	end
	assert(party_recv_count == party_total_count)
	assert(raid_recv_count == raid_total_count)
	assert(party_send_count == party_total_count)
	assert(raid_send_count == raid_total_count)
	if random(0,1) == 0 then
		self:Printf("UnregisterComm %s", prefix_party)
		self:UnregisterComm(prefix_party)
		self:Printf("UnregisterComm %s", prefix_raid)
		self:UnregisterComm(prefix_raid)
	else
		self:Print("UnregisterAllComm")
		self:UnregisterAllComm()
	end
	self:Print("Sending message after unregister")
	AceComm:SendCommMessage(prefix_raid, no_recv_msg, "RAID")
	AceComm:SendCommMessage(prefix_party, no_recv_msg, "PARTY")
	self:TestEnd("AceComm")
end