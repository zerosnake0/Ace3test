local AceGUI = LibStub("AceGUI-3.0")

local tgetn = table.getn
local strfind = string.find
local strlen = string.len
local tconcat = table.concat

local function print(a,b,c,d)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(a)..','..tostring(b)..','..tostring(c)..','..tostring(d))
end

local function ZOMGConfig(widget, event)
	AceGUI:Release(widget.userdata.parent)

	local f = AceGUI:Create("Frame")

	f:SetCallback("OnClose", function(widget, event) print("Closing") AceGUI:Release(widget) end )
	f:SetTitle("ZOMG Config!")
	f:SetStatusText("Status Bar")
	f:SetLayout("Fill")

	local maingroup = AceGUI:Create("DropdownGroup")
	maingroup:SetLayout("Fill")
	maingroup:SetGroupList({Addons = "Addons !!", Zomg = "Zomg Addons"})
	maingroup:SetGroup("Addons")
	maingroup:SetTitle("")

	f:AddChild(maingroup)

	--local tree = { "A", "B", "C", "D", B = { "B1", "B2", B1 = { "B11", "B12" } }, C = { "C1", "C2", C1 = { "C11", "C12" } } }
	--local text = { A = "Option 1", B = "Option 2", C = "Option 3", D = "Option 4", J = "Option 10", K = "Option 11", L = "Option 12",
	--				B1 = "Option 2-1", B2 = "Option 2-2", B11 = "Option 2-1-1", B12 = "Option 2-1-2",
	--				C1 = "Option 3-1", C2 = "Option 3-2", C11 = "Option 3-1-1", C12 = "Option 3-1-2" }
	local tree = {
			{
				value = "A",
				text = "Option 1"
			},
			{
				value = "B",
				text = "Option 2",
				children = {
					{
						value = "B1",
						text = "Option 2-1",
						children = {
							{
								value = "B11",
								text = "Option 2-1-1",
							},
							{
								value = "B12",
								text = "Option 2-1-2",
							},
						}
					},
					{
						value = "B2",
						text = "Option 2-2",
					},
				}
			},
			{
				value = "C",
				text = "Option 3",
				children = {
					{
						value = "C1",
						text = "Option 3-1",
						children = {
							{
								value = "C11",
								text = "Option 3-1-1",
							},
							{
								value = "C12",
								text = "Option 3-1-2",
							},
						}
					},
					{
						value = "C2",
						text = "Option 2-2",
					},
				}
			},
			{
				value = "D",
				text = "Option 4"
			},
		}
	local t = AceGUI:Create("TreeGroup")
	t:SetLayout("Fill")
	--t:SetTree(tree, text)
	maingroup:AddChild(t)

	local tab = AceGUI:Create("TabGroup")
	tab:SetTabs({"A","B","C","D"},{A="Yay",B="We",C="Have",D="Tabs"})
	tab:SetLayout("Fill")
	tab:SelectTab(1)
	t:AddChild(tab)

	local component = AceGUI:Create("DropdownGroup")
	component:SetLayout("Fill")
	component:SetGroupList({Blah = "Blah", Splat = "Splat"})
	component:SetGroup("Blah")
	component:SetTitle("Choose Componet")

	tab:AddChild(component)

	local more = AceGUI:Create("DropdownGroup")
	more:SetLayout("Fill")
	more:SetGroupList({ButWait = "But Wait!", More = "Theres More"})
	more:SetGroup("More")
	more:SetTitle("And More!")

	component:AddChild(more)

	local sf = AceGUI:Create("ScrollFrame")
	sf:SetLayout("Flow")
	more:AddChild(sf)
	local stuff = AceGUI:Create("Heading")
	stuff:SetText("Omg Stuff Here")
	stuff.width = "fill"
	sf:AddChild(stuff)

	for i = 1, 10 do
		local edit = AceGUI:Create("EditBox")
		edit:SetText("")
		edit:SetWidth(200)
		edit:SetLabel("Stuff!")
		edit:SetCallback("OnEnterPressed",function(widget,event,_,text) widget:SetLabel(text) end )
		edit:SetCallback("OnTextChanged",function(widget,event,_,text) print(text) end )
		sf:AddChild(edit)
	end

	f:Show()
end

