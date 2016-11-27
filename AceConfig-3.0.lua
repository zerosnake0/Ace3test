local LibStub = LibStub
local AceConfig = assert(LibStub("AceConfig-3.0"))
local AceConfigCmd = assert(LibStub("AceConfigCmd-3.0"))
local AceConfigRegistry = assert(LibStub("AceConfigRegistry-3.0"))
-- Ace3v: currently unable to test, need to test with AceGUI
--local AceConfigDialog = assert(LibStub("AceConfigDialog-3.0"))

local tgetn = table.getn

local v

local set_called
local function set_base(info, ...)
	set_called = set_called + 1
	assert(type(info) == "table")
	assert(tgetn(info) >= 1)
	assert(tgetn(arg) == 1)
	v = arg[1]
end

local get_called
local function get_base(info, ...)
	get_called = get_called + 1
	assert(type(info) == "table")
	assert(tgetn(info) >= 1)
	assert(tgetn(arg) == 0)
	return v
end

local validate_called
local function validate_base(info, ...)
	validate_called = validate_called + 1
	assert(type(info) == "table")
	assert(tgetn(info) >= 1)
	assert(tgetn(arg) == 1)
	assert(v == true or v == false or v == nil)
end

local app = {}
function app:get_toggle(info, ...)
	assert(self==app)
	assert(tgetn(arg)==0)
	get_called = get_called + 1
	return v
end

function app:set_toggle(info, ...)
	assert(self==app, "Expected self=="..tostring(app)..", got "..tostring(self))
	assert(tgetn(arg)==1)
	set_called = set_called + 1
	v = arg[1]
end

local function exe(info, ...)
	assert(tgetn(arg) == 0)
	v = true
end

local opt = {
	type = "group",
	set = set_base,
	get = get_base,
	validate = validate_base,
	args = {
		input = {
			name = "input",
			desc = "input desc",
			type = "input",
			validate = false,
		},
		toggle = {
			name = "toggle depth 1",
			desc = "toggle depth 1",
			type = "toggle",
			handler = app,
			get = "get_toggle",
			set = "set_toggle",
		},
		execute = {
			type = "execute",
			name = "Execute",
			validate = false,
			descStyle = "inline",
			confirm = true,
			func = exe,
		},
		plugcmd = {	-- this should never be used, we should use the plugin!
			name="PlugCmdOrig",
			desc="YOU SHOULD NOT SEE THIS",
			type="toggle",
			set = function() assert(false) end,
			get = function() assert(false) end,
		},
		moreoptions = {
			name = "More Options",
			type = "group",
			args = {
				-- more options go here
				toggle = {
					name = "tristate toggle depth 2",
					desc = "tristate toggle depth 2",
					type = "toggle",
					tristate = true,
				}
			}
		}
	},
	plugins = {	-- test plugins
		plugin1 = {
			plugcmd = {
				name="PluggedCmd",
				desc="Woohoo",
				type="toggle",
			},
			plugcmd2 = {
				name="PluggedCmd2",
				desc="WooTwo",
				type="toggle",
			}
		},
		plugin2 = {
			-- empty, shouldnt cause errors
		},
		plugin3 = {
			p3cmd = {
				name="Plugin3Cmd",
				desc="WooThree",
				type="toggle",
			},
		}
	}
}

local function reset()
	set_called = 0
	get_called = 0
	validate_called = 0
	v = nil
end

function Ace3test:TestAceConfig()
	self:TestBegin("AceConfig")
	assert(AceConfig)

	local slash_cmd = "A3TOPT"
	-- the registered app name must be like "mylib-1.0"
	local app_name = "Ace3test-1.0"
	AceConfig:RegisterOptionsTable(app_name, opt, slash_cmd)
	
	
	local handler = SlashCmdList["ACECONSOLE_" .. slash_cmd]

	-- input
	self:Print("> Test input")
	reset()
	handler("input abc")
	assert(v == "abc")
	assert(set_called == 1)
	assert(get_called == 0)
	assert(validate_called == 0)
	
	-- execute
	self:Print("> Test execute")
	reset()
	handler("execute blabla")
	assert(v == true)
	
	-- toggle
	self:Print("> Test toggle depth 1")

	reset()
	handler("toggle")
	assert(v == true)
	handler("toggle")
	assert(v == false)
	handler("toggle on")
	assert(v == true)
	handler("toggle off")
	assert(v == false)
	handler("toggle invalid")
	assert(v == false)
	
	assert(set_called == 4)
	assert(get_called == 2)
	assert(validate_called == 4)
	
	-- toggle inside
	self:Print("> Test toggle depth 2")

	reset()
	handler("moreoptions toggle")
	assert(v == false)
	handler("moreoptions toggle")
	assert(v == true)
	handler("moreoptions toggle")
	assert(v == nil)
	handler("moreoptions toggle on")
	assert(v == true)
	handler("moreoptions toggle off")
	assert(v == false)
	handler("moreoptions toggle invalid")
	assert(v == false)
	
	assert(set_called == 5)
	assert(get_called == 3)
	assert(validate_called == 5)
	
	-- plugin
	self:Print("> Test plugin")
	
	reset()
	handler("plugcmd")
	assert(v == true)
	handler("plugcmd")
	assert(v == false)
	handler("plugcmd2 on")
	assert(v == true)
	handler("plugcmd2 off")
	assert(v == false)
	handler("p3cmd invalid")
	assert(v == false)
	
	assert(set_called == 4)
	assert(get_called == 2)
	assert(validate_called == 4)
	
	
	self:TestEnd("AceConfig")
end