local prefix = "TestBucket"
local msghandle
local c2

function Ace3test:TestAceBucketMessage(arg)
	local c = 0
	for k,v in arg do
		c = c + 1
		assert(v == 1)
	end
	assert(c == c2)
	self:UnregisterAllBuckets()
	self:TestEnd("AceBucket")
end

function Ace3test:TestAceBucket2()

	msghandle = self:RegisterBucketMessage(prefix, 3, "TestAceBucketMessage")
	self:Print("> SendMessage")
	c2 = 1
	for i=1,c2 do
		self:SendMessage(prefix, i)
		self:Print("send "..tostring(i)..' '..tostring(Ace3test.TestAceBucketMessage))
	end
end

local c
local evhandle

function Ace3test:TestAceBucketEvent(arg)
	assert(evhandle)
	for k, v in arg do
		assert(v == c)
	end
	self:UnregisterBucket(evhandle)
	evhandle = nil
	self:TestAceBucket2()
end

function Ace3test:TestAceBucket()
	self:TestBegin("AceBucket")

	evhandle = self:RegisterBucketEvent("CHAT_MSG_SYSTEM", 2, "TestAceBucketEvent")

	self:Print("> test CHAT_MSG_SYSTEM by /ginfo")

	c = 1
	for i=1,c do
		SlashCmdList['GUILD_INFO']()
	end
end