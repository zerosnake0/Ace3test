function Ace3test:TestAceTab()
	self:TestBegin("AceTab")

	local AceCore = LibStub("AceCore-3.0")
	local _G = AceCore._G

	local AceTab = assert(LibStub("AceTab-3.0"))

	AceTab:RegisterTabCompletion("tabtest1", "hell=",
		function(t)
			table.insert(t, "ball")
			table.insert(t, "bat")
			table.insert(t, "glove")
		end,
		function(u)
			u["ball"] = "You hit, catch, and throw this."
			u["bat"] = "You hit with this."
			u["glove"] = "You catch with this."
	end)
	assert(AceTab:IsTabCompletionRegistered("tabtest1"))

	AceTab:RegisterTabCompletion("VisorFrames",
		{"^%/visor .*p=", "^%/visor .*pr=", "^/visor .*f=", "^%/vz .*p=", "^%/vz .*pr=", "^%/vz .*f="},
		function (t)
			local f = EnumerateFrames()
			while f do
				table.insert(t, f:GetName())
				f = EnumerateFrames(f)
			end
		end)
	assert(AceTab:IsTabCompletionRegistered("VisorFrames"))

	AceTab:RegisterTabCompletion("TinyPad", "",
		function(t, text, pos)
			for i in string.gfind(string.sub(text, 1, pos), "(%w+)") do
				table.insert(t, i)
			end
			for i in string.gfind(string.sub(text, string.find(text, "%s", pos+1) or string.len(text)), "(%w+)") do
				table.insert(t ,i)
			end
		end)
	self:TestEnd("AceTab")
end