local opt = {
  type = "group",
  args = {
  }
}

local defaults = {
	profile = {
		singleEntry = "singleEntry",
		tableEntry = {
			tableDefault = "tableDefault",
		},
		starTest = {
			["*"] = {
				starDefault = "starDefault",
			},
			sibling = {
				siblingDefault = "siblingDefault",
			},
		},
		doubleStarTest = {
			["**"] = {
				doubleStarDefault = "doubleStarDefault",
			},
			sibling = {
				siblingDefault = "siblingDefault",
			},
		},
	},
}

local app_name = "Ace3testDBOptions-1.0"
local slash_cmd = "A3TDBO"

function Ace3test:TestAceDBOptions()
	self:TestBegin("AceDBOptions")

	local AceConfig = assert(LibStub("AceConfig-3.0"))
	local AceConfigCmd = assert(LibStub("AceConfigCmd-3.0"))
	local AceDB = assert(LibStub("AceDB-3.0"))
	local AceDBOptions = assert(LibStub("AceDBOptions-3.0"))

	local testdb = AceDB:New({}, defaults)
	self:RegisterOptionsTable(app_name, opt, slash_cmd)
	assert(AceConfigCmd:GetChatCommandOptions(slash_cmd) == app_name)

	local handler = assert(SlashCmdList["ACECONSOLE_" .. slash_cmd])

	opt.args.profiles = AceDBOptions:GetOptionsTable(testdb)

	do
		self:Print("> Test callbacks")

		local triggers = {}
		local a1, a2, a3, a4, a5

		local function OnCallback(message, db, profile)
			assert(db == testdb)
			if message == "OnProfileChanged" then
				a1 = profile
			elseif message == "OnProfileDeleted" then
				a2 = profile
			elseif message == "OnProfileCopied" then
				a3 = profile
			elseif message == "OnNewProfile" then
				a4 = profile
			elseif message == "OnProfileReset" then
				a5 = profile
			end
			triggers[message] = triggers[message] and triggers[message] + 1 or 1
		end

		testdb:RegisterCallback("OnProfileChanged", OnCallback)
		testdb:RegisterCallback("OnProfileDeleted", OnCallback)
		testdb:RegisterCallback("OnProfileCopied", OnCallback)
		testdb:RegisterCallback("OnDatabaseReset", OnCallback)
		testdb:RegisterCallback("OnNewProfile", OnCallback)
		testdb:RegisterCallback("OnProfileReset", OnCallback)

		testdb:ResetDB("Healers")
		assert(triggers.OnProfileChanged == 1)
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == nil)
		assert(triggers.OnProfileCopied == nil)
		assert(triggers.OnProfileReset == nil)
		assert(triggers.OnNewProfile == nil)
		assert(a1 == "Healers")

		handler("profiles choose Tanks")
		assert(triggers.OnProfileChanged == 1)
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == nil)
		assert(triggers.OnProfileCopied == nil)
		assert(triggers.OnProfileReset == nil)
		assert(triggers.OnNewProfile == nil)

		handler("profiles new Tanks")
		assert(triggers.OnProfileChanged == 2)	-- +1
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == nil)
		assert(triggers.OnProfileCopied == nil)
		assert(triggers.OnProfileReset == nil)
		assert(triggers.OnNewProfile == 1)	-- +1, Healers created
		assert(a1 == "Tanks")
		assert(a4 == "Healers")

		handler("profiles choose Tanks")
		assert(triggers.OnProfileChanged == 2)
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == nil)
		assert(triggers.OnProfileCopied == nil)
		assert(triggers.OnProfileReset == nil)
		assert(triggers.OnNewProfile == 1)

		handler("profiles copyfrom Healers")
		assert(triggers.OnProfileChanged == 2)
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == nil)
		assert(triggers.OnProfileCopied == 1)
		assert(triggers.OnProfileReset == nil)
		assert(triggers.OnNewProfile == 2)	-- +1, Tanks created
		assert(a4 == "Tanks")

		self:HandleCommand(slash_cmd, app_name, "profiles delete Healers")
		assert(triggers.OnProfileChanged == 2)
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == 1)	-- +1
		assert(triggers.OnProfileCopied == 1)
		assert(triggers.OnProfileReset == nil)
		assert(triggers.OnNewProfile == 2)
		assert(a2 == "Healers")

		self:HandleCommand(slash_cmd, app_name, "profiles reset")
		assert(triggers.OnProfileChanged == 2)
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == 1)
		assert(triggers.OnProfileCopied == 1)
		assert(triggers.OnProfileReset == 1) -- +1
		assert(a5 == "Tanks")
		assert(triggers.OnNewProfile == 2)	-- "Healer" and "Tank"
	end

	self:TestEnd("AceDBOptions")
end