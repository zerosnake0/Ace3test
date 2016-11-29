local AceDB = assert(LibStub("AceDB-3.0"))

local tinsert = table.insert

local count = 0
function Ace3test:TestAceDB()
	self:TestBegin("AceDB")

	do
		self:Print("> Test the defaults system")
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

		local db = LibStub("AceDB-3.0"):New("MyDB", defaults)

		assert(db.profile.singleEntry == "singleEntry")
		assert(db.profile.tableEntry.tableDefault == "tableDefault")
		assert(db.profile.starTest.randomkey.starDefault == "starDefault")
		assert(db.profile.starTest.sibling.siblingDefault == "siblingDefault")
		assert(db.profile.starTest.sibling.starDefault == nil)
		assert(db.profile.doubleStarTest.randomkey.doubleStarDefault == "doubleStarDefault")
		assert(db.profile.doubleStarTest.sibling.siblingDefault == "siblingDefault")
		assert(db.profile.doubleStarTest.sibling.doubleStarDefault == "doubleStarDefault")
	end

	do
		self:Print("> Test the dynamic creation of sections")
		local defaults = {
			char = { alpha = "alpha",},
			realm = { beta = "beta",},
			class = { gamma = "gamma",},
			race = { delta = "delta",},
			faction = { epsilon = "epsilon",},
			factionrealm = { zeta = "zeta",},
			profile = { eta = "eta",},
			global = { theta = "theta",},
		}

		local db = LibStub("AceDB-3.0"):New({}, defaults)

		assert(rawget(db, "char") == nil)
		assert(rawget(db, "realm") == nil)
		assert(rawget(db, "class") == nil)
		assert(rawget(db, "race") == nil)
		assert(rawget(db, "faction") == nil)
		assert(rawget(db, "factionrealm") == nil)
		assert(rawget(db, "profile") == nil)
		assert(rawget(db, "global") == nil)
		assert(rawget(db, "profiles") == nil)

		-- Check dynamic default creation
		assert(db.char.alpha == "alpha")
		assert(db.realm.beta == "beta")
		assert(db.class.gamma == "gamma")
		assert(db.race.delta == "delta")
		assert(db.faction.epsilon == "epsilon")
		assert(db.factionrealm.zeta == "zeta")
		assert(db.profile.eta == "eta")
		assert(db.global.theta == "theta")
	end

	do
		self:Print("> Test OnProfileChanged")

		local testdb = LibStub("AceDB-3.0"):New({})
		local triggered = nil
		local function OnProfileChanged(event, db, profile)
			assert(event == "OnProfileChanged")
			assert(db == testdb)
			assert(profile == "Healers")
			triggered = true
		end
		testdb:RegisterCallback("OnProfileChanged", OnProfileChanged, "OnProfileChanged")
		testdb:SetProfile("Healers")
		assert(triggered)
	end

	do
		self:Print("> Test GetProfiles")
		local db = LibStub("AceDB-3.0"):New({})

		local profiles = {
			"Healers",
			"Tanks",
			"Hunter",
		}

		for idx,profile in ipairs(profiles) do
			db:SetProfile(profile)
		end

		local profileList = db:GetProfiles()
		table.sort(profileList)
		table.sort(profiles)

		local player = UnitName("player") .. " - " .. GetRealmName()
		local i = 1
		local b = 0
		for i=1,3 do
			if profileList[i] == player then
				assert(b == 0)
				b = 1
			end
			assert(profileList[b+i] == profiles[i])
		end
		if b == 0 then
			assert(profileList[4] == player)
		end
	end

	do
		self:Print("> Very simple default test")
		local defaults = {
			profile = {
				sub = {
					["*"] = {
						sub2 = {},
						sub3 = {},
					},
				},
			},
		}

		local db = LibStub("AceDB-3.0"):New({}, defaults)

		assert(type(db.profile.sub.monkey.sub2) == "table")
		assert(type(db.profile.sub.apple.sub3) == "table")

		db.profile.sub.random.sub2.alpha = "alpha"
	end

	do
		self:Print("> Table insert kills us")
		local defaults = {
			profile = {
				["*"] = {},
			},
		}

		local db = LibStub("AceDB-3.0"):New({}, defaults)

		table.insert(db.profile.monkey, "alpha")
		table.insert(db.profile.random, "beta")

		-- Here, the tables db.profile.monkey should be REAL, not cached
		assert(rawget(db.profile, "monkey"))
	end


	do
		self:Print("> Test multi-level defaults for hyper")
		local defaults = {
			profile = {
				autoSendRules = {
					['*'] = {
						include = {
							['*'] = {},
						},
						exclude = {
							['*'] = {},
						},
					},
				},
			}
		}

		local db = LibStub("AceDB-3.0"):New({}, defaults)

		assert(rawget(db.profile.autoSendRules.Cairthas.include, "ptSets") == nil)
		assert(rawget(db.profile.autoSendRules.Cairthas.include, "items") == nil)
		table.insert(db.profile.autoSendRules.Cairthas.include.ptSets, "TradeSkill.Mat.ByProfession.Leatherworking")
		table.insert(db.profile.autoSendRules.Cairthas.include.items, "Light Leather")

		db.profile.autoSendRules.Cairthas.include.ptSets.boo = true

		-- Tables should be real now, not cached.
		assert(rawget(db.profile.autoSendRules.Cairthas.include, "ptSets"))
		assert(rawget(db.profile.autoSendRules.Cairthas.include, "items"))
		assert(rawget(db.profile.autoSendRules.Cairthas.include.ptSets, "boo"))
	end

	do
		self:Print("> Test new with name")
		local testdb = LibStub("AceDB-3.0"):New("testdbtable", {profile = { test = 2, test3 = { a=1}}})
		assert(_G["testdbtable"])
		assert(testdb.profile.test == 2) --true
		testdb.profile.test = 3
		testdb.profile.test2 = 4
		testdb.profile.test3.b = 2
		assert(testdb.profile.test == 3) --true
		assert(testdb.profile.test2 == 4) --true
		local firstprofile = testdb:GetCurrentProfile()
		testdb:SetProfile("newprofile")
		assert(testdb.profile.test == 2) --true
		testdb:CopyProfile(firstprofile)
		assert(testdb.profile.test == 3) --false, the value is 2
		assert(testdb.profile.test2 == 4) --true
		assert(testdb.profile.test3.a == 1)
		_G["testdbtable"] = nil
	end

	do
		local testdb = LibStub("AceDB-3.0"):New({})
		testdb:SetProfile("testprofile")
		testdb:SetProfile("testprofile2")
		testdb:SetProfile("testprofile")
		assert(table.getn(testdb:GetProfiles()) == 3)
	end


	do
		self:Print("> Test callbacks")
		local testdb = LibStub("AceDB-3.0"):New({})

		local triggers = {}

		local function OnCallback(message, db, profile)
			if db == testdb then
				if message == "OnProfileChanged" then
					assert(profile == "Healers" or profile == "Tanks")
				elseif message == "OnProfileDeleted" then
					assert(profile == "Healers")
				elseif message == "OnProfileCopied" then
					assert(profile == "Healers")
				elseif message == "OnNewProfile" then
					assert(profile == "Healers" or profile == "Tanks")
				elseif message == "OnProfileReset" then
					assert(profile == "Tanks")
				end
				triggers[message] = triggers[message] and triggers[message] + 1 or 1
			end
		end

		testdb:RegisterCallback("OnProfileChanged", OnCallback, "OnProfileChanged")
		testdb:RegisterCallback("OnProfileDeleted", OnCallback, "OnProfileDeleted")
		testdb:RegisterCallback("OnProfileCopied", OnCallback, "OnProfileCopied")
		testdb:RegisterCallback("OnDatabaseReset", OnCallback, "OnDatabaseReset")
		testdb:RegisterCallback("OnNewProfile", OnCallback, "OnNewProfile")
		testdb:RegisterCallback("OnProfileReset", OnCallback, "OnProfileReset")
		-- dbreset, change
		testdb:ResetDB("Healers")
		-- change
		testdb:SetProfile("Tanks")
		-- copy
		testdb:CopyProfile("Healers")
		-- delete
		testdb:DeleteProfile("Healers")
		-- reset
		testdb:ResetProfile()
		assert(triggers.OnProfileChanged == 2)
		assert(triggers.OnDatabaseReset == 1)
		assert(triggers.OnProfileDeleted == 1)
		assert(triggers.OnProfileCopied == 1)
		assert(triggers.OnProfileReset == 1)
		assert(triggers.OnNewProfile == 2)	-- "Healer" and "Tank"
	end

	do
		self:Print("> Test OnNewProfile")
		local dbDefaults = {
			profile = { bla = 0, },
		}
		local db = LibStub("AceDB-3.0"):New({}, dbDefaults, true)
		db:RegisterCallback("OnNewProfile", function()
			db.profile.bla = 1
		end)
		db:SetProfile("blatest")
		assert(db.profile.bla == 1)
	end

	do
		self:Print("> Test incoherent field type")
		local defaultTest = {
			profile = {
				units = {
					["**"] = {
						test = 2
					},
					["player"] = {
					},
					["pet"] = {
						test = 3
					},
					["bug"] = {
						test = 3,
					},
				}
			}
		}

		local profile = "player - Realm Name"
		local bugdb = {
			["profileKeys"] = {
				[profile] = "player - Realm Name",
			},
			["profiles"] = {
				["player - Realm Name"] = {
					["units"] = {
						["player"] = {
						},
						["pet"] = {
						},
						["focus"] = {
						},
						bug = "bug",
					},
				},
			},
		}

		local data = LibStub("AceDB-3.0"):New(bugdb, defaultTest)
		data:SetProfile(profile)
		assert(data.profile.units["player"].test == 2)
		assert(data.profile.units["pet"].test == 3)
		assert(data.profile.units["focus"].test == 2)
		assert(type(data.profile.units.bug) == "string")
	end

	do
		self:Print("> Test single star")
		local defaultTest = {
			profile = {
				units = {
					["*"] = {
						test = 2
					},
					["player"] = {
					}
				}
			}
		}

		local profile = "player - Realm Name"
		local bugdb = {
			["profileKeys"] = {
				[profile] = "player - Realm Name",
			},
			["profiles"] = {
				["player - Realm Name"] = {
					["units"] = {
						["player"] = {
						},
						["pet"] = {
						},
					},
				},
			},
		}

		local data = LibStub("AceDB-3.0"):New(bugdb, defaultTest)
		data:SetProfile(profile)
		assert(data.profile.units["player"].test == nil)
		assert(data.profile.units["pet"].test == 2)
		assert(data.profile.units["focus"].test == 2)
	end

	do
		self:Print("> Test single star 2")
		local defaultTest = {
			profile = {
				foo = {
					["*"] = {
						plyf = true,
				},
				}
			}
		}

		local profile = "player - Realm Name"
		local bugdb = {
			["profileKeys"] = {
				[profile] = "player - Realm Name",
			},
			["profiles"] = {
				["player - Realm Name"] = {
					["foo"] = {
						hopla = 42,
					},
				},
			},
		}

		local data = LibStub("AceDB-3.0"):New(bugdb, defaultTest)
		data:SetProfile(profile)
		assert(data.profile.foo.hopla == 42)
	end

	do
		self:Print("> Test more stars with multiple access")
		local defaultTest = {
			profile = {
				['**'] = {
					['*'] = {
						stuff = 5,
						stuff2 = {
							['**'] = {
								a = 4,
							},
						},
					},
				},
				stuff2 = {
					blu = {
						stuff = 6,
						stuff2 = {
							b = {
								a = 5
							},
						},
					},
				},
			},
		}

		local bugdb = {}
		local data = LibStub("AceDB-3.0"):New(bugdb, defaultTest)
		data.profile.stuff2.blu.stuff = 5
		data.profile.stuff2.blu.stuff2.b.a = 4
		data:RegisterDefaults()

		local data2 = LibStub("AceDB-3.0"):New(bugdb, defaultTest)

		assert(data2.profile.stuff2.blu.stuff == 5)
		assert(data2.profile.stuff2.blu.stuff2.b.a == 4)
	end

	do
		self:Print("> Test assign")
		local db = {}
		-- test case for ticket 66
		local defaults = {
			profile = {
				Positions = {
					["**"] = {
						point = "CENTER",
						relativeTo = "UIParent",
						relativePoint = "CENTER",
						xOfs = 0,
						yOfs = 0
					},
				},
			},
		}

		local data = LibStub("AceDB-3.0"):New(db, defaults)

		local v1 = data.profile.Positions.foo

		defaults.profile.Positions["TestFrame"] = {
			point = "TOP",
			relativeTo = "UIParent",
			relativePoint = "TOP",
			xOfs = 100,
			yOfs = 200,
		}

		data:RegisterDefaults(defaults)
		assert(data.profile.Positions.TestFrame.xOfs == 100)
	end

	do
		self:Print("> Test namespace 1")
		local defaults = { profile = { key3 = "stillfun" } }
		local db = LibStub("AceDB-3.0"):New({})
		local namespace = db:RegisterNamespace("test", defaults)

		namespace.profile.key1 = "fun"
		namespace.profile.key2 = "nofun"

		local oldprofile = db:GetCurrentProfile()
		db:SetProfile("newprofile")
		assert(namespace.profile.key1 == nil)
		assert(namespace.profile.key2 == nil)
		assert(namespace.profile.key3 == "stillfun")
		db:SetProfile(oldprofile)
		assert(namespace.profile.key1 == "fun")
		assert(namespace.profile.key2 == "nofun")
		assert(namespace.profile.key3 == "stillfun")
		db:SetProfile("newprofile2")
		db:CopyProfile(oldprofile)
		assert(namespace.profile.key1 == "fun")
		assert(namespace.profile.key2 == "nofun")
		assert(namespace.profile.key3 == "stillfun")
		db:ResetProfile()
		assert(namespace.profile.key1 == nil)
		assert(namespace.profile.key2 == nil)
		assert(namespace.profile.key3 == "stillfun")
		db:DeleteProfile(oldprofile)
		db:SetProfile(oldprofile)
		assert(namespace.profile.key1 == nil)
		assert(namespace.profile.key2 == nil)
		assert(namespace.profile.key3 == "stillfun")

		local ns2 = db:GetNamespace("test")
		assert(namespace == ns2)
	end

	-- Test log out
	self:Print("> Testing logout")
	count = count + 1
	if count == 1 then
		if Ace3testDBLogout ~= nil then
			if Ace3testDBLogout ~= true then
				self:LogError("Error on AceDB logout event", Ace3testDBLogout)
			else
				self:LogSuccess("AceDB logout check ok")
			end
			self:Print("Ace3testDBLogout has been reset")
			Ace3testDBLogout = nil
			count = 0
		else
			self:Print(">> Logout testcase 1")

			local TestDB = {
				["namespaces"] = {
					["Space"] = {
						["profiles"] = {
							["Default"] = {
							},
						},
					},
				},
				["profiles"] = {
					["Default"] = {
						["notEmpty"] = true,
					},
					["Test"] = {
					},
				},
				["char"] = {
					["TestChar - SomeRealm"] = {
					},
				},
				["realm"] = {
					["SomeRealm"] = {
						["notEmpty"] = true,
					},
				},
			}

			local nsdef = {
				profile = {
					bla = true,
				}
			}

			local testdb = LibStub("AceDB-3.0"):New(TestDB, nil, true)
			local ns = testdb:RegisterNamespace("Space", nsdef)

			self:Print(">> Logout testcase 2")
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
						siblingDeriv = {
							starDefault = "not-so-starDefault",
						},
					},
					doubleStarTest = {
						["**"] = {
							doubleStarDefault = "doubleStarDefault",
						},
						sibling = {
							siblingDefault = "siblingDefault",
						},
						siblingDeriv = {
							doubleStarDefault = "overruledDefault",
						}
					},
					starTest2 = {
						["*"] = "fun",
						sibling = "notfun",
					}
				},
			}

			local db = LibStub("AceDB-3.0"):New("MyDB", defaults)
			assert(db.profile.singleEntry == "singleEntry")
			assert(db.profile.tableEntry.tableDefault == "tableDefault")
			assert(db.profile.starTest.randomkey.starDefault == "starDefault")
			assert(db.profile.starTest.sibling.siblingDefault == "siblingDefault")
			-- sibling is a defined key so wont inherit the starDefault
			assert(db.profile.starTest.sibling.starDefault == nil)
			assert(db.profile.starTest.siblingDeriv.starDefault == "not-so-starDefault")
			assert(db.profile.doubleStarTest.randomkey.doubleStarDefault == "doubleStarDefault")
			assert(db.profile.doubleStarTest.sibling.siblingDefault == "siblingDefault")
			-- always inherit with double stars
			assert(db.profile.doubleStarTest.sibling.doubleStarDefault == "doubleStarDefault")
			assert(db.profile.doubleStarTest.siblingDeriv.doubleStarDefault == "overruledDefault")
			assert(db.profile.starTest2.randomkey == "fun")
			assert(db.profile.starTest2.sibling == "notfun")

			db.profile.doubleStarTest.siblingDeriv.doubleStarDefault = "doubleStarDefault"
			db.profile.starTest2.randomkey = "notfun"
			db.profile.starTest2.randomkey2 = "fun"
			db.profile.starTest2.sibling = "fun"

			self:Print(">> Logout testcase 3")
			local defaultTest = {
				profile = {
					boo = {
						[true] = "true",
						[false] = "false",
					},
				}
			}

			local bugdb = {}
			local data = LibStub("AceDB-3.0"):New(bugdb, defaultTest)
			data.profile.boo[true] = "not so true"
			data.profile.boo[false] = "not so false"

			self:Print(">> Logout testcase 4 (namespace)")
			local dbtbl_4 = {}
			local db_4 = LibStub("AceDB-3.0"):New(dbtbl_4, nil, "bar")
			local ns_4 = db_4:RegisterNamespace("ns1")

			db_4.profile.foo = "bar"
			db_4:SetProfile("foo")

			self:RegisterEvent("PLAYER_LOGOUT", function()
				-- testcase1
				Ace3testDBLogout = 0
				assert(not TestDB.char)
				Ace3testDBLogout = 1
				assert(TestDB.profiles.Test)
				Ace3testDBLogout = 2
				assert(TestDB.realm.SomeRealm.notEmpty)
				Ace3testDBLogout = 3
				assert(not TestDB.namespaces.Space.profiles)
				Ace3testDBLogout = 4

				-- testcase2
				assert(db.profile.singleEntry == nil)
				Ace3testDBLogout = 5
				assert(db.profile.tableEntry == nil)
				Ace3testDBLogout = 6
				assert(db.profile.starTest == nil)	-- all fields use default value
				Ace3testDBLogout = 7
				assert(db.profile.doubleStarTest == nil)	-- all fields use default value
				Ace3testDBLogout = 8
				assert(db.profile.starTest2.randomkey == "notfun")
				Ace3testDBLogout = 9
				assert(db.profile.starTest2.randomkey2 == nil)	-- use default value
				Ace3testDBLogout = 10
				assert(db.profile.starTest2.sibling == "fun")

				-- testcase3
				Ace3testDBLogout = 11
				local data2 = LibStub("AceDB-3.0"):New(bugdb, defaultTest)
				Ace3testDBLogout = 12
				assert(data2.profile.boo[true] == "not so true")
				Ace3testDBLogout = 13
				assert(data2.profile.boo[false] == "not so false")
				Ace3testDBLogout = 14

				-- testcase4
				local db_lo4 = LibStub("AceDB-3.0"):New(dbtbl_4, nil, "foo")
				local ns_lo4 = db_lo4:RegisterNamespace("ns1")
				db_lo4:DeleteProfile("bar")

				Ace3testDBLogout = true
			end)
		end
	else
		self:Print("|cFFFFFF00Please reload and test again")
	end

	self:TestEnd("AceDB")
end