local function GroupA(content)
	content:ReleaseChildren()

	local sf = AceGUI:Create("ScrollFrame")
	sf:SetLayout("Flow")

	local edit = AceGUI:Create("EditBox")
	edit:SetText("Testing")
	edit:SetWidth(200)
	edit:SetLabel("Group A Option")
	edit:SetCallback("OnEnterPressed",function(widget,event,_,text) widget:SetLabel(text) end )
	edit:SetCallback("OnTextChanged",function(widget,event,_,text) print(text) end )
	sf:AddChild(edit)

	local slider = AceGUI:Create("Slider")
	slider:SetLabel("Group A Slider")
	slider:SetSliderValues(0,1000,5)
	slider:SetDisabled(false)
	sf:AddChild(slider)

	local zomg = AceGUI:Create("Button")
	zomg.userdata.parent = content.userdata.parent
	zomg:SetText("Zomg!")
	zomg:SetCallback("OnClick", ZOMGConfig)
	sf:AddChild(zomg)

	local heading1 = AceGUI:Create("Heading")
	heading1:SetText("Heading 1")
	heading1.width = "fill"
	sf:AddChild(heading1)

	for i = 1, 5 do
		local radio = AceGUI:Create("CheckBox")
		radio:SetLabel("Test Check "..i)
		radio:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "Check "..i.." Checked" or "Check "..i.." Unchecked") end )
		sf:AddChild(radio)
	end

	local heading2 = AceGUI:Create("Heading")
	heading2:SetText("Heading 2")
	heading2.width = "fill"
	sf:AddChild(heading2)

	for i = 1, 5 do
		local radio = AceGUI:Create("CheckBox")
		radio:SetLabel("Test Check "..i+5)
		radio:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "Check "..i.." Checked" or "Check "..i.." Unchecked") end )
		sf:AddChild(radio)
	end

	local heading1 = AceGUI:Create("Heading")
	heading1:SetText("Heading 1")
	heading1.width = "fill"
	sf:AddChild(heading1)

	for i = 1, 5 do
	    local radio = AceGUI:Create("CheckBox")
	    radio:SetLabel("Test Check "..i)
	    radio:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "Check "..i.." Checked" or "Check "..i.." Unchecked") end )
	    sf:AddChild(radio)
	end

	local heading2 = AceGUI:Create("Heading")
	heading2:SetText("Heading 2")
	heading2.width = "fill"
	sf:AddChild(heading2)

	for i = 1, 5 do
	    local radio = AceGUI:Create("CheckBox")
	    radio:SetLabel("Test Check "..i+5)
	    radio:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "Check "..i.." Checked" or "Check "..i.." Unchecked") end )
	    sf:AddChild(radio)
	end

	content:AddChild(sf)
end

local function GroupB(content)
	content:ReleaseChildren()
	local sf = AceGUI:Create("ScrollFrame")
	sf:SetLayout("Flow")

	local check = AceGUI:Create("CheckBox")
	check:SetLabel("Group B Checkbox")
	check:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "Checked" or "Unchecked") end )

	local dropdown = AceGUI:Create("Dropdown")
	dropdown:SetText("Test")
	dropdown:SetLabel("Group B Dropdown")
	dropdown:SetList({"Test","Test2"})
	dropdown:SetCallback("OnValueChanged",function(widget,event,_,value) print(value) end )

	sf:AddChild(check)
	sf:AddChild(dropdown)
	content:AddChild(sf)
end

local function OtherGroup(content)
	content:ReleaseChildren()

	local sf = AceGUI:Create("ScrollFrame")
	sf:SetLayout("Flow")

	local check = AceGUI:Create("CheckBox")
	check:SetLabel("Test Check")
	check:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "CheckButton Checked" or "CheckButton Unchecked") end )

	sf:AddChild(check)

	local inline = AceGUI:Create("InlineGroup")
	inline:SetLayout("Flow")
	inline:SetTitle("Inline Group")
	inline.width = "fill"

	local heading1 = AceGUI:Create("Heading")
	heading1:SetText("Heading 1")
	heading1.width = "fill"
	inline:AddChild(heading1)

	for i = 1, 10 do
		local radio = AceGUI:Create("CheckBox")
		radio:SetLabel("Test Radio "..i)
		radio:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "Radio "..i.." Checked" or "Radio "..i.." Unchecked") end )
		radio:SetType("radio")
		inline:AddChild(radio)
	end

	local heading2 = AceGUI:Create("Heading")
	heading2:SetText("Heading 2")
	heading2.width = "fill"
	inline:AddChild(heading2)

	for i = 1, 10 do
		local radio = AceGUI:Create("CheckBox")
		radio:SetLabel("Test Radio "..i)
		radio:SetCallback("OnValueChanged",function(widget,event,_,value) print(value and "Radio "..i.." Checked" or "Radio "..i.." Unchecked") end )
		radio:SetType("radio")
		inline:AddChild(radio)
	end

	sf:AddChild(inline)
	content:AddChild(sf)
