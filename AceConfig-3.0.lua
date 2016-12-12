local LibStub = LibStub
local AceConfig = assert(LibStub("AceConfig-3.0"))
local AceConfigCmd = assert(LibStub("AceConfigCmd-3.0"))
local AceConfigRegistry = assert(LibStub("AceConfigRegistry-3.0"))
-- Ace3v: currently unable to test, need to test with AceGUI
--local AceConfigDialog = assert(LibStub("AceConfigDialog-3.0"))

local tgetn = table.getn
local strtrim = strtrim

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

local select_opts = {a=1,b=2,c=3}
function Ace3test:select()
	return select_opts
end

local select_item
function Ace3test:select_get(info, ...)
	assert(tgetn(arg) == 0)
	return select_item
end

function Ace3test:select_set(info, ...)
	assert(tgetn(arg) == 1)
	assert(select_opts[arg[1]])
	select_item = arg[1]
end

function Ace3test:multiselect()
	return select_opts
end

local multiselect_item = {}
function Ace3test:multiselect_get(info, ...)
	assert(tgetn(arg) == 1)
	assert(select_opts[arg[1]])
	return multiselect_item[arg[1]]
end

function Ace3test:multiselect_set(info, ...)
	assert(tgetn(arg) == 2)
	assert(select_opts[arg[1]])
	multiselect_item[arg[1]] = arg[2]
end

local color = {}
local function color_get(info, ...)
	-- coding not finished yet in AceConfigCmd
	--for k,v in arg do
	--	dbg(k,v)
	--end
end

local function color_set(info, ...)
	assert(tgetn(arg) == 4)
	for i=1,tgetn(arg) do
		assert(arg[i] >= 0 and arg[i] <= 1)
		color[i] = arg[i]
	end
end

local keybinding_val
local function keybinding_set(info, ...)
	assert(tgetn(arg) == 1)
	keybinding_val = arg[1]
end

local range_v
local range_min
local range_max
local range_step

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
			handler = app,	-- with handler
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
		},
		-- range
		range = {
			name = "Range",
			type = "range",
			-- the current setting is for number only
			--min = function() return range_min end,
			--max = function() return range_max end,
			--step = function() return range_step end,
			min = 1,
			max = 10,
			step = 2,
			--get = 	-- coding not finished yet in AceConfigCmd
			set = function(info, ...)
				assert(tgetn(arg) == 1)
				range_v = arg[1]
			end,
			validate = false,
		},
		-- select
		select = {
			name = "Select",
			type = "select",
			values = "select",
			get = "select_get",
			set = "select_set",
			validate = false,
		},
		-- multiselect
		multiselect = {
			name = "Multiselect",
			type = "multiselect",
			values = "multiselect",
			get = "multiselect_get",
			set = "multiselect_set",
			validate = false,
		},
		-- color
		rgb = {
			name = "RGB",
			type = "color",
			validate = false,
			get = color_get,
			set = color_set,
			hasAlpha = false,
		},
		rgba = {
			name = "RGBA",
			type = "color",
			validate = false,
			hasAlpha = true,
			--get = color_get,	-- coding not finished yet in AceConfigCmd
			set = color_set,
		},
		-- keybinding
		keybinding = {
			name = "Keybinding",
			type = "keybinding",
			validate = false,
			--get = nil,	-- coding not finished yet in AceConfigCmd
			set = keybinding_set,
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
				desc="YOU SHOULD NOT SEE THIS",
				type="toggle",
				hidden=true,
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
	},
}

local function reset()
	set_called = 0
	get_called = 0
	validate_called = 0
	v = nil
	select_item = nil
	for k,v in select_opts do
		multiselect_item[k] = nil
	end
	for i=1,4 do
		color[i] = nil
	end
	keybinding_val = nil
	range_min = 5
	range_max = 10
	range_step = 1
	range_v = nil
end

