local strfind = string.find

local count = 0
function Ace3test:TestAceAddon()

	self:TestBegin("AceAddon")

	if count > 0 then
		self:LogError("Skipping, please reload UI if you wanna test again")
		return
	end
	count = count + 1

	local AceAddon = assert(LibStub("AceAddon-3.0"))

	do
		self:Print("> Test create addon.")
		local success, reason, addon

		-- 'name' - string expected
		success, reason = pcall( function() AceAddon:NewAddon() end )
		assert( success == false and strfind(reason, "'name' - string expected",1,true) )

		-- Cannot find a library instance of "Testing123".
		success, reason = pcall( function() AceAddon:NewAddon("TestAddon-1", "Testing123") end )
		assert( success == false and strfind(reason, "Cannot find a library instance",1,true))

		-- Success.
		addon = AceAddon:NewAddon("TestAddon-2")
		assert( addon and addon == AceAddon:GetAddon("TestAddon-2") )

		-- Addon 'TestAddon-2' already exists.
		success, reason = pcall( function() addon = AceAddon:NewAddon("TestAddon-2") end )
		assert( success == false and strfind(reason, "Addon 'TestAddon-2' already exists",1,true) )

	end

	do
		self:Print("> Test mixin.")
		-- Define a simple library for testing mixin.
		local libA = LibStub:NewLibrary("LibStupid",1)
		if libA then
			libA.mixins = { "BecomeStupid", "BecomeDumb" }
			function libA:BecomeStupid()
			end
			function libA:BecomeDumb()
			end
			function libA:Embed(target)
				for i,method in ipairs(self.mixins) do
					target[method] = self[method]
				end
			end
		end

		-- Yet another library.
		local libB = LibStub:NewLibrary("LibSmart",1)
		if libB then
			libB.mixins = { "BecomeSmart", "BecomeClever" }
			function libB:BecomeSmart()
			end
			function libB:BecomeClever()
			end
			function libB:Embed(target)
				for i,method in ipairs(self.mixins) do
					target[method] = self[method]
				end
			end
		end

		-- Create an AceAddon object with 2 libraries mixed.
		local addon = AceAddon:NewAddon("TestAddon-3","LibStupid","LibSmart")

		-- Are the methods mixed correctly?
		assert( addon.BecomeStupid == libA.BecomeStupid )
		assert( addon.BecomeDumb == libA.BecomeDumb )
		assert( addon.BecomeSmart == libB.BecomeSmart )
		assert( addon.BecomeClever == libB.BecomeClever )
	end

	do
		self:Print("> Test the call to OnInitialize, OnEnable and OnDisable.")
		-- Testing the call to addon:OnEnable()
		assert(self.test_initialized and self.test_enabled)

		-- Testing the call to addon:OnDisable()
		AceAddon:DisableAddon(self)
		assert(self.test_initialized and not self.test_enabled)

		-- Testing the call to addon:OnEnable()
		AceAddon:EnableAddon(self)
		assert(self.test_initialized and self.test_enabled)
	end
	self:TestEnd("AceAddon")
end