end

local function SelectGroup(widget, event, _, value)
	if value == "A" then
		GroupA(widget)
	elseif value == "B" then
		GroupB(widget)
	else
		OtherGroup(widget)
	end
end


local function TreeWindow(content)
	content:ReleaseChildren()

	local tree = {
			{
				value = "A",
				text = "Alpha"
			},
			{
				value = "B",
				text = "Bravo",
				children = {
					{
						value = "C",
						text = "Charlie",
					},
					{
						value = "D",
						text = "Delta",
						children = {
							{
								value = "E",
								text = "Echo",
							}
						}
					},
				}
			},
			{
				value = "F",
				text = "Foxtrot",
			},
		}
	local t = AceGUI:Create("TreeGroup")
	t.userdata.parent = content.userdata.parent
	t:SetLayout("Fill")
	t:SetTree(tree)
	t:SetCallback("OnGroupSelected", SelectGroup )
	content:AddChild(t)
	SelectGroup(t,"OnGroupSelected",1,"A")
end

local function TabWindow(content)
	content:ReleaseChildren()
	local tab = AceGUI:Create("TabGroup")
	tab.userdata.parent = content.userdata.parent
	tab:SetTabs({"A","B","C","D"},{A="Alpha",B="Bravo",C="Charlie",D="Deltaaaaaaaaaaaaaa"})
	tab:SetTitle("Tab Group")
	tab:SetLayout("Fill")
	tab:SetCallback("OnGroupSelected",SelectGroup)
	tab:SelectTab(1)
	content:AddChild(tab)
end

function TestFrame()
	local f = AceGUI:Create("Frame")
	f:SetCallback("OnClose",function(widget, event) print("Closing") AceGUI:Release(widget) end )
	f:SetTitle("AceGUI Prototype")
	f:SetStatusText("Root Frame Status Bar")
	f:SetLayout("Fill")

	local maingroup = AceGUI:Create("DropdownGroup")
	maingroup.userdata.parent = f
	maingroup:SetLayout("Fill")
	maingroup:SetGroupList({Tab = "Tab Frame", Tree = "Tree Frame"})
	maingroup:SetGroup("Tab")
	maingroup:SetTitle("Select Group Type")
	maingroup:SetCallback("OnGroupSelected", function(widget, event, _, value)
		widget:ReleaseChildren()
		if value == "Tab" then
			TabWindow(widget)
		else
			TreeWindow(widget)
		end
	end)

	TabWindow(maingroup)
	f:AddChild(maingroup)
	f:Show()
end