local slash_cmd = "A3TOPT"
-- the registered app name must be like "mylib-1.0"
local app_name = "Ace3testDB-1.0"

function Ace3test:A3TOPT(input, a1, a2)
	assert(a1 == slash_cmd)
	assert(a2 == app_name)
	-- Ace3v: currently unable to test, need to test with AceGUI
	--if not input or strtrim(input) == "" then
	--	AceConfigDialog:Open("MyOptions")
	--else
		self:HandleCommand(slash_cmd, app_name, input)
	--end
end

function Ace3test:TestAceConfig()
	self:TestBegin("AceConfig")
	assert(AceConfig)

	-- There are two ways of registering
	-- 1. use RegisterOptionsTable, the handler is AceConfigCmd.HandleCommand
	--self:RegisterOptionsTable(app_name, opt, slash_cmd)

	-- 2. use RegisterOptionsTable with CreateChatCommand, we can define our
	--    own handler
	self:RegisterOptionsTable(app_name, opt)
	self:CreateChatCommand(slash_cmd, app_name, slash_cmd)


	assert(AceConfigCmd:GetChatCommandOptions(slash_cmd) == app_name)

	local handler = assert(SlashCmdList["ACECONSOLE_" .. slash_cmd])
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
	self:HandleCommand(slash_cmd, app_name, "execute blabla") -- test with self
	assert(v == true)

	-- toggle
	self:Print("> Test toggle (with handler)")

	reset()
	handler("toggle")	-- test with slash handler
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
	self:Print("> Test toggle (subcommand)")

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

	-- range
	self:Print("> Test range")
	reset()
	handler("range")
	assert(range_v == nil)
	handler("range 1")
	assert(range_v == 1)
	handler("range 2")
	assert(range_v == 1)
	handler("range 5")
	assert(range_v == 5)
	handler("range 10")
	assert(range_v == 9)
	handler("range 11")
	assert(range_v == 9)

	-- select
	self:Print("> Test select")

	reset()
	handler("select")
	assert(select_item == nil)
	handler("select a")
	assert(select_item == "a")
	handler("select b")
	assert(select_item == "b")
	handler("select c")
	assert(select_item == "c")
	handler("select d")
	assert(select_item == "c")

	-- multiselect
	self:Print("> Test multiselect")

	reset()
	handler("multiselect")
	for k,v in select_opts do
		assert(multiselect_item[k] == nil)
	end
	handler("multiselect a")
	handler("multiselect b")
	handler("multiselect c")
	for k,v in select_opts do
		assert(multiselect_item[k])
	end
	handler("multiselect a b c")
	for k,v in select_opts do
		assert(not multiselect_item[k])
	end

	-- color
	self:Print("> Test color")

	reset()
	handler("rgb")
	for i=1,4 do
		assert(color[i] == nil)
	end
	handler("rgb ffffff")
	for i=1,4 do
		assert(color[i] == 1)
	end
	handler("rgb 000000")
	for i=1,3 do
		assert(color[i] == 0)
	end
	assert(color[4] == 1)

	reset()
	handler("rgba")
	for i=1,4 do
		assert(color[i] == nil)
	end
	handler("rgba ffffffff")
	for i=1,4 do
		assert(color[i] == 1)
	end
	handler("rgba 00000000")
	for i=1,4 do
		assert(color[i] == 0)
	end

	-- keybinding
	self:Print("> Test keybinding")

	reset()
	handler("keybinding")
	assert(keybinding_val == nil)
	handler("keybinding k")
	assert(keybinding_val == 'K')
	handler("keybinding ctrl-r")
	assert(keybinding_val == 'CTRL-R')
	handler("keybinding ctrl-alt-b")
	assert(keybinding_val == 'ALT-CTRL-B')
	handler("keybinding ctrl-alt-shift-J")
	assert(keybinding_val == 'ALT-CTRL-SHIFT-J')

	self:TestEnd("AceConfig")
end