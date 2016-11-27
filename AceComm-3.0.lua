local assert = assert
local floor = math.floor
local tgetn = table.getn
local strlen = string.len
local random = math.random
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

local function mod(a,b)
	return a-floor(a/b)*b
end

local myname = UnitName("Player")
local prefix_raid = "RaidTest"
local prefix_party = "PartyTest"
local no_recv_msg = "!!!This should not be received!!!"
local data

local party_send_count
local party_recv_count
local party_test_end
function Ace3test:OnCommReceivedParty(msg,channel,sender)
	if msg == no_recv_msg then
		self:Print(msg)
		return
	end
	if channel == "PARTY" then
		if sender == myname then
			party_recv_count = party_recv_count + 1
			local l = strlen(msg)
			local el = mod(party_recv_count,2)
			if el == 0 then
				el = party_recv_count * 4 - 4
			else
				el = party_recv_count *12 - 6
			end
			if l == el then
				--if mod(party_recv_count,20) == 0 then
					self:Print("PARTY", party_recv_count, party_send_count, l)
				--end
				if party_recv_count < party_send_count then
					return
				end
				self:Print("PARTY test end")
				party_test_end = true
			else
				self:Printf("PARTY:length %s instead of %s", l)
			end
		else
			self:Printf("PARTY:received from %s instead of %s", sender, myname)
		end
	else
		self:Printf("received from %s instead of party", channel)
	end
	self:TestAceComm2()
end

local raid_send_count
local raid_recv_count
local raid_test_end
function Ace3test:OnCommReceivedRaid(msg,channel,sender)
	if msg == no_recv_msg then
		self:Print(msg)
		return
	end
	if channel == "RAID" then
		if sender == myname then
			raid_recv_count = raid_recv_count + 1
			local l = strlen(msg)
			if l == raid_recv_count then
				if mod(raid_recv_count,20) == 0 then
					self:Print("RAID", raid_recv_count, raid_send_count, l)
				end
				if raid_recv_count < raid_send_count then
					return
				end
				self:Print("RAID test end")
				raid_test_end = true
			else
				self:Printf("RAID:length %s instead of %s", l, raid_recv_count)
			end
		else
			self:Printf("RAID:received from %s instead of %s", sender, myname)
		end
	else
		self:Printf("received from %s instead of raid", channel)
	end
	self:TestAceComm2()
end

local received1
local received2
local AceComm
function Ace3test:TestAceComm()
	self:TestBegin("AceComm")
	AceComm = assert(LibStub("AceComm-3.0"))
	local VERBOSE = 1
	
	party_test_end = nil
	party_recv_count = 0
	party_send_count = 0
	received1 = {}
	
	raid_test_end = nil
	raid_recv_count = 0
	raid_send_count = 0
	received2 = {}
	
	do
		self:Print("> RegisterComm")
		self:RegisterComm(prefix_raid,"OnCommReceivedRaid")
		self:RegisterComm(prefix_party,"OnCommReceivedParty")

		--local MSGS=255*4  -- length 1..1000, covers all of: Single, First+Last, First+Next+Last, First+Next+Next+Last
		--local MSGS=255 -- Ace3v: the CTL seems to refuse send the message containing more than 254 characters
		local MSGS=40
		data=randchar(10, 255)
		for i = 1,MSGS do
			data = data .. randchar(1, 255)
		end

		-- First send a boatload of data without pumping OnUpdates to CTL
		self:Print("> SendCommMessage")
		for i = 1,MSGS do
			if VERBOSE and VERBOSE>=2 then print("Sending len "..i) end
			local s = strsub(data,1,i)
			if strlen(prefix_raid) + i < 255 then
				AceComm:SendCommMessage(prefix_raid, s, "RAID", nil)
				raid_send_count = raid_send_count + 1
			end
			if strlen(prefix_party) + i < 254 then
				local j = mod(i-1,8)+1
				local control = string.char(j)
				AceComm:SendCommMessage(prefix_party, control..s, "PARTY", nil)
				if j == 3 or j == 4 then
					party_send_count = party_send_count + 1
				end
			end
		end
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
	assert(party_recv_count == party_send_count)
	assert(raid_recv_count == raid_send_count)
	if random(0,1) == 0 then
		self:Printf("UnregisterComm %s", prefix_party)
		self:UnregisterComm(prefix_party)
		self:Printf("UnregisterComm %s", prefix_raid)
		self:UnregisterComm(prefix_raid)
	else
		self:Print("UnregisterAllComm")
		self:UnregisterAllComm()
	end
	self:Print("# Continue to test", "AceComm")
	self:Print("Sending message after unregister")
	AceComm:SendCommMessage(prefix_raid, no_recv_msg, "RAID")
	AceComm:SendCommMessage(prefix_party, no_recv_msg, "PARTY")
	self:TestEnd("AceComm")
end