-----------------------
-- DragTarget Widget --
-----------------------
-- Designed to replace type='input' in AceConfigDialog-3.0
do
	local Type = "DragTarget"
	local Version = 1
	local function OnAcquire(self)

	end

	local function Release(self)
		self.frame:ClearAllPoints()
		self.frame:Hide()
	end


	local function SetLabel(self, text)
		self.label:SetText(text)
	end

	local function PickupItem(link)
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local slotlink = GetContainerItemLink(bag, slot)
				if link == slotlink then
					return PickupContainerItem(bag, slot)
				end
			end
		end
	end

	local function GetSpellIndexByName(name)
		for tabIndex = 1, MAX_SKILLLINE_TABS do
			local tabname, texture, offset, numspells = GetSpellTabInfo(tabIndex)
			if not tabname then break end
			for s = offset+1, offset+numspells do
				local spell, rank = GetSpellName(s, BOOKTYPE_SPELL)
				if rank ~= "" then spell = spell.."("..rank..")" end
				if spell == name then
					return s, BOOKTYPE_SPELL
				end
			end
		end
		local i = 1
		while true do
			local spell, rank = GetSpellName(i, BOOKTYPE_PET)
			if not spell then break end
			if rank ~= "" then spell = spell.."("..rank..")" end
			if spell == name then
				return i, BOOKTYPE_PET
			end
			i = i + 1
		end
	end

	local function GetMacroIndexByName(name)
		for i=1,36 do
			local macro, texture = GetMacroInfo(i)
			if name == macro then
				return i, texture
			end
		end
	end

	local function DragLinkOnDragStart()
		local self = this.obj
		if (self.objType == "item") then
			PickupItem(self.value)
		elseif (self.objType == "spell") then
			local id, book = GetSpellIndexByName(self.value)
			if not id then return end
			PickupSpell(id, book)
		elseif (self.objType == "macro") then
			local id = GetMacroIndexByName(strsub(self.value,7))
			if not id then return end
			PickupMacro(id)
		end
		self:SetText("")
		self:Fire("OnEnterPressed", 1, self.value)
	end

	local function DragLinkGetTexture(self)
		if (self.objType == "item") then
			local _,_,t = strfind(self.value,"|Hitem:(%d+):")
			_,_,_,_,_,_,_,_,t = GetItemInfo(t)
			if t then
				return t
			end
		elseif (self.objType == "spell") then
			local index, book = GetSpellIndexByName(self.value)
			if index and book then
				return GetSpellTexture(index, book)
			end
		elseif (self.objType == "macro") then
			local _, texture = GetMacroIndexByName(strsub(self.value,7))
			if texture then
				return texture
			end
		end
		return "Interface\\Icons\\INV_Misc_QuestionMark"
	end

	local function GetValueFromParams(objType, Info1, Info2)
		if objType == "item" then
			--for items use the itemlink
			return Info2
		elseif objType == "spell" then
			local name, rank = GetSpellName(Info1, Info2)
			if rank ~= "" then name = name.."("..rank..")" end
			return name
		elseif objType == "macro" then
			return "macro:"..GetMacroInfo(Info1)
		end
	end

	local function DragLinkOnReceiveDrag()
		if not GetCursorInfo then return end
		local self = this.obj

		local objType, Info1, Info2 = GetCursorInfo()

		if (objType == "item" or objType == "spell" or objType == "macro") then
			self.objType = objType
			self.value = GetValueFromParams(objType, Info1, Info2)
			self:Fire("OnEnterPressed", 1, self.value)
			self.linkIcon:SetTexture(DragLinkGetTexture(self))
			ClearCursor()
		end
	end

	local function SetText(self, text)
		if not text then text = "" end
		if strfind(text, "item:%d+") then
			self.objType = "item"
			self.value = text
		elseif strsub(text,1,6) == "macro:" then
			self.objType = "macro"
			self.value = text
		elseif text ~= "" then
			self.objType = "spell"
			self.value = text
		else
			self.objType = nil
			self.value = ""
		end
		self.linkIcon:SetTexture(DragLinkGetTexture(self))
		self.text:SetText(self.value or "")
	end

	local function SetDisabled(self, disabled)

	end

	local function Constructor()
		local frame = CreateFrame("Button",nil,UIParent)
		local self = {}
		self.type = Type


		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire
		self.SetLabel = SetLabel
		self.SetText = SetText
		self.SetDisabled = SetDisabled
		self.UpdateValue = UpdateValue

		self.frame = frame
		frame.obj = self

		frame:SetScript("OnDragStart", DragLinkOnDragStart)
		frame:SetScript("OnReceiveDrag", DragLinkOnReceiveDrag)
		frame:SetScript("OnClick", DragLinkOnReceiveDrag)
		frame:SetScript("OnEnter", DragLinkOnEnter)
		frame:SetScript("OnLeave", DragLinkOnLeave)

		frame:EnableMouse()
		frame:RegisterForDrag("LeftButton")
		frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		local linkIcon = frame:CreateTexture(nil, "OVERLAY")
		linkIcon:SetWidth(self.iconWidth or 36)
		linkIcon:SetHeight(self.iconHeight or 36)
		linkIcon:SetPoint("LEFT",frame,"LEFT",0,0)
		linkIcon:SetTexture(DragLinkGetTexture(self))
		linkIcon:SetTexCoord(0,1,0,1)
		linkIcon:Show()
		self.linkIcon = linkIcon

		local label = frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
		label:SetPoint("TOPLEFT",linkIcon,"TOPRIGHT",3,-3)
		label:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
		label:SetHeight(10)
		label:SetJustifyH("LEFT")
		self.label = label

		local text = frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
		text:SetPoint("BOTTOMLEFT",linkIcon,"BOTTOMRIGHT",3,3)
		text:SetPoint("RIGHT",frame,"RIGHT",0,0)
		text:SetHeight(10)
		text:SetTextColor(1,1,1,1)
		text:SetJustifyH("LEFT")
		self.text = text

		text:SetJustifyH("LEFT")
		text:SetTextColor(1,1,1)

		frame:SetHeight(36)
		frame:SetWidth(200)

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(Type,Constructor,Version)

end

local name = "ConfigTest"
local groups = {}
local testgroups = {
	type = "group",
	name = "Test Group Delete/Hide/Disabled",
	childGroups = "select",
	args = {

	}
}

local function Delete(info)
  testgroups.args[info.arg] = nil
end

local function Disable(info)
  testgroups.args[info.arg].disabled = true
end

local function Hide(info)
  testgroups.args[info.arg].hidden = true
end

local function Replace(info)
	testgroups.args[info.arg] = {
		type = "execute",
		name = "Replaced"..info.arg
	}
end

groups.description = {
	type = 'description',
	name = 'This is a test Description Icon + Width and height from a function, no coords',
	image = function() return "Interface\\Icons\\Temp.blp", 100, 100 end,
	--imageCoords = { 0, 0.5, 0, 0.5 },
	order = 1,
}
--[[
groups.description2 = {
	type = 'description',
	name = 'This is a test Description Image + width and height directly set',
	image = "Interface\\Icons\\Temp.blp",
	imageCoords = { 0, 0.5, 0, 0.5 },
	imageWidth = 100,
	imageHeight = 100,
	order = 2,
}

groups.description3 = {
	type = 'description',
	name = '',
	image = function() return "Interface\\Icons\\Temp.blp", 100, 100 end,
	--imageCoords = { 0, 0.5, 0, 0.5 },
	order = 3,
}
--]]
groups.confirm = {
	type = 'execute',
	name = 'Test Confirm',
	order = 15,
	func = function() print("Confirmed") end,
	confirm = true,
	confirmText = "Confirm Prompt",
}

local dragvalue = nil

groups.customDrag = {
	type = 'input',
	name = 'Test Custom Control',
	get = function() return dragvalue end,
	set = function(info, ...)
		local value = arg[1]
		dragvalue = value
	end,
	dialogControl = "DragTarget",
	order = 16,
}


for i = 1, 5 do
	testgroups.args["group"..i] = {
		order = i,
		type = "group",
		name = "Group"..i,
		args = {
			delete = {
				name = "Delete",
				desc = "Delete this group",
				type = "execute",
				arg = "group"..i,
				func = Delete,
			},
			disable = {
				name = "Disable",
				desc = "Disable this group",
				type = "execute",
				arg = "group"..i,
				func = Disable,
			},
			hide = {
				name = "Hide",
				desc = "Hide this group",
				type = "execute",
				arg = "group"..i,
				func = Hide,
			},
			replace = {
				name = "Replace",
				desc = "Replace this group",
				type = "execute",
				arg = "group"..i,
				func = Replace,
			},
		}
	}
end

local m = { }

groups.multi = {
	type = 'multiselect',
	name = 'multi',
	desc = 'Test Multiselect',
	tristate = true,
	width = "half",
	set = function(info, key, value) m[key] = value print(key, value) end,
	get = function(info, key) return m[key] end,
	order = 100,
	values = {
		a = "Alpha",
		b = "Bravo",
		c = "Charlie",
		d = "Delta",
		e = "Echo",
		f = "Foxtrot",
	}
}

local sel = 'a'

groups.select = {
	type = 'select',
	name = 'select',
	desc = 'Test Select',
	set = function(info, key, value) sel = key print(sel) end,
	get = function(info, key) return sel end,
	order = 101,
	values = {
		a = "Alpha",
		b = "Bravo",
		c = "Charlie",
		d = "Delta",
		e = "Echo",
		f = "Foxtrot",
	}
}

local toggleval

groups.toggle = {
	type = 'toggle',
	name = 'toggle',
	desc = 'Test Toggle',
	set = function(info, value) toggleval = value print(toggleval) end,
	get = function(info) return toggleval end,
	tristate = true,
	order = 102
}

local R,G,B,A = 1.0,1.0,1.0,1.0

groups.color = {
	type = 'color',
	name = 'color',
	desc = 'Test Color',
	set = function(info, r,g,b,a) R,G,B,A = r,g,b,a print(R,G,B,A) end,
	get = function(info) return R,G,B,A end,
	hasAlpha = false,
	order = 103
}

groups.colora = {
	type = 'color',
	name = 'colora',
	desc = 'Test Color with Alpha',
	set = function(info, r,g,b,a) R,G,B,A = r,g,b,a print(R,G,B,A) end,
	get = function(info) return R,G,B,A end,
	hasAlpha = true,
	order = 104
}

local keyval
groups.key = {
	type = 'keybinding',
	name = 'key',
	desc = 'Test Keybind',
	set = function(info, value) keyval = value print(keyval) end,
	get = function(info) return keyval end,
	order = 105,
}

local mval = "abcdefg"
groups.multiline = {
	type = 'input',
	name = "Multiline",
	desc = "Test Multiline",
	set = function(info, value) mval = value print(mval) end,
	get = function(info) return mval end,
	multiline = true,
}

local options = {
	type = "group",
	name = name,
	childGroups = "tab",
	args = {
		test = {
			type = "group",
			name = "Test Controls",
			args = groups,
			disabled = false
		}
	}
}

local types = {'input', 'toggle', 'select', 'multiselect', 'range', 'keybinding', 'execute', 'color'}
local function GetTestOpts(disabled)
	local values = { input = "Test", select = 'a', multiselect = true, range = 1}
	if disabled then
		values.input = "Disabled Test"
	end
	local group = {
		type = "group",
		--inline = true,
		name = "Options",
		set = function(info, value)
			values[info[tgetn(info)]] = value
		end,
		get = function(info, value)
			return values[info[tgetn(info)]]
		end,
		args = {},
	}

	if disabled then
		group.name = "Disabled Options"
	end

	for i, t in ipairs(types) do
		local opt = {}
		opt.name = t
		opt.type = t
		opt.desc = "Test "..t
		opt.order = i
		opt.disabled = disabled
		if t == "select" or t == "multiselect" then
			opt.values = {
				a = "Alpha",
				b = "Bravo",
				c = "Charlie",
				d = "Delta",
				e = "Echo",
				f = "Foxtrot",
			}
		end

		if t == "multiselect" then
			opt.set = function(info, key, value)
				local optk = info[tgetn(info)]
				local optv = values[optk]
				if type(optv) ~= "table" then
					local t = {}
					for k in opt.values do
						t[k] = optv
					end
					values[optk] = t
				end
				values[optk][key] = value
			end
			opt.get = function(info, value)
				local v = values[info[tgetn(info)]]
				if type(v) == "table" then
					return v[value]
				else
					return v
				end
			end
		end

		if t == "color" then
			opt.set = function(info, r,g,b,a)
				local k = info[tgetn(info)]
				values[k] = values[k] or {}
				k = values[k]
				k.r = r
				k.g = g
				k.b = b
				k.a = a
			end
			opt.get = function(info, ...)
				local k = values[info[tgetn(info)]]
				if type(k) == "table" then
					return k.r, k.g, k.b, k.a
				else
					return k, k, k, k
				end
			end
		end

		if t == "range" then
			opt.min = 0
			opt.max = 1000
			opt.step = 1
			opt.bigStep = 10
		end

		if t == "execute" then
			opt.func = function(info) print("Execute") end
		end

		group.args[t] = opt
	end
	return group
end

options.plugins = {}
options.plugins.normal = { normal = GetTestOpts() }
options.plugins.disabled = { disabled = GetTestOpts(true) }
options.plugins.test = { testgroups = testgroups }


LibStub("AceConfig-3.0").RegisterOptionsTable(nil, name, options, "ct")
--LibStub("AceConfigDialog-3.0"):Open("ConfigTest")
