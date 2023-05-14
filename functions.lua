--[[

**** M **** E **** N **** U ****

U N D O

M A T H

S T R I N G S

T A B L E S

M I D I

(R E) S T O R E

T R A C K S

F O L D E R S

E N V E L O P E S

A U T O M A T I O N  I T E M S

C H U N K

F X

I T E M S

C O L O R

C L O S U R E S

M A R K E R S  &  R E G I O N S

G F X

W I N D O W S

F I L E S

M E A S U R E M E N T S

B A S E 6 4  E N / D E C O D E R

U N I C O D E  --  U T F - 8   C O N V E R T E R

]]




local r = reaper

function Msg(param) -- X-Raym's
reaper.ShowConsoleMsg(tostring(param).."\n")
end


function Msg(param, cap) -- caption second or none
local cap = cap and type(cap) == 'string' and #cap > 0 and cap..' = ' or ''
	if Debug then -- declared outside of the function, allows to only didplay output when true without the need to comment the function out when not needed, borrowed from spk77
	reaper.ShowConsoleMsg(cap..tostring(param)..'\n')
	end
end


function Msg(cap, param) -- caption always, if not needed can be empty string
local cap = cap and type(cap) == 'string' and #cap > 0 and cap..' = ' or ''
	if Debug then -- declared outside of the function, allows to only didplay output when true without the need to comment the function out when not needed, borrowed from spk77
	reaper.ShowConsoleMsg(cap..tostring(param)..'\n')
	end
end


function Msg(...) -- caption first (must be string otherwise ignored) or none, accepts functions with only one return value
local t = {...}
	if #t > 1 then
	local cap, param = table.unpack(t) -- assign arguments to vars
	local cap = cap and type(cap) == 'string' and #cap > 0 and cap..' = ' or ''
	displ = cap..tostring(param)..'\n'
	elseif #t == 1 then
	displ = tostring(...)..'\n'
	end
	if Debug then -- declared outside of the function, allows to only display output when true without the need to comment the function out when not needed, borrowed from spk77
	r.ShowConsoleMsg(displ)
	end
end


local function printf(...) -- cfillion's from cfillion_Step sequencing (replace mode).lua
	if debug then
	reaper.ShowConsoleMsg(string.format(...))
	end
end
-- e.g. printf(">\tnote %d\tchan=%s vel=%s\n", note.pitch, note.chan, note.vel)


local date = os.date('%H-%M-%S_%d.%m.%y') -- a convenient way to make file names unique and prevent clashes


function Is_Project_Start()
local start_time, end_time = r.GetSet_ArrangeView2(0, false, 0, 0, start_time, end_time) -- isSet false // https://forum.cockos.com/showthread.php?t=227524#2 the function has 6 arguments; screen_x_start and screen_x_end (3d and 4th args) are not return values, they are for specifying where start_time and stop_time should be on the screen when non-zero when isSet is true
--local TCP_width = tonumber(cont:match('leftpanewid=(.-)\n')) -- only changes in reaper.ini when dragged
local proj_time_offset = r.GetProjectTimeOffset(0, false) -- rndframe false
return start_time == proj_time_offset
end



function Validate_Positive_Integer(str, type) -- str is a numeric string, type is a string, script specific to distinguish between 2 modes
local default = type and (type:lower() == 'bend' and 12 or type:lower() == 'offset' and 80)
	if not default then return end
local str = str:gsub(' ','') -- remove all spaces
local str = #str == 0 and default or tonumber(str)
return str and math.abs(str) > default and default or str and math.floor(str)
end


function validate_sett(sett) -- validate setting, can be either a non-empty string or any number
return type(sett) == 'string' and #sett:gsub(' ','') > 0 or type(sett) == 'number'
end


function validate_output(string) -- with GetUserInputs()
local string = string:gsub(' ','')
return #string > 0 and string ~= ',,' -- 3 field user dialogue if separator is a comma
end
-- USE:
-- if not retval or not validate_output(output) then return r.defer(function() do return end end) end


---------------------------------------------------------------------------------------------
-- Get command ID of the executed action, the action must be run
-- for its command ID to be returned by the function
local comm_id

function Get_Action_ID()
--local t = {0,32060,32061,32062,32063} -- UNUSED
comm_id = r.PromptForAction(0, 0, 0) -- session_mode 0, init_id 0, section_id 0 // POLL
--Msg(comm_id)
	if comm_id > 0 then
	r.PromptForAction(-1, 0, 0) -- session_mode -1, init_id 0, section_id 0 // STOP
	return end
r.defer(Get_Action_ID)
end

r.PromptForAction(1, 0, 0) -- session_mode 1, init_id 0, section_id 0 // LAUNCH
Get_Action_ID()
r.atexit(function() r.ShowConsoleMsg(r.ReverseNamedCommandLookup(comm_id)) end)

----------------------------------------------------------------------------------------

-- do something in X sec
local cur_time = os.time() -- in sec
local duration = 300 -- in sec
function do_in_X_mins(cur_time, duration)
	if select(2, math.modf((os.time() - cur_time)/duration)) == 0 then -- when the difference can be divided by duration without remainder it means exactly the duration value
		-- DO STUFF --
	end
end


function ACT(comm_ID) -- both string and integer work
local comm_ID = comm_ID and r.NamedCommandLookup(comm_ID)
local act = comm_ID and comm_ID ~= 0 and r.Main_OnCommand(r.NamedCommandLookup(comm_ID),0)
end


local ME = r.MIDIEditor_GetActive()
function ACT(ID, ME) -- supports MIDI Editor actions, get MIDI editor pointer ME and add as argument otherwise can be left out
-- ID - string or integer
	if ID then
	local ID = r.NamedCommandLookup(ID) -- works with srings and integers
		if ID ~= 0 then -- valid command_ID
			if not ME then r.Main_OnCommand(ID, 0)
			else
			r.MIDIEditor_LastFocused_OnCommand(ID, false) -- islistviewcommand is false
		--	r.MIDIEditor_OnCommand(ME, ID)
			end
		end
	end
end


function ACT(comm_ID, midi) -- midi is boolean
local comm_ID = comm_ID and r.NamedCommandLookup(comm_ID)
local act = comm_ID and comm_ID ~= 0 and (midi and r.MIDIEditor_LastFocused_OnCommand(comm_ID, false) -- islistviewcommand false
or r.Main_OnCommand(comm_ID, 0)) -- only if valid command_ID
end


function get_tog_state(sect_ID, comm_ID)
-- supports string command IDs
return r.GetToggleCommandStateEx(sect_ID, r.NamedCommandLookup(comm_ID))
end


function capture_command(input, str) -- weed out illegal entries in the Profile console

	for cmd in input:gmatch('[^,]*') do -- check all slots; if dot were added here it would help to catch decimal numbers, but opted for error in the main routine
		if cmd ~= '' and cmd ~= '0' and cmd ~= '1' and not cmd:match('^h+$') and not cmd:match('oo?ut') and cmd ~= 'quit' and not cmd:match('oo?pen') and cmd ~= 'reload' and not cmd:match('toolbar[0-9]+') and not cmd:match('toolbar[0-8]m') and not cmd:match('auto[0-9]+') and cmd ~= 'auto0' then input = nil break end
	end

	if input and str then
	input = input:match('^('..str..'),') or input:match(',('..str..'),') or input:match(',('..str..')$')
	end

return input

end


--------------------------------------------

-- Enable this setting by inserting any QWERTY alphanumeric
-- character between the quotation marks so the script can be used
-- then configure the settings below
ENABLE_SCRIPT = ""
function Script_Not_Enabled(ENABLE_SCRIPT)
	if #ENABLE_SCRIPT:gsub(' ','') == 0 then
	local emoji = [[
		_(ツ)_
		\_/|\_/
	]]
	r.MB('  Please enable the script in its USER SETTINGS.\n\nSelect it in the Action list and click "Edit action...".\n\n'..emoji, 'PROMPT', 0)
	return true
	end
end
if Script_Not_Enabled(ENABLE_SCRIPT) then return r.defer(function() do return end end) end

-- Enable this setting by inserting by inserting any alphanumeric
-- character between the quotation marks
-- to permanently prevent USER SETTINGS reminder pop-up
REMINDER_OFF = ""
function Reminder_Off(REMINDER_OFF)
	local function gap(n) -- number of repeats, integer
	local n = not n and 0 or tonumber(n) and math.abs(math.floor(n)) or 0
	return string.rep(' ',n)
	-- return (' '):rep(n)
	end
local _, scr_name, scr_sect_ID, cmd_ID, _,_,_ = r.get_action_context()
local scr_name = scr_name:match('([^\\/]+)%.%w+') -- without path and extension
--local cmd_ID = r.ReverseNamedCommandLookup(cmd_ID) -- to use instead of scr_name // just an idea
local ret, state = r.GetProjExtState(0, scr_name, 'REMINDER_OFF')
	if #REMINDER_OFF:gsub(' ','') == 0 and ret == 0 then
	local resp = r.MB('\t'..gap(7)..'This is to make you aware\n\n'..gap(12)..'that the script includes USER SETTINGS\n\n'..gap(10)..'you might want to tailor to your workflow.\n\n'..gap(17)..'Clicking "OK" disables this prompt\n\n'..gap(8)..'for the current project (which will be saved).\n\n\t'..gap(6)..'To disable it permanently\n\n change the REMINDER_OFF setting inside the script.\n\n   Select it the the Action list and click "Edit action..."', 'REMINDER', 1)
		if resp == 1 then
		r.SetProjExtState(0, scr_name, 'REMINDER_OFF', '1')
		r.Main_SaveProject(0, false) -- forceSaveAsIn false
		return true
		end
	else return true
	end
end
if not Reminder_Off(REMINDER_OFF) then return r.defer(function() do return end end) end


-------------------------------------------

function Validate_All_Global_Settings(...) -- global vars must be passed as arguments in string representation; in current form only suitable for validation of truth
-- https://stackoverflow.com/questions/59448334/convert-string-to-variable-name-in-lua
-- https://love2d.org/forums/viewtopic.php?t=75392
-- https://stackoverflow.com/questions/67407628/in-lua-having-found-a-variable-of-type-function-in-g-how-to-pass-a-paramete
local t = {...}
local t2 = {}
	for k, setting in ipairs(t) do
	local glob_var = t[k]
	t2[setting] = #_G[glob_var]:gsub(' ','') > 0 -- or #_G[t[k]]...
	end
return t2
end
--[[
USAGE
a = '.'
b = ''
c = ' 2'
local t = Validate_All_Global_Settings('a','b','c')
Msg(t.a) Msg(t.b) Msg(t.c)
]]


gfx.init('', 0, 0)
-- open menu at the mouse cursor
gfx.x = gfx.mouse_x
gfx.y = gfx.mouse_y
local input = gfx.showmenu(menu) -- menu string
gfx.quit()


function Re_Store_Ext_State(section, key, persist, val) -- section & key args are strings, persist is boolean if false/nil global ext state is only stored for the duration of REAPER session, only relevant for storage stage; presence of val arg is anything which needs storage, determines whether the state is loaded or stored
	if not val then
	local ret, state = r.GetProjExtState(0, section, key)
	local state = (not ret or #state == 0) and r.GetExtState(section, key) or state
	return state
	else
	r.SetExtState(section, key, val, persist)
	r.SetProjExtState(0, section, key, val)
	end
end

-- USAGE:
-- local state = Re_Store_Ext_State(section, key) -- load
-- Re_Store_Ext_State(section, key, persist, val) -- store


--------------------- T O G G L E S -------------------------

-- (re)setting toggle state and updating toolbar button, see also Re_Set_Toggle_State() below
local _, scr_name, sect_ID, cmd_ID, _,_,_ = r.get_action_context()

r.SetToggleCommandState(sect_ID, cmd_ID, 1)
r.RefreshToolbar(cmd_ID)

-- CODE (mainly for defer functions)

r.atexit(function() r.SetToggleCommandState(sect_ID, cmd_ID, 0); r.RefreshToolbar(cmd_ID) end)


function EMERGENCY_TOGGLE()
local t = {reaper.get_action_context()}
reaper.SetToggleCommandState(t[3], t[4], 0)
end
---------------- EMERGENCY -------------------

-- EMERGENCY_TOGGLE() do return end

---------------------------------------------

local function Wrapper1(func,...)
-- wrapper for a 3d function with arguments
-- to be used with defer() and atexit()
-- thanks to Lokasenna, https://forums.cockos.com/showthread.php?t=218805 -- defer with args
-- func is function name, the elipsis represents the list of function arguments
-- Lokasenna's code didn't work because func(...) produced an error 
-- without there being elipsis in function() as well, but gave direction
local t = {...}
return function() func(table.unpack(t)) end
end
-- USE:
--[[
function MY_FUNCTION(arg1, arg2)
r.defer(Wrapper(MY_FUNCTION, arg1, arg2))
end
MY_FUNCTION(arg1, arg2)

function My_Function(arg1, arg2, arg3) -- some routine -- end
r.atexit(Wrapper(My_Function, arg1, arg2, arg3)
]]



local function Wrapper2(...) -- more wordy
-- to be used with defer() and atexit()
-- https://forums.cockos.com/showthread.php?t=218805 Lokasenna
local t = {...}
local func = t[1] -- assign function name val
table.remove(t,1) -- remove function name arg
return function() func(table.unpack(t)) end
end



local _, scr_name, sect_ID, cmd_ID, _,_,_ = r.get_action_context()
function Re_Set_Toggle_State(sect_ID, cmd_ID, toggle_state) -- in deferred scripts can be used to set the toggle state on start and then with r.atexit and At_Exit_Wrapper() to reset it on script termination
r.SetToggleCommandState(sect_ID, cmd_ID, toggle_state)
r.RefreshToolbar(cmd_ID)
end
-- USAGE:
-- Re_Set_Toggle_State(sect_ID, cmd_ID, 1)
-- defer routine
-- r.atexit(At_Exit_Wrapper(Re_Set_Toggle_State, sect_ID, cmd_ID, 0))

-- TOGGLE MODE AND ARMABILITY ARE NOT COMPATIBLE


--------------------- T O G G L E S  E N D -------------------------

-- STORE DEFERRED SCRIPT DATA -----------------------------------------------------------
function defer_store()
local is_new_value, fullpath, sectionID, cmdID, mode, resolution, val = reaper.get_action_context()
-- Find first available slot
local i = 1
	repeat
	local state = r.GetExtState(os.date('%x'), 'defer'..i)
		if #state == 0 then break end
	i = i+1
	until #state == 0
r.SetExtState(os.date('%x'), 'defer'..i, table.concat({sectionID, cmdID, fullpath:match('.+[\\/](.+)'), fullpath}, ';'), false)
return i
end

local defer_data_slot = defer_store()

-- EXTRACT STORED DEFERRED SCTIPT DATA
local i = 1
	repeat
	local sectionID, cmdID, name, fullpath = r.GetExtState(os.date('%x'), 'defer'..i):match('(.+);(.+);(.+);(.+)')
		if not sectionID then break end
	i = i+1
	until not sectionID

-- DELETE STORED DEFERRED SCRIPT DATA
r.atexit(r.DeleteExtState(os.date('%x'), 'defer'..defer_data_slot, true))

--------------------------------------------------------------------------------------------------


function Temp_Proj_Tab()
-- relies on Create_Dummy_Project_File() if current tab isn't linked to a saved project
local cur_proj, projfn = r.EnumProjects(-1) -- store cur project pointer
r.Main_OnCommand(41929, 0) -- New project tab (ignore default template) // open new proj tab
-- DO STUFF
local dummy_proj = Create_Dummy_Project_File()
r.Main_openProject('noprompt:'..projfn) -- open dummy proj in the newly open tab without save prompt
r.Main_OnCommand(40860, 0) -- Close current (temp) project tab // save prompt won't appear either because nothing has changed in the dummy proj
r.SelectProjectInstance(cur_proj) -- re-open orig proj tab
end



--========================= U N D O  S T A R T =========================

do return r.defer(function() end) end

do r.defer(function() if not bla then return end end) end -- to avoid defer being stuck and display ReaScrpt task control dialogue on successive runs
--OR
do r.defer(function() do return end end) end
-- neither works work if a shortcut is held continuously


function no_undo()
do return end
end
-- USE:
-- do return r.defer(no_undo) end
-- OR
-- if ... then return r.defer(no_undo) end


function no_undo() end
do return r.defer(no_undo) end -- 'return' isn't required

local function nothing() end; local function bla() r.defer(nothing) end -- nofish; ARCHIE
bla() return


-- in some situation must be placed after
-- 'return r.defer(function() do return end end) end'
-- to make it prevent creation of a generic undo point (ReaScript: Run) or one generated by a native action when such is used upstream in the routine
r.Undo_BeginBlock()
r.Undo_EndBlock('', -1)

-- also when undo condition isn't satisfied, e.g.

if undo then
r.Undo_EndBlock(undo, -1)
else r.Undo_EndBlock('', -1) end


function Force_MIDI_Undo_Point1(take)
-- a trick shared by juliansader to force MIDI API to register undo point; Undo_OnStateChange() works too but with native actions it may create extra undo points, therefore Undo_Begin/EndBlock() functions must stay
-- https://forum.cockos.com/showpost.php?p=1925555
local item = take and r.GetMediaItemTake_Item(take) or r.GetMediaItemTake_Item(r.MIDIEditor_GetTake(r.MIDIEditor_GetActive()))
--r.SetMediaItemSelected(item, false)
--r.SetMediaItemSelected(item, true)
local is_item_sel = r.IsMediaItemSelected(item)
r.SetMediaItemSelected(item, not is_item_sel)
r.SetMediaItemSelected(item, is_item_sel)
end

function Force_MIDI_Undo_Point2(take) -- may or may not work, the above version is more reliable
local item = r.GetMediaItemTake_Item(take)
local tr = r.GetMediaItemTrack(item)
r.MarkTrackItemsDirty(tr, item)
end


function GetUndoSettings()
-- Checking settings at Preferences -> General -> Undo settings -> Include selection:
-- thanks to Mespotine https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
-- https://github.com/mespotine/ultraschall-and-reaper-docs/blob/master/Docs/Reaper-ConfigVariables-Documentation.txt
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local undoflags = cont:match('undomask=(%d+)')
local t = {
1, -- item selection
2, -- time selection
4, -- full undo, keep the newest state
8, -- cursor pos
16, -- track selection
32 -- env point selection
}
	for k, bit in ipairs(t) do
	t[k] = undoflags&bit == bit
	end
return t
end



--========================= U N D O  E N D =======================================


function PAUSE()
do r.MB('PAUSE','PAUSE',0) return end
end

do r.MB('PAUSE','PAUSE',0) return end

--================================ M A T H  S T A R T ===================================

-- find if number is integer
function is_integer(num)
return math.floor(num) == num -- integer is true, fraction is false
-- or math.ceil(num) == num
end

function is_decimal(num) -- flipped version of the above
return math.floor(num) ~= num -- or math.ceil(num) ~= num
end


function is_even(num)
return num%2 == 0 -- can be divided by 2 without a remainder
end


function round1(num) -- if decimal part is greater than or equal to 0.5 round up else round down; rounds to the closest integer
	if math.floor(num) == num then return num end -- if number isn't decimal
return math.ceil(num) - num <= num - math.floor(num) and math.ceil(num) or math.floor(num)
end


function round2(num) -- if decimal part is smaller than 0.5 round down else round up; rounds to the closest integer
local rounded = math.floor(num)
	if rounded == num then return num end -- if number isn't decimal
return rounded+0.5 > num and rounded or math.ceil(num)
end


-- OR SIMPLY
function round3(num)
return math.floor(num+0.5)
end



function round(num, idp) -- idp = number of decimal places, 0 means rounding to integer
-- http://lua-users.org/wiki/SimpleRound
-- round to N decimal places
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


function truncate_decimal(num, num_decimal_places) -- number, integer
local dec = num_decimal_places
local dec = tonumber(dec) and 10^math.floor(dec) -- preventing non-numbers and decimal numbers
	if not dec and num then return num, 'Error: missing argument'
	elseif not num then return 'Error: missing arguments' end
return math.floor(num*dec+0.5)/dec
end


math.randomseed(math.floor(r.time_precise()*1000)) -- seems to facilitate greater randomization at fast rate thanks to milliseconds count


function Get_Closest_Prev_Whole_Multiple(dividend, int_divisor)
-- https://math.stackexchange.com/questions/2179579/how-can-i-find-a-mod-with-negative-number modulo of negative numbers
-- charactertic of Lua in particular https://torstencurdt.com/tech/posts/modulo-of-negative-numbers/
-- not in all languages modulo of a negative number differs from its positive countepart; in Lua to have the same modulo for negative numbers the divisor must be negative as well
-- the formula is to get the modulo and then subtract it from the dividend
	if math.abs(dividend) >= 1 and -- allowing for numbers smaller than 1
	( math.abs(dividend) < math.abs(int_divisor) -- accounting for negative values
	or dividend ~= math.floor(dividend) ) -- dividend is a decimal number
	or dividend == 0
	or int_divisor ~= math.floor(int_divisor) -- divisor is a decimal number
	or int_divisor == 0
	then return false
	else
		if math.abs(dividend) < 1 then
		local dec_places = 10^#tostring(dividend):match('%.(%d+)')
		return (dividend*dec_places - dividend*dec_places%int_divisor)/dec_places
		-- return (dividend*dec_places - (dividend < 0 and math.abs(dividend)*dec_places%int_divisor*-1 or dividend*dec_places%int_divisor))/dec_places -- to get the multiple mirroring positive dividend, that is one closer to 0, otherwise the multiple is the next value smaller than the dividend which for negative numbers is farther from 0
		else return dividend - dividend%int_divisor
		-- return dividend - (dividend < 0 and math.abs(dividend)%int_divisor*-1 or dividend%int_divisor) -- to get the multiple mirroring positive dividend, that is one closer to 0, otherwise the multiple is the next value smaller than the dividend which for negative numbers is farther from 0
		end
	end
end


function Get_Closest_Multiple_Of_Divisor(number, divisor) -- number is some number, decimal arguments are supported; the closest meaning the closest to the number
	local function round(num) -- if decimal part is greater than or equal to 0.5 round up else round down; rounds to the closest integer
		if math.floor(num) == num then return num end -- if number isn't decimal
	return math.ceil(num) - num <= num - math.floor(num) and math.ceil(num) or math.floor(num)
	end
return round(number/divisor)*divisor
end


local function nmb(...)
return tonumber(...)
end


function split_integer_to_1s_and_10s(integer)
local tens, ones
	if integer then
	tens, ones = math.modf(integer/10) -- ones return as a decimal number whose decimal value represent whole ones, e.g. 0.3
	ones = ones*10 -- convert decimal number with whole part being 0, to integer
	-- OR
	-- ones = math.floor(ones*10+0.1) -- ro get rid of the decimal 0 in case ones is 0.0
	end
return tens, ones
end


function range_to_sequence(start, fin) -- integers only
local start = tonumber(start)
local fin = tonumber(fin)
	if not start or not fin then return end
local start_int = math.floor(start) == tonumber(start)
local fin_int = math.floor(start) == tonumber(start)
	if not start_int or not fin_int then return end
local t = {}
	for i = start, fin do
	t[#t+1] = i
	end
return t
end


function mod(a, b) -- same as math.fmod(a,b) since Lua 5.1 and math.mod in Lua 5.0
-- https://stackoverflow.com/a/20858039/8883033
    return a - (math.floor(a/b)*b)
end


function get_integral_1(num, divisor) -- get intergal part of the quotient after division of num by divisor
return math.modf(num/divisor)
end

function get_integral_2(num, divisor) -- same as the 1st return value of math.modf(num/divisor)
return math.floor((num - num%divisor)/divisor) -- previous multiple divided by the divisor so the intergal value is obtained
end

function get_fractional_1(num, divisor) -- get fractional part of the quotient after division of num by divisor
return select(2, math.modf(num/divisor)) -- or ({math.modf(num/diviser)})[2]
end

function get_fractional_2(num, divisor) -- same as the 2nd return value of math.modf(num/divisor)
return num/divisor - math.floor((num - num%divisor)/divisor) -- quotient minus the integral part
end


function get_prev_multiple(num, divisor) -- a multiple of the divisor lesser than the num
return num - num%divisor
end


function get_base2_log(number) -- the power to which 2 must be raised to get number
-- https://www.gammon.com.au/scripts/doc.php?lua=math.log
return math.log(number)/math.log(2)
end


function truncate_all_dec_places1(num, wantString) -- wantString is boolean to convert to string
local num = math.floor(num)
return wantString and num..'' or num
end


function truncate_all_dec_places2(num, wantString) -- wantString is boolean to convert to string
return wantString and (num..''):match('(.+)%.') or math.floor(num)
end


function toBits(num) -- represent integer as binary
-- returns a table of bits, least significant first
-- https://stackoverflow.com/questions/9079853/lua-print-integer-as-a-binary
local t={} -- will contain the bits
local num = num
	while num > 0 do
	local rest = math.fmod(num,2)
	t[#t+1]= rest
	num = (num-rest)/2
	end
return t
end
--bits = toBits(num)


function toBits(num, bits)
-- returns a table of bits
local t={} -- will contain the bits
    for b=bits,1,-1 do
	rest=math.fmod(num,2)
	t[b]=rest
	num=(num-rest)/2
    end
	if num == 0 then return t else return {'Not enough bits to represent this number'} end
end
--num=255
--bits=8
--bits=toBits(num, bits)


function toBits(num, bits) -- represent integer as binary // bits is the number of required bits
-- returns a table of bits, most significant first
-- https://stackoverflow.com/questions/9079853/lua-print-integer-as-a-binary
local num = num
local bits = bits or math.max(1, select(2, math.frexp(num)))
local t = {} -- will contain the bits
	for b = bits, 1, -1 do
	t[b] = math.fmod(num, 2)
	num = math.floor((num - t[b]) / 2)
	end
return t
end


function gener_numer_seq(start, fin)
local t = {}
	for i = start, fin do
	t[#t+1] = i
	end
return t
end


function hex2dec(str)
-- https://stackoverflow.com/questions/27294310/convert-hexadecimal-to-decimal-number
return str:match('0x') and tonumber(str) or tonumber(str,16)
end


function count_bits_in_number(integer)
local integer = tonumber(integer)
local base = 1
local bit_cnt = 0
  while base < integer do
  base = base*2
  bit_cnt = bit_cnt+1
  end
return bit_cnt
end

--================================ M A T H  E N D ===================================


--=========================== S T R I N G S  S T A R T ==============================

local function str(...)
return tostring(...)
end


-- add spaces
function space(n) -- number of repeats, integer
local n = not n and 0 or tonumber(n) and math.abs(math.floor(n)) or 0
return string.rep(' ',n)
-- return (' '):rep(n)
end

-- same
function Rep(x) -- repeat space x times, to be added to the Message box text
local x = not n and 0 or tonumber(x) and math.abs(math.floor(x)) or 0
return string.rep(' ', x)
-- return (' '):rep(n)
end


-- removes spaces for settings evaluation
function is_set(sett) -- sett is a string
return #sett:gsub(' ','') > 0
end


function Esc(str)
	if not str then return end -- prevents error
-- isolating the 1st return value so that if vars are initialized in a row outside of the function the next var isn't assigned the 2nd return value
local str = str:gsub('[%(%)%+%-%[%]%.%^%$%*%?%%]','%%%0')
return str
end


function literalize(str) -- same as Esc()
    return str:gsub(
      "[%(%)%.%%%+%-%*%?%[%]%^%$]",
      function(c)
        return "%" .. c
      end
    )
end


local function replace(str, what, with)
-- https://stackoverflow.com/a/29379912/8883033
    what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = string.gsub(with, "[%%]", "%%%%") -- escape replacement
    return string.gsub(str, what, with)
end


function spaceout(str)
return str:gsub('.', '%0 ') -- space out text
end
-- OR
local name = name:gsub('.', '%0 ') -- space out text


function starts_with(str, start)
-- http://lua-users.org/wiki/StringRecipes
   return str:sub(1, #start) == start
end

function ends_with(str, ending)
-- http://lua-users.org/wiki/StringRecipes
   return str:sub(-#ending) == ending
end


-- split string to multi-line by character count represented with line_len
function split_to_multiple_lines(str, line_len) -- str is string, line_len is integer
local line_len = math.floor(line_len) -- prevent decimals
local w_cntr = 0
local i = 0
local split_str = ''
local linebreak
	for w in str:gmatch('([^%s]+)') do -- only complete words
		if w_cntr >= line_len then linebreak, w_cntr = '\n', 0 -- reset counter
		else linebreak, w_cntr = ' ', w_cntr + #w end
	i = i + 1 -- just to prevent adding leading space to the very 1st line
	linebreak = i == 1 and '' or linebreak -- same
	split_str = split_str..linebreak..w
	end
return split_str
end



function Are_Multiple_Captures(chunk, str)
local cnt = 0
	for w in chunk:gmatch(Esc(str)) do
		if w then cnt = cnt+1 end
	end
return cnt > 1, cnt > 1 and cnt -- boolean and integer
end



function count_captures(str,capt) -- capt is a pattern or a literal string
local cntr = str
local cntr = {cntr:gsub(capt, '%0')}
return cntr[2] -- 2nd return value of gsub is the number of replaced captures
end


function remove_Nth_capture(str,capt,N) -- removes with adjacent punctuation marks
-- 1. if not N then N is 1
-- 2. if no captures or N is 0 or greater than the number of captures returns original string
local N = N and tonumber(N) and math.abs(math.floor(N)) -- validate N
	if not N then N = 1 end
local cntr = 0
local str_new = ''
	for w1, w2 in str:gmatch('(%w*)([%p%s%c]*)') do
	cntr = (N ~= cntr and w1 == capt or N == cntr) and cntr+1 or cntr
		if N ~= cntr then str_new = str_new..w1..w2 end
	end
return str_new, str ~= str_new -- 2nd val is boolean showing if any changes were made
end
-- see advanced USE CASES after replace_Nth_capture2() function below


function replace_Nth_capture1(src_str,capt,repl_str,N)
-- 1. if not N then N is 1
-- 2. if no captures or N is 0 or greater than the number of captures returns original string
-- if the 3d arg (repl_str) isn't a string then returns orig string and boolean to indicate no changes
local N = N and tonumber(N) and math.abs(math.floor(N)) -- validate N
	if not N then N = 1 end
local cntr = 0
local str_new = ''
	if repl_str and not type(repl_str) then return str, false end
	for w1, w2 in src_str:gmatch('(%w*)([%p%s%c]*)') do
	cntr = (N ~= cntr and w1 == capt or N == cntr) and cntr+1 or cntr
		if N == cntr then w1, w2 = repl_str..w2, '' end
	str_new = str_new..w1..w2
	end
return str_new, str ~= str_new -- 2nd val is boolean showing if any changes were made
end
-- see advanced USE CASES after replace_Nth_capture2() function below


function remove_replace_Nth_capture(src_str,capt,N,repl_str)
-- if the last arg is omitted or isn't a string then works for removal
-- 1. if not N then N is 1
-- 2. if no captures or N is 0 or greater than the number of captures returns original string
local N = N and tonumber(N) and math.abs(math.floor(N)) -- validate N
	if not N then N = 1 end
local repl_str = repl_str and type(repl_str) == 'string' and repl_str
local cntr = 0
local str_new = ''
	for w1, w2 in src_str:gmatch('(%w*)([%p%s%c]*)') do
	cntr = (N ~= cntr and w1 == capt or N == cntr) and cntr+1 or cntr
		if repl_str then
			if N == cntr then w1, w2 = repl_str..w2, '' end
		str_new = str_new..w1..w2
		elseif N ~= cntr then
		str_new = str_new..w1..w2
		end
	end
return str_new, str ~= str_new -- 2nd val is boolean showing if any changes were made
end
-- see advanced USE CASES after replace_Nth_capture2() function below


function replace_Nth_capture2(src_str, patt, repl_str, N) -- patt is either a literal string or a pattern; N is ordinal number of the capture to be replaced, if not N or 0 then N is 1
local N = N and tonumber(N) and math.abs(math.floor(N))
	if not N or N == 0 then N = 1 end
local i = 1
local st, fin, capt
local capt_cnt = 0
	while i < #src_str do
	-- OR
	--repeat
	st, fin, capt = src_str:find('('..patt..')', i)
		if capt then capt_cnt = capt_cnt + 1 end
		if capt_cnt == N then break end
	i = fin + 1
	--OR
	--until i > #src_str -- > because of fin + 1, doesn't happen with 'while' operator
	end
return N > capt_cnt and src_str or src_str:sub(1, fin-#capt)..repl_str..src_str:sub(fin+1) -- if N is greater than the number of captrures the original string is returned otherwise the one with substitutions
end

-- USE CASES
local src_str = 'test one test one one test'
local repl_str = 'ffsds'

	--1)
	for _, v in ipairs({1,6}) do -- replaces 1st and 6th captures of any word
	src_str = replace_Nth_capture(src_str, '%a+', repl_str, v)
	end
	-- result: 'ffsds one test one one ffsds'

	--2)
	for _, v in ipairs({{1,2}}) do -- replaces 1st and 3d instances of the word 'test' // every next instance number must be 1 less (2 instead of 3) because their number is being reduced as replacement continues, e.g. to replace 1st and 2nd instances {1,1} must be used
	src_str = replace_Nth_capture(src_str, 'test', repl_str, v)
	end
	-- result: 'ffsds one test one one ffsds'

	--3)
	for patt, repl_str in pairs({test = 'test1', one = 'one1'}) do -- replaces 3d instance of 'test' with 'test1' and 3d instance of 'one' with 'one1'
	src_str = replace_Nth_capture(src_str, patt, repl_str, 3)
	end
	-- result: 'test one test one one1 test1'

	--4)
	for patt, v in pairs({test = {[2] = 'test1'}, one = {[3] = 'one1'}}) do -- replaces 2d instance of 'test' with 'test1' and 3d instance of 'one' with 'one1'
		for N, repl_str in pairs(v) do
		src_str = replace_Nth_capture(src_str, patt, repl_str, N)
		end
	end
	-- result: 'test one test1 one one1 test'

	--5)
	for _, t in ipairs({ {one1 = 1}, {one2 = 1} }) do -- raplaces 1st instance of 'test' with 'one1' and 2nd instance of 'test' with 'one2'; for N values see use case 2) above
		for repl_str, N in pairs(t) do
		src_str = replace_Nth_capture(src_str, 'test', repl_str, N)
		end
	end
	-- result: 'one1 one one2 one one test'

	
function replace_capture_by_capture_number(str, what, with, ...)
-- the elipsis represents a list of integers denoting the number of the what instance in the str
-- if the what instance number is out of scope or it isn't found, returns the original str
-- this type of replacement is impossible with string.gsub()
local inst_t = {...}
local t = {}
local i = 1
	while i < #str do -- collect indices at which the what instances start
	local s, e = str:find(what, i)
		if s then t[#t+1] = s
		i = e+1
		else
		i = i+1
		end	
	end
table.sort(inst_t) -- in case the what instance numbers weren't passed in ascending order
	for i = inst_t[#inst_t], 1, -1 do -- iterating backwards from the greatest ordinal number
	local idx = inst_t[i]
		if t[idx] then -- instance number from the arguments matches key in the table holding indices of the what instances
		str = str:sub(1,t[idx]-1)..with..str:sub(t[idx]+#what)
		end
	end	
return str
end
-- EXAMPLE
-- local str = 'one two one two one two, two'
-- local str = replace_capture_by_capture_number(str, 'two', 'three', 1, 3, 4) -- replaces 1st, 2nd and 4th instances of 'two' with 'three'
	


-- !!!! OVER 26 captures may make the system freeze (could also depend on the length of each capture) // same with string.find()
function list_2_table(str, pattern, delimiter) -- pattern e.g. '(%d+);?' to extract semicolon delimited numbers; if using the included tables pattern and delimiter must be numbers else delimiter arg isn't needed
local pattern = {'(%a+)', -- mixed case words = 1
				 '(%l+)' -- only lower case words = 2
				 '(%u+)' -- only upper case words = 3
				 '(%-?%d+)', -- integers, uncluding signed =  4
				 '(%-?[%d%.]*)' -- decimal numbers, uncluding signed = 5
				-- hexadecimal could be added
				}
local delimiter = { ',' -- = 1
					'%.' -- a dot = 2
					':' -- = 3
					';' -- = 4
					'/' -- = 5
					'\\' -- = 6
					'[\\/%.,:;]+' -- any of the above = 7
				  }
local counter = str -- a safety measure to avoid accidental ovewriting the orig. string, although this shouldn't happen thanks to %0
local counter = {counter:gsub(pattern, '%0')} -- 2nd return value is the number of replaced captures
local t = {str:match(string.rep(pattern, counter[2]))} -- captures the pattern as many times as there're pattern repetitions in the string
-- OR IF USING TABLES:
-- counter = {counter:gsub(pattern[pattern]..delimiter[delimiter], '%0')}
-- t = {str:match(string.rep(pattern[pattern]..delimiter[delimiter], counter[2]))}
return t, counter[2] -- second return value holds number of captures
end


-- !!!! OVER 26 caprures may make the system freeze (could also depend on the length of each capture) // same with string.find()
function list_2_table(str, pattern) -- pattern e.g. '(%d+);?' to extract semicolon delimited numbers;
local counter = str -- a safety measure to avoid accidental ovewriting the orig. string, although this shouldn't happen thanks to %0
local counter = {counter:gsub(pattern, '%0')} -- 2nd return value is the number of replaced captures
local t = {str:match(string.rep(pattern, counter[2]))} -- captures the pattern as many times as there're pattern repetitions in the string
return t, counter[2] -- second return value holds number of captures
end


-- to process user input
-- to be used within loop as get_index_from_range_or_list1(str, i+1), if true, i+1 or value which corresponds to it will be saved to a table
function get_index_from_range_or_list1(str, tr_idx) -- str is a string containing range 'X-X' or list 'X, X, X, X' of numerals
local min, max = str:match('(%d+)%s*%-%s*(%d+)') -- the syntax is X-X // range
	if (min and max)
	and (tr_idx >= min+0 and max+0 >= tr_idx) -- range // +0 converts string to number to match tr_idx data type
	then return true
	elseif str:match('%d+,') then -- list // additional condition to prevent falling back on this routine when previous expression returns nils, because this will return true at least once since in the list the 1st numeral will always be found
		for idx in str:gmatch('%d+') do -- list
			if tonumber(idx) == tr_idx then return true end
		end
	end
end


-- to process user input
-- to be used within loop as get_index_from_range_or_list2(str, i+1), if true, i+1 or value which corresponds to it will be saved to a table
function get_index_from_range_or_list2(str, num) -- str is a string containing range 'X-X' or list 'X X X X' of numerals, the type of separator doesn't matter
local min, max = str:match('(%d+)%s*%-%s*(%d+)') -- the syntax is X-X // range
	if (min and max)
	and (num >= min+0 and max+0 >= num or num >= max+0 and min+0 >= num) -- range // +0 converts string to number to match num data type // allows reversed ranges, e.g. 10 - 1
	then return true
	elseif str:match('%f[%d]'..num..'%f[%D]') then return true -- list
--[[OR
	elseif str:match(num) then -- list
		for w in str:gmatch('%d+') do -- without the loop parts of composite numbers will produce truth as well in str:match(num), i.e. 16 will be true 3 times as 1, 6 and 16 // the loop allows respecting separators
			if tonumber(w) == num then return true end
		end
	]]
	end
end

--[[ EXAMPLE

	for i = 1, 16 do
		if get_index_from_range_or_list(output, i) then -- output is a string containing range or list
		ch_t[#ch_t+1] = i
		end
	end

	if #ch_t == 0 or #ch_t == 1 and ch_t[1]-1 == cur_chan -- -1 to conform to 0-based system used in cur_chan value
	then
	local err = #ch_t == 0 and 'No valid target MIDI channel has been specified.' or 'The target MIDI channel is the same as the current one.'
	local resp = r.MB(err, 'ERROR', 5)
		if resp == 4 then autofill = move and move..output or output goto RETRY
		else return r.defer(function() do return end end)
		end
	end

]]


function validate_search_term1(input_str, target_str, exact) -- exact is boolean
-- relies on Esc() function
	if exact then return target_str:match('^%s*('..Esc(input_str)..')%s*$') end
local cnt = 0
local truth_cnt = 0
	for w in input_str:gmatch('[%w%p]+') do
		if w then cnt = cnt+1 end
		if target_str:match(Esc(w)) then truth_cnt = truth_cnt+1 end
	end
return cnt > 0 and cnt == truth_cnt -- all words/punctuation marks of the search term found in the track name; preventing equality of zeros
end


local function validate_search_term2(input_str, target_str, exact) -- exact is boolean
-- relies on Esc() function
	if exact then return target_str:match('^%s*('..Esc(input_str)..')%s*$') end
local loop_run
	for w in input_str:gmatch('[%w%p]+') do
	loop_run = 1
		if w and not target_str:match(Esc(w)) then return end
	end
return loop_run -- if nothing is found the loop doesn't start, if does start and is not exited preemptively, then search term was found
end


function Convert_Text_To_Menu(text, max_line_len) -- max_line_len is integer, determines length of line as a menu item, 70 seems optimal
-- relies on multibyte_str_len() function to accurately count UTF-8 characters

local text = text:gsub('|', 'ㅣ') -- replace pipe, if any, with Hangul character for /i/ since its a menu special character
local notes, stat = notes:gsub('&', '+') -- convert ampersand to + because it's a menu special character used as a quick access shortuct hence not displayed in the menu
local text = text:gsub('\n', '|')-- OR notes:gsub('\r', '|') // convert user line breaks into pipes to divide lines by creating menu items, otherwise user line breaks aren't respected; multiple line break is created thanks to the space between pipes originally left after each \n character, if there's none a solid line is displayed instead or several thereof starting from 3 pipes and more
local t = {}
	for w in notes:gmatch('[%w%p\128-\255]+[%s%p]*') do -- split into words + trailing space if any; [%w%p] makes sure that words with apostrophe <it's>, <don't> aren't split up; [%s%p] makes menu divider pipes and special characters (!#<>), if any, attached to the words bevause they're punctuation marks (%p); accounting for utif-8 characters
		if w then
		t[#t+1] = w end
	end

local text, menu = '',''
	for k, w in ipairs(t) do
	local text_clean = (text..w):gsub('|','') -- doesn't seem to make a difference with or without the pipe
		if multibyte_str_len(text_clean) > max_line_len or text:match('(.+)|') then -- dump text var to menu var and reset text, if not dumped immediately when the text var ends with line break then when text var will exceed the length limit containing a user line break, hanging words will appear after such line break because they will now be included in the menu var and next time length of text var will be evaluated without them, e.g.:
		-- | text = 'The generated Lorem Ipsum is therefore | always' -- assuming the string exceeds the length limit, 'always' will be left hanging ...
		-- | menu = menu..'The generated Lorem Ipsum is therefore | always'..pipe -- line break is created after 'always' with pipe var, next time text var will be added after the pipe, so the result will look like:
		-- | 'The generated Lorem Ipsum is therefore 
		-- | always
		-- | free from repetition, injected humor
		-- whereas 'always' has to be grouped with 'free from repetition, injected humor'
		local pipe = text:match('(.+)|') and '' or '|' -- when the above condition is true because text end with pipe the pipe is user's line break so no need to add another one, otherwise when condition is true because the line length exceeds the limit pipe is added to delimit lines as menu items
		text = #pipe == 0 and text:gsub('[!#<>]',' %0') or text -- make sure that menu special characters at the beginning of a new line (menu item) are ignored prefacing them with space; when string stored in the text var has pipe in the end, if ther're any menu special characters in the user text, they will follow the pipe due to the way user text are split into words at the beginning of the function, so if there're any specal characters placed at the beginning of a new line in the user text they will necessarily be found in the text var right next to the new line character converted at the beginning of the function into pipe to conform to the menu syntax and such new line character is attached to the preceding line
		menu = menu..text..pipe -- between menu and text pipe isn't needed because it's added after the text and next time will be at the end of the menu
		text = ''
		end
		if k == #t then
		menu = ' |'..menu..text..w..'| |' -- add padding
		else
		text = text..w
--Msg(text) -- interesting to watch
		end
	end
return menu
end


function multibyte_str_len(str)
-- https://stackoverflow.com/questions/43125333/lua-string-length-cyrillic-in-utf8
-- https://stackoverflow.com/questions/22129516/string-sub-issue-with-non-english-characters
-- https://www.splitbrain.org/blog/2020-09/03-regexp_to_match_multibyte_character
-- https://stackoverflow.com/questions/9356169/utf-8-continuation-bytes
-- https://www.freecodecamp.org/news/what-is-utf-8-character-encoding/
-- count string length in characters regardless of the number of bytes they're represented by, works for Korean, Japanese, Chinese
-- Lua string library counts bytes, and UTF-8 characters produce inaccurate count because they're multi-byte, consisting also of leading (leader) bytes (192-254) and continuation (trailing) bytes (128-191), the continuation bytes must be discarded so only the basic ASCII (0-127) remain
return #str:gsub('[\128-\191]','') -- OR #str:gsub('[\x80-\xbf]','') -- same in HEX
end


-- iterate over a UTF-8 string by character
-- https://stackoverflow.com/questions/22129516/string-sub-issue-with-non-english-characters
for c in str:gmatch(".[\128-\191]*") do
-- DO STUFF
end


function utf8_len(str)
-- REAPER stock lyrics.lua
local a = utf8.len(str);
  if a == nil then return str:len() end
  return a;
end


function utf8_chars_to_bytes(str, a, b)
-- REAPER stock lyrics.lua
a = utf8.offset(str,a)
b = utf8.offset(str,b)
  if a == nil then a = str:len()+1 end
  if b == nil then b = str:len()+1 end
  if b < a then return b,a end
  return a,b
end


function format_time(US_order, _12_hour, Isr_date, Roman_month, dot) -- all booleans
-- US_order - month first
-- _12_hour - 12 hour cycle + AM/PM
-- Isr_date - zeros in day and month are discared
-- Roman_month - Roman month number delimited with slash
-- Isr_date and Roman_month are only relevant if US_order is false
-- dot instead of slash, incompatible with Roman_month, the latter has priority
local d = US_order and '%m/%d' or '%d/%m' -- month first
local t = _12_hour and '%I' or '%H'
local period = t == '%I' and (os.date('%H')+0 < 12 and ' AM' or ' PM') or ''
local date = os.date(d..'/%Y '..t..':%M'..period)
	local function roman(str)
	local t = {'I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII'}
	return '/'..t[tonumber(str:match('%d+'))]..' ' 
	end
	local function isr(str)
		if str:match('0%d/0%d') then return str:gsub('0','')
		elseif str:match('0%d/%d+') then return str:match('%d(%d/%d+/)') -- or str:sub(2)
		elseif str:match('%d+/0%d') then return str:gsub('/0', '/')
		end
	end
-- local date = '02/01/2023 15:29' -- TESTING
local date = not US_order and 
(Roman_month and date:gsub('/%d+/', roman) or Isr_date and date:gsub('%d+/%d+/', isr)) 
or date
local date = not Roman_month and dot and date:gsub('/','.') or date
return date
end


--=========================== S T R I N G S  E N D ==============================


--=============================== T A B L E S ===================================

function copy_array1(t)
	if not t or #t == 0 then return end
local a = {}
	for k, v in ipairs(t) do
	a[k] = v
	end
return a
end


function copy_array2(t)
	if not t or #t == 0 then return end
local a = {}
	for i = 1, #t do
	table.insert(a, i, t[i])
	end
return a
end


function copy_table(t)
-- inspired by https://stackoverflow.com/a/10842827/8883033
-- https://stackoverflow.com/questions/10842679/lua-multiple-assignment
return {table.unpack(t)}
end
-- e.g. local t2 = copy_table(t1)
-- OR simply
-- local t2 = {table.unpack(t1)}


function reverse_indexed_table1(t) -- around the last value
	if not t then return end
	for i = 1, #t-1 do -- loop as many times as the table length less 1, since the last value won't need moving
	local v = t[#t-i] -- store value
	table.remove(t, #t-i) -- remove it
	t[#t+1] = v -- insert it as the last value
	end
--return t
end

function reverse_indexed_table2(t)
	if not t then return end
local fin = #t -- separate var because using #t in the loop won't work due to the table length increase
	for i = fin,1,-1 do
	t[#t+1] = t[i] -- append all values starting from the last to the end of current table
	end
	for i = 1, fin do
	table.remove(t,1) -- remove 1st field as many times as the length of the orig table, with each removal next field becomes 1st
	end
end


function reverse_indexed_table3(t)
	for i = #t,1,-1 do
	t[#t+1] = t[i]
	table.remove(t,i)
	end
end


function reverse_indexed_table4(t)
	for k, v in ipairs(t) do
		if k > #t/2 then break end -- only run half the table length (rounded down half if the length is an odd number), otherwise the order will be restored
	local i = k-1
	t[k] = t[#t-i]
	t[#t-i] = v
	end
end


function James_Bradbury_reverse_table(t)
-- Invert the table around the middle point (mirror!)
-- https://github.com/ReaCoMa/ReaCoMa-2.0/blob/main/lib/utils.lua
    -- Reverse a table in place
	local i, j = 1, #t
	while i < j do
		t[i], t[j] = t[j], t[i]
		i = i + 1
		j = j - 1
	end
end


function filter_table_vals(t, val, func) -- val can be number, string, pointer or table, of course table values type must match 'val' arg type // t arg seems unnecessary because table is recognized even being local // basic use is (in)equality evaluation; for numbers <> operators can be employed // the function works recursively
-- idea - https://stackoverflow.com/questions/49709998/how-to-filter-a-lua-array-inplace
local num = type(val) == 'number'
local str = type(val) == 'string'
local ptr = type(val) == 'userdata'
local tab = type(val) == 'table'
	for k, v in ipairs(t) do
		if v ~= val then
	-- 	if str and not v:match(val) then -- filtering by string contents
	--  if tab and v == val[k] then -- filtering by values found in another table
		table.remove(t,k)
		func(t, val, filter_table_vals) -- recursiveness is used to overcome the problem of table indices (k) shift as slots are being removed which results in some indices being skipped
		end
	end
end


function filter_inplace(t, val, func)
   for k, v in ipairs(t) do
       if v == val then
       table.remove(t,k)
       func(t, val, filter_inplace)
	   -- OR
	   -- filter_inplace(t, val) and use example is filter_inplace(t, 1)
       end
    end
end
-- EX
-- filter_inplace(t, 1, filter_inplace)

-- OR
function filter_inplace(t, val)
   for k, v in ipairs(t) do
       if v = val then
       table.remove(t,k)
       filter_inplace(t, val)
       end
    end
end
-- EX
-- filter_inplace(t, 1)


function sort_tableA_by_tableB(tA, tB) -- indexed tables; table lengths may differ
-- replicate in tA order found in tB
	 for _, vB in ipairs(tB) do
		for kA, vA in ipairs(tA) do
			if vA == vB then
			tA[#tA+1] = vA
			table.remove(tA,kA)
			end
		end
	end
end


function merge_2_arrays_at_index(t1,t2,index) -- the result is updated t1
local offset = 1-index
  for i = index, #t2+index-1 do
  table.insert(t1, i, t2[i+offset])
  end
end


function merge_tables(t, new, ...) -- new is boolean to indicate if to merge with t or create a new table, elipsis represents a list of tables to be merged with t
local t = new and {table.unpack(t)} or t
local to_merge = {...}
	for _, table in ipairs(to_merge)do
		for i = 1, #table do
		t[#t+1] = table[i]
	--[[ OR
		for _, v in ipairs(table) do
		t[#t+1] = v
	--]]
		end
	end
return t -- required if merge_tables is used as an argument in another function, e.g. unpack() below or if new t
end


function unpack(t, from, to)
-- from & to are indices of fields
-- if from is nil then from the 1st up until 'to'
-- if 'to' is nil, then 'from' to the last
-- if both are nil, then all
return table.unpack(t, from, to)
end


function shuffle_array(t, places, backward) -- places integer, backward boolean
-- number of places backward = #t - places forward and vice versa, the results will be identical
	if places == #t then return end -- because the order will end up being the same
local i = 0
	if not backward then
	local last = t[#t] -- store to assign to the 1st field
		repeat
		for i = #t,1,-1 do
			if i < #t then t[i+1] = t[i] end
		end
		t[1] = last
		last = t[#t]
		i = i+1
		until i == places
	else
	local first = t[1] -- store to assign to the last field
		repeat
		for i = 1, #t do
			if i > 1 then t[i-1] = t[i]	end
		end
		t[#t] = first
		first = t[1]
		i = i+1
		until i == places
	end
end



-- local t = {'Bb1','E3','D2','B4','F#5','G#1','Db2','C4','A5','B3','Eb3','G1'}
-- in note names created by REAPER explode actions sharps are applied to F and G, flats are applied to D, E and B
function sort_notes_by_name(t, wantReverse) -- t is an array containing note names, wantReverse is boolean
-- the notes must use # and b for sharps and flats
-- the notes must be capitalized to distinguish between B and flat sign b
local pat = '[%-%d]+'
table.sort(t, function(a,b) return a:match(pat) < b:match(pat) end) -- sort by octave
local oct = -10 -- a value lower than the lowest octave number to be able to detect the 1st lowest and so forth
local table_len = #t -- to be used in removing all separate note fields

-- STEP 1
	for _, v in ipairs(t) do -- store notes belonging to every octave in a separate nested table
	local str = type(v) == 'string' -- could be table because nested tables are being added during the loop
	-- outwitting sorting algo used below to make it place sharps later and flats earlier in the sequence, otherwise sharps are sorted to earlier slots because '#' precedes numerals in the character list while 'b' comes after numerals, numeral matter because in the note name they denote octave, so G#1 will precede G1 and E1 will precede Eb1
	local v = str and v:gsub('#','z') -- z follows numerals
	local v = str and v:gsub('b','!') -- ! precedes numerals
		if str and v:match(pat) > oct..'' then -- create a nested table and store first note name
		t[#t+1] = {v}
		oct = v:match(pat)
		elseif str and v:match(pat) == oct..'' then -- keep adding note names to the nested table while the octave is the same
		local len = #t[#t]
		t[#t][len+1] = v
		else break -- all strings have been removed, no point to continue
		end
	end

	for i = table_len, 1, -1 do -- remove all separate note fields
	table.remove(t,i)
	end

-- STEP 2
local table_len = #t -- to be used in removing all nested tables, there're fewer fields at this stage because their number is based on octaves

	for k, v in ipairs(t) do -- sort each octave alphabetically
		if type(v) == 'table' then -- could be string because note names are being added during the loop
		table.sort(v) -- sort nested table
			for i = 1, #v do
			local note = v[i]
				if note:match('A') or note:match('B') then -- move these notes to the end of the list
				v[#v+1] = note
				v[i] = '' -- mark for deletion, deletion during the loop ruins the table but moving and deleting while iterating in reverse doesn't produce the accurate result, A ends up following B because it follows it in reversed loop
				end
			end
			for i = #v,1,-1 do -- delete A and B placeholder fields if any
				if v[i] == '' then table.remove(v,i) end
			end

			for _, v in ipairs(v) do -- place nested table fields back to the main table in separate fields
			local v = v:gsub('z','#') -- restoring sharps and flats
			local v = v:gsub('!','b')
			t[#t+1] = v
			end
		else break -- all tables have been removed, no point to continue
		end
	end

-- STEP 3
	for i = table_len, 1, -1 do -- remove all nested tables
	table.remove(t,i)
	end

	if wantReverse then
		--[[ reverse table -- WORKS
		for i = #t,1,-1 do
		t[#t+1] = t[i]
		table.remove(t,i)
		end
		--]]
		--[-[ OR
		for k, v in ipairs(t) do -- WORKS
			if k > #t/2 then break end -- only run half the table length (rounded down half if the length is an odd number), otherwise the order will be restored
		local i = k-1
		t[k] = t[#t-i]
		t[#t-i] = v
		end
		--]]
	end

--return t -- unnecessary because the table is the same

end


function binary_search(t, value)
-- https://stackoverflow.com/questions/19522451/binary-search-of-an-array-of-arrays-in-lua
local lo = 1
local hi = #t
local mid
	while lo < hi do
	mid = math.floor((lo+hi)/2)
		if t[mid] < value then
			lo = mid+1
		else
			hi = mid
		end
	end
	return lo
end


function binary_search(t, value) -- my implementation, isn't the classic method
-- the speed advantage over simple iteration only starts to be felt from about 100,000 array entries
-- https://github.com/ReaTeam/ReaScripts/blob/master/MIDI%20Editor/js_Notation%20-%20Set%20displayed%20length%20of%20selected%20notes%20to%20custom%20value.lua -- idea source
-- https://github.com/Roblox/Wiki-Lua-Libraries/blob/master/StandardLibraries/BinarySearch.lua
local mid = 1
local fin = #t
	while t[mid] < value do
	local result = math.floor((fin+mid)/2)
		if t[result] < value and result ~= mid then mid = result -- result ~= mid prevents endless loop when the sought value is the last in the array
		elseif 
		t[result] > value and result ~= fin then fin = result
		else break end -- breaks short of the searched last value by 1
	end
	for i = mid, fin do
		if t[i] == value then return i end
	end
end

--=========================== T A B L E S  E N D ==============================


--================================ M I D I ================================

r.MIDIEditor_GetSetting_int(ME, 'last_clicked_cc_lane')
-- -1 -- Piano roll was last clicked context
-- 0 - 127 -- regular CC lanes
-- 256 - 287 -- 31 14-bit CC lanes
-- 513 -- pitch
-- 514 -- program
-- 515 -- channel pressure
-- 516 -- program/bank select
-- MIDI CHANNEL IS IRRELEVANT FOR:
-- 512 -- velocity
-- 519 -- off velocity
-- 517 -- text events
-- 518 -- SysEx
-- 520 -- notation events
-- 528 -- media item lane // doesn't seem to be actually returned by the function, instead returns last clicked lane or -1

r.MIDIEditor_GetSetting_int(ME, 'default_note_chan') -- returns channel currently selected in the MIDI Editor channel drop-down menu or last selected if 'All channels' or 'Multichannel' menu option is active

MIDI_GetCC()
-- chanmsg (event type):
-- 0 - non-CC: (off) velocity, text/notation/sysex events, 160 - Poly Aftertouch, 176 - CC, Bank/Program select, Bank select, 192 - Program change, 208 - Channel pressure (aftertouch), 224 - Pitch (bend)
-- msg2:
-- always 0 for non-CC, Bank/Program select, 00 Bank select MSB events
-- first 7 bits (MSB) of event value for Pitch (msg3 provides second 7 bits (LSB))
-- program number for Program
-- event value for Channel pressure
-- CC message number for CC events starting from 0
-- msg3:
-- always 0 for non-CC, Program, Channel pressure
-- second 7 bits (LSB) of event value for Pitch (msg2 provides first 7 bits (MSB))
-- bank MSB for Bank/Program select and 00 Bank select MSB events, 0 if Bank/Program select event doesn't have .reabank loaded
-- event value for CC events
MIDI_GetTextSysexEvt()
-- type var
-- text events: 1 text, 2 copyright notice, 3 track name, 4 instrument name, 5 lyrics, 6 marker, 7 cue, 8 program name, 9 device name
-- notation event: 15
-- sysex event: -1
-- setting sysex event data https://forums.cockos.com/showthread.php?p=2267909
r.MIDI_InsertTextSysexEvt() -- not inserted with empty bytestr argument
-- to insert a notation event linked to a note bytestr string must include 'NOTE' prefix, channel number and note number, e.g 'NOTE '..chan..' '..note, it can be additionally complemented with text, e.g. 'NOTE '..chan..' '..note..' '..text; 'TRAC ' prefix pertains to notation events inserted in the Notation events lane which aren't linked to notes
-- https://forum.cockos.com/showthread.php?t=273389&page=3#111
-- https://forum.cockos.com/showthread.php?p=2636270
-- https://forum.cockos.com/showthread.php?t=278052
-- the 'NOTE' and 'TRAC' prefixes are contained in the msg return value of r.MIDI_GetTextSysexEvt() depending on the source of the event, as well as in stuffed data
-- using stuffed MIDI data
-- https://github.com/MichaelPilyavskiy/ReaScripts/blob/master/MIDI%20editor/mpl_Remove%20MIDI%20CC.lua
-- https://forum.cockos.com/showthread.php?t=241140


function Is_MIDI_Ed_Open()
-- NOT RELIABLE SINCE DOCKED MIDI EDITOR IN CLOSED DOCK IS STILL VALID
-- IF DOCK IS FLOATING THE NATURAL INSTINCT IS TO CLOSE IT USING THE WINDOW CLOSE BUTTON
-- AND THAT'S WHERE THE PROBLEM EMERGES
-- THE MIDI EDITOR REMAINS DOCKED AND EVEN BEING INVISIBLE IS VALID SINCE IT WASN'T EXPLICITLY CLOSED
-- ONLY CLOSURE WITH TAB CLOSE BUTTON MAKES IT TRULY NON-FOCUSED AND INVALID
-- https://forum.cockos.com/showthread.php?t=278871
return r.GetToggleCommandStateEx(32060, 1014) ~= -1 -- View: Toggle snap to grid // if closed toggle state isn't returned
end


function Lane_Type_To_Event_Data(ME) -- relies on Error_Tooltip() for error message
-- further implementation see in Insert or edit MIDI event at edit cursor.lua
local ME = not ME and r.MIDIEditor_GetActive()
local last_clicked_lane = r.MIDIEditor_GetSetting_int(ME, 'last_clicked_cc_lane')

	if last_clicked_lane == -1 then  -- last clicked lane return value is -1 when the Piano roll was last clicked context
	Error_Tooltip('\n\nthe last clicked lane is undefined\n\n  click any lane to make it active \n\n', 1, 1) -- caps, spaced true
	return end

return (last_clicked_lane >= 0 and last_clicked_lane <= 119 -- regular 7-bit cc lanes
or last_clicked_lane >= 256 and last_clicked_lane <= 287) -- 14-bit lanes
and 176
or last_clicked_lane == 513 and 224 -- pitch
or last_clicked_lane == 514 and 192 -- program change
or last_clicked_lane == 515 and 208 -- channel pressure (aftertouch)
or last_clicked_lane == 516 and 176 -- Bank/Program select // the data in this lane is linked to CC#00 Bank select MSB lane, events created in one automatically appear in the other, for both MIDI_GetCC() chanmsg return value is 176
or last_clicked_lane == 517 and 1 -- text events, between 1 and 14, currently only 9 are available // the value will be fine tuned in the loop so that all text event types are covered
or last_clicked_lane == 518 and -1 -- sysex event
or last_clicked_lane == 520 and 15 -- notation event

end


function MIDI_Take_Open_Close(is_open, item)
-- check if take is open in the MIDI Editor
-- if not open then open
-- run twice: 1) to open if not open and get take pointer; 2) to close if wasn't open initially
	if item then
	local item = r.GetSelectedMediaItem(0,0)
	local act_take = r.GetActiveTake(item)
	local is_midi = r.TakeIsMIDI(act_take)
	local is_open = r.MIDIEditor_GetActive() -- check if MIDI Editor is open
	local open = is_midi and not is_open and r.Main_OnCommand(40153, 0) -- Item: Open in built-in MIDI editor (set default behavior in preferences)
	local hwnd = r.MIDIEditor_GetActive()
	local midi_take = r.MIDIEditor_GetTake(hwnd)
	return midi_take, is_open
	elseif not is_open then -- wasn't open initially
	r.MIDIEditor_LastFocused_OnCommand(2, false)  -- File: Close window;  islistviewcommand false
	end
and
-- USAGE EXAMPLE:
-- r.PreventUIRefresh(1)
--local midi_take, is_open = MIDI_Take_Open_Close(is_open, item)
--DO STUFF
--MIDI_Take_Open_Close(is_open)
-- r.PreventUIRefresh(-1)


function Clear_Restore_MIDI_Channel_Filter(enabled_ID, is_open) -- must be applied to selected MIDI item
-- when Channel filter is enabled Get/Set functions only target events in the current channel
-- which may be undesirable if working with all events
-- run twice: 1) to open if not open and clear filter if enabled 2) to close if wasn't open initially and to restore filter if was enabled

-- Conditioning is reversed the 1st part will be activated after the 2nd when the function is run twice

	if enabled_ID then -- has been opened
	r.MIDIEditor_LastFocused_OnCommand(enabled_ID, false) -- islistviewcommand false // Re-enable filter
		if not is_open then r.MIDIEditor_LastFocused_OnCommand(2, false) end -- File: Close window;  islistviewcommand false // close if wasn't initially open
	else
	-- for the MIDI Editor action GetToggleCommandStateEx() only works if its open
	local is_open = r.MIDIEditor_GetActive() -- check if MIDI Editor is open
	local open = not is_open and r.Main_OnCommand(40153, 0) -- Item: Open in built-in MIDI editor (set default behavior in preferences)
	local enabled_ID
		for i = 18, 33 do
			if r.GetToggleCommandStateEx(32060, 40200+i) == 1 -- ID range of actions which enable channel filter is 40218 - 40233 Channel: Show only channel X // actions Channel: Toggle channel X could be evaluated instead, their ID range is 40643 - 40658
			then enabled_ID = 40200+i break end
		end
		if enabled_ID then
		r.MIDIEditor_LastFocused_OnCommand(40217, false) -- Channel: Show all channels // islistviewcommand false // DISABLE FILTER
		return enabled_ID, is_open
		elseif not is_open then r.MIDIEditor_LastFocused_OnCommand(2, false) -- File: Close window;  islistviewcommand false // close if wasn't initially open and filter wasn't enabled otherwise will stay open until the 2nd run to re-enable the filter
		end
	end
end
-- USAGE EXAMPLE:
-- r.PreventUIRefresh(1)
--local enabled_ID, is_open = Clear_Restore_MIDI_Channel_Filter()
--DO STUFF
-- if enabled_ID then Clear_Restore_MIDI_Channel_Filter(enabled_ID, is_open) end
-- r.PreventUIRefresh(-1)



local ME = r.MIDIEditor_GetActive()
local take = r.MIDIEditor_GetTake(ME)


function are_notes_selected(ME, take)
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local retval, notecnt, ccevtcnt, textsyxevtcnt = r.MIDI_CountEvts(take)
	for i = 0, notecnt-1 do
	local retval, sel, muted, startppq, endppq, chan, pitch, vel = r.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		if sel then return true end
	end
end


function Notes_Selected(ME, take) -- in current MIDI channel
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
return r.MIDI_EnumSelNotes(take, -1) ~= -1 -- OR >= 0 OR > -1 // 1st selected note
end


function CC_Evts_Selected(ME, take) -- in current MIDI channel but across all CC lanes
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
return r.MIDI_EnumSelCC(take, -1) ~= -1 -- -- OR >= 0 OR > -1 // 1st selected CC event // bar velocity, text/notation events and SysEx
end


function Notes_CCEvts_Selected(ME, take)
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
return r.MIDI_EnumSelNotes(take, -1) ~= -1, -- -- OR >= 0 OR > -1 // 1st selected note // in current MIDI channel
r.MIDI_EnumSelCC(take, -1) ~= -1 -- 1st selected CC event // in current MIDI channel but across all CC lanes // bar velocity, text/notation events and SysEx
end


function Evts_Selected(ME, take) -- in current MIDI channel but across all CC lanes + notes
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
return r.MIDI_EnumSelEvts(take, -1) ~= -1 -- -- OR >= 0 OR > -1 // 1st selected event
end


function All_Sel_CCEvts_Belong_To_Visble_OR_Last_Clicked_Lane(ME, take) -- ONLY USEFUL IF JUST ONE CC LANE IS OPEN WHICH MIGHT NOT BE THE CASE
-- 2 boolean return values: if any selected and if true then if all belong to the same lane
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local autom_lane = r.MIDIEditor_GetSetting_int(ME, 'last_clicked_cc_lane') -- last clicked if several lanes are displayed, otherwise currently visible lane
local autom_lane = autom_lane >= 256 and autom_lane <= 287 and autom_lane - 256 or autom_lane -- for events in 14-bit lanes MIDI_GetCC() returns 7-bit CC#
local first_sel_evt_idx = r.MIDI_EnumSelCC(take, -1) -- idx of the first selected event
local i = 0
local last_sel_evt_idx
	repeat
	local idx = r.MIDI_EnumSelCC(take, i)
		if r.MIDI_EnumSelCC(take, i+1) == -1 then last_sel_evt_idx = idx break end
	i = i + 1
	until idx == -1
local first = {r.MIDI_GetCC(take, first_sel_evt_idx)} -- retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 // -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all CC events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
local last = {r.MIDI_GetCC(take, last_sel_evt_idx)}
return first_sel_evt_idx > -1, first[7] == autom_lane and first[7] == last[7] -- 7th return value is CC#
end


function count_selected_notes(ME, take)
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local sel_note_cnt = 0
local noteidx = -1 -- since MIDI_EnumSelNotes returns the index of the next selected MIDI note, the first of which would be 0
	repeat
	noteidx = r.MIDI_EnumSelNotes(take, noteidx)
	sel_note_cnt = noteidx > -1 and sel_note_cnt+1 or sel_note_cnt
	until noteidx == -1 -- -1 if there are no more or no selected events
return sel_note_cnt
end


function count_selected_events(ME, take, evt_type, lane, ch) -- TEXT/SYSEX/NOTATION EVENTS ROUTINE ISN'T DEVELOPED
-- IF FILTER OR MULTICHANNEL MODE ARE ENABLED THEY WILL HAVE TO BE DISABLED SO THE FUNCTIONS TARGET ALL MIDI CHANNELS AND NOT ONLY THE ACTIVE ONES
-- evt_type is a string: '' - all, 'n' - notes, 'c' - cc, 't' - text/sysex
-- cc covers 160 - Poly Aftertouch, 176 - CC, Bank/Program select, Bank select, 192 - Program change, 208 - Channel pressure (aftertouch), 224 - Pitch (bend)
-- Use the above numbers as lane indices bar CC lanes (176) for which actual CC# should be used in the range of 0-119
-- lane and ch are either tables or integers if only single lane or channel
-- lane property is irrelevant for notes
-- ch property is irrelevant to text, notation and sysex events
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local typ = evt_type:match('[nct]+')
local EnumEvts, GetEvt = table.unpack(not typ and {r.MIDI_EnumSelEvts, r.MIDI_GetEvt}
or typ == 'n' and {r.MIDI_EnumSelNotes, r.MIDI_GetNote}
or typ == 'c' and {r.MIDI_EnumSelCC, r.MIDI_GetCC}
or typ == 't' and {r.MIDI_EnumSelTextSysexEvts, r.MIDI_GetTextSysexEvt} or {})
local ch = type(ch) == 'table' and ch or {ch}
local lane = type(lane) == 'table' and lane or {lane}
local sel_evt_cnt = 0
local idx = -1 -- since EnumEvts returns the index of the next selected MIDI event, the first of which would be 0
	repeat
	idx = EnumEvts(take, idx)
		if idx == -1 then break end
	local evt_t = {GetEvt(take, idx)}
	local ch_match, lane_match
		if ch and typ ~= 't' then
			for _, ch in ipairs(ch) do
				if evt_t[6] == ch then ch_match = true break end -- in notes and cc event props ch is 6th return value
			end
		end
		if lane and typ ~= 'n' then
			for _, lane in ipairs(lane) do
				if evt_t[5] == 176 and lane == msg2 or evt_t[5] == cc then lane_match = true break end -- in cc event props chanmsg is 5th return value, for CC messages (chanmsg = 176) lane number (CC#) is returned as msg2 value, for non-CC messages instead of actual lane number chanmsg value is evaluated since it's supposed to be passed as lane argument into the function // when Bank/Program select lane is visible the number of selected events there is trippled because they're counted in lanes 0 and 32 as well
			end
		end

	if typ == 'n' then -- notes,
	sel_evt_cnt = idx > -1 and (ch and ch_match or not ch) and sel_evt_cnt+1 or sel_evt_cnt
	elseif typ == 'c' then
	sel_evt_cnt = idx > -1 and (ch and ch_match or not ch) and (lane and lane_match or not lane) and sel_evt_cnt+1 or sel_evt_cnt
	elseif typ == 't' then
	sel_evt_cnt = idx > -1 and (lane and lane_match or not lane) and sel_evt_cnt+1 or sel_evt_cnt
	else
	sel_evt_cnt = idx > -1 and sel_evt_cnt+1 or sel_evt_cnt
	end
	until idx == -1 -- -1 if there are no more or no selected events

return sel_evt_cnt

end



function selected_notes_exist(ME, take)
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local noteidx = -1 -- since MIDI_EnumSelNotes returns the index of the next selected MIDI note, the first of which would be 0
	repeat
	noteidx = r.MIDI_EnumSelNotes(take, noteidx)
		if noteidx > 0 then break end -- at least 1 sel note
	until noteidx == -1 -- -1 if there are no more or no selected events
end


function find_first_next_note(take, start_pos) -- the first which starts later than the given one (start_pos) which allows ignoring chord notes in case they start simultaneously
local retval, notecnt, _, _ = r.MIDI_CountEvts(take)
local i = 0
	while i < notecnt do
	local retval, _, _, start_pos_next, _, _, _, _ = r.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		if start_pos_next > start_pos then return start_pos_next end
	i = i+1
	end
end


function Notes_Overlap_Ignored_Chords(take) -- chord notes which start simultaneously are recognized as overlapping
local retval, notecnt, _, _ = reaper.MIDI_CountEvts(take)
local i = 0
	while i < notecnt do
	local retval, _, _, _, end_pos, _, _, _ = reaper.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
	local retval, _, _, start_pos, _, _, _, _ = reaper.MIDI_GetNote(take, i+1)
		if end_pos > start_pos and start_pos ~= 0 then return true end -- start_pos ~= 0 to ignore a non-existing note index beyond the note count whose start_pos will be 0
	i = i + 1
	end
end


function Notes_Overlap_Respected_Chords(take) -- chord notes which start simultaneously aren't recognized as overlapping
local retval, notecnt, _, _ = reaper.MIDI_CountEvts(take)
local i = 0
	while i < notecnt do
	local retval, _, _, start_pos1, end_pos, _, _, _ = reaper.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
	local retval, _, _, start_pos2, _, _, _, _ = reaper.MIDI_GetNote(take, i+1)
		if start_pos1 < start_pos2 and end_pos > start_pos and start_pos2 ~= 0 then return true end -- start_pos1 < start_pos2 makes sure that chord notes which start simultanelusly aren't recognized as overlapping, start_pos ~= 0 to ignore a non-existing note index beyond the note count whose start_pos will be 0
	i = i + 1
	end
end


function Correct_Overlapping_Notes1(take) -- chord notes with start simultaneously are recognized as overlapping, so chords aren't preserved
local retval, notecnt, _, _ = reaper.MIDI_CountEvts(take)
local i = 0
	while i < notecnt do
	local retval, _, _, _, end_pos, _, _, _ = reaper.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
	local retval, _, _, start_pos, _, _, _, _ = reaper.MIDI_GetNote(take, i+1)
		if end_pos > start_pos and start_pos ~= 0 then -- start_pos ~= 0 to ignore a non-existing note index beyond the note count whose start_pos will be 0 thereby preventing setting the last note end_pos to 0
		reaper.MIDI_SetNote(take, i, selectedIn, mutedIn, startppqposIn, start_pos, chanIn, pitchIn, velIn, true) -- noSortIn
		end
	i = i + 1
	end
reaper.MIDI_Sort(take)
end


function Correct_Overlapping_Notes2(take) -- chord notes with start simultaneously aren't recognized as overlapping, so chords are preserved, uniformly correcting chord notes against notes which start later
local retval, notecnt, _, _ = reaper.MIDI_CountEvts(take)
local i = 0
	while i < notecnt do
	local retval, _, _, start_pos1, end_pos, _, _, _ = r.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
	local retval, _, _, start_pos2, _, _, _, _ = r.MIDI_GetNote(take, i+1)
	if start_pos1 == start_pos2 then -- collect all notes statring simultaneously (chord notes)
	chord_notes_t[i], chord_notes_t[i+1] = 1, 1 -- dummy values
	elseif start_pos1 < start_pos2 and end_pos > start_pos2 and start_pos2 ~= 0 then -- as soon as an overlapping note  which starts later (the closest one) is found // start_pos1 < start_pos2 to ignore simultaneous chord notes, start_pos ~= 0 to ignore a non-existing note index beyond the note count whose start_pos will be 0 thereby preventing setting the last note end_pos to 0
		if next(chord_notes_t) then -- if the table isn't empty, i.e. there're chord notes starting simultaneously
			for note_idx in pairs(chord_notes_t) do -- correct them (trim down to the start of the closest overlapping note)
			r.MIDI_SetNote(take, note_idx, selectedIn, mutedIn, startppqposIn, start_pos2, chanIn, pitchIn, velIn, true) -- noSortIn
			end
		r.MIDI_Sort(take)
		chord_notes_t = {}
		else -- if no chord notes, simply correct the current note
		r.MIDI_SetNote(take, i, selectedIn, mutedIn, startppqposIn, start_pos2, chanIn, pitchIn, velIn, true) -- noSortIn
		end
	end
	i = i + 1
	end
r.MIDI_Sort(take)
end


local ME = r.MIDIEditor_GetActive()
local take = r.MIDIEditor_GetTake(ME)

function re_store_sel_MIDI_notes(take,t) -- store and restore (in the current MIDI channel if Channel filter is enabled)

local retval, notecnt, ccevtcnt, textsyxevtcnt = r.MIDI_CountEvts(take)

	if not t then
	local sel_note_t = {}
		for i = 0, notecnt-1 do
		local retval, sel, mute, startpos, endpos, chan, pitch, vel = r.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
			if sel then sel_note_t[#sel_note_t+1] = i end
		end
	--[[ ALTERNATIVE
		local i = 0
			repeat
			local note = r.MIDI_EnumSelNotes(take, i)
				if note > -1 then sel_note_t[#sel_note_t+1] = i end
			i = i+1
			until note == -1
	]]
	return sel_note_t
	elseif #t > 0 then
		for _, v in ipairs(t) do
		r.MIDI_SetNote(take, v, true, false, -1, -1, 0, -1, -1, true) -- noteidx - v, selectedIn - true, mutedIn - false, startppqposIn and endppqposIn both -1, chanIn - 0, velIn -1, noSortIn - true since only one note params are set
		end
	end

end


local ME = r.MIDIEditor_GetActive()
local take = r.MIDIEditor_GetTake(ME)

function Cursor_outside_pianoroll(take)

r.PreventUIRefresh(1)
local stored_edit_cur_pos = r.GetCursorPosition()
local item = r.GetMediaItemTake_Item(take)
ACT(40443, ME) -- View: Move edit cursor to mouse cursor
local edit_cur_pos = r.GetCursorPosition()
ACT(40037, ME) -- View: Go to end of file
local item_end = r.GetCursorPosition()
ACT(40036, ME) -- View: Go to start of file
local item_start = r.GetCursorPosition()
r.SetEditCurPos(stored_edit_cur_pos, 0, 0) -- restore edit cursor pos; moveview is 0, seekplay is 0
r.PreventUIRefresh(-1)

	if edit_cur_pos >= item_end or edit_cur_pos <= item_start then
	return true end

end


function Get_Mouse_Coordinates_MIDI(wantSnapped) -- wantsnapped is boolean
-- inserts a note at mouse cursor, gets its pitch and start position and then deletes it
-- advised to use with Get_Note_Under_Mouse() to avoid other notes, that is only run this function if that function returns nil to be sure that there's no note under mouse

local ME = r.MIDIEditor_GetActive()
local take = r.MIDIEditor_GetTake(ME)
local is_snap = r.GetToggleCommandStateEx(32060, 1014) -- View: Toggle snap to grid
local ACT = r.MIDIEditor_LastFocused_OnCommand

r.PreventUIRefresh(1)
r.Undo_BeginBlock() -- to prevent creation of undo point by 'Edit: Insert note at mouse cursor' and 'Edit: Delete notes'

	if wantSnapped and is_snap == 0 or not wantSnapped and is_snap == 1 then
	ACT(1014, false) -- View: Toggle snap to grid // islistviewcommand false
	end

local retval, notecnt, ccevtcnt, textsyxevtcnt = r.MIDI_CountEvts(take)

local sel_note_t = {}
	for i = 0, notecnt-1 do -- store currently selected notes
	local retval, sel, mute, startpos, endpos, chan, pitch, vel = r.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		if sel then sel_note_t[#sel_note_t+1] = i end
	end

r.MIDI_SelectAll(take, false) -- deselect all notes so the inserted one is the only selected and can be gotten hold of

ACT(40001, false) -- Edit: Insert note at mouse cursor // islistviewcommand false

local retval, notecnt, ccevtcnt, textsyxevtcnt = r.MIDI_CountEvts(take) -- re-count after insertion

		for i = 0, notecnt-1 do -- get index and cordinates of the inserted note which is selected by default and the only one selected since the rest have been deselected above; the coordinates correspond to the mouse cursor position wihtin piano roll
		local retval, sel, mute, startpos, endpos, chan, pitch, vel = r.MIDI_GetNote(take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
			if sel then idx, x_cord, y_coord = i, startpos, pitch break end
		end

--r.MIDI_DeleteNote(take, idx) -- delete the inserted note // buggy, lengthens the note overlaped by the one being deleted
-- https://forum.cockos.com/showthread.php?t=159848
-- https://forum.cockos.com/showthread.php?t=195709

ACT(40002, false) -- Edit: Delete notes // islistviewcommand false

--do return end

	-- restore note selection
	for _, idx in ipairs(sel_note_t) do
	r.MIDI_SetNote(take, idx, true, x, x, x, x, x, x, true) -- selectedIn true, mutedIn, startppqposIn, endppqposIn, chanIn, noSortIn are nil, noSort true since multiple notes
	end
	r.MIDI_Sort(take)
	-- restore orig Snap state
	local rest = r.GetToggleCommandStateEx(32060, 1014) ~= is_snap and ACT(1014, false)

r.PreventUIRefresh(-1)
r.Undo_EndBlock('',-1) -- to prevent creation of undo point by 'Edit: Insert note at mouse cursor' and 'Edit: Delete notes'

return x_coord, y_coord, r.MIDI_GetProjTimeFromPPQPos(take, x_coord)
-- OR return {x_coord, y_coord, r.MIDI_GetProjTimeFromPPQPos(take, x_coord)}
end


local hwnd = r.MIDIEditor_GetActive()
local midi_take = r.MIDIEditor_GetTake(hwnd)

function Get_Note_Under_Mouse(hwnd, midi_take) -- returns note index or nil if no note under mouse cursor
r.PreventUIRefresh(1)
r.Undo_BeginBlock() -- to prevent creation of undo point by 'Edit: Split notes at mouse cursor'
local retval, notecntA, ccevtcnt, textsyxevtcnt = r.MIDI_CountEvts(midi_take)
local props_t = {}
	for i = 0, notecntA-1 do -- collect current notes properties
	local retval, sel, muted, startppq, endppq, chan, pitch, vel = r.MIDI_GetNote(midi_take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
	props_t[#props_t+1] = {startppq, endppq, pitch}
	end
local snap = r.GetToggleCommandStateEx(32060, 1014) == 1 -- View: Toggle snap to grid
local off = snap and r.MIDIEditor_OnCommand(hwnd, 1014) -- disable snap
r.MIDIEditor_OnCommand(hwnd, 40052)	-- Edit: Split notes at mouse cursor
local on = snap and r.MIDIEditor_OnCommand(hwnd, 1014) -- re-enable snap
local retval, notecntB, ccevtcnt, textsyxevtcnt = r.MIDI_CountEvts(midi_take) -- re-count after split
local idx, fin, note
	if notecntB > notecntA then -- some note was split
		for i = 0, notecntB-1  do
		retval, sel, muted, startppq, endppq, chan, pitch, vel = r.MIDI_GetNote(midi_take, i) -- only targets notes in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
			--[[-- INEFFICIENT
			if not idx then -- locate the 1st part of the split note
				for k, v in ipairs(props_t) do
					if k-1 == i -- k-1 since table index is 1-based while note count is 0-based; the 1st part of the note will keep the note original index after split and after restoration
					and startppq == v[1] and endppq ~= v[2] and pitch == v[3] then
					idx, fin, note = i, endppq, pitch
					break end
				end
			elseif idx and startppq == fin and pitch == note then -- locate the 2nd part of the split note
			r.MIDI_DeleteNote(midi_take, i) -- delete the 2nd part
			r.MIDI_SetNote(midi_take, idx, false, false, -1, endppq, -1, -1, -1, false) -- restore the note original length // selected false, muted false; startppq, chan, pitch, vel all -1, noSort false
			return idx end
			---]]-----
		local v = props_t[i+1] -- +1 since table index is 1-based while note count is 0-based; the 1st part of the note will keep the note original index after split and after restoration
			if v and startppq == v[1] and endppq ~= v[2] and pitch == v[3] then
			idx, fin, note = i, endppq, pitch end
			if idx and startppq == fin and pitch == note then -- locate the 2nd part of the split note
			r.MIDI_DeleteNote(midi_take, i) -- delete the 2nd part
			r.MIDI_SetNote(midi_take, idx, x, x, x, endppq, x, x, x, false) -- restore the note original length // selected, muted, startppq, chan, pitch, vel all nil, noSort false because only one note is affected
			return idx end
		end
	end
r.PreventUIRefresh(-1)
r.Undo_EndBlock('',-1) -- to prevent creation of undo point by 'Edit: Split notes at mouse cursor'
end



function is_dotted(num) -- find if a note is already dotted, arg is duration in QN
-- https://www.liveabout.com/music-theory-101-dotted-notes-rests-4686771
-- https://hellomusictheory.com/learn/dotted-notes/
--local t = {0.03125, 0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8} -- 1/128, 1/64, 1/32, 1/16, 1/8, 1/4, 1/2, 1, 2 // if using raw QN value num/1.5
local t = {0.5, 1, 2, 4, 8, 16, 32, 64, 128} -- 2 whole notes, whole, breve, crotchet, eighth, sixteenth etc // if converting raw QN value to fraction of a quarter note: 4/(num/1.5)
local num = 4/(num/1.5)
	for _, div in ipairs(t) do
		if num == div then return true end
	end
end


function round_note(num)
-- used in 'Convert selected notes to dotted'
-- round note duration down or up to the closest straight musical division
--local t = {0.03125, 0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8} -- 1/128, 1/64, 1/32, 1/16, 1/8, 1/4, 1/2, 1, 2 // if using  raw QN value
local t = {0.5, 1, 2, 4, 8, 16, 32, 64, 128} -- 2 whole notes, whole, breve, crotchet, eighth, sixteenth etc // if converting raw QN value to fraction of a quarter note: 4/num, the return value must then be converted back to raw QN: 4/return value
	for k, div in ipairs(t) do
		if num == div then return div end
	local nxt = t[k+1]
		if nxt and num > div and num < nxt then
			if num - div < nxt - num then
			return div
			else return nxt
			end
		elseif k == 1 and num < div
		or k == #t and num > div
		then return div
		end
	end
end



function is_CC_Env_active(ME, take) -- whether there're events
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local cur_CC_lane = r.MIDIEditor_GetSetting_int(ME, 'last_clicked_cc_lane') -- last clicked if several lanes are displayed, otherwise currently visible lane
local cur_CC_lane = cur_CC_lane == 513 and 224 or cur_CC_lane == 515 and 208 or cur_CC_lane == 514 and 192 or cur_CC_lane -- converting  MIDIEditor_GetSetting_int() function return values to MIDI_GetCC() chanmsg return value: pitch bend, channel pressure, program change, regular CC
local evt_idx = 0
	repeat
	local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- Velocity / Off Velocity / Text events / Notation enents / SySex lanes are ignored || only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel
	-- Watch out for 'Bank/Program select' lane (chanmsg 176 but no dedicated lane number) because the number of events there is trippled as they're counted in lanes 0 and 32 as well
		if retval then
			if chanmsg == 176 and msg2 == cur_CC_lane then return msg2  -- CC message, chanmsg = 176 // as soon as event is found in the current lane
			elseif chanmsg == cur_CC_lane then -- non-CC message (chanmsg =/= 176)
			return chanmsg == 192 and 'Program change' or chanmsg == 208 and 'Channel pressure' or chanmsg == 224 and 'Pitch bend'
			end
		end
	evt_idx = evt_idx + 1
	until not retval
end


-- USE THIS, COMPREHENSIVE FUNCTION or Get_Currently_Active_Chan_And_Filter_State2()
function Get_Currently_Active_Chan_And_Filter_State1(ME, take)
-- returns number of currently active channel is channel filter is enabled or multiple active channels if multichannel mode is enabled
-- if filter isn't enabled and no multichannel mode, the returned table will be empty and the filter state will be nil
-- MIDI Ed actions toggle state can only be evaluated when ME is open
local is_open = ME or r.MIDIEditor_GetActive() -- check if MIDI Editor is open
-- OR
-- local is_open = ME or r.GetToggleCommandStateEx(32060, 40218) > -1
local open = not is_open and r.Main_OnCommand(40153, 0) -- Item: Open in built-in MIDI editor (set default behavior in preferences)
local ME = r.MIDIEditor_GetActive()
local take = not take and r.MIDIEditor_GetTake(ME) or take
local act_ch_t, filter_state = {}

	for i = 40218, 40233 do -- ID range of actions 'Channel: Show only channel X' which select a channel in the filter and enable the filter
-- 	for i = 40643, 40658 do -- ID range of actions 'Channel: Toggle channel X' -- unsuitable since these aren't mutually exclusive, they apply to the filter Multichannel mode
		if r.GetToggleCommandStateEx(32060, i) == 1 then
		filter_state = i-40217 break end -- currently active channel 1-based
	end

	for i = 40643, 40658 do -- ID range of actions 'Channel: Toggle channel X' which activate the Multichannel mode and aren't mutually exclusive
		if r.GetToggleCommandStateEx(32060, i) == 1 then
		act_ch_t[#act_ch_t+1] = i-40642 -- store 1-based ch #
		end
	end

	if not is_open then r.MIDIEditor_LastFocused_OnCommand(2, false) end -- File: Close window; islistviewcommand false

-- the table is empty and filter_state is false when the filter isn't enabled and some channel is selected in its drop-down menu or when All channels option is enabled regardless of filter actual state
-- the table contains a single channel and filter_state is assigned a channel number when the filter is enabled and a single channel is exclusively displayed by being selected in the filter drop-down menu
-- the table contains several channels and filter_state is true when Multichannel mode is enabled
-- so basically unlike the next Get_Currently_Active_Chan_And_Filter_State2() function this function cannot detect a single channel selected in the filter when the filter is OFF
return act_ch_t, filter_state

end


-- USE THIS, COMPREHENSIVE FUNCTION
function Get_Currently_Active_Chan_And_Filter_State2(obj, ME) -- via chunk, ME is MIDI Editor pointer
-- returns channel filter status and the channels currently selected in the filter regardless of its being enabled in 1-BASED COUNT
-- for a single active channel when filter is enabled see Get_Ch_Selected_In_Ch_Filter() or Ch_Filter_Enabled1()
-- filter enabled status is true when either a single channel is active, multichannel mode is active or 'Show only events that pass the filter' option is checked in Event filter dialogue and can be true when 'All channels' option is active in the menu as well;
-- when the table contains a single channel this means this channel is selected in the filter drop-down menu, in this case the filter status indicates whether this channel is exclusively displayed;
-- when the table contains several channels the filter state is always true;
-- the table's being empty means that ALL channels are active, i.e. 'All channels' option is selected in the filter drop-down menu while filter isn't enabled, filter_state will be false, in this case last active channel will be returned;
-- 16 entries in the table mean that ALL channels are active, i.e. 'All channels' option is selected while the filter is enabled, filter_state will be true
local item = r.ValidatePtr(obj, 'MediaItem*')
local take = r.ValidatePtr(obj, 'MediaItem_Take*')
local item = item and obj or take and r.GetMediaItemTake_Item(obj)
	if not item then return end
local take = take and obj or r.GetActiveTake(item)
local retval, takeGUID = r.GetSetMediaItemTakeInfo_String(take, 'GUID', '', false) -- setNewValue false
local ret, chunk = r.GetItemStateChunk(item, '', false) -- isundo
local takeGUID = takeGUID:gsub('[%(%)%+%-%[%]%.%^%$%*%?%%]','%%%0') -- escape
local take_found
--local ch_bit_t = {1,2,4,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536}
local act_ch_t, filter_state = {}
	for line in chunk:gmatch('[^\n\r]+') do
		if line:match(takeGUID) then take_found = 1 end
		if take_found and line:match('EVTFILTER') then
		local cnt = 0
			for val in line:gmatch('[%-%d]+') do
			cnt = val and cnt+1 or cnt
				if cnt == 7 then filter_state = val break end -- filter boolean is 7th field
			end
		local val = line:match('EVTFILTER (%d+)')
			if val then
				for i = 0, 15 do
				local bit = 2^i
					if val&bit == bit then -- channel numbers are 0-based logarithm of the value from the chunk with base 2
					act_ch_t[#act_ch_t+1] = i+1 -- 1-based channel number // can be changed
					end
				end
			break end -- break to prevent chunk loop from continuing and getting data from next takes because take_found remains valid, it could be reset to nil at this point but this wouldn't stop the chunk loop
		end
	end
return #act_ch_t > 0 and act_ch_t or {r.MIDIEditor_GetSetting_int(ME, 'default_note_chan')+1}, filter_state == '1' -- 1-based last active channel number
end



------------ THESE ARE CUT-DOWN VERSIONS OF THE ABOVE Get_Currently_Active_Chan_And_Filter_State 1 & 2 ----------------------
function Ch_Filter_Enabled1(ME, take)
-- MIDI Ed actions toggle state can only be evaluated when ME is open
-- returns 1-based # of a channel currently selected in the enabled channel filter so only supports exclusively displayed channel, not Multichannel mode
local is_open = ME or r.MIDIEditor_GetActive() -- check if MIDI Editor is open
-- OR
-- local is_open = ME or r.GetToggleCommandStateEx(32060, 40218) > -1
local open = not is_open and r.Main_OnCommand(40153, 0) -- Item: Open in built-in MIDI editor (set default behavior in preferences)
local ME = r.MIDIEditor_GetActive()
local take = not take and r.MIDIEditor_GetTake(ME) or take
local filter_on
	for i = 40218, 40233 do -- ID range of actions 'Channel: Show only channel X' which select a channel in the filter and enable the filter
-- 	for i = 40643, 40658 do -- ID range of actions 'Channel: Toggle channel X' -- unsuitable since these aren't mutually exclusive, they apply to the filter Multichannel mode
		if r.GetToggleCommandStateEx(32060, i) == 1 then
			if not is_open then r.MIDIEditor_LastFocused_OnCommand(2, false) end -- File: Close window; islistviewcommand false
		return i-40217 end -- currently active channel 1-based
	end
	if not is_open then r.MIDIEditor_LastFocused_OnCommand(2, false) end -- File: Close window; islistviewcommand false // in case the loop didn't exit early
end


function Ch_Filter_Enabled2(obj) -- via chunk, no need to open the MIDI Ed
-- filter enabled status is true when either a single channel is active, multichannel mode is active or 'Show only events that pass the filter' option is checked in Event filter dialogue and can be true when 'All channels' option is active in the menu as well
local item = r.ValidatePtr(obj, 'MediaItem*')
local take = r.ValidatePtr(obj, 'MediaItem_Take*')
local item = item and obj or take and r.GetMediaItemTake_Item(obj)
	if not item then return end
local take = take and obj or r.GetActiveTake(item)
local retval, takeGUID = r.GetSetMediaItemTakeInfo_String(take, 'GUID', '', false) -- setNewValue false
local ret, chunk = r.GetItemStateChunk(item, '', false) -- isundo
local takeGUID = takeGUID:gsub('[%(%)%+%-%[%]%.%^%$%*%?%%]','%%%0') -- escape
local take_found
	for line in chunk:gmatch('[^\n\r]+') do
		if line:match(takeGUID) then take_found = 1 end
		if take_found and line:match('EVTFILTER') then
		local cnt = 0
			for val in line:gmatch('[%-%d]+') do
			cnt = val and cnt+1 or cnt
				if cnt == 7 then return val == '1' end -- filter boolean is 7th field
			end
		end
	end
end


function Get_Ch_Selected_In_Ch_Filter(obj)
-- return value is 1-based channel # regardless of whether the filter is enabled or not, or nil if several channels are selected in 'Multichannel' mode or 'All channels' so doesn't support Multichannel mode, ONLY SUPPORTS 1 ACTIVE CHANNEL
local item = r.ValidatePtr(obj, 'MediaItem*')
local take = r.ValidatePtr(obj, 'MediaItem_Take*')
local item = item and obj or take and r.GetMediaItemTake_Item(obj)
	if not item then return end
local take = take and obj or r.GetActiveTake(item)
local retval, takeGUID = r.GetSetMediaItemTakeInfo_String(take, 'GUID', '', false) -- setNewValue false
local ret, chunk = r.GetItemStateChunk(item, '', false) -- isundo
local takeGUID = takeGUID:gsub('[%(%)%+%-%[%]%.%^%$%*%?%%]','%%%0') -- escape
local take_found
	for line in chunk:gmatch('[^\n\r]+') do
		if line:match(takeGUID) then take_found = 1 end
		if take_found and line:match('EVTFILTER') then
		local val = line:match('EVTFILTER (%d+)')
			if val then
				for i = 0, 15 do
					if val+0 == 2^i then return i+1 end -- channel numbers are 0-based logarithm of the value from the chunk with base 2
				end
			--[[ OR without the loop
			-- https://www.gammon.com.au/scripts/doc.php?lua=math.log
			local chan_No = math.log(val)/math.log(2)
			return chan_No == math.floor(chan_No) and chan_No+1 -- if integer
			]]
			end
		end
	end
end
--------- THESE ARE CUT-DOWN VERSIONS OF THE ABOVE Get_Currently_Active_Chan_And_Filter_State 1 & 2 END ---------------


function Prompt_to_Enable_MIDI_Ch_Filter(ME, take) -- for scripts where selection of one MIDI channel is essencial due to the use of Re_Store_Selected_CCEvents3() since there's no way to ascertain that a channel is actually selected in the channel filter

-- MIDI Ed actions toggle state can only be evaluated when ME is open
local ME = ME or r.MIDIEditor_GetActive()
local take = not take and r.MIDIEditor_GetTake(ME) or take

-- MIDIEditor_GetSetting_int(ME, 'default_note_chan') used inside Re_Store_Selected_CCEvents3() is unreliable in getting the current channel because when 'All Channels' or 'Multichannel' option is selected in the Channel filter it still returns the last active channel which may not be the channel the user intends to use as the source but which will be selected by Re_Store_Selected_CCEvents3() restore routine and if such channel has no events the script will throw an error message about absence of valid selected events, hence the need to make the user select the channel explicitly; restoring the channel selection to 'All Channels' in this case will not look consistent if the user initially had channel selected (some bits refer to the script 'Copy or Move selected notes and/or other MIDI events in visible lanes to specified MIDI channels')

local filter_on
	for i = 40218, 40233 do -- ID range of actions 'Channel: Show only channel X' which select a channel in the filter and enable the filter
-- 	for i = 40643, 40658 do -- ID range of actions 'Channel: Toggle channel X' -- unsuitable since these aren't mutually exclusive and apply to the filter Multichannel mode which must be avoided in this script exactly like 'All channels'
		if r.GetToggleCommandStateEx(32060, i) == 1 then filter_on =  1 break end
	end
	if not filter_on then
	local s = ' '
	r.MB(s:rep(10)..'The script only supports one source channel.\n\n   It appears that the MIDI channel filter is not enabled.\n\n\t'..s:rep(6)..'For the script to work reliably\n\n  please select the MIDI channel in the filter and enable it.', 'ALERT', 0)
	return true end
end
-- USE:
-- if Prompt_to_Enable_MIDI_Ch_Filter() then return r.defer(function() do return end end) end




function Re_Store_Selected_CCEvents1(ME, take, t)
-- !!!! will work if no events were deleted or added in the interim regardless of the MIDI channel
-- if channel filter is enabled per channel clicking within one MIDI channel doesn't affect event selection in other MIDI channels
-- if channel filter is enabled per channel deleting selected events in one MIDI channel with action doesn't affect selected events in other MIDI channels; in the same MIDI channels selected events are deleted regardless of their lane visibility
-- with the mouse CC events can only be selected in one lane, the selection is exclusive just like track automation envelope nodes unless Shift is held down, marque selection or Ctrl+A are used
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take

	if not t then
	local t, evt_idx = {}, 0
		repeat
		local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for events from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
			if sel then t[#t+1] = evt_idx -- store and deselect
			r.MIDI_SetCC(take, evt_idx, false, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn false, noSortIn true // deselect
			end
		evt_idx = evt_idx+1
		until not retval
	r.MIDI_Sort(take)
--	r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation
	return t
	else
--	r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation
	local evt_idx = 0
		repeat -- deselect all
		local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- just to use retval to stop the loop // only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for events from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		r.MIDI_SetCC(take, evt_idx, false, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn false, noSortIn true // deselect
		evt_idx = evt_idx+1
		until not retval
	r.MIDI_Sort(take)
		for _, evt_idx in ipairs(t) do -- restore
		r.MIDI_SetCC(take, evt_idx, true, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn, noSortIn true
		end
	r.MIDI_Sort(take)
	end
end


function Re_Store_Selected_CCEvents2(ME, take, t, deselect_before_restore) -- deselect_before_restore is boolean
-- !!!! will work EVEN IF events were deleted or added in the interim BUT FOR THE  CURRENTLY ACTIVE MIDI CHANNELS IF THE MIDI FILTER IS ENABLED
-- if channel filter is enabled per channel clicking within one MIDI channel doesn't affect event selection in other MIDI channels
-- if channel filter is enabled per channel deleting selected events in one MIDI channel with action doesn't affect selected events in other MIDI channels; in the same MIDI channels selected events are deleted regardless of their lane visibility
-- with the mouse CC events can only be selected in one lane, the selection is exclusive just like track automation envelope nodes unless Shift is held down, marque selection or Ctrl+A are used
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take

	if not t then
	local t, evt_idx = {}, 0
		repeat
		local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for events from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
			if sel then
			t[#t+1] = {retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3, evt_idx} -- store and deselect // evt_idx is stored to be able to reselect events in the visible lanes with Only_Select_Evnts_In_Visble_CC_Lanes() after using Get_Currently_Visible_CC_Lanes()
			r.MIDI_SetCC(take, evt_idx, false, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn false, noSortIn true // deselect
			end
		evt_idx = evt_idx+1
		until not retval
	r.MIDI_Sort(take)
--	r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation
	return t
	else
--	r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation
		if deselect_before_restore then
		local evt_idx = 0
			repeat -- deselect all
			local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- just to use retval to stop the loop // probably MIDI_SetCC() boolean return value could be used instead //  only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for events from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
			r.MIDI_SetCC(take, evt_idx, false, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn false, noSortIn true // deselect
			evt_idx = evt_idx+1
			until not retval
		r.MIDI_Sort(take)
		end
	r.MIDI_Sort(take)
	local evt_idx = 0
		repeat
		local evt_data = {r.MIDI_GetCC(take, evt_idx)} -- only targets events in the current MIDI channel if Channel filter is enabled
	--	local restore
			for _, evt_data_stored in ipairs(t) do
			local match = 0
				for i = 3, 8 do -- extract and compare values one by one; only 6 values are relevant, 3 - 8, i.e. muted, ppqpos, chanmsg, chan, msg2, msg3
				local val1 = table.unpack(evt_data, i, i) -- the 3d argument isn't really necessary since even when multiple values are returned starting from index up to the end, only the first one is stored
				local val2 = table.unpack(evt_data_stored, i, i)
					if val1 == val2 then match = match+1 end
			 -- OR
			 -- match = evt_data[i] == evt_data_stored[i] and match+1 or match
				end
				if match == 6 then restore = 1 break end -- 6 return values match
			-- OR
			-- if match == 6 then break end -- 6 return values match
			end
			if restore then -- restore
		 -- OR
		 -- if match == 6 then
			local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = table.unpack(evt_data) -- if only selection and event count changed these values aren't needed
			r.MIDI_SetCC(take, evt_idx, true, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn, noSortIn true
			end
		evt_idx = evt_idx+1
		until not evt_data[1] -- retval
	r.MIDI_Sort(take)
	end
end


function Re_Store_Selected_CCEvents3(ME, take, t, deselect_before_restore) -- deselect_before_restore is boolean
-- !!!! will work EVEN IF events were deleted or added in the interim FOR ALL MIDI CHANNELS
-- if channel filter is enabled per channel clicking within one MIDI channel doesn't affect event selection in other MIDI channels
-- if channel filter is enabled per channel deleting selected events in one MIDI channel with action doesn't affect selected events in other MIDI channels; in the same MIDI channels selected events are deleted regardless of their lane visibility
-- with the mouse CC events can only be selected in one lane, the selection is exclusive just like track automation envelope nodes unless Shift is held down, marque selection or Ctrl+A are used
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local cur_chan = r.MIDIEditor_GetSetting_int(ME, 'default_note_chan') -- 0-15 // returns last channel when channel filter is set to 'All Channels' or 'Multichannel'
local cur_ch_comm_ID = 40218 + cur_chan -- 40218 is 'Channel: Show only channel 01' // will be used to restore current channel after traversing all

-- if channel filter isn't enabled, it's either set to 'All channels' or to a specific channel BUT actions 'Set channel for new events to ...' which switch channels in the filter keeping it OFF only change their toggle state to ON if 'Channel: Show only channel ...' are ON as well, bug report https://forum.cockos.com/showthread.php?t=276748, so cannot be used to determine if a channel is selected in the filter while the filter is OFF, hence we're left with All channels ('Channel: Show all channels' ID 40217) as the only option also because it's not possible to use 'Set channel for new events to ...' (40482 - 40497) to disable the filter and set it to another (original) channel, since while the filter is enabled these behave exactly like 'Channel: Show only channel ...' and the only way to disable the filter is to use 'Channel: Show all channels' which effectively makes it switch to All channels option, and also because 'Set channel for new events to ...' doesn't make the filter switch if the filter is set to All channels

	if not t then
	r.PreventUIRefresh(1)
	local t = {}
		for ch = 0, 15 do
		local comm_ID = 40218 + ch -- construct command ID for the next action 'Channel: Show only channel N'; starting from 1
		r.MIDIEditor_LastFocused_OnCommand(comm_ID, false) -- islistviewcommand false // select MIDI channel
		local evt_idx = 0
			repeat
			local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for events from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
				if sel then
				t[#t+1] = {retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3, evt_idx} -- store and deselect // evt_idx is stored to be able to reselect events in the visible lanes with Only_Select_Evnts_In_Visble_CC_Lanes() after using Get_Currently_Visible_CC_Lanes()
				r.MIDI_SetCC(take, evt_idx, false, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn false, noSortIn true // deselect
				end
			evt_idx = evt_idx+1
			until not retval
		r.MIDI_Sort(take)
		end
	--	r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation https://forum.cockos.com/showthread.php?t=272887
	r.MIDIEditor_LastFocused_OnCommand(cur_ch_comm_ID, false) -- islistviewcommand false // restore original channel
	r.PreventUIRefresh(-1)
	return t
	else
	r.PreventUIRefresh(1)
--	r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation
		if deselect_before_restore then
			for ch = 0, 15 do
			local comm_ID = 40218 + ch -- construct command ID for the next action 'Channel: Show only channel N'; starting from 1
			r.MIDIEditor_LastFocused_OnCommand(comm_ID, false) -- islistviewcommand false // select MIDI channel
			local evt_idx = 0
				repeat -- deselect all
				local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- just to use retval to stop the loop // probably MIDI_SetCC() boolean return value could be used instead || only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for events from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
				r.MIDI_SetCC(take, evt_idx, false, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn false, noSortIn true // deselect
				evt_idx = evt_idx+1
				until not retval
			r.MIDI_Sort(take)
			end
		end
		for ch = 0, 15 do
		local comm_ID = 40218 + ch -- construct command ID for the next action 'Channel: Show only channel N'; starting from 1
		r.MIDIEditor_LastFocused_OnCommand(comm_ID, false) -- islistviewcommand false // select MIDI channel
		local evt_idx = 0
			repeat
			local evt_data = {r.MIDI_GetCC(take, evt_idx)} -- only targets events in the current MIDI channel if Channel filter is enabled
			local restore
				for _, evt_data_stored in ipairs(t) do
				local match = 0
					for i = 3, 8 do -- extract and compare values one by one; only 6 values are relevant, 3 - 8, i.e. muted, ppqpos, chanmsg, chan, msg2, msg3
					local val1 = table.unpack(evt_data, i, i) -- the 3d argument isn't really necessary since even when multiple values are returned starting from index up to the end, only the first one is stored
					local val2 = table.unpack(evt_data_stored, i, i)
						if val1 == val2 then match = match+1 end
				 -- OR
				 -- match = evt_data[i] == evt_data_stored[i] and match+1 or match
					end
					if match == 6 then restore = 1 break end -- 6 return values match
				 -- OR
				 -- if match == 6 then break end -- 6 return values match
				end
				if restore then -- restore
			 -- OR
			 -- if match == 6 then
				local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = table.unpack(evt_data) -- if only selection and event count changed these values aren't needed
				r.MIDI_SetCC(take, evt_idx, true, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn, noSortIn true // only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for events from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
				end
			evt_idx = evt_idx+1
			until not evt_data[1] -- retval
		r.MIDI_Sort(take)
		end
	r.MIDIEditor_LastFocused_OnCommand(cur_ch_comm_ID, false) -- islistviewcommand false // restore original channel
	r.PreventUIRefresh(-1)
	end

end


-- VISIBLE actually means selected in the left hand CC lane menu, regardless of its being collapsed or not
function Get_Currently_Visible_CC_Lanes(ME, take) -- WITH EVENTS ONLY, must be preceded and followed by Re_Store_Selected_CCEvents3() because it changes selection
-- lanes of 14-bit CC messages aren't supported because the action 40802 'Edit: Select all CC events in time selection (in all visible CC lanes)' doesn't select their events, it only does if their 7-bit lane is open; doesn't affect non-CC lanes; doesn't deselect events in invisible lanes
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local item = r.GetMediaItemTake_Item(take)
local pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
local fin = pos + r.GetMediaItemInfo_Value(item, 'D_LENGTH')
local time_st, time_end = r.GetSet_LoopTimeRange(false, false, 0, 0, false) -- isSet, isLoop, allowautoseek false // store
r.GetSet_LoopTimeRange(true, false, pos, fin, false) -- isSet true, isLoop, allowautoseek false // create time sel
r.PreventUIRefresh(1)
--r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation

-- DESELECTION OF ALL MUST BE HANDLED BY Re_Store_Selected_CCEvents3() instead of the above action

r.MIDIEditor_LastFocused_OnCommand(40802, false) -- islistviewcommand false // Edit: Select all CC events in time selection (in all visible CC lanes) -- DOESN'T AFFECT non-CC events BUT IGNORES visible 14 bit CC lanes // EXCLUSIVE, i.e. deselects all other CC events
-- https://forum.cockos.com/showthread.php?t=272887
local idx = -1 -- start with -1 since MIDI_EnumSelCC returns idx of the next event hence will actually start from 0
local evt_t, ch_t = {}, {}
	repeat
	idx = r.MIDI_EnumSelCC(take, idx)
		if idx > -1 then
		local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, idx) -- point indices are based on their time position hence points with sequential indices will likely belong to different CC envelopes // only targets events in the current MIDI channel if Channel filter is enabled // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		local stored
			for _, cc in ipairs(evt_t) do
				if cc == msg2 or cc == chanmsg then stored = 1 break end
			end
			if not stored then evt_t[#evt_t+1] = chanmsg == 176 and msg2 or chanmsg  -- only collect unique numbers of CC messages (chanmsg = 176) for which msg2 value represents CC#, or non-CC messages which have channel data (chanmsg is not 176) for which msg2 value doesn't represent CC#; chanmsg = Pitch bend - 224, Program - 192, Channel pressure - 208, Poly aftertouch - 160
			end
		local stored
			for _, ch in ipairs(ch_t) do
				if ch == chan then stored = 1 break end
			end
			if not stored then ch_t[#ch_t+1] = chan end
		end
--	i = i+1
	until idx == -1
--[[ ALSO WORKS
local retval, notecnt, ccevtcnt, textsyxevtcnt = r.MIDI_CountEvts(take)
	for i = 0, ccevtcnt-1 do
	local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, i) -- point indices are based on their time position hence points with sequential indices will likely belong to different CC envelopes
		for _, cc in ipairs(evt_t) do
			if cc == msg2 or cc == chanmsg then stored = 1 break end
		end
		if not stored then evt_t[#evt_t+1] = chanmsg == 176 and msg2 or chanmsg -- only collect unique numbers of CC messages (chanmsg = 176) for which msg2 value represents CC#, or non-CC messages which have channel data (chanmsg is not 176) for which msg2 value doesn't represent CC#; chanmsg = Pitch bend - 224, Program - 192, Channel pressure - 208, Poly aftertouch - 160
		ch_t[#ch_t+1] = chan
		end
	end
--]]

--r.MIDIEditor_LastFocused_OnCommand(40671, false) -- islistviewcommand false // Unselect all CC events -- IN FACT DESELECTS EVEN non-CC events such as text and notation

-- DESELECTION OF ALL MUST BE HANDLED BY Re_Store_Selected_CCEvents3() instead of the above action

r.GetSet_LoopTimeRange(true, false, time_st, time_end, false) -- isSet true, isLoop, allowautoseek false // restore
r.PreventUIRefresh(-1)
table.sort(evt_t) table.sort(ch_t)
return evt_t, ch_t

end


-- VISIBLE actually means selected in the left hand CC lane menu, regardless of its being collapsed or not
function Only_ReSelect_Evnts_In_Visble_CC_Lanes(sel_evts_t, vis_lanes_t, evt_ch_t, take)
-- Only re-select originally selected events in the visible lanes // can be modified to select all events in visible lanes whether originally selected or not
-- sel_evts_t and vis_lanes_t are tables returned by Re_Store_Selected_CCEvents3() and Get_Currently_Visible_CC_Lanes() above respectively
-- evt_ch_t is returned by Get_Currently_Active_Chan_And_Filter_State() function
-- search by index isn't reliable as they change after sorting, so all return values must be collated to find originally selected events bar selected status value because at this stage the event won't be selected; this loop basically searches for current indices of the stored events so they can be re-selected
Re_Store_Selected_CCEvents3(take) -- deselect all
local i = 0
	repeat
		local evt_data = {r.MIDI_GetCC(take, i)}
		for _, sel_evts_data in ipairs(sel_evts_t) do
		local match_cnt = 0
			for i = 3, 8 do
			match_cnt = evt_data[i] == sel_evts_data[i] and match_cnt+1 or match_cnt
			end
			if match_cnt == 6 then -- original event found in sel_evts_t table
			local chmsg, chan, msg2 = table.unpack(sel_evts_data,5,7)
			-- determine if the original event belongs to one of the visible lanes, 14-bit lane events aren't supported
			local evt_match
				for _, cc in ipairs(vis_lanes_t) do
					if chmsg == 176 and cc == msg2 -- CC message, chanmsg = 176
					or chmsg == cc then -- non-CC message (chanmsg =/= 176) which has channel data, such as Pitch, Channel pressure, ProgramChange and for which chanmsg value is stored instead since it's unique while their msg2 value doesn't refer to the CC#
					evt_match = 1
					break end
				end
				-- when channel filter is enabled per channel or multichannel mode is enabled, belonging to one of the visible lanes isn't enough because the channel an event belongs to may not be visible
				if evt_match then
					for _, ch in ipairs(evt_ch_t) do
						if chan == ch-1 then -- ch-1 because channels are stored by Get_Currently_Active_Chan_And_Filter_State() using 1-based count
						r.MIDI_SetCC(take, i, true, mutedIn, ppqposIn, chanmsgIn, chanIn, msg2In, msg3In, true) -- selectedIn, noSortIn true
						break end
					end
				end
			end
		end
	until not evt_data[1]

r.MIDI_Sort(take)

end


-- VISIBLE actually means selected in the left hand CC lane menu, regardless of its being collapsed or not
function Get_Visible_Lanes_With_Selected_Events(ME, take, vis_lanes_t) -- vis_lanes_t stems from Get_Currently_Visible_CC_Lanes() function
-- 14-bit lanes aren't supported if Get_Currently_Visible_CC_Lanes() was used
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
-- Find numbers of the message types of visible lanes with selected events
local lanes_with_sel_evts_t, ch_t = {}, {}
local evt_idx = 0
	repeat
	local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel
		if sel then
			for _, cc in ipairs(vis_lanes_t) do
				if chanmsg == 176 and cc == msg2 -- CC message, chanmsg = 176
				or chanmsg == cc then -- non-CC message (chanmsg =/= 176) which has channel data, such as Pitch, Channel pressure, ProgramChange and for which chanmsg value is stored instead since it's unique while their msg2 value doesn't refer to the CC#
				local stored
					for _, cc2 in ipairs(lanes_with_sel_evts_t) do
						if cc == cc2 then stored = true break end
					end
					if not stored then
					local len = #lanes_with_sel_evts_t+1
					lanes_with_sel_evts_t[len] = chanmsg == 176 and msg2 or chanmsg -- only collect unique numbers of CC messages (chanmsg = 176) for which msg2 value represents CC#, or non-CC messages which have channel data (chanmsg is not 176) for which msg2 value doesn't represent CC#; chanmsg = Pitch bend - 224, Program - 192, Channel pressure - 208, Poly aftertouch - 160
					end
				local stored
					for _, ch in ipairs(ch_t) do
						if ch == chan then stored = 1 break end
					end
					if not stored then ch_t[#ch_t+1] = chan end
				end
			end
		end
	evt_idx = evt_idx+1
	until not retval
return lanes_with_sel_evts_t, ch_t
end



function Get_CC_Lanes_With_Selected_Events(ME, take) -- if preceded by the sequence of functions Re_Store_Selected_CCEvents3(), Get_Currently_Visible_CC_Lanes(), Re_Store_Selected_CCEvents3(ME, take) to deselect all, and Only_ReSelect_Evnts_In_Visble_CC_Lanes() amounts to getting visible CC lanes with selected events
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
-- Find numbers of the message types of visible lanes with selected events
local i = -1 -- start with -1 since MIDI_EnumSelCC returns idx of the next event hence will actually start from 0
local t = {}
	repeat
	local idx = r.MIDI_EnumSelCC(take, i)
		if idx > -1 then
		local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, idx) -- point indices are based on their time position hence points with sequential indices will likely belong to different CC envelopes // only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		local stored
			for _, cc in ipairs(t) do
				if cc == msg2 or cc == chanmsg then stored = 1 break end
			end
			if not stored then t[#t+1] = chanmsg == 176 and msg2 or chanmsg  -- only collect unique numbers of CC messages (chanmsg = 176) for which msg2 value represents CC#, or non-CC messages which have channel data (chanmsg is not 176) for which msg2 value doesn't represent CC#; chanmsg = Pitch bend - 224, Program - 192, Channel pressure - 208, Poly aftertouch - 160
			end
		end
	i = i+1
	until idx == -1
return t
end



function Delete_CC_Evts_From_Target_Lanes(ME, take, lanes_with_sel_evts_t) -- before pasting/moving in case there's old automation to prevent mixing/garbling // lanes_with_sel_evts_t is the table returned by Get_Visible_Lanes_With_Selected_Events() or Get_CC_Lanes_With_Selected_Events() functions
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
-- Count events in the current channel to use in reversed loop below for the sake of deletion
local count = 0
	repeat
	local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, count) -- only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel
		if not retval then break end
	count = count+1
	until not retval
-- Delete events from target lanes, if any
r.MIDI_DisableSort(take)
local evt_idx = count-1 -- in reverse due to deletion, -1 because the count ends up being 1-based
	repeat
	local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel
		if not retval then break end
		for _, cc in ipairs(lanes_with_sel_evts_t) do
			if chanmsg == 176 and cc == msg2 -- CC message, chanmsg = 176
			or chanmsg == cc then -- non-CC message (chanmsg =/= 176) which has channel data, such as Pitch, Channel pressure, ProgramChange and for which chanmsg value is stored instead since it's unique while their msg2 value doesn't refer to the CC#
			r.MIDI_DeleteCC(take, evt_idx)
			end
		end
	evt_idx = evt_idx-1
	until not retval
r.MIDI_Sort(take)
end


-- VISIBLE actually means selected in the left hand CC lane menu, regardless of its being collapsed or not
function Selected_Evnts_In_Visible_CC_Lanes(vis_lanes_t, take) -- vis_lanes_t is the table returned by Get_Currently_Visible_CC_Lanes() function above
-- Find if there're selected events in at least one visible CC lane (out of several)
local ccidx = 0
local sel_cnt = 0
	repeat -- deselect all
	local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, ccidx) -- just to use retval to stop the loop // only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		for _, cc in ipairs(vis_lanes_t) do
			if sel and (chanmsg == 176 and cc == msg2 or chanmsg == cc) then sel_cnt = sel_cnt+1 break end -- for non-CC messages (chanmsg =/= 176) their chanmsg value is stored since it's unique while their msg2 value doesn't refer to the CC#
		end
		if sel_cnt > 0 then break end -- exit if at least one found
	ccidx = ccidx+1
	until not retval
return sel_cnt > 0
end


-- CURRENTLY ONLY USEFUL IF JUST ONE CC LANE IS OPEN WHICH MIGHT NOT BE THE CASE
-- should be modified to:
-- after getting all sel CC events with Re_Store_Selected_CCEvents3()
-- after getting currently visible CC lanes with Get_Currently_Visible_CC_Lanes()
-- collate msg2 or chanmsg return values of CC or non-CC events respectively with the numbers of currently visible lanes
-- VISIBLE actually means selected in the left hand CC lane menu, regardless of its being collapsed or not
function All_Sel_CCEvts_Belong_To_Visble_OR_Last_Clicked_Lane(ME, take) -- 2 boolean return values: if any selected and if true then if all belong to the same lane // non-CC events are ignored so return values are both false
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local autom_lane = r.MIDIEditor_GetSetting_int(ME, 'last_clicked_cc_lane') -- last clicked if several lanes are displayed, otherwise currently visible lane
--Msg(autom_lane)
local autom_lane = autom_lane >= 256 and autom_lane <= 287 and autom_lane - 256 or autom_lane -- for events in 14-bit lanes MIDI_GetCC() returns 7-bit CC# hence the subtraction // events are displayed as selected in both 7 and 14 bit lanes
local first_sel_evt_idx = r.MIDI_EnumSelCC(take, -1) -- idx of the first selected event
local i = 0
local last_sel_evt_idx
	repeat
	local idx = r.MIDI_EnumSelCC(take, i)
		if r.MIDI_EnumSelCC(take, i+1) == -1 then last_sel_evt_idx = idx break end
	i = i + 1
	until idx == -1
local first = {r.MIDI_GetCC(take, first_sel_evt_idx)} -- retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 // only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all events use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
local last = {r.MIDI_GetCC(take, last_sel_evt_idx)}
return first_sel_evt_idx > -1, first[7] == autom_lane and first[7] == last[7] -- 7th return value is CC#
end



function Delete_Notes_In_MIDI_Channel(ME, take) -- STRANGE, THE ACTUAL MIDI CHANNEL ISN'T SPECIFIED, PROBABLY NEEDS REVISION, as is will only work if channel filter is enabled and will delete from the currently active channel
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
-- Count notes in the current channel to use in reversed loop below for the sake of deletion
local count = 0
	repeat
	local retval, sel, muted, ppqpos, endppq, chan, pitch, vel = r.MIDI_GetNote(take, count) -- only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel // if looking for all notes use Clear_Restore_MIDI_Channel_Filter() to disable filter if enabled and re-enable afterwards
		if not retval then break end
	count = count+1
	until not retval
r.MIDI_DisableSort(take)
local note_idx = count-1 -- in reverse due to deletion, -1 because the count ends up being 1-based
	repeat
	r.MIDI_DeleteNote(take, note_idx)
	note_idx = note_idx-1
	until note_idx < 0
r.MIDI_Sort(take)
end


function CC_Evts_Exist(ME, take)
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local evt_idx = 0
	repeat
	local retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3 = r.MIDI_GetCC(take, evt_idx) -- Velocity / Off Velocity / Text events / Notation enents / SySex lanes are ignored || only targets events in the current MIDI channel if Channel filter is enabled, if looking for genuine false or 0 values must be validated with retval which is only true for notes from current channel
		if retval then return retval end -- as soon as a selected event is found
	evt_idx = evt_idx + 1
	until not retval
end


function Store_Insert_Notes_OR_Evts(ME, take, t, move, chanIn, events) -- move is boolean, if true events will be deleted from the source channel, chanIn is channel for note/event setting, events is boolean to handle envelope events rather than notes
local ME = not ME and r.MIDIEditor_GetActive() or ME
local take = not take and r.MIDIEditor_GetTake(ME) or take
local Get, Delete, Insert = table.unpack(not events and {r.MIDI_GetNote, r.MIDI_DeleteNote, r.MIDI_InsertNote} or {r.MIDI_GetCC, r.MIDI_DeleteCC, r.MIDI_InsertCC})
-- !!!! Get, Delete, Insert, GeCCShape functions only target event in the current MIDI channel if Channel filter is enabled !!!!!
-- local chanIn = not chanIn and r.MIDIEditor_GetSetting_int(ME, 'default_note_chan') or chanIn -- 0-15
	if not t then
	local t = {}
	local idx = 0
		repeat
		local retval, shape, beztension = table.unpack(events and {r.MIDI_GetCCShape(take, idx)} or {})
		t[#t+1] = {Get(take, idx)}
		table.insert(t[#t], shape); table.insert(t[#t], beztension)
		local retval = t[#t][1]
			if idx == 0 and not retval then t = {} break end -- if no notes/events at all, resetting the table which would otherwise contain 1 field and produce false positive
		idx = idx+1
		until not retval
		if move then -- delete from the source channel
		r.MIDI_DisableSort(take)
			for i = #t,1,-1 do
			Delete(take, i-1)
			end
		r.MIDI_Sort(take)
		end
	return t
	else -- insert
	-- Count content in the current channel to use in reversed loop below for the sake of deletion
	local count = 0
		repeat
		local retval, sel, muted, ppqpos, endppq, chan, pitch, vel = Get(take, count) -- here only retval matters
			if not retval then break end
		count = count+1
		until not retval
	-- Delete content from the target channel
	r.MIDI_DisableSort(take)
	local idx = count-1 -- in reverse due to deletion, -1 because the count ends up being 1-based
		repeat
		Delete(take, idx)
		idx = idx-1
		until idx < 0
	r.MIDI_Sort(take)
		-- Insert notes or events in the target channel
		for k, data in ipairs(t) do
		local retval, sel, muted, ppqpos, a, chan, b, c, shape, beztension = table.unpack(data, 1, 10) -- for note it's retval, sel, muted, startppqpos, endppqpos, chan, pitch, vel; for CC events it's retval, sel, muted, ppqpos, chanmsg, chan, msg2, msg3, shape, beztension
			if retval then -- the last retval will be nil since one invalid event is stored at the end of the store loop
			Insert(take, sel, muted, ppqpos, a, chanIn, b, c, true) -- chanIn comes from the function argument, noSortIn true
				if events then
				r.MIDI_SetCCShape(take, k-1, shape, beztension, true) -- noSortIn true
				end
			end
		end
	r.MIDI_Sort(take)
	end

end
--[[ USE:

local notes_t = Store_Insert_Notes_OR_Evts(ME, take, t, move, chanIn, events) -- events false // store
local evts_t = Store_Insert_Notes_OR_Evts(ME, take, t, move, chanIn, true) -- events true // store

-- DO STUFF

local del = notes_move and Store_Insert_Notes_OR_Evts(ME, take, t, notes_move, chanIn, false) -- t, chanIn, events are false // delete notes from the source channel
local del = events_move and Store_Insert_Notes_OR_Evts(ME, take, t, events_move, chanIn, true) -- t, chanIn are false, events true // delete events from the source channel

if #notes_t > 0 and notes then Store_Insert_Notes_OR_Evts(ME, take, notes_t, notes_move, ch-1, false) end -- events false // insert
if #evts_t > 0 and events then Store_Insert_Notes_OR_Evts(ME, take, evts_t, events_move, ch-1, true) end -- events true // insert
]]


--============================= M I D I  E N D =============================


--============================= (R E) S T O R E   O B J E C T S =============================

function StoreSelectedObjects() -- CAN BE COMBINED INTO A SINGLE FUNCTION WITH THE RESTORE ONE BELOW

-- Store selected items
local sel_itms_cnt = r.CountSelectedMediaItems(0)
local itm_sel_t = {}
	if sel_itms_cnt > 0 then
	local i = 0
		while i < sel_itms_cnt do
		itm_sel_t[#itm_sel_t+1] = r.GetSelectedMediaItem(0,i)
		i = i+1
		end
	end

-- Store selected tracks
local sel_trk_cnt = reaper.CountSelectedTracks2(0,true) -- plus Master, wantmaster true
local trk_sel_t = {}
	if sel_trk_cnt > 0 then
	local i = 0
		while i < sel_trk_cnt do
		trk_sel_t[#trk_sel_t+1] = r.GetSelectedTrack2(0,i,true) -- plus Master, wantmaster true
		i = i+1
		end
	end

return itm_sel_t, trk_sel_t

end


function Restore_Saved_Selected_Objects(itm_sel_t, trk_sel_t) -- only restored if there was selection, if nothing was selected the latest selection is kept

r.PreventUIRefresh(1)

	-- Restore selected items
	if #itm_sel_t > 0 then
--	r.Main_OnCommand(40289,0) -- Item: Unselect all items
	r.SetMediaItemsSelected(0,false) -- deselect all
	local i = 0
		while i < #itm_sel_t do
		r.SetMediaItemSelected(itm_sel_t[i+1],true) -- +1 since item count is 1 based while the table is indexed from 1
		i = i + 1
		end
	end

	-- Restore selected tracks
	if #trk_sel_t > 0 then
--	r.Main_OnCommand(40297,0) -- Track: Unselect all tracks
	r.SetOnlyTrackSelected(trk_sel_t[1]) -- select one to be restored while deselecting all the rest
	r.SetTrackSelected(r.GetMasterTrack(0),false) -- deselect Master
		for _,v in next, trk_sel_t do
		r.SetTrackSelected(v,true)
		end
	end

r.UpdateArrange()
r.TrackList_AdjustWindows(0)

r.PreventUIRefresh(-1)
end


function Restore_Saved_Selected_Objects(itm_sel_t, trk_sel_t) -- selection state is restored if objects both were and weren't selected

r.PreventUIRefresh(1)

--r.Main_OnCommand(40289,0) -- Item: Unselect all items OR
r.SetMediaItemsSelected(0,false) -- deselect all
	if #itm_sel_t > 0 then
	local i = 0
		while i < #itm_sel_t do
		r.SetMediaItemSelected(itm_sel_t[i+1],true) -- selected is true
		i = i + 1
		end
	end

--r.Main_OnCommand(40297,0) -- Track: Unselect all tracks
r.SetOnlyTrackSelected(r.GetMasterTrack(0)) -- select to deselect the rest
r.SetTrackSelected(r.GetMasterTrack(0),false) -- deselect Master
	if #trk_sel_t > 0 then
		for _,v in next, trk_sel_t do
		r.SetTrackSelected(v,true) -- selected is true
		end
	end

r.UpdateArrange()
r.TrackList_AdjustWindows(0)

r.PreventUIRefresh(-1)
end




function Re_Store_Selected_Objects(t1,t2) -- when storing the arguments aren't needed

r.PreventUIRefresh(1)

local t1, t2 = t1, t2

	if not t1 then
	-- Store selected items
	local sel_itms_cnt = r.CountSelectedMediaItems(0)
		if sel_itms_cnt > 0 then
		t1 = {}
		local i = sel_itms_cnt-1
			while i >= 0 do -- in reverse due to deselection
			local item = r.GetSelectedMediaItem(0,i)
			t1[#t1+1] = item
		--	r.SetMediaItemSelected(item, false) -- selected false; deselect item // OPTIONAL
			i = i - 1
			end
		end
	elseif t1 and #t1 > 0 then -- Restore selected items
--	r.Main_OnCommand(40289,0) -- Item: Unselect all items
--	OR
	r.SelectAllMediaItems(0, false) -- selected false
		for _, item in ipairs(t1) do
		r.SetMediaItemSelected(item, true) -- selected true
		end
	r.UpdateArrange()
	end

	if not t2 then
	-- Store selected tracks
	local sel_trk_cnt = reaper.CountSelectedTracks2(0,true) -- plus Master, wantmaster true
		if sel_trk_cnt > 0 then
		t2 = {}
		local i = sel_trk_cnt-1
			while i >= 0 do -- in reverse due to deselection
			local tr = r.GetSelectedTrack2(0,i,true) -- plus Master, wantmaster true
		--	r.SetTrackSelected(tr, false) -- selected false; deselect track // OPTIONAL
			t2[#t2+1] = tr
			i = i - 1
			end
		end
	elseif t2 and #t2 > 0 then -- restore selected tracks
--	r.Main_OnCommand(40297,0) -- Track: Unselect all tracks
	r.SetOnlyTrackSelected(t2[1]) -- select one to be restored while deselecting all the rest
	r.SetTrackSelected(r.GetMasterTrack(0), false) -- unselect Master
	-- OR
	-- r.SetOnlyTrackSelected(t2[1])
		for _, tr in ipairs(t2) do
		r.SetTrackSelected(tr, true) -- selected true
		end
	r.UpdateArrange()
	r.TrackList_AdjustWindows(0)
	end

r.PreventUIRefresh(-1)

return t1, t2

end

------------------ USAGE -------------------
local t1, t2 = Re_Store_Selected_Objects() -- store
-- DO STUFF --
Re_Store_Selected_Objects(t1, t2) -- restore
--------------------------------------------


function re_store_sel_trks(t) -- with deselection; t is the stored tracks table to be fed in at restoration stage
	if not t then
	local sel_trk_cnt = reaper.CountSelectedTracks2(0,true) -- plus Master, wantmaster true
	local trk_sel_t = {}
		if sel_trk_cnt > 0 then
		local i = sel_trk_cnt -- in reverse because of deselection
			while i > 0 do -- not >= 0 because sel_trk_cnt is not reduced by 1, i-1 is on the next line
			local tr = r.GetSelectedTrack2(0,i-1,true) -- plus Master, wantmaster true
			trk_sel_t[#trk_sel_t+1] = tr
			r.SetTrackSelected(tr, 0) -- selected 0 or false // unselect each track
			i = i-1
			end
		end
	return trk_sel_t
	elseif t and #t > 0 then
	r.PreventUIRefresh(1)
--	r.Main_OnCommand(40297,0) -- Track: Unselect all tracks
	r.SetOnlyTrackSelected(t[1]) -- select one to be restored while deselecting all the rest
	r.SetTrackSelected(r.GetMasterTrack(0), false) -- unselect Master
		for _,v in next, t do
		r.SetTrackSelected(v,1)
		end
	r.UpdateArrange()
	r.TrackList_AdjustWindows(0)
	r.PreventUIRefresh(-1)
	end
end


function ReStoreSelectedItems(t)
	if not t then -- Store selected items
	local sel_itms_cnt = r.CountSelectedMediaItems(0)
		if sel_itms_cnt > 0 then
		local t = {}
		local i = sel_itms_cnt-1
			while i >= 0 do -- in reverse due to deselection
			local item = r.GetSelectedMediaItem(0,i)
			t[#t+1] = item
			r.SetMediaItemSelected(item, false) -- deselect item
			i = i - 1
			end
		return t end
	elseif t and #t > 0 then -- Restore selected items
--	r.Main_OnCommand(40289,0) -- Item: Unselect all items // not needed because deselection was done at the storage state
	local i = 0
		while i < #t do
		r.SetMediaItemSelected(t[i+1],true) -- +1 since item count is 1 based while the table is indexed from 1
		i = i + 1
		end
	r.UpdateArrange()
	end
end


function re_store_obj_selection(t1, t2)
	if not t1 and not t2 then
	local t1, t2 = {}, {}
		for i = 0, r.CountSelectedTracks2(0,true) do -- plus Master, wantmaster true
		t1[#t1+1] = r.GetSelectedTrack2(0,i,true) -- plus Master, wantmaster true
		end
		for i = 0, r.CountSelectedMediaItems(0)-1 do
		t2[#t2+1] = r.GetSelectedMediaItem(0,i)
		end
	return #t1 > 0 and t1, #t2 > 0 and t2
	else
		r.SetOnlyTrackSelected(r.GetMasterTrack(0))
		r.SetTrackSelected(r.GetMasterTrack(0),false) -- unselect Master
		if t1 then
			for _, tr in ipairs(t1) do
			r.SetTrackSelected(tr, true) -- selected true
			end
		end
		r.SelectAllMediaItems(0, false) -- selected false // deselect all
		if t2 then
			for _, itm in ipairs(t2) do
			r.SetMediaItemSelected(itm, true) -- selected true
			end
		end
	end
end



function Find_And_Get_New_Objects(t, wantItems) -- wantItems is boolean
local Count, Get = table.unpack(not wantItems and {r.CountTracks, r.GetTrack} or {r.CountMediaItems,r.GetMediaItem})
	if not t then
	local t = {}
		for i = 0, Count(0)-1 do
		t[r.Get(0,i)] = '' -- dummy field
		end
	return t
	elseif t then
	local t2 = {}
		for i = 0, Count(0)-1 do
		local obj = Get(0,i)
			if not t[obj] then -- track wasn't stored so is new
			t2[#t2+1] = {obj=obj, idx=i}
			end
		end
	return #t2 > 0 and t2
	end
end


--========================= (R E) S T O R E   O B J E C T S   E N D ============================


function Get_Object_Under_Mouse_Curs() -- used in 'FX presets menu script'

-- Before build 6.37 GetCursorContext() and r.GetTrackFromPoint(x, y) are unreliable in getting TCP since the track context and coordinates are true along the entire timeline as long as it's not another context
-- using edit cursor to find TCP context instead since when mouse cursor is over the TCP edit cursor doesn't respond to action 'View: Move edit cursor to mouse cursor' // before build 6.37 STOPS PLAYBACK WHILE GETTING TCP
-- Before build 6.37 no MCP support; when mouse is over the Mixer on the Arrange side the trick to detect track panel doesn't work, because with 'View: Move edit cursor to mouse cursor' the edit cursor does move to the mouse cursor

	local function GetMonFXProps() -- get mon fx accounting for floating window, GetFocusedFX() doesn't detect mon fx in builds prior to 6.20

		local master_tr = r.GetMasterTrack(0)
		local src_mon_fx_idx = r.TrackFX_GetRecChainVisible(master_tr)
		local is_mon_fx_float = false -- only relevant if there's need to reopen the fx in floating window
			if src_mon_fx_idx < 0 then -- fx chain closed or no focused fx -- if this condition is removed floated fx gets priority
				for i = 0, r.TrackFX_GetRecCount(master_tr) do
					if r.TrackFX_GetFloatingWindow(master_tr, 0x1000000+i) then
					src_mon_fx_idx = i; is_mon_fx_float = true break end
				end
			end
		return src_mon_fx_idx, is_mon_fx_float
	end

r.PreventUIRefresh(1)

local retval, tr, item = r.GetFocusedFX() -- account for focused FX chains and Mon FX chain in builds prior to 6.20
local fx_chain_focus = LOCK_FX_CHAIN_FOCUS or r.GetCursorContext() == -1

local obj, obj_type

	if (retval > 0 or GetMonFXProps() >= 0) and fx_chain_focus then -- (last) focused FX chain as GetFocusedFX() returns last focused which is still open
	obj, obj_type = table.unpack(retval == 2 and tr > 0 and {r.GetTrackMediaItem(r.GetTrack(0,tr-1), item), 1} or retval == 1 and tr > 0 and {r.GetTrack(0,tr-1), 0} or {r.GetMasterTrack(0), 0})
	else -- not FX chain
	local x, y = r.GetMousePosition()
		if tonumber(r.GetAppVersion():match('(.+)/')) >= 6.37 then -- SUPPORTS MCP
		local retval, info_str = r.GetThingFromPoint(x, y)
		obj, obj_type = table.unpack(info_str == 'arrange' and {({r.GetItemFromPoint(x, y, true)})[1], 1} -- allow locked is true
		or info_str:match('[mt]cp') and {r.GetTrackFromPoint(x, y), 0} or {nil})
		else
		-- First get item to avoid using edit cursor actions
		--[-[------------------------- WITHOUT SELECTION --------------------------------------------
		obj, obj_type = ({r.GetItemFromPoint(x, y, true)})[1], 1 -- get without selection, allow locked is true, the function returns both item and take pointers, here only item's is collected, works for focused take FX chain as well
		--]]
		--[[-----------------------------WITH SELECTION -----------------------------------------------------
		-- will require prior storage and restoration of selection (generally inefficient)
		r.Main_OnCommand(40289,0) -- Item: Unselect all items;  -- when SEL_OBJ_IN_CURR_CONTEXT option in the USER SETTINGS is OFF to prevent getting any selected item when mouse cursor is outside of Arrange proper (e.g. at the Mixer or Ruler or a focused Window), forcing its recognition only if the item is under mouse cursor, that's because when cursor is within Arrange and there's no item under it the action 40528 (below) itself deselects all items (until their selection is restored at script exit) and GetSelectedMediaItem() returns nil so there's nothing to fetch the data from, but when the cursor is outside of the Arrange proper (e.g. at the Mixer or Ruler) this action does nothing, the current item selection stays intact and so GetSelectedMediaItem() does return first selected item identificator
		r.Main_OnCommand(40528,0) -- Item: Select item under mouse cursor
		obj, obj_type = r.GetSelectedMediaItem(0,0), 1
		--]]
			if not obj then -- before build 6.37
			-- r.GetTrackFromPoint() covers the entire track timeline hence isn't suitable for getting the TCP
			local curs_pos = r.GetCursorPosition() -- store current edit curs pos
			local start_time, end_time = r.GetSet_ArrangeView2(0, false, 0, 0, start_time, end_time) -- isSet false, screen_x_start, screen_x_end are 0 to get full arrange view coordinates // get time of the current Arrange scroll position to use to move the edit cursor away from the mouse cursor // https://forum.cockos.com/showthread.php?t=227524#2 the function has 6 arguments; screen_x_start and screen_x_end (3d and 4th args) are not return values, they are for specifying where start_time and stop_time should be on the screen when non-zero when isSet is true
--local TCP_width = tonumber(cont:match('leftpanewid=(.-)\n')) -- only changes in reaper.ini when dragged
			local right_tcp = r.GetToggleCommandStateEx(0,42373) -- View: Show TCP on right side of arrange
			local edge = right_tcp and start_time-5 or end_time+5
			r.SetEditCurPos(edge, false, false) -- moveview, seekplay false // to secure against a vanishing probablility of overlap between edit and mouse cursor positions in which case edit cursor won't move just like it won't if mouse cursor is over the TCP // +/-5 sec to move edit cursor beyond right/left edge of the Arrange view to be completely sure that it's far away from the mouse cursor
			r.Main_OnCommand(40514,0) -- View: Move edit cursor to mouse cursor (no snapping) // more sensitive than with snapping
				if r.GetCursorPosition() == edge or r.GetCursorPosition() == start_time then -- the edit cursor stayed put at the pos set above since the mouse cursor is over the TCP // if the TCP is on the right and the Arrange is scrolled all the way to the project start start_time-5 won't make the edit cursor move past project start hence the 2nd condition, but it can move past the right edge
				--[-[------------------------- WITHOUT SELECTION --------------------------------------------
				obj, obj_type = r.GetTrackFromPoint(x, y), 0 -- get without selection, works for focused track FX chain as well
				--]]
				--[[-----------------------------WITH SELECTION -----------------------------------------------------
				-- will require prior storage and restoration of selection (generally inefficient)
				r.Main_OnCommand(41110,0) -- Track: Select track under mouse
				obj, obj_type = r.GetSelectedTrack2(0,0, true), 0 -- account for Master is true
				--]]
				end
		-- restore edit cursor position
		--[[
			local new_curs_pos = r.GetCursorPosition()
			local min_val, subtr_val = table.unpack(new_curs_pos == edge and {curs_pos, edge} -- TCP found, edit cursor remained at edge
			or new_curs_pos ~= edge and {curs_pos, new_curs_pos} -- TCP not found, edit cursor moved
			or {0,0})
			r.MoveEditCursor(min_val - subtr_val, false) -- dosel false = don't create time sel; restore orig. edit curs pos, greater subtracted from the lesser to get negative value meaning to move closer to zero (project start) // MOVES VIEW SO IS UNSUITABLE
		--]]
		--[-[ OR SIMPLY
			r.SetEditCurPos(curs_pos, false, false) -- moveview, seekplay false // restore orig. edit curs pos
		--]]
			end
		end
	end

r.PreventUIRefresh(-1)

	return obj, obj_type

end


function GetObjInfo_Value(obj, param) -- param is a string // envelope included
local t = {'MediaItem*', 'MediaItem_Take*', 'MediaTrack*', 'TrackEnvelope*', 'ReaProject*'}
	for _, v in ipairs(t) do
		if reaper.ValidatePtr2(0, obj, v) then p = v break end
	end
local func = p == 'MediaItem*' and reaper.GetMediaItemInfo_Value or p == 'MediaItem_Take*' and reaper.GetMediaItemTakeInfo_Value or p == 'MediaTrack*' and reaper.GetMediaTrackInfo_Value or p == 'TrackEnvelope*' and reaper.GetEnvelopeInfo_Value or p == 'ReaProject*' and reaper.GetSetProjectInfo
return func(obj, param, 0, false) -- last two args are for project data, is_set is false
end


function SetObjInfo_Value(obj, param, val) -- param is a string, val is a number // envelope doesn't exist
local t = {'MediaItem*', 'MediaItem_Take*', 'MediaTrack*', 'ReaProject*'}
	for _, v in ipairs(t) do
		if reaper.ValidatePtr2(0, obj, v) then p = v break end
	end
local func = p == 'MediaItem*' and reaper.SetMediaItemInfo_Value or p == 'MediaItem_Take*' and reaper.SetMediaItemTakeInfo_Value or p == 'MediaTrack*' and reaper.SetMediaTrackInfo_Value or p == 'ReaProject*' and reaper.GetSetProjectInfo
return func(obj, param, val, true) -- last args is for project data, is_set is true
end


function GetSetObjInfo_String(obj, param, name, is_set) -- param and name are strings, is_set is boolean
local t = {'MediaItem*', 'MediaItem_Take*', 'MediaTrack*', 'ReaProject*'}
	for _, v in ipairs(t) do
		if reaper.ValidatePtr2(0, obj, v) then p = v break end
	end
local func = p == 'MediaItem*' and reaper.GetSetMediaItemInfo_String or p == 'MediaItem_Take*' and reaper.GetSetMediaItemTakeInfo_String or p == 'MediaTrack*' and reaper.GetSetMediaTrackInfo_String
return func(obj, param, name, is_set)
end


function GetObjAllInfo_Values(obj) -- as of REAPER 6.12c
local t = {'MediaItem*', 'MediaItem_Take*', 'MediaTrack*', 'TrackEnvelope*', 'ReaProject*'}
local p
	for _, v in ipairs(t) do
		if reaper.ValidatePtr2(0, obj, v) then p = v break end
	end
local t = p == 'MediaItem*' and {B_MUTE = 0, B_MUTE_ACTUAL = 0, C_MUTE_SOLO = 0, B_LOOPSRC = 0, B_ALLTAKESPLAY = 0, B_UISEL = 0, C_BEATATTACHMODE = 0, C_AUTOSTRETCH = 0, C_LOCK = 0, D_VOL = 0, D_POSITION = 0, D_LENGTH = 0, D_SNAPOFFSET = 0, D_FADEINLEN = 0, D_FADEOUTLEN = 0, D_FADEINDIR = 0, D_FADEOUTDIR = 0, D_FADEINLEN_AUTO = 0, D_FADEOUTLEN_AUTO = 0, C_FADEINSHAPE = 0, C_FADEOUTSHAPE = 0, I_GROUPID = 0, I_LASTY = 0, I_LASTH = 0, I_CUSTOMCOLOR = 0, I_CURTAKE = 0, IP_ITEMNUMBER = 0, F_FREEMODE_Y = 0, F_FREEMODE_H = 0, P_TRACK = 0}
or p == 'MediaItem_Take*' and {D_STARTOFFS = 0, D_VOL = 0, D_PAN = 0, D_PANLAW = 0, D_PLAYRATE = 0, D_PITCH = 0, B_PPITCH = 0, I_CHANMODE = 0, I_PITCHMODE = 0, I_CUSTOMCOLOR = 0, IP_TAKENUMBER = 0, P_TRACK = 0, P_ITEM = 0, P_SOURCE = 0}
or p == 'MediaTrack*' and {B_MUTE = 0, B_PHASE = 0, IP_TRACKNUMBER = 0, I_SOLO = 0, I_FXEN = 0, I_RECARM = 0, I_RECINPUT = 0, I_RECMODE = 0, I_RECMON = 0, I_RECMONITEMS = 0, I_AUTOMODE = 0, I_NCHAN = 0, I_SELECTED = 0, I_WNDH = 0, I_TCPH = 0, I_TCPY = 0, I_MCPX = 0, I_MCPY = 0, I_MCPW = 0, I_MCPH = 0, I_FOLDERDEPTH = 0, I_FOLDERCOMPACT = 0, I_MIDIHWOUT = 0, I_PERFFLAGS = 0, I_CUSTOMCOLOR = 0, I_HEIGHTOVERRIDE = 0, B_HEIGHTLOCK = 0, D_VOL = 0, D_PAN = 0, D_WIDTH = 0, D_DUALPANL = 0, D_DUALPANR = 0, I_PANMODE = 0, D_PANLAW = 0, P_ENV = 0, B_SHOWINMIXER = 0, B_MAINSEND = 0, C_MAINSEND_OFFS = 0, B_FREEMODE = 0, C_BEATATTACHMODE = 0, F_MCP_FXSEND_SCALE = 0, F_MCP_SENDRGN_SCALE = 0, I_PLAY_OFFSET_FLAG = 0, D_PLAY_OFFSET = 0, P_PARTRACK = 0, P_PROJECT = 0}
or p == 'TrackEnvelope*' and {I_TCPY = 0, I_TCPH = 0, I_TCPY_USED = 0, I_TCPH_USED = 0, P_TRACK = 0, P_ITEM = 0, P_TAKE = 0}
or p == 'ReaProject*' and {RENDER_SETTINGS = 0, RENDER_BOUNDSFLAG = 0, RENDER_CHANNELS = 0, RENDER_SRATE = 0, RENDER_STARTPOS = 0, RENDER_ENDPOS = 0, RENDER_TAILFLAG = 0, RENDER_TAILMS = 0, RENDER_ADDTOPROJ = 0, RENDER_DITHER = 0, PROJECT_SRATE = 0, PROJECT_SRATE_USE = 0}
local GET = p == 'MediaItem*' and reaper.GetMediaItemInfo_Value or p == 'MediaItem_Take*' and reaper.GetMediaItemTakeInfo_Value or p == 'MediaTrack*' and reaper.GetMediaTrackInfo_Value or p == 'ReaProject*' and reaper.GetSetProjectInfo
	if type(t) == 'table' and next(t) then
		for k in pairs(t) do
		t[k] = GET(obj, k, 0, false) -- last two args are for project data, is_set is false // overwrite zeros with actual return values
		end
	return t
	end
end



function Get_Obj_By_GUID1(obj_type, GUID)
-- obj_type: 'track', 'item', 'take', 'track fx', 'take fx', 'env'; GUID is a string
-- return values are: track, item, take, take_id, fx_id, fx_parm_id, env, env_id
-- if fx_id >= 16777216 the fx is either track input fx or Mon FX if tr is the Master track
-- env_id is only valid if it's a track/take envelope (and not an fx param envelope) accessed with CountTrack/TakeEnvelopes and GetTrack/TakeEnvelope
-- for fx parm envelopes fx_parm_id is returned

local TRACK, ITEM = obj_type:match('track'), obj_type == 'item' or obj_type:match('take')
local obj_count = TRACK and r.CountTracks or (ITEM or obj_type == 'take') and r.CountMediaItems
local get_obj = TRACK and r.GetTrack or (ITEM or obj_type == 'take') and r.GetMediaItem
local get_info_string = TRACK and r.GetSetMediaTrackInfo_String or ITEM and r.GetSetMediaItemInfo_String

	if obj_type ~= 'env' then
		for i = (TRACK and -1 or ITEM and 0), obj_count(0)-1 do
		local obj = TRACK and i == -1 and r.GetMasterTrack(0) or get_obj(0,i)
		local ret, obj_GUID = get_info_string(obj, 'GUID', '', false) -- setNewValue false
			if (TRACK or ITEM) and obj_GUID == GUID then
			return TRACK and obj, ITEM and obj, take, take_id, fx_id, parm_id, env, env_id
			elseif obj_type == 'take' then
				for take_idx = 0, r.CountTakes(obj)-1 do
				local take = r.GetTake(obj, take_idx)
				local ret, take_GUID = r.GetSetMediaItemTakeInfo_String(take, 'GUID', '', false) -- setNewValue false
					if take_GUID == GUID then return tr, obj, take, take_idx, fx_id, parm_id, env, env_id end
				end
			elseif obj_type:match('fx') then
				if r.ValidatePtr(obj, 'MediaTrack*') then
					for fx_idx = 0, r.TrackFX_GetCount(obj)-1 do -- main fx chain
					local fx_GUID = r.TrackFX_GetFXGUID(obj, fx_idx)
						if fx_GUID == GUID then return obj, item, take, take_id, fx_idx, parm_id, env, env_id end
					end
					for fx_idx = 0, r.TrackFX_GetRecCount(obj)-1 do -- input and Mon fx chains
					local fx_GUID = r.TrackFX_GetFXGUID(obj, fx_idx+0x1000000) -- OR fx_idx + 16777216
						if fx_GUID == GUID then return obj, item, take, take_id, fx_idx+0x1000000, parm_id, env, env_id end
					end
				elseif r.ValidatePtr(obj, 'MediaItem*') then
					for take_idx = 0, r.CountTakes(obj)-1 do
					local take = r.GetTake(obj, take_idx)
						for fx_idx = 0, r.TakeFX_GetCount(take)-1 do
						local fx_GUID = r.TakeFX_GetFXGUID(take, fx_idx)
							if fx_GUID == GUID then return tr, obj, take, take_idx, fx_idx, parm_id, env, env_id end
						end
					end
				end
			end
		end
	else
		for i = -1, r.CountTracks(0)-1 do -- track envs
		local tr = r.GetTrack(0,i) or r.GetMasterTrack(0)
			-- CountTrackEnvelopes() only lists active track built-in and fx envelopes (isn't affected by enabled parameter modulation when no actual envelope is active) hence fx envelopes should be targeted separately first to avoid mixing up envelopes in different contexts
			-- GetFXEnvelope() returns envelope even if there's no active envelope but parameter modulation was enabled at least once, after disabling the data isn't removed from the chunk so env remains valid; must be validated with r.ValidatePtr(env, 'TrackEnvelope*') which only returns active envelope
			for fx_idx = 0, r.TrackFX_GetCount(tr)-1 do -- main fx chain
				for parm_idx = 0, r.TrackFX_GetNumParams(tr, fx_idx)-1 do -- fx parm envs
				local env = r.GetFXEnvelope(tr, fx_idx, parm_idx, false) -- create false
					if r.ValidatePtr(env, 'TrackEnvelope*') then
					local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
						if chunk:match('GUID ({.-})') == GUID then
						return tr, item, take, take_id, fx_idx, parm_idx, env, env_id end
					end
				end
			end

			-- (input and Mon FX don't support envelopes)

			for env_idx = 0, r.CountTrackEnvelopes(tr)-1 do
			local env = r.GetTrackEnvelope(tr, env_idx)
			local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
				if chunk:match('GUID ({.-})') == GUID then return tr, item, take, take_id, fx_id, parm_id, env, env_idx end
			end
		end

		for i = 0, r.CountMediaItems(0)-1 do
		local item = r.GetMediaItem(0,i)
			for take_idx = 0, r.CountTakes(item)-1 do
			local take = r.GetTake(item, take_idx)
				-- CountTakeEnvelopes() lists both take and take fx envelopes hence fx envelopes should be targeted separately first to avoid mixing up envelopes in different contexts
				for fx_idx = 0, r.TakeFX_GetCount(take)-1 do
					for parm_idx = 0, r.TakeFX_GetNumParams(take, fx_idx)-1 do
					local env = r.TakeFX_GetEnvelope(take, fx_idx, parm_idx, false) -- create false
					-- TakeFX_GetEnvelope() returns env even if there's none but parameter mudulation was enabled at least once for the corresponding fx parameter hence must be validated with CountEnvelopePoints(env) because in this case there're no points; ValidatePtr(env, 'TrackEnvelope*'), ValidatePtr(env, 'TakeEnvelope*') and ValidatePtr(env, 'Envelope*') on the other hand always return 'true' therefore are useless
						if env and r.CountEnvelopePoints(env) > 0 then -- real, not ghost envelope
						local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
							if chunk:match('GUID ({.-})') == GUID then
							return tr, item, take, take_idx, fx_idx, parm_idx, env, env_id end
						end
					end
				end
				-- CountTakeEnvelopes() lists ghost envelopes when fx parameter modulation was enabled at least once without the parameter having an active envelope, hence must be validated with CountEnvelopePoints(env) because in this case there're no points; ValidatePtr(env, 'TrackEnvelope*'), ValidatePtr(env, 'TakeEnvelope*') and ValidatePtr(env, 'Envelope*') on the other hand always return 'true' therefore are useless
				for env_idx = 0, r.CountTakeEnvelopes(take)-1 do
				local env = r.GetTakeEnvelope(take, env_idx)
					if r.CountEnvelopePoints(env) > 0 then -- real, not ghost envelope
					local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
						if chunk:match('GUID ({.-})') == GUID then
						return tr, item, take, take_idx, fx_id, parm_id, env, env_idx end
					end
				end
			end
		end
	end

end


function Get_Obj_By_GUID2(GUID) -- GUID is a string
-- return values are: track, item, take, take_id, fx_id, fx_parm_id, env, env_id
-- if fx_id >= 16777216 the fx is either track input fx or Mon FX if tr is the Master track
-- env_id is only valid if it's a track/take envelope (and not an fx param envelope) accessed with CountTrack/TakeEnvelopes and GetTrack/TakeEnvelope
-- for fx parm envelopes fx_parm_id is returned

	for i = -1, r.CountTracks(0)-1 do
	local tr = r.GetTrack(0,i) or r.GetMasterTrack(0)
	local ret, tr_GUID = r.GetSetMediaTrackInfo_String(tr, 'GUID', '', false) -- setNewValue false
		if tr_GUID == GUID then
		return tr, item, take, take_id, fx_id, parm_id, env, env_id
		end
		for fx_idx = 0, r.TrackFX_GetCount(tr)-1 do -- main fx chain
		local fx_GUID = r.TrackFX_GetFXGUID(tr, fx_idx)
			if fx_GUID == GUID then return tr, item, take, take_id, fx_idx, parm_id, env, env_id end
		-- CountTrackEnvelopes() only lists active track built-in and fx envelopes (isn't affected by enabled parameter modulation when no actual envelope is active) hence fx envelopes should be targeted separately first to avoid mixing up envelopes in different contexts
		-- GetFXEnvelope() returns envelope even if there's no active envelope but parameter modulation was enabled at least once, after disabling the data isn't removed from the chunk so env remains valid; must be validated with r.ValidatePtr(env, 'TrackEnvelope*') which only returns active envelope
			for parm_idx = 0, r.TrackFX_GetNumParams(tr, fx_idx)-1 do -- fx parm envs
			local env = r.GetFXEnvelope(tr, fx_idx, parm_idx, false) -- create false
				if r.ValidatePtr(env, 'TrackEnvelope*') then
				local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
					if chunk:match('GUID ({.-})') == GUID then
					return tr, item, take, take_id, fx_idx, parm_idx, env, env_id end
				end
			end
		end
		for fx_idx = 0, r.TrackFX_GetRecCount(tr)-1 do -- input and Mon fx chains
		local fx_GUID = r.TrackFX_GetFXGUID(tr, fx_idx+0x1000000) -- OR fx_idx + 16777216
			if fx_GUID == GUID then return tr, item, take, take_id, fx_idx+0x1000000, parm_id, env, env_id end
		end
		for env_idx = 0, r.CountTrackEnvelopes(tr)-1 do
		local env = r.GetTrackEnvelope(tr, env_idx)
		local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
			if chunk:match('GUID ({.-})') == GUID then return tr, item, take, take_id, fx_id, parm_id, env, env_idx end
		end
	end

	for i = 0, r.CountMediaItems(0)-1 do
	local item = r.GetMediaItem(0,i)
	local ret, itm_GUID = r.GetSetMediaItemInfo_String(item, 'GUID', '', false) -- setNewValue false
		if itm_GUID == GUID then
		return tr, item, take, take_id, fx_id, parm_id, env, env_id
		end
		for take_idx = 0, r.CountTakes(item)-1 do
		local take = r.GetTake(item, take_idx)
		local ret, take_GUID = r.GetSetMediaItemTakeInfo_String(take, 'GUID', '', false) -- setNewValue false
			if take_GUID == GUID then return tr, item, take, take_idx, fx_id, parm_id, env, env_id end
			for fx_idx = 0, r.TakeFX_GetCount(take)-1 do
			local fx_GUID = r.TakeFX_GetFXGUID(take, fx_idx)
				if fx_GUID == GUID then return tr, item, take, take_idx, fx_idx, parm_id, env, env_id end
			-- CountTakeEnvelopes() lists both take and take fx envelopes hence fx envelopes should be targeted separately first to avoid mixing up envelopes in different contexts;
			-- it lists ghost envelopes when fx parameter modulation was enabled at least once without the parameter having an active envelope, hence must be validated with CountEnvelopePoints(env) because in this case there're no points; ValidatePtr(env, 'TrackEnvelope*'), ValidatePtr(env, 'TakeEnvelope*') and ValidatePtr(env, 'Envelope*') on the other hand always return 'true' therefore are useless
			-- TakeFX_GetEnvelope() returns env even if there's none but parameter mudulation was enabled at least once for the corresponding fx parameter hence must be validated with CountEnvelopePoints(env) because in this case there're no points; ValidatePtr(env, 'TrackEnvelope*'), ValidatePtr(env, 'TakeEnvelope*') and ValidatePtr(env, 'Envelope*') on the other hand always return 'true' therefore are useless
				for parm_idx = 0, r.TakeFX_GetNumParams(take, fx_idx)-1 do
				local env = r.TakeFX_GetEnvelope(take, fx_idx, parm_idx, false) -- create false
					if env and r.CountEnvelopePoints(env) > 0 then -- real, not ghost envelope
					local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
						if chunk:match('GUID ({.-})') == GUID then
						return tr, item, take, take_idx, fx_idx, parm_idx, env, env_id end
					end
				end
			end
			for env_idx = 0, r.CountTakeEnvelopes(take)-1 do
			local env = r.GetTakeEnvelope(take, env_idx)
				if r.CountEnvelopePoints(env) > 0 then -- real, not ghost envelope
				local retval, chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
					if chunk:match('GUID ({.-})') == GUID then
					return tr, item, take, take_idx, fx_id, parm_id, env, env_idx end
				end
			end
		end
	end

end

--[[ TESTING Get_Obj_By_GUID()
local tr = r.GetSelectedTrack2(0,0, true)
--Msg(tr)
--local ret, GUID = table.unpack(tr and {r.GetSetMediaTrackInfo_String(tr, 'GUID', '', false)} or {})
--Msg(GUID, 'MASTER')
local item = r.GetSelectedMediaItem(0,0)
--Msg(item)
--local ret, GUID = table.unpack(item and {r.GetSetMediaItemInfo_String(item, 'GUID', '', false)} or {})
local take = item and r.GetActiveTake(item)
--Msg(take)
--local ret, GUID = table.unpack(take and {r.GetSetMediaItemTakeInfo_String(take, 'GUID', '', false)} or {})
local env = r.GetSelectedEnvelope(0)
--Msg(env)
--Msg(r.CountEnvelopePoints(env), 'points')
local retval, chunk = table.unpack(env and {r.GetEnvelopeStateChunk(env, '', false)} or {}) -- isundo false
--local GUID = chunk and chunk:match('GUID ({.-})')
--local GUID = r.TrackFX_GetFXGUID(tr, 2)
--local GUID = r.TakeFX_GetFXGUID(take, 2)
--tr, item, take, take_id, fx_id, parm_id, env, env_id = Get_Obj_By_GUID('take fx', GUID)
tr, item, take, take_id, fx_id, parm_id, env, env_id = Get_Obj_By_GUID(GUID)
Msg(tr, 'TRACK')
Msg(item, 'ITEM')
Msg(take, 'TAKE')
Msg(take_id, 'TAKE ID')
Msg(fx_id, 'FX ID')
Msg(parm_id, 'PARM ID')
Msg(env, 'ENV')
Msg(env_id, 'ENV ID')
--]]




--=================================== T R A C K S ==================================

function Get_TCP_Under_Mouse() -- based on the function Get_Object_Under_Mouse_Curs()
-- r.GetTrackFromPoint() covers the entire track timeline hence isn't suitable for getting the TCP
-- master track is supported
local right_tcp = r.GetToggleCommandStateEx(0,42373) -- View: Show TCP on right side of arrange
local curs_pos = r.GetCursorPosition() -- store current edit curs pos
local start_time, end_time = r.GetSet_ArrangeView2(0, false, 0, 0, start_time, end_time) -- isSet false, screen_x_start, screen_x_end are 0 to get full arrange view coordinates // get time of the current Arrange scroll position to use to move the edit cursor away from the mouse cursor // https://forum.cockos.com/showthread.php?t=227524#2 the function has 6 arguments; screen_x_start and screen_x_end (3d and 4th args) are not return values, they are for specifying where start_time and stop_time should be on the screen when non-zero when isSet is true
--local TCP_width = tonumber(cont:match('leftpanewid=(.-)\n')) -- only changes in reaper.ini when dragged
r.PreventUIRefresh(1)
local edge = right_tcp and start_time-5 or end_time+5
r.SetEditCurPos(edge, false, false) -- moveview, seekplay false // to secure against a vanishing probablility of overlap between edit and mouse cursor positions in which case edit cursor won't move just like it won't if mouse cursor is over the TCP // +/-5 sec to move edit cursor beyond right/left edge of the Arrange view to be completely sure that it's far away from the mouse cursor
r.Main_OnCommand(40514,0) -- View: Move edit cursor to mouse cursor (no snapping) // more sensitive than with snapping
local tcp_under_mouse = r.GetCursorPosition() == edge or r.GetCursorPosition() == start_time -- if the TCP is on the right and the Arrange is scrolled all the way to the project start start_time-5 won't make the edit cursor move past project start hence the 2nd condition, but it can move past the right edge
-- Restore orig. edit cursor pos
--[[
local new_curs_pos = r.GetCursorPosition()
local min_val, subtr_val = table.unpack(new_curs_pos == edge and {curs_pos, edge} -- TCP found, edit cursor remained at edge
or new_curs_pos ~= edge and {curs_pos, new_curs_pos} -- TCP not found, edit cursor moved
or {0,0})
r.MoveEditCursor(min_val - subtr_val, false) -- dosel false = don't create time sel; restore orig. edit curs pos, greater subtracted from the lesser to get negative value meaning to move closer to zero (project start) // MOVES VIEW SO IS UNSUITABLE
--]]
--[-[ OR SIMPLY
r.SetEditCurPos(curs_pos, false, false) -- moveview, seekplay false // restore orig. edit curs pos
--]]
r.PreventUIRefresh(-1)

return tcp_under_mouse and r.GetTrackFromPoint(r.GetMousePosition())

end


function Get_Track_At_Mouse_Cursor_Y() -- covers the entire track timeline
local x, y = reaper.GetMousePosition()
local tr, info_code = reaper.GetTrackFromPoint(x, y)
return tr and info_code < 1 and tr -- not envelope and not docked FX window
end


function collapse_TCP(tr) -- = r.SetMediaTrackInfo_Value(tr, 'I_HEIGHTOVERRIDE', 1)
	repeat
	local tr_height = r.GetMediaTrackInfo_Value(tr, 'I_TCPH')
	r.Main_OnCommand(41326,0) -- View: Decrease selected track heights
	until r.GetMediaTrackInfo_Value(tr, 'I_TCPH') == tr_height -- until TCP height doesn't change after action is applied meaning it's been fully contracted
	r.TrackList_AdjustWindows(true) -- -- isMinor is true // updates TCP only https://forum.cockos.com/showthread.php?t=208275
end


function Deselect_All_Tracks1()
	if r.CountTracks(0) > 0 then -- OR r.GetNumTracks() > 0
	local tr = r.GetTrack(0,0)
	r.SetOnlyTrackSelected(tr)
	r.SetTrackSelected(tr, false) -- selected false
	end
end


function Deselect_All_Tracks2() -- API alternative to the action 'Track: Unselect all tracks' (40297)
local master = r.GetMasterTrack(0) -- Master track because it's always there
r.SetOnlyTrackSelected(master)
r.SetTrackSelected(master, false) -- selected is false
end


function Track_Controls_Locked(tr) -- locked is 1, not locked is nil
	if tr == r.GetMasterTrack(0) then return end -- Master track controls cannot be locked
r.PreventUIRefresh(1)
local mute_state = r.GetMediaTrackInfo_Value(tr, 'B_MUTE')
r.SetMediaTrackInfo_Value(tr, 'B_MUTE', mute_state ~ 1) -- flip the state
local mute_state_new = r.GetMediaTrackInfo_Value(tr, 'B_MUTE')
local locked
	if mute_state == mute_state_new then locked = 1
	else r.SetMediaTrackInfo_Value(tr, 'B_MUTE', mute_state) -- restore
	end
r.PreventUIRefresh(-1)
return locked
end


function Collect_Snd_Data(tr) -- dest track and channels // blueprint of dealing with sends/receives
local t = {}
	for snd_idx = 0, r.GetTrackNumSends(tr, 0)-1 do -- 0 is sends
	local dest_tr = r.GetTrackSendInfo_Value(tr, 0, snd_idx, 'P_DESTTRACK') -- 0 is sends
	local src_ch = r.GetTrackSendInfo_Value(tr, 0, snd_idx, 'I_SRCCHAN') -- 0 is sends
-- St channel count: 0 = 1/2, 1 = 2/3, 2 = 3/4, 3 = 4/5 etc
-- To get stereo source both ch indices, 1-based, add 1 and 2 to the return value, e.g. 0+1, 0+2 = 1/2 (index 0), 3+1, 3+2 = 4/5 (index 3)
-- Mono channel count starts from 1024, to evaluate if channel is mono do src_ch&1024==1024
-- To get mono source regular ch index, 0-based, subtract 1024 from the return value (src_ch), e.g. 1024-1024 = 0 (ch 1), 1025-1024 = 1 (ch 2) etc.
	local mono = src_ch&1024 == 1024
	t[dest_tr] = mono and {(src_ch-1024)+1} or {src_ch+1, src_ch+2} -- saving 1-based channel indices
	end
return t
end


function GetSetTrackSendInfo_Value(tr, cat, send_idx, param, val) -- param is a string, last two args are for setting
	if not param or not val then
	local t = {B_MUTE = 0, B_PHASE = 0, B_MONO = 0, D_VOL = 0, D_PAN = 0, D_PANLAW = 0, I_SENDMODE = 0, I_AUTOMODE = 0, I_SRCCHAN = 0, I_DSTCHAN = 0, I_MIDIFLAGS = 0, P_DESTTRACK = 0, P_SRCTRACK = 0, ['P_ENV:<VOLENV'] = 0, ['P_ENV:<PANENV'] = 0, ['P_ENV:<MUTEENV'] = 0}
		for k in pairs(t) do
		t[k] = reaper.GetTrackSendInfo_Value(tr, cat, send_idx, k)
		end
	return t
	elseif param and val return reaper.SetTrackSendInfo_Value(tr, cat, send_idx, param, val)
	end
end



function Preserve_TCP_Heights_When_Bot_Dock_Open()
-- TCP height isn't preserved when bottom dock is opened if the height was changed with vertical zoom
-- https://forum.cockos.com/showthread.php?t=267091#2 -- Edgemeal
	if r.GetToggleCommandStateEx(0,40279) == 1 then -- bottom docker open
	r.Main_OnCommand(40279, 0) -- View: Show docker / (toggle close it)
	else
	r.PreventUIRefresh(1)
	r.Main_OnCommand(reaper.NamedCommandLookup('_SWS_SAVESEL'), 0) -- SWS: Save current track selection
	r.Main_OnCommand(40296, 0) -- Track: Select all tracks
	r.Main_OnCommand(41327, 0) -- View: Increase selected track heights a little bit
	r.Main_OnCommand(41328, 0) -- View: Decrease selected track heights a little bit
	-- reaper.Main_OnCommand(40297, 0) -- Track: Unselect all tracks -- (Not Needed ?)
	r.Main_OnCommand(reaper.NamedCommandLookup('_SWS_RESTORESEL'), 0) -- SWS: Restore saved track selection
	r.Main_OnCommand(40279, 0) -- View: Show docker
	r.PreventUIRefresh(-1)
	end
end


function Re_Store_Track_Heights_Selection_x_Scroll(t, ref_tr_y) -- scroll state isn't restored
	if not t then
	local t = {}
		for i=0, r.CountTracks(0)-1 do
		local tr = r.GetTrack(0,i)
		t[#t+1] = {height=r.GetMediaTrackInfo_Value(tr, 'I_TCPH'), sel=r.IsTrackSelected(tr)}
		end
	local ref_tr = r.GetTrack(0,0) -- reference track (any) to scroll back to in order to restore scroll state after track heights restoration
	local ref_tr_y = r.GetMediaTrackInfo_Value(ref_tr, 'I_TCPY')
	return t, ref_tr_y
	else
		for k, data in ipairs(t) do -- restore heights
		local height = data.height
		local tr = r.GetTrack(0,k-1)
		local tr_h = r.GetMediaTrackInfo_Value(tr, 'I_TCPH')
			if tr_h ~= height then
			local bigger, smaller = tr_h > height, tr_h < height
			local action = bigger and 41326 -- View: Decrease selected track heights
			or smaller and 41325 -- View: Increase selected track heights
			r.SetOnlyTrackSelected(tr)
				repeat
				r.Main_OnCommand(action, 0)
				-- r.Main_OnCommand(41327, 0) -- View: Increase selected track heights a little bit
				-- r.Main_OnCommand(41328, 0) -- View: Decrease selected track heights a little bit
				local tr_h = r.GetMediaTrackInfo_Value(tr, 'I_TCPH')
			until bigger and tr_h <= height or smaller and tr_h >= height
			end
		end
		for k, data in ipairs(t) do -- restore selection
		local tr = r.GetTrack(0,k-1)
		r.SetTrackSelected(tr, data.sel)
		end
	r.PreventUIRefresh(1)
		repeat
		r.CSurf_OnScroll(0, -1) -- y is negative to scroll up because after track heights restoration the tracklist ends up being scrolled all the way down // 1 vert scroll unit is 8 px
		until r.GetMediaTrackInfo_Value(ref_tr, 'I_TCPY') >= ref_tr_y
	r.PreventUIRefresh(-1)
	end

end


function Temp_Track_For_FX(obj, fx_idx, take_GUID)

r.PreventUIRefresh(1)

-- r.Main_OnCommand(40702, 0) -- Track: Insert new track at end of track list and hide it // creates undo point hence unsuitable
r.InsertTrackAtIndex(r.GetNumTracks(), false) -- wantDefaults false; insert new track at end of track list and hide it; action 40702 'Track: Insert new track at end of track list' creates undo point hence unsuitable
local temp_track = r.GetTrack(0,r.CountTracks(0)-1)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINMIXER', 0) -- hide in Mixer
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINTCP', 0) -- hide in Arrange

r.TrackFX_AddByName(temp_track, 'Video processor', 0, -1) -- insert
local copy = take_GUID and r.TakeFX_CopyToTrack(obj, fx_idx, temp_track, 0, false) or not take_GUID and r.TrackFX_CopyToTrack(obj, fx_idx, temp_track, 0, false) -- is_move false // difficult to work with r.TrackFX_AddByName() using plugin names as they can be renamed which will only be reflected in reaper-vstrenames(64).ini, not in the chunk; 'not take_GUID' cond is needed to avoid error when object is take which doesn't fit TrackFX_CopyToTrack() function // when copying FX envelopes don't follow, only when moving

-- DO STUFF --

local copy =  take_GUID and r.TrackFX_CopyToTake(temp_track, 0, obj, fx_idx, false) or not take_GUID and r.TrackFX_CopyToTrack(temp_track, 0, obj, fx_idx, false) -- copy back from temp track

r.DeleteTrack(temp_track)

r.PreventUIRefresh(-1)

return -- STUFF

end


function Get_Vis_TCP_Tracklist_Length_px_X_Topmost_Track(unhide, exclusive_track_display) -- return values are used to scroll tracklist all the way up and then, if needed, to restore the position of the track which was the topmost prior to that thereby restoring tracklist scroll position

--[[ -- UNHIDING AND GETTING TRACKLIST LENGTH IN THE SAME FUNCTION DOESN'T WORK
	for i = 0, r.CountTracks(0)-1 do
	local tr = r.GetTrack(0,i)
	local name, flags = r.GetTrackState(tr)
	-- Unhide previosuly hidden with the script with -h operator
		if flags&512 == 512 then -- invisible in TCP -- OR r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') == 0
		local retval, ext_data = r.GetSetMediaTrackInfo_String(tr, 'P_EXT:'..cmdID, '', false) -- setNewValue false // find if it was hidden with this script
			if retval then r.GetSetMediaTrackInfo_String(tr, 'P_EXT:'..cmdID, '', true) -- setNewValue true // delete ext data
			r.SetMediaTrackInfo_Value(tr, 'B_SHOWINTCP', 1) -- unhide in TCP
			end
		end
	end
r.TrackList_AdjustWindows(false) -- isMinor false - both TCP and MCP
--]]

	local function get_next_vis_track(cur_idx)
		for i = cur_idx, r.CountTracks(0)-1 do
		local tr = r.GetTrack(0,i)-- or master_vis and r.GetMasterTrack(0)
		local name, flags = r.GetTrackState(tr)
			if flags&512 ~= 512 then return tr end
		end
	end

local master_vis = r.GetMasterTrackVisibility()&1 -- in TCP // OR r.GetToggleCommandStateEx(0,40075) == 1 -- View: Toggle master track visible

local tracklist_len, topmost_vis_tr
--	for i = 0, r.CountTracks(0)-1 do
	for i = master_vis and -1 or 0, r.CountTracks(0)-1 do -- -1 to account for the Master track if visible in the TCP
	local tr = r.GetTrack(0,i) or master_vis and r.GetMasterTrack(0)
	local name, flags = r.GetTrackState(tr) -- reget the state after unhiding (if ever) to account for in the TCP length
		if flags&512 ~= 512 then -- visible in TCP -- OR r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') == 1
		local tr_TCPY = r.GetMediaTrackInfo_Value(tr, 'I_TCPY')
			if not topmost_vis_tr and tr_TCPY + r.GetMediaTrackInfo_Value(tr, 'I_WNDH') >= 0 -- find 1st track whose TCP top is at 0 px or which crosses from negative (partially hidden from view at the top) to positive pixel value
			then
				if math.abs(tr_TCPY) < r.GetMediaTrackInfo_Value(tr, 'I_WNDH')/2 -- store the top track as long as its TCPY value is less than the half of its height + envelopes, i.e. sticks out of the Arrange top edge by at least half of its height + envelopes and if less, the next track will be stored and scrolled to; math.abs to account for negative TCPY value when part of a track is hidden at the top // store only once, as long as topmost_vis_tr is nil
				and (not (unhide and exclusive_track_display) or unhide and exclusive_track_display and i~=-1) -- accounting for cases of 's' operator usage while not in exclusive display mode and its usage while in exclusive display mode with Master track being the topmost visible to ensure that the topmost media track is kept at the top instead when all tracks are unhidden
				then
				topmost_vis_tr = tr
				else -- if the top track is hidden by more than half or when going out of the exclusive display mode with Master track visible, store the next track
				topmost_vis_tr = get_next_vis_track(i+1) or tr -- store only once as long as topmost_vis_tr is nil // accounting for a case where there's no next track
				end
			end
		tracklist_len = tr_TCPY + r.GetMediaTrackInfo_Value(tr, 'I_WNDH') -- incl envelopes // count
		end
	end

return tracklist_len, topmost_vis_tr

end
r.CSurf_OnScroll(0, tracklist_len*-1) -- scroll the tracklist all the way up, without division by 8, to the very start to then be able to scroll down from 0 (I_TCPY value of the 1st visible track) searching for a specific track
local topmost_vis_tr_I_TCPY = r.GetMediaTrackInfo_Value(topmost_vis_tr, 'I_TCPY')
r.CSurf_OnScroll(0, round(topmost_vis_tr_I_TCPY/8))


function Scroll_Track_To_Top(tr)
local tr_y = r.GetMediaTrackInfo_Value(tr, 'I_TCPY')
local dir = tr_y < 0 and -1 or tr_y > 0 and 1 or 0 -- if less than 0 (out of sight above) the scroll must move up to bring the track into view, hence -1 and vice versa
r.PreventUIRefresh(1)
local cntr, Y_init = 0 -- to store track Y coordinate between loop cycles and monitor when the stored one equals to the one obtained after scrolling within the loop which will mean the scrolling can't continue due to reaching scroll limit when the track is close to the track list end or is the very last, otherwise the loop will become endless because there'll be no condition for it to stop
    repeat
    r.CSurf_OnScroll(0, dir) -- unit is 8 px
    local Y = r.GetMediaTrackInfo_Value(tr, 'I_TCPY')
		if Y ~= Y_init then Y_init = Y -- store
		else cntr = cntr+1
		end
	until not Y or dir > 0 and Y <= 0 or dir < 0 and Y >= 0 or cntr == 1 -- not Y if tr is invalid
--[[OR
	repeat
    r.CSurf_OnScroll(0, dir) -- unit is 8 px
    local Y = r.GetMediaTrackInfo_Value(tr, 'I_TCPY')
		if Y ~= Y_init then Y_init = Y -- store
		elseif Y == Y_init then break -- if scroll has reached the end before track has reached the destination to prevent loop becoming endless
		end
	until dir > 0 and Y <= 0 or dir < 0 and Y >= 0
--]]

r.PreventUIRefresh(-1)

end


function Scroll_Track_To_Top2(tr)
-- for previous first sel track is scrolled, for next - last
local GetValue = r.GetMediaTrackInfo_Value
local tr_y = GetValue(tr, 'I_TCPY')
local dir = tr_y < 0 and -1 or tr_y > 0 and 1 -- if less than 0 (out of sight above) the scroll must move up to bring the track into view, hence -1 and vice versa
r.PreventUIRefresh(1)
local Y_init -- to store track Y coordinate between loop cycles and monitor when the stored one equals to the one obtained after scrolling within the loop which will mean the scrolling can't continue due to reaching scroll limit when the track is close to the track list end or is the very last, otherwise the loop will become endless because there'll be no condition for it to stop
	if dir then
		repeat
		r.CSurf_OnScroll(0, dir) -- unit is 8 px
		local Y = GetValue(tr, 'I_TCPY')
			if Y ~= Y_init then Y_init = Y -- store
			elseif Y == Y_init then break end -- if scroll has reached the end before track has reached the destination to prevent loop becoming endless
		until dir > 0 and Y <= 0 or dir < 0 and Y >= 0
	end
r.PreventUIRefresh(-1)
end


function Scroll_Track_To_Bottom(tr, arrange_h) -- arrange_h is the value returned by Get_Arrange_and_Header_Heights2() function
local tr_y = r.GetMediaTrackInfo_Value(tr, 'I_TCPY')
local dir = tr_y < 0 and -1 or tr_y > 0 and 1 or 0 -- if less than 0 (out of sight above) the scroll must move up to bring the track into view, hence -1 and vice versa
r.PreventUIRefresh(1)
local cntr, Y_init = 0 -- to store track Y coordinate between loop cycles and monitor when the stored one equals to the one obtained after scrolling within the loop which will mean the scrolling can't continue due to reaching scroll limit when the track is close to the track list start or is the very first, otherwise the loop will become endless because there'll be no condition for it to stop
    repeat
    r.CSurf_OnScroll(0, dir) -- unit is 8 px
--  local tr = r.GetTrack(0, r.CSurf_TrackToID(tr, false)-3) -- 2nd prev track
    local tr = r.GetTrack(0, r.CSurf_TrackToID(tr, false)-2) -- prev track // otherwise the track list stops at the next track
    local Y = r.GetMediaTrackInfo_Value(tr, 'I_TCPY') -- mcpView false
		if Y ~= Y_init then Y_init = Y -- store
		else cntr = cntr+1
		end
--  local H = r.GetMediaTrackInfo_Value(tr, 'I_WNDH') -- mcpView false // only needed if 2nd prev track is used which is unnecessary
 -- until not Y or dir > 0 and Y+H <= arrange_h or dir < 0 and Y+H >= arrange_h or cntr == 1 // if 2nd prev track is used
	until not Y or dir > 0 and Y <= arrange_h or dir < 0 and Y >= arrange_h or cntr == 1 -- not Y if tr is invalid
r.PreventUIRefresh(-1)
end



function Un_Collapse_All_Tracks_Temporarily(t)
local GET, SET = r.GetMediaTrackInfo_Value, r.SetMediaTrackInfo_Value
	if not t then -- uncollapse and store
	r.SetMediaTrackInfo_Value
	local t = {}
		for i = 0, r.CountTracks(0)-1 do
		local tr = r.GetTrack(0,i)
			if GET(tr, 'I_FOLDERDEPTH') == 1 -- parent
			and GET(tr, 'I_FOLDERCOMPACT') == 2 -- tiny children
			then
			SET(tr, 'I_FOLDERCOMPACT', 1) -- small
			t[#t+1] = tr
			end
		end
	return t
	else -- restore
		for _, tr in ipairs(t) do
		SET(tr, 'I_FOLDERCOMPACT', 2) -- tiny children
		end
	end
end


function Create_Buss_Track()
-- select the source track, insert below a new one, create a pre-fader (post-fx) send
-- https://old.reddit.com/r/Reaper/comments/11clcho/is_there_a_shortcut_to_create_a_parallel_track/
local tr = r.GetSelectedTrack(0,0)
	if not tr then r.MB('No selected tracks', 'ERROR', 0) return end
local tr_idx = r.CSurf_TrackToID(tr, false) -- mcpView false
r.InsertTrackAtIndex(tr_idx, true) -- wantDefaults true
local buss_tr = r.CSurf_TrackFromID(tr_idx+1, false) -- mcpView false
r.CreateTrackSend(tr, buss_tr)
r.SetTrackSendInfo_Value(tr, 0, 0, 'I_SENDMODE', 3) -- category 0 (send), sendidx 0, newvalue 3 (pre fader post-fx)
end


function Find_And_Get_New_Tracks(t)
	if not t then
	local t = {}
		for i = 0, r.GetNumTracks()-1 do
		t[r.GetTrack(0,i)] = '' -- dummy field
		end
	return t
	elseif t then
	local t2 = {}
		for i = 0, r.GetNumTracks()-1 do
		local tr = r.GetTrack(0,i)
			if not t[tr] then -- track wasn't stored so is new // some conditions can be added here to only target certain new tracks
			t2[#t2+1] = {tr=tr, idx=i}
			end
		end
	return #t2 > 0 and t2
	end
end
-- USAGE EXAMPLE:
--local t = Find_And_Get_New_Tracks() -- store current tracks
--DO STTUFF
--local t = Find_And_Get_New_Tracks(t) -- get new if any, if none returns nil


function Get_Track_Minimum_Height() -- may be different from 24 px in certain themes

r.PreventUIRefresh(1)

local uppermost_tr, Y_init

	for i = 0, r.CountTracks(0)-1 do
	uppermost_tr = r.GetTrack(0,i)
	Y_init = r.GetMediaTrackInfo_Value(uppermost_tr, 'I_TCPY')
		if Y_init >= 0 -- store to restore scroll position after getting minimum track height because insertion of new track via API whether at the top or at the bottom makes the tracklist scroll to the end
		then break end
	end

local sel_tr_t = {} -- store currently selected tracks
	for i = 0, r.CountSelectedTracks(0)-1 do
	sel_tr_t[#sel_tr_t+1] = r.GetSelectedTrack(0,i)
	end

-- r.Main_OnCommand(40702, 0) -- Track: Insert new track at end of track list and hide it // creates undo point hence unsuitable
r.InsertTrackAtIndex(r.GetNumTracks(), false) -- wantDefaults false; insert new track at end of track list and hide it; action 40702 'Track: Insert new track at end of track list' creates undo point hence unsuitable
local temp_track = r.GetTrack(0,r.CountTracks(0)-1)
r.SetOnlyTrackSelected(temp_track)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINMIXER', 0) -- hide in Mixer
--r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINTCP', 0) -- hide in Arrange // must appear in TCP otherwise the action 'View: Decrease selected track heights' won't affect it

r.PreventUIRefresh(-1)

-- find minimum height by fully collapsing // must be outside of PreventUIRefresh() because it also prevents change in height
local H_min = r.GetMediaTrackInfo_Value(temp_track, 'I_TCPH')
	repeat
	r.Main_OnCommand(41326,0) -- View: Decrease selected track heights // does 8 px
	local H = r.GetMediaTrackInfo_Value(temp_track, 'I_TCPH')
		if H < H_min then H_min = H
		elseif H_min == H then break end -- can't be changed to any lesser value
	until H == 0 -- this condition is immaterial since the loop exits earlier once minimum height is reached which is always greater than 0

r.PreventUIRefresh(1)

r.DeleteTrack(temp_track)

	for _, tr in ipairs(sel_tr_t) do -- restore originally selected tracks
	r.SetTrackSelected(tr, true) -- selected true
	end

	repeat -- restore scroll
	r.CSurf_OnScroll(0, -1) -- scroll up because so the tracklist is scrolled down
	until r.GetMediaTrackInfo_Value(uppermost_tr, 'I_TCPY') >= Y_init

r.PreventUIRefresh(-1)

return H_min

end


function Reverse_Track_Order(tr_t) -- tr_t is a table of track pointers in their current order, must all be adjacent
local ref_idx = r.CSurf_TrackToID(t[#t], false) -- mcpView false // track which immediately follows the last stored track CSurf_TrackToID() returns 1-based index of the current track which equals 0-based index of the next track
local decrement = 0
	for _, tr in ipairs(t) do
	r.SetOnlyTrackSelected(tr)
	r.ReorderSelectedTracks(ref_idx-decrement, makePrevFolder) -- beforeTrackIdx is ref_idx-decrement
	decrement = decrement+1 -- at each cycle decrease beforeTrackIdx because each track will have to be placed before the previous and travel less places
	end

end


function Remove_Track_From_All_Groups(tr, high) -- high is boolean to target groups 33-64
-- the bits are counted as 1,2,4,8,16,32,64,128 etc. up to 4,294,967,295
-- each bit represents one of the first 32 groups with the function GetSetTrackGroupMembership()
-- and one of groups 33-64 with the function GetSetTrackGroupMembershipHigh()
-- to query states in a specific group, a bit which corresponds to such group must be used, e.g. to query states in group 6, the integer 32 must be used because decimal equvalent of a set bit 6 is 32, i.e.
-- 0000 0000 0000 0000 0000 0000 0010 0000 -- 1 occupies 6th place from the right, and 32 is the 6th number in the above list
-- but since for obtaining the corresponding integer 2 (the base) must be raised to a power, the exponent sequence begins with 0 to begin with bit 1 (2^0) and each following exponent is less than the group number by 1, i.e. 2 = 2^1 (group 2), 4 = 2^2 (group 3) ... 32 = 2^5 (group 6) etc
--[[
TOGGLE
local bitfield = r.GetSetTrackGroupMembership(r.GetSelectedTrack(0,0), 'VOLUME_LEAD', 0, 32) -- query group 6
--Msg(state&32==32)
local set = bitfield&32==32 and 0 or 32
r.GetSetTrackGroupMembership(r.GetSelectedTrack(0,0), 'VOLUME_LEAD', 32, set) -- set// setvalue 32 to set, 0 to unset
--OR
--r.GetSetTrackGroupMembership(r.GetSelectedTrack(0,0), 'VOLUME_LEAD', 32, bitfield~32) -- set if not set and vice versa
]]
local GetSet = high and r.GetSetTrackGroupMembershipHigh or r.GetSetTrackGroupMembership
local m, s = '_MASTER', '_SLAVE'
local parm_t = {'VOLUME','VOLUME_VCA','PAN','WIDTH','MUTE','SOLO',
'POLARITY','RECARM','AUTOMODE','VOLUME_REVERSE','PAN_REVERSE',
'WIDTH_REVERSE','VOLUME_VCA_FOLLOW_ISPREFX','NO_LEAD_WHEN_FOLLOW','NO_MASTER_WHEN_SLAVE'} -- 'NO_LEAD_WHEN_FOLLOW' is listed but doesn't work, 'NO_MASTER_WHEN_SLAVE' does
-- https://forum.cockos.com/showthread.php?t=277048
	for i = 0, 32 do -- 32 bits, each represents 1 of the 64 groups
	local bit = 2^i -- calculate the bit representing the group
		for k, parm in ipairs(parm_t) do
			if k <=9 then -- parms which have two roles
			-- Master role
			local bitfield = GetSet(tr, parm..m, 0, bit) -- setmask is 0, query, setvalue is the target bit, returns current bitfield
				if bitfield&bit == bit then -- set // mask is used to query the state
				GetSet(tr, parm..m, bit, bitfield~bit) -- setmask is the target bit, setvalue is 0, created with bitwise NOT
				end
			-- Slave role
			local bitfield = GetSet(tr, parm..s, 0, bit) -- query
				if bitfield&bit == bit then -- set
				GetSet(tr, parm..s, bit, bitfield~bit) -- unset
				end
			else -- parms which don't have roles and are additional
			local bitfield = GetSet(tr, parm, 0, bit) -- query
				if bitfield&bit == bit then -- set
				GetSet(tr, parm, bit, bitfield~bit) -- unset
				end
			end
		end
	end

end


function Remove_Track_Master_Role_From_All_Groups(tr, high) -- high is boolean to target groups 33-64 // to remove from Slave role comment out Master and additional parameter routines
-- the bits are counted as 1,2,4,8,16,32,64,128 etc. up to 4,294,967,295
-- each bit represents one of the first 32 groups with the function GetSetTrackGroupMembership()
-- and one of groups 33-64 with the function GetSetTrackGroupMembershipHigh()
-- to query states in a specific group, a bit which corresponds to such group must be used, e.g. to query states in group 6, the integer 32 must be used because decimal equvalent of a set bit 6 is 32, i.e.
-- 0000 0000 0000 0000 0000 0000 0010 0000 -- 1 occupies 6th place from the right, and 32 is the 6th number in the above list
-- but since for obtaining the corresponding integer, 2 (the base) must be raised to a power, the exponent sequence begins with 0 to begin with bit 1 (2^0) and each following exponent is less than the group number by 1, i.e. 2 = 2^1 (group 2), 4 = 2^2 (group 3) ... 32 = 2^5 (group 6) etc
--[[
TOGGLE
local bitfield = r.GetSetTrackGroupMembership(r.GetSelectedTrack(0,0), 'VOLUME_LEAD', 0, 32) -- query group 6
--Msg(state&32==32)
local set = bitfield&32==32 and 0 or 32
r.GetSetTrackGroupMembership(r.GetSelectedTrack(0,0), 'VOLUME_LEAD', 32, set) -- set// setvalue 32 to set, 0 to unset
--OR
--r.GetSetTrackGroupMembership(r.GetSelectedTrack(0,0), 'VOLUME_LEAD', 32, bitfield~32) -- set if not set and vice versa
]]
local GetSet = high and r.GetSetTrackGroupMembershipHigh or r.GetSetTrackGroupMembership
local m, s = '_MASTER', '_SLAVE'
local parm_t = {'VOLUME','VOLUME_VCA','PAN','WIDTH','MUTE','SOLO',
'POLARITY','RECARM','AUTOMODE','VOLUME_REVERSE','PAN_REVERSE',
'WIDTH_REVERSE','VOLUME_VCA_FOLLOW_ISPREFX','NO_LEAD_WHEN_FOLLOW','NO_MASTER_WHEN_SLAVE'} -- 'NO_LEAD_WHEN_FOLLOW' is listed but doesn't work, 'NO_MASTER_WHEN_SLAVE' does
-- https://forum.cockos.com/showthread.php?t=277048
	for i = 0, 32 do -- 32 bits, each represents 1 of the 64 groups
	local bit = 2^i -- calculate the bit representing the group
		for k, parm in ipairs(parm_t) do
			if k <=9 then -- parms which have two roles
			-- Master role
			local bitfield = GetSet(tr, parm..m, 0, bit) -- setmask is 0, query, setvalue is the target bit, returns current bitfield
				if bitfield&bit == bit then -- set // mask is used to query the state
				GetSet(tr, parm..m, bit, bitfield~bit) -- setmask is the target bit, setvalue is 0, created with bitwise NOT
				end
			--[[ Slave role
			local bitfield = GetSet(tr, parm..s, 0, bit) -- query
				if bitfield&bit == bit then -- set
				GetSet(tr, parm..s, bit, bitfield~bit) -- unset
				end
			else -- parms which don't have roles and are additional
			local bitfield = GetSet(tr, parm, 0, bit) -- query
				if bitfield&bit == bit then -- set
				GetSet(tr, parm, bit, bitfield~bit) -- unset
				end
			--]]
			end
		end
	end

end



--================================ T R A C K S  E N D ================================


--================================== F O L D E R S ====================================


function Count_And_Store_Children(tr)
local t = {}
local cnt = 0
	for i = r.CSurf_TrackToID(tr, false), r.CountTracks(0)-1 do -- mcpView false // starting loop from the 1st child
	local chld_tr = r.GetTrack(0, i)
	--	if r.GetParentTrack(chld_tr) == tr then -- wrong since will be false for grandchildren in nested folders
		if r.GetTrackDepth(chld_tr) > 0 then -- correct
		t[#t+1] = chld_tr
		cnt = cnt+1
		else return t, cnt
		end
	end
end

function Are_All_Children_Selected(tr)
	for i = r.CSurf_TrackToID(tr, false), r.CountTracks(0)-1 do -- starting loop from the 1st child
	local chld_tr = r.GetTrack(0, i)
	local is_parent = r.GetParentTrack(sibl_tr) == tr
		if is_parent and not r.IsTrackSelected(chld_tr) then
		return false
		elseif not is_parent then break
		end
	end
return true
end


function Count_And_Store_Siblings(chld_tr)
local parent_tr = r.GetParentTrack(chld_tr)
local t = {}
local cnt = 0
	for i = r.CSurf_TrackToID(parent_tr, false), r.CountTracks(0)-1 do -- starting the loop from the 1st child of the parent track // include the source child track in the table
	local sibl_tr = r.GetTrack(0, i)
		if r.GetParentTrack(sibl_tr) == parent_tr then
		t[#t+1] = sibl_tr
		cnt = cnt+1
		else return t, cnt
	end
end


function Are_All_Siblings_Selected(chld_tr)
local parent_tr = r.GetParentTrack(chld_tr)
-- starting loop from the 1st sibling
	for i = r.CSurf_TrackToID(parent_tr, false), r.CountTracks(0)-1 do -- starting the loop from the 1st child of the parent track
	local sibl_tr = r.GetTrack(0, i)
	local same_parent = r.GetParentTrack(sibl_tr) == parent_tr
		if same_parent and not r.IsTrackSelected(sibl_tr)
		then return false
		elseif not same_parent then break
		end
	end
return true
end


function Get_Folder_First_Track(child_idx) -- either idx or pointer
-- VISIBILITY IS NOT EVALUATED
local child_idx = tonumber(child_idx) or r.CSurf_TrackToID(child_idx, false)-1 -- mcpView false
local parent
	if child_idx then
	local i = child_idx
		repeat
		parent = r.GetTrack(0,i)
		i = i - 1
		until r.GetTrackDepth(parent) == 0 -- topmost parent found
	return parent
	end
end


function Get_Folder_Last_Track(child_idx) -- either idx or pointer
-- VISIBILITY IS NOT EVALUATED
local child_idx = tonumber(child_idx) or r.CSurf_TrackToID(child_idx, false)-1 -- mcpView false
	if child_idx then
		for i = child_idx, r.CountTracks(0)-1 do
		local tr = r.GetTrack(0,i)
			if r.GetTrackDepth(tr) == 0 -- first track outside of the folder
			or not tr -- the last child was the last in the tracklist
			then return r.GetTrack(0,i-1) end
		end
	end
end


function Get_All_Track_Parents(start_tr)
-- VISIBILITY IS NOT EVALUATED
local parent = r.GetParentTrack(start_tr)
local parents_t = {}
	for i = r.CSurf_TrackToID(start_tr, false)-2, 0, -1 do -- mcpView false // -2 to start from immediatedly preceding track
	local tr = r.GetTrack(0,i)
		if tr == parent then -- and itself has a parent
		parents_t[#parents_t+1] = tr
		parent = r.GetParentTrack(tr)
		end
	end
return parents_t
end


function Get_Topmost_Uncollapsed_TCP_Parent(child_idx, child_tr, t) -- t is a table
-- VISIBILITY IS NOT EVALUATED
	for i = child_idx, 0, -1 do -- in reverse
	local tr = r.GetTrack(0,i)
		if tr == r.GetParentTrack(child_tr) then
			if r.GetMediaTrackInfo_Value(tr, 'I_FOLDERCOMPACT') == 2 -- parent track is fully collapsed // only valid for folders
			then
			t[#t+1] = tr
			end
		get_topmost_uncollapsed_parent(i, tr, t) -- repeat using current parent as a child to find its own parent, if any, and so on
		end
	end
return t, t[#t] -- return table to use for uncollapsing and the topmost uncollapsed track which ends up being the very last
end


function get_last_uncollapsed_parent(child_idx, child_tr, t, tcp)
-- t is a table; tcp is boolean to activate either the tcp or the mcp routine // last uncollapsed means that the parent itself isn't collapsed inside the folder it belongs to, unless it's the topmost level parent of the entire folder which cannot be collapsed, this is equal to the parent of the 1st/topmost (sub)folder whose child tracks are collapsed // equals parent of the 1st folder whose tracks are collapsed
-- relies on GetObjChunk2() for MCP routine, i.e. when tcp arg is nil

	if r.GetTrackDepth(child_tr) == 0 then return child_tr end -- if target track isn't a child

		if tcp then -- get in the TCP and store all parents of the found track
			for i = child_idx, 0, -1 do -- in reverse
			local tr = r.GetTrack(0,i)
				if tr == r.GetParentTrack(child_tr) then
					if r.GetMediaTrackInfo_Value(tr, 'I_FOLDERCOMPACT') == 2 -- parent track whose child tracks are fully collapsed // only valid for folders
					then
					t[#t+1] = tr
					end
				get_last_uncollapsed_parent(i, tr, t, tcp) -- go recursive, using current parent as a child to find its own parent, if any, and so on
				end
			end
			if #t > 0 then return t[#t], t -- return last uncollapsed track which ends up being the very last and the table to use for uncollapsing
			else return child_tr end -- if no parent track of a collapsed folder was found

		else -- search the leftmost uncollapsed parent in the MCP, if any, to select it if the context is not TCP (not TCP cond is applied outside of the function

		-- Collect all parents of the track to then find the last (rightmost) uncollapsed if any // uncollapsed means that the parent itself isn't collapsed inside the folder it belongs to, unless it's the topmost level parent of the entire folder which cannot be collapsed, this is equal to the parent of the leftmost (sub)folder whose child tracks are collapsed
		local parent = r.GetParentTrack(child_tr)
			for i = child_idx, 0, -1 do -- in reverse
			local tr = r.GetTrack(0,i)
				if tr == parent then
				t[#t+1] = tr -- in the table the leftmost track is at the end
				parent = r.GetParentTrack(tr)
				end
			end
			-- Find the leftmost collapsed parent, if any
			for i = #t, 1, -1 do -- in reverse since parent tracks were stored from right to left; if the table is empty the loop won't start
			local tr = t[i]
			local ret, chunk = GetObjChunk2(tr)
				if ret ~= 'err_mess' -- if parent track chunk is larger than 4.194303 Mb and no SWS extension to handle that to find out if it's collapsed
				and chunk:match('BUSCOMP %d (%d)') == '1' then -- child tracks are collapsed
				return tr -- as soon as parent with collapsed children is found; since the parents are traversed from the left, first parent with collapsed children means that lower level parents are all collapsed and are unsuitable for selection
				end
			end
		return child_tr -- if no parent track of a collapsed folder was found
		end

end


function Find_Last_Uncollapsed_MCP_Parent(targ_tr, GetTrackChunk)
-- returns parent of a collapsed folder (if any) of the target track in order to scroll to it, because child track of a collapsed folder can't be scrolled to
-- r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER') doesn't indicate if it's under collapsed folder, only when it's explicitly hidden, r.CSurf_TrackToID(tr, true) -- mcpView true does returning in this case -1
-- last uncollapsed means that the parent itself isn't collapsed inside the folder it belongs to, unless it's the topmost level parent of the entire folder which cannot be collapsed, this is equal to the parent of the 1st/topmost (sub)folder whose child tracks are collapsed // equals parent of the 1st folder whose tracks are collapsed

	if r.GetTrackDepth(targ_tr) == 0 then return targ_tr end -- if target track isn't a child

-- Collect all parents of the track to then find the last (rightmost) uncollapsed if any // uncollapsed means that the parent itself isn't collapsed inside the folder it belongs to, unless it's the topmost level parent of the entire folder which cannot be collapsed, this is equal to the parent of the leftmost (sub)folder whose child tracks are collapsed
local targ_tr_idx = r.CSurf_TrackToID(targ_tr, false)-1 -- mcpView false
local parent = r.GetParentTrack(targ_tr)
local parents_t = {}
--------------------------------
	for i = targ_tr_idx-1, 0, -1 do -- in reverse // targ_tr_idx-1 to start from previous track
	local tr = r.GetTrack(0,i)
		if tr == parent then
		t[#t+1] = tr -- in the table the leftmost track is at the end
		parent = r.GetParentTrack(tr)
		end
	end
--[[ OR
local parent = r.GetParentTrack(targ_tr)
local parents_t = {}
local i = targ_tr_idx-1 -- start from previous track
	repeat
	local tr = r.GetTrack(0,i)
		if tr == parent then parents_t[#parents_t+1] = tr // OR = parent // in the table the leftmost track is at the end
		parent = r.GetParentTrack(tr)
		end
	i = i - 1
	until r.GetTrackDepth(parent) == 0 -- uppermost parent found
--]]---------------------------

	-- Find the leftmost collapsed parent, if any
	for i = #parents_t, 1, -1 do -- in reverse since parent tracks were stored from right to left; if the table is empty the loop won't start
	local parent_tr = parents_t[i]
	local ret, chunk = GetTrackChunk(parent_tr)
		if ret ~= 'err_mess' -- if parent track chunk is larger than 4.194303 Mb and no SWS extension to handle that to find out if it's collapsed
		and chunk:match('BUSCOMP %d (%d)') == '1' then -- child tracks are collapsed
		return parent_tr -- as soon as parent with collapsed children is found; since the parents are traversed from the left, first parent with collapsed children means that lower level parents are all collapsed and are unsuitable for selection
		end
	end

return targ_tr -- if no parent track of a collapsed folder was found return original track

end


function Get_Parent_Of_MCP_First_Uncollapsed_Folder1(tr) -- basically the same as the above Find_Last_Uncollapsed_MCP_Parent() with added visibility evaluation, stems from the same script
-- tr argument is a pointer of a track to scroll to, if it happens to be a child of a collapsed folder
-- return its parent track or first (from the left) uncollapsed parent of a nested folder
-- (which itself is a parent of collapsed folder), otherwise return tr
-- relies on GetObjChunk() function

-- Collect all parents of the found track to then find the first (leftmost) uncollapsed if any
local parent = r.GetParentTrack(tr)
local parents_t = {}
	for i = r.CSurf_TrackToID(tr, false)-2, 0, -1 do -- in reverse // mcpView false, allows to get it even if it's hidden in a collapsed folder // -2 to start from immediatedly preceding track as CSurf_TrackToID returns 1-based track index which is greater than the 0-based by 1
	local tr = r.GetTrack(0,i)
		if tr == parent
		and r.IsTrackVisible(tr, true) -- mixer true // VISIBILITY IS EVALUATED
		then -- and itself has a parent
		parents_t[#parents_t+1] = tr -- in the table the leftmost track is at the end
		end
	parent = r.GetParentTrack(tr)
	end
	-- Find the leftmost uncollapsed parent, if any ((un)collapsing Mixer tracks must be done via chunk which is too cumbersome and isn't worth the effort for this script)
	for i = #parents_t, 1, -1 do -- in reverse since parent tracks were stored from right to left; if the table is empty the loop won't start
	local parent_tr = parents_t[i]
	local ret, chunk = GetObjChunk(parent_tr)
		if ret ~= 'err_mess' -- if parent track chunk is larger than 4.194303 Mb and no SWS extension to handle that to find out if it's collapsed
		and chunk:match('BUSCOMP %d (%d)') == '1' then -- collapsed
		return parent_tr -- as soon as uncollapsed parent is found
		end
	end

return tr

end


function Get_Parent_Of_MCP_First_Uncollapsed_Folder2(tr) -- NO CHUNK IS REQUIRED, ONLY FOR TRACKS 100% VISIBLE IN THE MIXER AS when mcpView is true CSurf_TrackToID() returns -1 for both hidden completely and hidden in a collapsed folder in the Mixer
local parent = r.GetParentTrack(tr)
local tr_vis = r.IsTrackVisible(tr, true)
	if parent and tr_vis -- mixer true
	and r.CSurf_TrackToID(tr, true) == -1 -- mcpView true // the function doesn't return index if track is in a collapsed folder
	then return Get_Parent_Of_MCP_First_Uncollapsed_Folder(parent) -- recursive
	elseif parent and tr_vis and r.IsTrackVisible(parent, true) -- mixer true
	then return parent
	end
end


function Get_All_Children(...) -- arg is either track idx or track pointer

local arg = {...}
local tr_idx, tr
	if #arg > 0 then
		if tonumber(arg[1]) then tr_idx = arg[1]
		elseif r.ValidatePtr(arg[1], 'MediaTrack*') then tr = arg[1]
		else return
		end
	else return
	end

	if not tr then tr = r.CSurf_TrackFromID(tr_idx, false) end -- mcpView false
	if not tr_idx then r.CSurf_TrackToID(tr_idx, false)-1 end -- mcpView false

local depth = r.GetTrackDepth(tr)
local child_t = {}
	for i = tr_idx, r.CountTracks(0) do
	local tr = r.GetTrack(0,i)
	local tr_depth = r.GetTrackDepth(tr)
		if tr_depth > depth then
		child_t[#child_t+1] = tr
		elseif tr_depth <= depth then break
		end
	end

return child_t

end


function Is_TCP_MCP_Collapsed(tr_chunk)
-- TCP collapse state is direct value because there're 3: 0=not collapsed, 1=collapsed medium, 2=collapsed small
-- MCP collapse state is either true or false
	return tr_chunk:match('BUSCOMP (%d)'), tr_chunk:match('BUSCOMP %d (%d)') == '1'
-- to only return true or false for TCP as well:
-- return (match:tr_chunk('BUSCOMP (%d)') == '1' or tr_chunk:match('BUSCOMP (%d)') == '2'), tr_chunk:match('BUSCOMP %d (%d)') == '1'
end



function Dismantle_FolderOrSubfolder(parent_tr) -- nested folders are supported

	if r.GetMediaTrackInfo_Value(parent_tr, 'I_FOLDERDEPTH') ~= 1 then return end -- the track isn't folder parent

local first_child_idx = r.CSurf_TrackToID(parent_tr, false) -- mcpView false // returns 1-based index which corresponds to 0-based index of the 1st child
local child_t = {}
--[[VERSION 1 WORKS
	for i = first_child_idx, r.CountTracks(0)-1 do -- collect children to dismantle in reverse since it's easier
	local tr = r.GetTrack(0,i)
	local depth = r.GetTrackDepth(tr)
	local child_state = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')
		if depth > 0 and (child_state == 1 or child_state < 0 and not r.GetParentTrack(parent_tr)) then -- parent of a children subfoler or the last track in the folder or a subfolder to prevent leaving the last track in the folder marked as such but only if the entire folder is being dismantled which is conditioned with not r.GetParentTrack(parent_tr), because otherwise dismantling a subfolder will bring track outside of the folder into it
		child_t[#child_t+1] = tr
		elseif depth == 0 then break -- first found track outside of the folder // OR not r.GetParentTrack(tr)
		end
	end
--]]
--[-[VERSION 2 WORKS
	for i = first_child_idx, r.CountTracks(0)-1 do -- collect children to dismantle in reverse since it's easier
	local tr = r.GetTrack(0,i)
		if r.GetTrackDepth(tr) > 0 and (r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH') > 0 or not r.GetParentTrack(parent_tr)) then -- if not the entire folder is being dismantled which is conditioned with not r.GetParentTrack(parent_tr), exclude the last track in the folder because otherwise dismantling only the very last subfolder will bring track outside of the folder into it
		child_t[#child_t+1] = tr
		else break
		end
	end
--]]
	for i = #child_t, 1, -1 do
	r.SetMediaTrackInfo_Value(child_t[i], 'I_FOLDERDEPTH', 0)
	end
r.SetMediaTrackInfo_Value(parent_tr, 'I_FOLDERDEPTH', 0) -- parent must be dismantled as well but if it's dismantled first the depth of the 1st child track becomes 0, it won't satisfy the condition r.GetTrackDepth(tr) > 0 and the children loop won't be able to continue since it's supposed to break at first found track with 0 depth meaning the 1st found track outside of the folder
end



function Track_Is_Vis_And_Child_Of_Collapsed_MCP_Folder(tr)
return r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER') == 1 -- track isn't hidden in the Mixer // same as r.IsTrackVisible(tr, true) -- mixer true
and r.CSurf_TrackToID(tr, true) == -1 -- mcpView true // when the track is inside a collaped MCP folder the function doesn't return its index // r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER') doesn't work this way so not suitable
end


function Track_Is_Vis_And_Child_Of_Collapsed_TCP_Folder(tr)
return r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') == 1 -- track isn't hidden in the Mixer // same as r.IsTrackVisible(tr, true) -- mixer true
and r.GetParentTrack(tr) and r.GetMediaTrackInfo_Value(r.GetParentTrack(tr), 'I_FOLDERCOMPACT') == 2 -- mcpView true // when the track is inside a collaped MCP folder the function doesn't return its index // r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER') doesn't work this way so not suitable
end



function Track_Is_Child_Of_Collapsed_Folder1(tr, wantMixer) -- wantMixer is boolean // visibility is not evaluated
	local function get_first_collapsed_tcp_fldr(tr) -- for Arrange
	local parent = r.GetParentTrack(tr)
		if parent and r.GetMediaTrackInfo_Value(parent, 'I_FOLDERCOMPACT') == 2 -- tiny children
		then return true
		elseif parent then
		return get_first_collapsed_tcp_fldr(parent) -- recursive
		end
	end
return wantMixer and r.CSurf_TrackToID(tr, true) == -1 -- mcpView true // when the track is inside a collapsed MCP folder the function doesn't return its index // r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER') doesn't work this way so not suitable
or not wantMixer and get_first_collapsed_tcp_fldr(tr) -- in Arrange
end


function Track_Is_Vis_And_Child_Of_Collapsed_Folder2(tr, wantMixer) -- wantMixer is boolean // visibility IS evaluated

	local function get_first_collapsed_tcp_fldr(tr) -- for Arrange
	--	if r.IsTrackVisible(tr, false) then -- mixer false // not needed here, evaluated in the main routine
		local parent = r.GetParentTrack(tr)
			if parent and r.GetMediaTrackInfo_Value(parent, 'I_FOLDERCOMPACT') == 2 -- tiny children
			then return true
			elseif parent then
			return get_first_collapsed_tcp_fldr(parent) -- recursive
			end
	--	end
	end

local parm = wantMixer and 'B_SHOWINMIXER' or 'B_SHOWINTCP'
return r.GetMediaTrackInfo_Value(tr, parm) == 1 -- track isn't hidden in Arrange/Mixer // same as r.IsTrackVisible(tr, false/true) -- mixer false/true
and (wantMixer and r.CSurf_TrackToID(tr, true) == -1 -- mcpView true // when the track is inside a collaped MCP folder the function doesn't return its index // r.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER') doesn't work this way so not suitable
not wantMixer and get_first_collapsed_tcp_fldr(tr)) -- in Arrange

end



--================================ F O L D E R S  E N D =================================


--================================ E N V E L O P E S ==================================


function Get_Env_GUID(env)
local retval, env_chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
return env_chunk:match('EGUID (.-)\n')
end


function Is_Env_Visible(env)
	if r.CountEnvelopePoints(env) > 0 then -- validation of fx envelopes
	local retval, env_chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
	return env_chunk:match('\nVIS 1 ')
	end
end


function Is_Env_Bypassed(env)
	if r.CountEnvelopePoints(env) > 0 then -- validation of fx envelopes
	local retval, env_chunk = r.GetEnvelopeStateChunk(env, '', false) -- isundo false
	return env_chunk:match('\nACT 0 ')
	end
end


function Re_Store_Env_Selection(...)
-- after setting a chunk and reordering envelopes, originally selected envelope pointer ends up belonging to another envelope, so in order to keep the original envelope selected its new pointer must be retrieved because now it will differ from the originally selected envelope pointer
-- 1st function run is without arguments, returns 3 values
-- 2nd function run is with all 3 arguments, re-selects originally selected env
local tr, fx_idx, parm_idx = table.unpack(...)
	if not tr then -- store
	local sel_env = r.GetSelectedTrackEnvelope(0)
	return r.Envelope_GetParentTrack(sel_env) -- tr, fx_idx, parm_idx
	else -- restore
	local env = r.GetFXEnvelope(tr, fx_idx, parm_idx, false)
	r.SetCursorContext(2, env)
	end
end


function Manipulate_Envelope_With_Actions(env, act_t) -- act_t an indexed table with action IDs
-- selects target env, which is the only way to affect it with actions
local sel_env = r.GetSelectedEnvelope(0) -- store currently selected env // gets both track and take envs
-- sel_env = r.GetSelectedTrackEnvelope(0) -- only track envs
r.SetCursorContext(2, env) -- select target env
	if act_t then
		for _, act_id in ipairs(act_id) do -- manipulale
		r.Main_OnCommand(act_id, 0)
		end
	end
r.SetCursorContext(2, sel_env) -- restore original env selection
end



function Count_FX_Envelopes()

local env_cnt = 0
-- Regular tracks
	for i = -1, r.CSurf_NumTracks(true)-1 do -- start from -1 to target the Master track
	local tr = r.GetTrack(0,i) or r.GetMasterTrack(0)
--	env_cnt = env_cnt + r.CountTrackEnvelopes(tr)
		for j = 0, r.TrackFX_GetCount(tr)-1 do
			for k = 0, r.TrackFX_GetNumParams(tr, j)-1 do
			local env = r.GetFXEnvelope(tr, j, k, false) -- create is false; for env to be valid it suffices that param mod be enabled
			env_cnt = env and r.ValidatePtr(env, 'TrackEnvelope*') and env_cnt + 1 or env_cnt -- When param modulation is enabled, GetFXEnvelope() returns parameter envelope even if there's none, if it's a ghost envelope ValidatePtr() will return false
			end
		end
	end
--[[ Master track // moved to the track loop above
local tr = r.GetMasterTrack(0)
--env_cnt = env_cnt + r.CountTrackEnvelopes(tr) -- includes Tempo Map env
	for i = 0, r.TrackFX_GetCount(tr)-1 do
		for k = 0, r.TrackFX_GetNumParams(tr, j)-1 do
		env_cnt = r.GetFXEnvelope(tr, j, k, false) -- create is false; for env to be valid it suffices that param mod be enabled
		and env_cnt + 1 or env_cnt
		end
	end
	]]
-- Items
	for i = 0, r.CountMediaItems(0)-1 do
	local item = r.GetMediaItem(0,i)
		for i = 0, r.CountTakes(item)-1 do
		local take = r.GetTake(item,i)
		env_cnt = env_cnt + r.CountTakeEnvelopes(take)
			for j = 0, r.TakeFX_GetCount(take)-1 do
				for k = 0, r.TakeFX_GetNumParams(take, j)-1 do
				local env = r.TakeFX_GetEnvelope(tr, j, k, false) -- create is false
				env_cnt = r.CountEnvelopePoints(env) > 0 and env_cnt + 1 or env_cnt -- When param modulation is enabled, TakeFX_GetEnvelope() returns parameter envelope even if there's none, if it's a ghost envelope there're no points
				end
			end
		end
	end
return env_cnt

end


local function Get_Env_Point_At_Time(env, item, take) -- autom items are ignored
-- the mouse cursor must be to the right of the point vertical axis, not necessarily near the point
r.PreventUIRefresh(1)
local x, y = r.GetMousePosition()
local cur_pos = r.GetCursorPosition()
r.Main_OnCommand(40514, 0) -- View: Move edit cursor to mouse cursor (no snapping)
local pt_time = r.GetCursorPosition()
	if item then -- convert cursor project time to time within item
	local item_pos = r.GetMediaItemInfo_Value(r.GetMediaItemTake_Item(take), 'D_POSITION')
	local offset = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')
	local playrate = r.GetMediaItemTakeInfo_Value(take, 'D_PLAYRATE') -- affects take start offset and take env point pos
	pt_time = (pt_time - item_pos + offset)*playrate
	end
local pt_idx = r.GetEnvelopePointByTimeEx(env, -1, pt_time) -- autoitem_idx -1 for the envelope points
local retval, time, value, shape, tens, is_sel = r.GetEnvelopePointEx(env, -1, pt_idx) -- autoitem_idx -1 for the envelope points
r.SetEditCurPos(cur_pos, false, false) -- moveview, seekplay false // restore orig edit cursor pos
r.PreventUIRefresh(-1)
return pt_idx, value, is_sel
end


local function Count_Sel_Points(env, pt_idx) -- and evaluate is specific point is selected
local sel_pt_cnt, is_pt_idx_sel = 0
local pt_cnt = r.CountEnvelopePointsEx(env, -1) -- autoitem_idx -1 for the envelope points
	for idx = 0, pt_cnt-1 do
	local retval, time, value, shape, tens, is_sel = r.GetEnvelopePointEx(env, -1, idx) -- autoitem_idx -1 for the envelope points
	sel_pt_cnt = is_sel and sel_pt_cnt+1 or sel_pt_cnt
	is_pt_idx_sel = idx == pt_idx and is_sel or is_pt_idx_sel
	end
return pt_cnt, sel_pt_cnt, is_pt_idx_sel -- cannot iterate exclusively over selected points so the actual point count is necessary to then filter points by their selection state
end


function Get_FX_Env_Src_Parameter(env) -- get fx parameter the envelope belongs to
local tr = r.GetEnvelopeInfo_Value(env, 'P_TRACK') -- if take env is selected returns 0.0, otherwise pointer
local take = r.GetEnvelopeInfo_Value(env, 'P_TAKE') -- if track env is selected returns 0.0, otherwise pointer
local tr, take = tr ~= 0 and tr, take ~= 0 and take -- validate
local retval, env_name = r.GetEnvelopeName(env)
-- capture fx name displayed in the fx chain, fx env name format is 'parm name / displayed fx name'
local fx_name = env_name:match('.+ / (.+)') -- clean name, without the plugin type prefix
local cur_val, minval, maxval, step
local CountFX, GetFXName, GetNumParams, GetFXEnvelope, GetFXParam, GetParamStepSizes = table.unpack(tr and {r.TrackFX_GetCount, r.TrackFX_GetFXName, r.TrackFX_GetNumParams, r.GetFXEnvelope, r.TrackFX_GetParam, r.TrackFX_GetParameterStepSizes} or take and {r.TakeFX_GetCount, r.TakeFX_GetFXName, r.TakeFX_GetNumParams, r.TakeFX_GetEnvelope, r.TakeFX_GetParam, r.TakeFX_GetParameterStepSizes})
local obj = take or tr
	for fx_idx = 0, CountFX(obj)-1 do
	local retval, name = GetFXName(obj, fx_idx)
		if name:match(': (.+) %(') == fx_name or name == fx_name then -- either default or custom plugin name
			for parm_idx = 0, GetNumParams(obj, fx_idx)-1 do
			local parm_env = GetFXEnvelope(obj, fx_idx, parm_idx, false) -- create false
				if parm_env == env then
				local cur_val, minval, maxval = GetFXParam(obj, fx_idx, parm_idx)
				local retval, step, smallstep, largestep, istoggle = GetParamStepSizes(obj, fx_idx, parm_idx) -- if no step retval is false
				return cur_val, minval, maxval, step ~= 0 and step
				end
			end
		end
	end

end


function Get_Take_Pitch_Env_Snap()
-- Preferences -> Editing behavior -> Envelope display -> Default per take pitch envelope ... snap:
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local val = cont:match('pitchenvrange=(.-)\n')
local val = #val > 0 and tonumber(val)
local snap
-- Thanks to Mespotine
-- https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
-- 'pitchenvrange' value is the sum of the range integer and then snap integer
-- snap integer is an 8 bit value and is changed by 8 bit increments
-- statring from 0, so if the value is 328 the settings are
-- 72 (range) + 256 (1 st snap)
-- the range cannot be equal to or greater than 256,
-- because when added to the snap value it will cause clash with the next snap value
	if val > 256 and val < 512 then snap = 1
	elseif val > 512 and val < 768 then snap = 0.5
	elseif val > 768 and val < 1024 then snap = 0.25
	elseif val > 1024 and val < 1280 then snap = 0.1
	elseif val > 1280 and val < 1537 then snap = 0.05
	elseif val > 1537 or val < 256 then snap = 0.01 end
-- if snap is OFF (< 256) natively pitch can be set
-- by as little as 1/1000st which isn't practical
-- so in this case the unit is 0.01st i.e. 1 cent
return snap
end


function Get_Vol_Env_Range()
-- Preferences -> Editing behavior -> Envelope display -> Volume envelope range
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local val = cont:match('volenvrange=(.-)\n')
local val = tonumber(val)
-- Thanks to Mespotine
-- https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
	if val then
	local bit1, bit2 = val&1, val&4
--Msg(bit1) Msg(bit2)
	-- the lower limit is -inf so it doesn't have to be returned
	-- the lower limit is set within the routine to another value
	return bit1 == 1 and bit2 == 0 and 0
	or bit1 == 0 and bit2 == 0 and 6
	or bit1 == 0 and bit2 == 4 and 12
	or bit1 == 1 and bit2 == 4 and 24
	end
end



function Is_FX_Envelope(env) -- 1st return val being nil means not an FX envelope
-- to verify further the next function Is_Track_Or_Take_Env() can be used
local tr, fx_idx, parm_idx = r.Envelope_GetParentTrack(env)
	if fx_idx > -1 then return tr, fx_idx, parm_idx end
end


function Is_Track_Or_Take_Env(env)
--[[ special case
local env = r.GetCursorContext() == 2
local env = env and r.GetSelectedEnvelope(0)
]]
local env = not env and r.GetSelectedEnvelope(0) or env -- arg either is not or is provided
local is_tr_env = env and r.GetEnvelopeInfo_Value(env, 'P_TRACK') -- if take env is selected returns 0.0, otherwise pointer
local is_take_env = env and r.GetEnvelopeInfo_Value(env, 'P_TAKE') -- if track env is selected returns 0.0, otherwise pointer
return is_tr_env ~= 0 and is_tr_env,  is_take_env ~= 0 and is_take_env
-- OR
-- return env and r.GetEnvelopeInfo_Value(env, 'P_TRACK') ~= 0 and env,
-- env and r.GetEnvelopeInfo_Value(env, 'P_TAKE') ~= 0 and env
end
-- OR
-- env, fx_idx, parm_idx = r.Envelope_GetParentTake(env)
-- env, fx_idx, parm_idx = r.Envelope_GetParentTrack(env)


function Envelopes_Locked()
return r.GetToggleCommandStateEx(0, 40585) == 1, -- Locking: Toggle track envelope locking mode
r.GetToggleCommandStateEx(0, 41851) == 1 -- Locking: Toggle take envelope locking mode
end
tr, take = Envelopes_Locked() -- booleans


--============================ E N V E L O P E S   E N D ==================================


--============================ A U T O M A T I O N  I T E M S ================================

function UnTrim_AutomItem_LeftEdge(env, autoitem_idx, val) -- rather mimics trim by shifting contents, changing length and position
-- val in sec, positive val trim [->, negative val untrim <-[
	if not env or not autoitem_idx or not val then return end
local props = {['D_POSITION'] = 0, ['D_LENGTH'] = 0, ['D_STARTOFFS'] = 0, ['D_PLAYRATE'] = 0}
	for k in pairs(props) do
	props[k] = r.GetSetAutomationItemInfo(env, autoitem_idx, k, -1, false)
	end
	for k, v in pairs(props) do
		if props.D_LENGTH <= val then return end -- don't apply if AI is too short, otherwise it will keep changing position
		if k ~= 'D_PLAYRATE' then -- playrate is only required for startoffs calculation and shouldn't be set
		local val = k == 'D_LENGTH' and v-val
		or k == 'D_STARTOFFS' and v+val*props.D_PLAYRATE -- minus val*playrate is shift rightwards (forward), plus is shift leftwards (backwards)
		or v+val -- D_POSITION
		r.GetSetAutomationItemInfo(env, autoitem_idx, k, val, true)
		end
	end
--[[ OR
local pos = r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_POSITION', -1, false) -- val -1, is_set false
local len = r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_LENGTH', -1, false)
local startoffs = r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_STARTOFFS', -1, false)
local playrate = r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_PLAYRATE', -1, false)
r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_STARTOFFS', startoffs+val*playrate, true) -- is_set true
r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_LENGTH', len-val, true)
r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_POSITION', pos+val, true)
]]
end


function Trim_AutomItem_LeftEdge(env, autoitem_idx, pos) -- genuine trim but no way to untrim // make sure no other autom items are selected
r.PreventUIRefresh(1)

-- Split
local cur_pos = r.GetCursorPosition() -- store current edit cur pos
r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_UISEL', 1, true) -- value 1 (select), ise_set true
r.SetEditCurPos(pos, false, false) -- restore edit cur pos // moveview & seekplay false
r.Main_OnCommand(42087,0) -- Envelope: Split automation items
r.GetSetAutomationItemInfo(env, autoitem_idx+1, 'D_UISEL', 0, true) -- unselect to prevent deletion of the righthand part of the split // autoitem_idx+1 is righthand part of the split being a new autom item, value 0 (unselect), ise_set true
r.SetEditCurPos(cur_pos, false, false) -- restore edit cur pos // moveview & seekplay false
--r.SetMediaItemSelected(item, true) -- re-select media item

-- Delete the lefthand part of the split
r.Main_OnCommand(42086,0) -- Envelope: Delete automation items

r.PreventUIRefresh(-1)
end


-- STORE, UNSELECT AND RESTORE SELECTED ITEMS (incl. autom items)
function Delete_AutomItem(item, env, autoitem_idx, length, limit) -- length and limit are optional
	if length and limit and length < limit  -- minimum length allowed is 0.1 sec when set programmatically or via input
	or not length or not limit
	then
	-- https://forum.cockos.com/showpost.php?p=2239082&postcount=9 thanks to X-Raym for the tip
	r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_UISEL', 1, true) -- value 1 (select), ise_set true
	r.Main_OnCommand(42086,0) -- Envelope: Delete automation items
	r.SetMediaItemSelected(item, true) -- re-select media item
	end
end


function Split_AutomItem(item, item_start_init, env, autoitem_idx)
r.PreventUIRefresh(1)
local cur_pos = r.GetCursorPosition() -- store current edit cur pos
r.GetSetAutomationItemInfo(env, autoitem_idx, 'D_UISEL', 1, true) -- value 1 (select), ise_set true
r.SetEditCurPos(item_start_init, false, false) -- restore edit cur pos // moveview & seekplay false
r.Main_OnCommand(42087,0) -- Envelope: Split automation items
r.GetSetAutomationItemInfo(env, autoitem_idx+1, 'D_UISEL', 0, true) -- unselect to prevent deletion when media item length is being changed // autoitem_idx+1 is righthand part of the split being a new autom item, value 0 (unselect), ise_set true
r.SetEditCurPos(cur_pos, false, false) -- restore edit cur pos // moveview & seekplay false
r.SetMediaItemSelected(item, true) -- re-select media item
r.PreventUIRefresh(-1)
end


local Re_Store_Sel_AIs(sel_AI)

local is_AI_sel
	if not sel_AI then
	local sel_AI = {}
		for tr_idx = 0, r.CountTracks(0)-1 do -- check if there're selected AI and save them because they'll have to be deselected below in order to not be affected by duplication of media items directly above them
		local tr = r.GetTrack(0,tr_idx)
			for env_idx = 0, r.CountTrackEnvelopes(tr)-1 do
			local env = r.GetTrackEnvelope(tr, env_idx)
				for AI_idx = 0, r.CountAutomationItems(env)-1 do
					if r.GetSetAutomationItemInfo(env, AI_idx, 'D_UISEL', -1, false) > 0 -- selected; is_set false
					then
					sel_AI[env] = not sel_AI[env] and {idx = {}, pos = {}} or sel_AI[env] -- only create table if there're selected AIs
					local len = #sel_AI[env].idx -- for brevity
					sel_AI[env].idx[len+1] = AI_idx -- saving indices as well for simplicity of code in AI de-selecton routine if needed
						if r.GetToggleCommandStateEx(0, 40070) == 1 -- Options: Move envelope points with media items and razor edits
						then -- if the option is ON and context is 'Items' and the media items have AIs attached to them, the AIs will be duplicated along with media items so their total count will change and their indices won't be reliable to restore their selection at the end of the script which is especially true with leftward duplication because count starts from the left; position seems the only most reliable piece of data in this case which is still not failproof because AI start might get trimmed with another overlapping AI during duplication
						local len = #sel_AI[env].pos -- for brevity
						sel_AI[env].pos[len+1] = r.GetSetAutomationItemInfo(env, AI_idx, 'D_POSITION', -1, false) -- is_set false
						end
					is_AI_sel = 1 -- if at least 1 AI is selected
					end
				end
			end
		end
	return is_AI_sel, sel_AI
	else -- re-select originally selected AIs if 'Items' context because in this case AIs are deselected to prevent possible glitches; or select all last duplicate instances if 'Automation items' context, otherwise only the very last ends up being selected
		for env in pairs(sel_AI) do
			if ctx == 'Items' and r.GetToggleCommandStateEx(0, 40070) == 1 -- use position data to restore selection because that's what was saved in the loop at the beginning of the script under the GetToggleCommandStateEx condition
			then
				for _, AI_pos in ipairs(sel_AI[env].pos) do
					for AI_idx = 0, r.CountAutomationItems(env)-1 do
					local pos = r.GetSetAutomationItemInfo(env, AI_idx, 'D_POSITION', -1, false) -- is_set false
						if pos == AI_pos then r.GetSetAutomationItemInfo(env, AI_idx, 'D_UISEL', 1, true) -- is_set true
						break end -- to jump to the next AI_data value
					end
				end
			else -- context 'Automation items', if context is 'Tracks' the table is empty // LESS RELEVANT FOR GENERAL USE
				for _, AI_idx in ipairs(sel_AI[env].idx) do
				r.GetSetAutomationItemInfo(env, AI_idx, 'D_UISEL', 1, true) -- is_set true
				end
			end
		end
	end

end



function Deselect_Selected_AIs(sel_AI) -- arg is a table from prev function
	for env in pairs(sel_AI) do
		for _, AI_idx in ipairs(sel_AI[env].idx) do
		r.GetSetAutomationItemInfo(env, AI_idx, 'D_UISEL', 0, true) -- is_set true
		end
	end
end


function Get_Sel_AI_St_And_End(t) -- t from previous function
-- get the start of the first and the end of the last amongst selected AIs
local first_start = math.huge
local last_end = math.huge*-1
	for env in pairs(t) do
		for _, AI_idx in ipairs(t[env].idx) do
			if r.GetSetAutomationItemInfo(env, AI_idx, 'D_UISEL', -1, false) > 0 then -- selected; is_set false
			local pos = r.GetSetAutomationItemInfo(env, AI_idx, 'D_POSITION', -1, false) -- is_set false
			local fin = pos + r.GetSetAutomationItemInfo(env, AI_idx, 'D_LENGTH', -1, false) -- is_set false
			first_start = pos < first_start and pos or first_start
			last_end = fin > last_end and fin or last_end
			end
		end
	end
return first_start, last_end
end



function Get_Sel_Items_St_And_End()
local first_start = math.huge -- when note or repeats value is negative (leftward duplication) we search for the earliest pos value
local last_end = math.huge*-1 -- when duplicating rightwards we search for the latest end value
	for i = 0, r.CountSelectedMediaItems(0)-1 do
	local item = r.GetSelectedMediaItem(0,i)
	local item_pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
	first_start = item_pos < first_start and item_pos or first_start -- get the earliest pos value amongst selected items because when copying/pasting multiple items which maintain their relative positions that's the defining value
	local fin = item_pos + r.GetMediaItemInfo_Value(item, 'D_LENGTH')
	last_end = fin > last_end and fin or last_end -- get the latest end value amongst selected items to place cursor at to emulate duplicate action
	end
return first_start, last_end
end


function RESOLVE_AI_OVERLAPS()

local sel_AI_t = {}

	for i = 0, r.CountTracks(0)-1 do -- store selected AIs and deselect
	local tr = r.GetTrack(0,i)
		for i = 0, r.CountTrackEnvelopes(tr)-1 do
		local env = r.GetTrackEnvelope(tr, i)
			for i = 0, r.CountAutomationItems(env)-1 do -- backwards because some AIs may need to be deleted
				if r.GetSetAutomationItemInfo(env, i, 'D_UISEL', 0, false) ~= 0 then -- is_set false
				sel_AI_t[env] = not sel_AI_t[env] and {} or sel_AI_t[env]
				sel_AI_t[env][1] = r.CountAutomationItems(env) -- store count to collate later to allow deciding whether to restore
				local len = #sel_AI_t[env] -- for brevity
				sel_AI_t[env][len+1] = i
				r.GetSetAutomationItemInfo(env, i, 'D_UISEL', 0, true) -- is_set true // deselect
				end
			end
		end
	end

local cur_pos = r.GetCursorPosition()

local func = r.GetSetAutomationItemInfo

	local function Find_First_Overlap(env, AI_idx, pos_curr) -- addresses cases when one AI overlaps several other AIs and have index which is not immediately precedes current AI index
		for i = AI_idx-1, 0, -1 do -- start from previous
		local fin_prev = func(env, i, 'D_POSITION', 0, false) + func(env, i, 'D_LENGTH', 0, false) -- is_set false
		local diff = fin_prev - pos_curr
			if diff > 0 then return diff, fin_prev end
		end
	end


	local function Trim_AI_By_Splitting(env, AI_idx, fin_prev)
	func(env, AI_idx, 'D_UISEL', 1, true) -- is_set true // select AI
	r.SetEditCurPos(fin_prev, false, false) -- oveview, seekplay false // set cur to the end of prev AI which overlaps
	r.Main_OnCommand(42087, 0) -- Envelope: Split automation items
	func(env, AI_idx+1, 'D_UISEL', 0, true)-- is_set true // deselect right part of the split
	func(env, AI_idx, 'D_UISEL', 1, true) -- is_set true // select left part of the split
	r.Main_OnCommand(42086, 0) -- Envelope: Delete automation items // delete left part
	end

	for i = 0, r.CountTracks(0)-1 do
	local tr = r.GetTrack(0,i)
		for i = 0, r.CountTrackEnvelopes(tr)-1 do
		local env = r.GetTrackEnvelope(tr, i)

local ret, chunk = r.GetEnvelopeStateChunk(env, '', false) -- MONITORING ONLY
--Msg(chunk)

			for i = r.CountAutomationItems(env)-1, 0, -1 do -- backwards because some AIs may need to be deleted
			local func = r.GetSetAutomationItemInfo
			local pos_curr = func(env, i, 'D_POSITION', 0, false) -- is_set false
			local len_curr = func(env, i, 'D_LENGTH', 0, false) -- is_set false
			local startoffs_curr = func(env, i, 'D_STARTOFFS', 0, false) -- is_set false
			local playrate = func(env, i, 'D_PLAYRATE', 0, false) -- is_set false
			local fin_curr = pos_curr + len_curr
			local diff, fin_prev = Find_First_Overlap(env, i, pos_curr) -- addresses cases when one AI overlaps several which don't overlap each other
				if diff and diff > 0 then -- AIs overlap
					if len_curr < 0.02 -- delete because it cannot be shortened or split, AI length cannot be set to less than 100 ms via API (when setting length shorter that 100 ms to a an already shorter AI it ends up being exactly 100 ms) and it cannot be split with action if the edit cursor is at less than 10 ms from either of AI edges // must be deleted with action because setting length to 0 only shortens AI down to 100 ms // requires preemptive deselection of all AIs
					or fin_prev >= fin_curr -- prev AI fully overlaps current one, delete current
					or fin_curr - fin_prev < 0.01 -- overlaps almost completely shy of 10 ms, delete because there'll be no way to shorten the AI or to split and keep that extra non-overlapped length of under 10 ms // same as len_curr - diff < 0.01
					then
					func(env, i, 'D_UISEL', 1, true) -- is_set true // select
					r.Main_OnCommand(42086, 0) -- Envelope: Delete automation items
					elseif len_curr - diff >= 0.1 then -- can be shortened via API since certainly won't get shorter than 100 ms
					func(env, i, 'D_POSITION', fin_prev, true) -- is_set true // shift rightwards
					func(env, i, 'D_LENGTH', len_curr-diff, true) -- is_set true // shorten
					func(env, i, 'D_STARTOFFS', startoffs_curr+diff*playrate, true) -- is_set true // shift contents leftwards so that it looks as if the AI start (pos) was cut off
					elseif diff >= 0.01 and fin_curr-fin_prev >= 0.01 -- // same as len_curr - diff >= 0.01
					then -- can't be shortened via API hence must be split provided the edit cursor can be placed farther than or at 0.01 from either edge of the AI; select, split with action, delete left hand part // action splits all selected AI crossed by the edit cursor so requires preemptive deselection of all, after split always selects right
					Trim_AI_By_Splitting(env, i, fin_prev)
					else -- the overlapped part is shorter than 10 ms which prevents splitting, hence lengthen the AI, shift left increasing the overlapped part to or to over 10 ms so it could be split and moving contents to original pos where they should end up after splitting
					local ext = 0.1-len_curr -- minimum length to which an AI shorter than 100 ms can be set is 100 ms
					func(env, i, 'D_LENGTH', len_curr+ext, true) -- is_set true // lengthen up to 100 ms
					func(env, i, 'D_POSITION', pos_curr-ext, true) -- is_set true // offset by shifting left by the same amount
					func(env, i, 'D_STARTOFFS', startoffs_curr-ext*playrate, true) -- is_set true // move contents rightwards by the same amount to restore their orig pos after split
					Trim_AI_By_Splitting(env, i, fin_prev)
					end
				end

			end -- AI loop end
		end -- env loop end
	end -- track loop end


r.SetEditCurPos(cur_pos, false, false) -- oveview, seekplay false // restore cur pos in case changed

	-- Restore AI selection
	for env in pairs(sel_AI_t) do
	local AI_cnt = r.CountAutomationItems(env)
		if AI_cnt == sel_AI_t[env][1] then -- if count didn't change in the interim
			for k, AI_idx in ipairs(sel_AI_t[env]) do -- restore AI selection
			local re_sel = k ~= 1 and r.GetSetAutomationItemInfo(env, AI_idx, 'D_UISEL', 1, true) -- is_set true // excluding 1st field because it holds total count
			end
		end
	end

end -- RESOLVE_AI_OVERLAPS() end


function Get_AI_At_Mouse_Cursor(env) -- returns AI index
local cur_pos = r.GetCursorPosition()
local x, y = r.GetMousePosition()
r.Main_OnCommand(40514, 0) -- View: Move edit cursor to mouse cursor (no snapping)
local pos_at_mouse = r.GetCursorPosition()
local AI
	for ai_idx = 0, r.CountAutomationItems(env)-1 do
	local start = r.GetSetAutomationItemInfo(env, ai_idx, 'D_POSITION', 0, false) -- is_set false, value 0
	local fin = start + r.GetSetAutomationItemInfo(env, ai_idx, 'D_LENGTH', 0, false) -- is_set false, value 0
		if start <= pos_at_mouse and fin >= pos_at_mouse then AI = ai_idx break end
	end
r.SetEditCurPos(cur_pos, false, false) -- moveview, seekplay false // restore orig edit cursor pos
return AI
end


--=========================== A U T O M A T I O N  I T E M S  E N D ==========================


--================================= C H U N K ========================================

local function GetObjChunk1(retval, obj, obj_type) -- retval stems from r.GetFocusedFX(), value 0 is only considered at the pasting stage because in the copying stage it's error caught before the function
-- https://forum.cockos.com/showthread.php?t=193686
-- https://raw.githubusercontent.com/EUGEN27771/ReaScripts_Test/master/Functions/FXChain
-- https://github.com/EUGEN27771/ReaScripts/blob/master/Various/FXRack/Modules/FXChain.lua
		if not obj then return end
		if retval == 0 then retval = tonumber(obj_type) end -- for pasting stage when fx chains/floating windows are closed or not in focus
  -- Try standard function -----
	local t = retval == 1 and {r.GetTrackStateChunk(obj, '', false)} or {r.GetItemStateChunk(obj, '', false)} -- isundo = false // https://forum.cockos.com/showthread.php?t=181000#9
	local ret, obj_chunk = table.unpack(t)
		if ret and obj_chunk and #obj_chunk >= 4194303 and not r.APIExists('SNM_CreateFastString') then return 'err_mess'
		elseif ret and obj_chunk and #obj_chunk < 4194303 then return ret, obj_chunk -- 4194303 bytes (4.194303 Mb) = (4096 kb * 1024 bytes) - 1 byte // since build 4.20 http://reaper.fm/download-old.php?ver=4x
		end
-- If chunk_size >= max_size, use wdl fast string --
	local fast_str = r.SNM_CreateFastString('')
		if r.SNM_GetSetObjectState(obj, fast_str, false, false) -- setnewvalue and wantminimalstate = false
		then obj_chunk = r.SNM_GetFastString(fast_str)
		end
	r.SNM_DeleteFastString(fast_str)
		if obj_chunk then return true, obj_chunk end
end


local function GetObjChunk2(obj)
-- https://forum.cockos.com/showthread.php?t=193686
-- https://raw.githubusercontent.com/EUGEN27771/ReaScripts_Test/master/Functions/FXChain
-- https://github.com/EUGEN27771/ReaScripts/blob/master/Various/FXRack/Modules/FXChain.lua
		if not obj then return end
local tr = r.ValidatePtr(obj, 'MediaTrack*')
local item = r.ValidatePtr(obj, 'MediaItem*')
local env = r.ValidatePtr(obj, 'TrackEnvelope*') -- works for take envelope as well
  -- Try standard function -----
	local t = tr and {r.GetTrackStateChunk(obj, '', false)} or item and {r.GetItemStateChunk(obj, '', false)} or env and {r.GetEnvelopeStateChunk(obj, '', false)} -- isundo = false // https://forum.cockos.com/showthread.php?t=181000#9
	local ret, obj_chunk = table.unpack(t)
	-- OR
	-- local ret, obj_chunk = table.unpack(tr and {r.GetTrackStateChunk(obj, '', false)} or item and {r.GetItemStateChunk(obj, '', false)} or env and {r.GetEnvelopeStateChunk(obj, '', false)} or {x,x}) -- isundo = false // https://forum.cockos.com/showthread.php?t=181000#9
		if ret and obj_chunk and #obj_chunk >= 4194303 and not r.APIExists('SNM_CreateFastString') then return 'err_mess'
		elseif ret and obj_chunk and #obj_chunk < 4194303 then return ret, obj_chunk -- 4194303 bytes (4.194303 Mb) = (4096 kb * 1024 bytes) - 1 byte // since build 4.20 http://reaper.fm/download-old.php?ver=4x
		end
-- If chunk_size >= max_size, use wdl fast string --
	local fast_str = r.SNM_CreateFastString('')
		if r.SNM_GetSetObjectState(obj, fast_str, false, false) -- setnewvalue and wantminimalstate = false
		then obj_chunk = r.SNM_GetFastString(fast_str)
		end
	r.SNM_DeleteFastString(fast_str)
		if obj_chunk then return true, obj_chunk end
end


function Err_mess() -- if chunk size limit is exceeded and SWS extension isn't installed

	local sws_ext_err_mess = "              The size of data requires\n\n     the SWS/S&M extension to handle them.\n\nIf it's installed then it needs to be updated.\n\n         After clicking \"OK\" a link to the\n\n SWS extension website will be provided\n\n\tThe script will now quit."
	local sws_ext_link = 'Get the SWS/S&M extension at\nhttps://www.sws-extension.org/\n\n'

	local resp = r.MB(sws_ext_err_mess,'ERROR',0)
		if resp == 1 then r.ShowConsoleMsg(sws_ext_link, r.ClearConsole()) return end
end


local function SetObjChunk(retval, obj, obj_type, obj_chunk) -- retval stems from r.GetFocusedFX(), value 0 is only considered at the pasting stage because in the copying stage it's error caught before the function
		if not (obj and obj_chunk) then return end
		if retval == 0 then retval = tonumber(obj_type) end -- for pasting stage when fx chains/floating windows are closed or not in focus
	return retval == 1 and r.SetTrackStateChunk(obj, obj_chunk, false) or r.SetItemStateChunk(obj, obj_chunk, false) -- isundo is false // https://forum.cockos.com/showthread.php?t=181000#9
end


local function SetObjChunk2(obj, obj_chunk)
	if not (obj and obj_chunk) then return end
local tr = r.ValidatePtr(obj, 'MediaTrack*')
local item = r.ValidatePtr(obj, 'MediaItem*')
local env = r.ValidatePtr(obj, 'TrackEnvelope*') -- works for take envelope as well
	return tr and r.SetTrackStateChunk(obj, obj_chunk, false) or item and r.SetItemStateChunk(obj, obj_chunk, false) or env and r.SetEnvelopeStateChunk(obj, obj_chunk, false) -- isundo is false // https://forum.cockos.com/showthread.php?t=181000#9
end


function Replace_GUIDs_in_Chunk(chunk)
	return chunk:gsub('{[%-%w]+}', function() return r.genGuid('') end)
end
-- OR
local fx_chunk = fx_chunk:gsub('{[%-%w]+}', function() return r.genGuid('') end) -- replace GUIDs making them unique


--================================= C H U N K  E N D ========================================


--============================================ F X ===============================================

--[[
-- Summary of FX selection functions

-- applies equally to take FX functions

r.TrackFX_GetFloatingWindow(tr, fx_idx) -- helps to determine if fx is open in a floating window

r.TrackFX_GetOpen(tr, fx_idx)
true:
1. fx UI is shown in the open fx chain
2. fx UI is shown in a floating window regardless of being shown in fx chain and of fx chain visibility
false:
1. fx UI is not shown both in fx chain and in a floating window while fx chain is open 
2. fx UI is not shown in a floating window while fx chain is closed

r.TrackFX_GetChainVisible(tr)
-- DOES NOT SUPPORT INPUT and MONITORING FX CHAINS, use Get_InputMonFX_Chain_Truely_SelectedFX()
>= 0 index of fx whose UI is shown in the open fx chain; !!!! returns index of selected fx even if its UI is open in a floating window
-1 the fx chain is closed
-2 the fx chain is open but is empty

r.TrackFX_SetOpen(tr, fx_idx, open)

1. open is false:
A. fx is floating - closes its floating window;
B. fx isn't floating regardless of its UI being shown fx chain - closes the fx chain;
2. open is true:
A. opens the fx chain with fx UI shown if fx chain was closed;
B. if fx chain is already open shows the fx UI in the fx chain if it wasn't shown

r.TrackFX_Show(tr, fx_idx, showFlag)

showFlag:
0 - hide chain
1 - show chain with fx UI shown
2 - close fx floating window
3 - open fx in a floating window

]]


function GetMonFXProps() -- get mon fx accounting for floating window, reaper.GetFocusedFX() doesn't detect mon fx in builds prior to 6.20

-- r.TrackFX_GetOpen(master_tr, integer fx)
	local master_tr = r.GetMasterTrack(0)
	local mon_fx_idx = r.TrackFX_GetRecChainVisible(master_tr)
	local is_mon_fx_float = false -- only relevant for pasting stage to reopen the fx in floating window
		if mon_fx_idx < 0 then -- fx chain closed or no focused fx -- if this condition is removed floated fx gets priority
			for i = 0, r.TrackFX_GetRecCount(master_tr) do
				if r.TrackFX_GetFloatingWindow(master_tr, 0x1000000+i) then
				mon_fx_idx = i; is_mon_fx_float = true break end
			end
		end
	return mon_fx_idx, is_mon_fx_float -- expected >= 0, true
end

local retval, track_num, item_num, fx_num = r.GetFocusedFX()
local mon_fx_idx = retval == 1 and track_num == 0 and fx_num >= 16777216
or retval == 0 and GetMonFXProps() >= 0 -- for builds older that 6.20 where GetFocusedFX() doesn't detect Monitor FX
local input_fx = retval == 1 and fx_num >= 16777216	-- since 6.20 covers both input and Mon FX // to differentiate track_num return value must be considered as above


function GetFocusedFX1() -- still must complemented with GetMonFXProps() below to get Mon FX in builds prior to 6.20 // see GetFocusedFX2() below
local retval, src_track_num, src_item_num, src_fx_num = r.GetFocusedFX()
-- Returns 1 if a track FX window has focus or was the last focused and still open, 2 if an item FX window has focus or was the last focused and still open, 0 if no FX window has focus. tracknumber==0 means the master track, 1 means track 1, etc. itemnumber and fxnumber are zero-based. If item FX, fxnumber will have the high word be the take index, the low word the FX index.
-- if take fx, item number is index of the item within the track (not within the project) while track number is the track this item belongs to, if not take fx src_item_num is -1, if retval is 0 the rest return values are 0 as well
-- if src_take_num is 0 then track or no object ??????

local tr = retval > 0 and (r.GetTrack(0,src_track_num-1) or r.GetMasterTrack()) -- will require adjustment if Mon FX should be supported as prior to build 6.20 Master track will have to be gotten even when retval is 0
local item = retval == 2 and r.GetTrackMediaItem(tr, src_item_num)
-- hight word is 16 bits on the left, low word is 16 bits on the right
local take_num, fx_num = src_fx_num>>16, src_fx_num&0xFFFF -- high word is right shifted by 16 bits (out of 32), low word is masked by 0xFFFF = binary 1111111111111111 (16 bit mask)
local take = retval == 2 and r.GetMediaItemTake(item, take_num)
local fx_num = retval == 2 and src_fx_num&0xFFFF or retval == 1 and src_fx_num -- take or track fx index (incl input/mon fx) // unlike in GetLastTouchedFX() input/Mon fx index is returned directly and need not be calculated // will require adjustment if Mon FX should be supported as prior to build 6.20 Mon FX will have to be gotten when retval is 0 as well
--	local mon_fx = retval == 0 and src_mon_fx_idx >= 0
--	local fx_num = mon_fx and src_mon_fx_idx + 0x1000000 or fx_num -- mon fx index

local fx_name
	if take then
	fx_name = select(2, r.TakeFX_GetFXName(take, fx_num))
	elseif tr then
	fx_name = select(2, r.TrackFX_GetFXName(tr, fx_num))
	end

return retval, src_track_num-1, tr, src_item_num, item, take_num, take, fx_num, fx_name -- src_track_num = -1 means Master;

end


function GetFocusedFX2() -- complemented with GetMonFXProps() to get Mon FX in builds prior to 6.20

local retval, tr_num, itm_num, fx_num = r.GetFocusedFX()
-- Returns 1 if a track FX window has focus or was the last focused and still open, 2 if an item FX window has focus or was the last focused and still open, 0 if no FX window has focus. tracknumber==0 means the master track, 1 means track 1, etc. itemnumber and fxnumber are zero-based. If item FX, fxnumber will have the high word be the take index, the low word the FX index.
-- if take fx, item number is index of the item within the track (not within the project) while track number is the track this item belongs to, if not take fx itm_num is -1, if retval is 0 the rest return values are 0 as well
-- if src_take_num is 0 then track or no object ???????

local mon_fx_num = GetMonFXProps() -- expected >= 0 or > -1

local tr = retval > 0 and (r.GetTrack(0,tr_num-1) or r.GetMasterTrack()) or retval == 0 and mon_fx_num >= 0 and r.GetMasterTrack() -- prior to build 6.20 Master track has to be gotten even when retval is 0

local item = retval == 2 and r.GetTrackMediaItem(tr, itm_num)
-- high word is 16 bits on the left, low word is 16 bits on the right
local take_num, take_fx_num = fx_num>>16, fx_num&0xFFFF -- high word is right shifted by 16 bits (out of 32), low word is masked by 0xFFFF = binary 1111111111111111 (16 bit mask); in base 10 system take fx numbers starting from take 2 are >= 65536
local take = retval == 2 and r.GetMediaItemTake(item, take_num)
local fx_num = retval == 2 and take_fx_num or retval == 1 and fx_num or mon_fx_num >= 0 and 0x1000000+mon_fx_num -- take or track fx index (incl. input/mon fx) // unlike in GetLastTouchedFX() input/Mon fx index is returned directly and need not be calculated // prior to build 6.20 Mon FX have to be gotten when retval is 0 as well // 0x1000000+mon_fx_num is equivalent to 16777216+mon_fx_num
--	local mon_fx = retval == 0 and mon_fx_num >= 0
--	local fx_num = mon_fx and mon_fx_num + 0x1000000 or fx_num -- mon fx index

local fx_name
	if take then
	fx_name = select(2, r.TakeFX_GetFXName(take, fx_num))
	elseif tr then
	fx_name = select(2, r.TrackFX_GetFXName(tr, fx_num))
	end

return retval, tr_num-1, tr, itm_num, item, take_num, take, fx_num, mon_fx_num >= 0, fx_name -- tr_num = -1 means Master;

end


function GetOrigFXName(obj_chunk, fx_GUID)

-- Get original FX name regardless of a custom plugin name assigned by the user which is returned by r.TrackFX_GetFXName()

local fx_GUID = fx_GUID:gsub('[%-]','%%%0') -- escape dashes for capture inside string.match below

		local t = {} -- split chunk into lines and save each to table
			for line in obj_chunk:gmatch('[^\n\r]*') do
			t[#t+1] = line
			end
		local k -- to reset or prevent its spilling over outside of this function
			for i = #t,1,-1 do -- parse from the end since GUID string follows the settings data block
				if t[i]:match(fx_GUID) then k = i end
				if k and k - i > 2 and t[i]:match('<') then fx_name_line = t[i] -- settings data block starts 2 lines above the GUID string, once plugin chunk top line is reached save it
				break end
			end
		local plug_type = fx_name_line:match('<([ACDJLPSTUVX]*)') -- all plugin types bar Video processor
		local fx_name
			if #plug_type > 1 and plug_type ~= 'JS' then fx_name = string.gsub(fx_name_line:match('<'..plug_type..' \"('..plug_type..'%w?: [^\"]*)'),'[%(%)%+%-%[%]%.%^%$%*%?%%]','%%%0') -- VST, AU, DX, LV2 or CLAP, escape magic characters likely to appear in plugin names for evaluation against dest object chunks at pasting stage
			elseif #plug_type > 1 then fx_name = string.gsub(fx_name_line:match('<(JS [^\"]*)'),'[%(%)%+%-%[%]%.%^%$%*%?%%]','%%%0') -- same, only gets file name, the plugins name must be retrieved either from 'desc:' tag inside the file or from reaper-jsfx.ini searching by the relative path
			end
		return fx_name or obj_chunk:match('Video processor')
end



function Get_Focused_FX_Orig_Name() -- regardless of a user custom name displayed in the FX chain; if non-JSFX plugin name was changed in the FX browser, then it's this name which will be retrieved since this is what's displayed in the chunk
-- relies on GetFocusedFX() and GetObjChunk() functions

-- SINCE 6.31 r.Track/TakeFX_GetNamedConfigParm() can be used

-- non-JSFX plugin name changes in the FX browser are reflected in reaper-vstplugins(64).ini file
-- JSFX plugin names can't be changed in the FX browser but can in the NAME entries inside reaper-jsfx.ini
-- and then they will be reflected in the FX browser after restatring REAPER or refreshing the FX browser with F5

-- JSFX local to project are only displayed in the FX browser if the project is saved and aren't listed in reaper-jsfx.ini
-- <JS "<Project>/ReaperBlog_Macro Controller test.jsfx" "" // local fx chunk
-- JS: <Project>/ReaperBlog_Macro Controller test.jsfx // local fx fx chain name
-- for the local JSFX to load presets saved with its regular version, the presets file in the /presets folder must be duplicated and named js-_Project__(JSFX file name).ini

	if r.GetToggleCommandStateEx(0,40605) == 1 then return end -- Show action list // ignore FX if Action list window is open

	local function jsfx_exists(path, sep, name, type) -- evaluate if a JSFX exists in case it'd been removed before the FX browser was refreshed with F5 or REAPER restarted
		if type == 'JS' then
		local path = name:match('<Project>') and
		select(2,r.EnumProjects(-1)):match('(.+[\\/])')..'Effects'..sep..name:match('/(.+)')
		or path..sep..'Effects'..sep..(name:match('%[(.+)%]') or name:match('.+')) -- 2nd option if a non-local jsfx appearing in the chain isn't available, in which case only relative path is displayed either in the chain or in the chunk, without the fx name
		return r.file_exists(path)
		else return true -- all other fx types exist by default
		end
	end


local retval, fx_name, fx_type -- retval just because fx_name must be made local as both are returned together, otherwise retval would end up being global; fx_type to limit Add_Remove_FX_Notes_Tag() to VST and JSFX plugins as cannot test AU/DX/LV2/CLAP (files reaper-auplugins_arm64-bc.ini, reaper-auplugins64-bc.ini, reaper-dxplugins64.ini)

	if r.GetToggleCommandStateEx(0, 40271) == 1 -- View: Show FX browser window // fx browser is open // the action adds last selected fx from the fx browser even when it's closed so must be additionally conditioned
	then -- Insert temporary track to insert FX and get FX props
	r.InsertTrackAtIndex(r.GetNumTracks(), false) -- wantDefaults false; insert new track at end of track list and hide it; action 40702 'Track: Insert new track at end of track list' creates undo point hence unsuitable
	local temp_tr = r.GetTrack(0,r.CountTracks(0)-1)
	r.SetMediaTrackInfo_Value(temp_tr, 'B_SHOWINMIXER', 0) -- hide in Mixer
	r.SetMediaTrackInfo_Value(temp_tr, 'B_SHOWINTCP', 0) -- hide in Arrange
	r.TrackFX_AddByName(temp_tr, 'FXADD:1e', false, 0) -- recFX false
	retval, fx_name = r.TrackFX_GetFXName(temp_tr, 0, '')
	fx_type = fx_name:match('^[CPJLVSTAUDX]+') -- see explanation at the variable declaration above
	r.DeleteTrack(temp_tr)
	end

	if not fx_name or #fx_name == 0 then -- FX browser isn't open or open and no FX is selected, look for focused FX in FX chain and get its orig name from chunk because it can be renamed by the user in the fx chain // orig name in the chunk reflects name in reaper-vstplugins64.ini and reaper-jsfx.ini (NAME entry)
	local retval, tr_num, tr, itm_num, item, take_num, take, fx_num, mon_fx = get_focused_fx() -- tr_num = -1 means Master;
		if fx_num then
		local get_fx_GUID, obj = table.unpack((retval == 1 or retval == 0 and mon_fx) and {r.TrackFX_GetFXGUID, tr} or retval == 2 and {r.TakeFX_GetFXGUID, take})
		local fx_GUID = get_fx_GUID(obj, fx_num)
		local prev_fx_GUID = get_fx_GUID(obj, fx_num-1) or ''
		local ret, displayed_fx_name = table.unpack(retval == 2 and {r.TakeFX_GetFXName(obj, fx_num, '')} or (retval == 1 or retval == 0 and mon_fx) and {r.TrackFX_GetFXName(obj, fx_num, '')})
		-- Extract from chunk
		local obj = (retval == 1 or retval == 0 and mon_fx) and obj or r.GetMediaItemTake_Item(obj) -- since the next function needs item, not a take
		local ret, chunk = get_obj_chunk(obj)
			if ret == 'err_mess' then return 'err_mess' end
		local fx_chunk = mon_fx and get_mon_fx_chunk(fx_GUID, prev_fx_GUID) or get_fx_chunk(chunk, fx_GUID, prev_fx_GUID)
		fx_name = fx_chunk:match('BYPASS.-<[CPVSTAUDXL23i:]+ "(.-)" ')
		fx_type = fx_chunk:match('BYPASS.-<([CPJLVSTAUDX2]+)') -- see explanation at the variable declaration above
		local fx_file_name = fx_chunk:match('BYPASS.-<[CPVSTAUDXL23i:]+ ".-" "(.-)" ') or fx_chunk:match('BYPASS.-<[CPVSTAUDXL23i:]+ ".-" (.-) ') -- file name WITH or WITHOUT spaces
		-- in JSFX chunk only file relative path is displayed without the name defined at desc: tag in their code
		fx_name = fx_name
		or fx_chunk:match('BYPASS.-<JS "?(.-)" .-'..esc(displayed_fx_name)) -- displayed name with or without spaces; file path WITH spaces
		or fx_chunk:match('BYPASS.-<JS (.-) .-'..esc(displayed_fx_name)) -- displayed name with or without spaces; file path WITHOUT spaces
		or fx_chunk:match('BYPASS.-<JS "?(.-)"? ""') -- NO displayed name; file path with or without spaces
		or fx_chunk:match('BYPASS.-<VIDEO_EFFECT "(Video processor)"')

		-- Get JSFX which became unavailable during the session (before FX Browser was refreshed) to generate appropriate error message // if these were loaded into the fx chain after becoming unavailable no chunk data is stored for them, hence reliance on the displayed name is required // if they were renamed in the fx chain while being unavailable there's no way to retrieve their original type, name and path
		fx_type = fx_type or displayed_fx_name:match('^[CPJLVSTAUDX]+')
		fx_name = fx_name or displayed_fx_name:match('JS: %[(.+)%]') or displayed_fx_name:match('JS: (.+)') -- either regular or local
		end

	end


fx_name = fx_name and (fx_name:match('.+ %(n%) %[.-%]$') or fx_name:match('(.+) %(n%)')) or fx_name -- if there's notes tag ignore it, from JSFX it'll be removed in Create_Section_Title() function // option 1 is for JSFX since the tag is placed between the name and the path, option 2 is for other FX types

return fx_name and #fx_name > 0 and (fx_type == 'JS' and jsfx_exists(path, sep, fx_name, fx_type) or fx_type ~= 'JS') and fx_name, fx_type -- if JSFX, checking if file exists

end



function Get_FX_Chain_Chunk(chunk, path, sep, type, take_GUID) -- isolate object fx chain, for track main fx chain exclude items/input fx, for track input fx exclude items, for items exclude takes other than the active one; type arg is set within the routine: 0 - track main fx, 1 - track input fx or Mon FX for the Master track; if take_GUID arg is valid, then take fx

local take_GUID = Esc(take_GUID)
local fx_chain_chunk

	if chunk and #chunk > 0 then
		if take_GUID then -- take fx chain
		fx_chain_chunk = chunk:match(take_GUID..'.-(<TAKEFX.->)\nTAKE') or chunk:match(take_GUID..'.-(<TAKEFX.->)\n<ITEM') or chunk:match(take_GUID..'.-(<TAKEFX.*>)\n>')
		else
			if type == 0 then -- track main fx chain
			fx_chain_chunk = chunk:match('(<FXCHAIN.*>)\n<FXCHAIN_REC') or chunk:match('(<FXCHAIN.->)\n<ITEM') or chunk:match('(<FXCHAIN.*WAK.*>)\n>')
			elseif type == 1 then -- track input fx chain
				if chunk:match('<FXCHAIN_REC') then -- regular track input fx
				fx_chain_chunk = chunk:match('(<FXCHAIN_REC.->)\n<ITEM') or chunk:match('(<FXCHAIN_REC.*WAK.*>)\n>')
				else -- monitor fx of the master track, extract fx chunk from reaper-hwoutfx.ini
				local f = io.open(path..sep..'reaper-hwoutfx.ini', 'r')
				fx_chain_chunk = f:read('*a')
				f:close()
				end
			end
		end
	end

return fx_chain_chunk

end


function Get_FX_Chunk(obj, obj_chunk, fx_idx, take_idx) -- obj is track or item pointer; if no take_idx arg is supplied, the active take will be used // for track input FX and Mon FX fx_idx argument must look like fx_idx+0x1000000 or fx_idx+16777216; uses Esc() function

local track = r.ValidatePtr(obj, 'MediaTrack*')
local item = r.ValidatePtr(obj, 'MediaItem*')
local take = item and (take_idx and r.GetTake(obj, take_idx) or r.GetActiveTake(obj))

local GetFXGUID = take and r.TakeFX_GetFXGUID or r.TrackFX_GetFXGUID

local obj = track and obj or take

local MON_FX = obj == r.GetMasterTrack(0) and fx_idx >= 16777216
local FXCHAINSEC = take and '<TAKEFX' or fx_idx >= 16777216 and not MON_FX and '<FXCHAIN_REC' or ''

	if MON_FX then
	local path = r.GetResourcePath()
	local sep = r.GetResourcePath():match('[\\/]+')
	local f = io.open(path..sep..'reaper-hwoutfx.ini', 'r')
	obj_chunk = f:read('*a') -- not global so isn't accessible outside of the function
	f:close()
	end

local target_fx_GUID = obj and fx_idx and GetFXGUID(obj, fx_idx)
local prev_fx_GUID = obj and fx_idx and GetFXGUID(obj, fx_idx-1)

return prev_fx_GUID and target_fx_GUID and obj_chunk:match(FXCHAINSEC..'\n.-'..Esc(prev_fx_GUID)..'.-\n(BYPASS %d %d[%s%d]*.-'..Esc(target_fx_GUID)..'.-WAK.-)\n') or target_fx_GUID and obj_chunk:match(FXCHAINSEC..'.-\n(BYPASS %d %d[%s%d]*.-'..Esc(target_fx_GUID)..'.-WAK.-)\n') -- in older REAPER versions BYPASS only has 2 flags; originally the capture was ending with 'WAK %d %d', but was changed to accommodate possible expansion of flags in the future

end


function Collect_VideoProc_Instances(fx_chain_chunk) -- fx chain chunk is obtained with Get_FX_Chain_Chunk()

local video_proc_t = {} -- collect indices of video processor instances, because detection by fx name is unreliable as not all its preset names contain 'video processor' phrase due to length
local counter = 0 -- to store indices of video processor instances

	if fx_chunk and #fx_chunk > 0 then
		for line in fx_chunk:gmatch('[^\n\r]*') do -- all fx must be taken into account for video proc indices to be accurate
		local plug = line:match('<VST') or line:match('<AU') or line:match('<JS') or line:match('<DX') or line:match('<LV2') or line:match('<VIDEO_EFFECT')
			if plug then
				if plug == '<VIDEO_EFFECT' then
				video_proc_t[counter] = '' -- dummy value as we only need indices
				end
			counter = counter + 1
			end
		end
	end

return video_proc_t

end


function Collect_VST3_Instances(fx_chain_chunk) -- -- fx chain chunk is obtained with Get_FX_Chain_Chunk()// replicates Collect_VideoProc_Instances()

-- required to get hold of .vstpreset file names stored in the plugin dedicated folder and list those in the menu

local vst3_t = {} -- collect indices of vst3 plugins instances, because detection by fx name is unreliable as it can be changed by user in the FX browser
local counter = 0 -- to store indices of vst3 plugin instances

	if fx_chunk and #fx_chunk > 0 then
		for line in fx_chunk:gmatch('[^\n\r]*') do -- all fx must be taken into account for vst3 plugin indices to be accurate
		local plug = line:match('<VST') or line:match('<AU') or line:match('<JS') or line:match('<DX') or line:match('<LV2') or line:match('<VIDEO_EFFECT')
			if plug then
				if line:match('VST3') then
				vst3_t[counter] = '' -- dummy value as we only need indices
				end
			counter = counter + 1
			end
		end
	end

return vst3_t

end


function Collect_FX_Preset_Names(obj, src_fx_cnt, src_fx_idx, pres_cnt)
-- getting all preset names in a roundabout way by travesring them in an instance on a temp track
-- cannot traverse in the source track as if plugin parameters haven't been stored in a preset
-- after traversing they will be lost and will require prior storage and restoration whose accuracy isn't guaranteed

r.PreventUIRefresh(1)
r.InsertTrackAtIndex(r.GetNumTracks(), false) -- insert new track at end of track list and hide it; action 40702 creates undo point
local temp_track = r.GetTrack(0,r.CountTracks(0)-1)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINMIXER', 0) -- hide in Mixer
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINTCP', 0) -- hide in Arrange

	if r.ValidatePtr(obj, 'MediaTrack*') then
	r.TrackFX_CopyToTrack(obj, src_fx_idx, temp_track, 0, false) -- is_move false // when copying FX envelopes don't follow, only when moving
	elseif r.ValidatePtr(obj, 'MediaItem_Take*') then
	r.TakeFX_CopyToTrack(obj, src_fx_idx, temp_track, 0, false) -- is_move false
	end

r.TrackFX_SetPresetByIndex(temp_track, 0, pres_cnt-1) -- start from the last preset in case user has a default preset enabled and advance forward in the loop below
local _, pres_cnt = r.TrackFX_GetPresetIndex(temp_track, 0)

local preset_name_t = {}

	for i = 1, pres_cnt do
	r.TrackFX_NavigatePresets(temp_track, 0, 1) -- forward
	local _, pres_name = r.TrackFX_GetPreset(temp_track, 0, '')
	preset_name_t[i] = pres_name..'|'
	end

r.DeleteTrack(temp_track)

r.PreventUIRefresh(-1)

	if src_fx_cnt > 1 then -- close submenu, otherwise no submenu
	table.insert(preset_name_t, #preset_name_t, '<')
	end

	if #preset_name_t > 0 and
	(#preset_name_t-1 == pres_cnt  -- one extra entry '<' if any
	or #preset_name_t == pres_cnt) -- when there's no submenu closure '<' because there's only one plugin in the chain
	then return preset_name_t end

end


local _, scr_name, scr_sect_ID, cmd_ID, _,_,_ = r.get_action_context()

function Re_Store_Plugin_Settings(obj, fx_idx, t, scr_cmd_ID) -- scr_cmd_ID is obtained with r.get_action_context()
-- if applied to focused fx then fx_idx must be obtained from custom GetFocusedFX2() function
local r = reaper
local tr, take = r.ValidatePtr(obj, 'MediaTrack*'), r.ValidatePtr(obj, 'MediaItem_Take*')
local GetNumParams, GetParam, SetParam = table.unpack(tr and {r.TrackFX_GetNumParams, r.TrackFX_GetParam, r.TrackFX_SetParam} or take and {r.TakeFX_GetNumParams, r.TakeFX_GetParam, r.TakeFX_SetParam} or {nil})
local parm_list = r.GetExtState(scr_cmd_ID, 'PARM_LIST')

	if not t and parm_list == '' then -- store
	local t = {}
		for parm_idx = 0, GetNumParams(obj, fx_idx)-1 do
		local retval, minval, maxval = GetParam(obj, fx_idx, parm_idx)
		t[#t+1] = retval
		end
	-- setting ext state allows restoration on the second script run rather than within one run
	r.SetExtState(scr_cmd_ID, 'PARM_LIST', table.concat(t, ';'), false) -- persist false
	return t
	elseif t or parm_list ~= '' then -- restore
	local t = t or (function(parm_list)-- if restoring on second run in which case the t will be nil // function in place
					local t = {}
						for parm_val in parm_list:gmatch('[^;]+') do
						t[#t+1] = parm_val
						end
					return t
					end)(parm_list)

		for parm_idx = 0, GetNumParams(obj, fx_idx)-1 do
		SetParam(obj, fx_idx, parm_idx, t[parm_idx+1])
		end
		if parm_list ~= '' then -- if restored at subsequent script runs
		local resp = r.MB('Keep the stored settings?', 'PROMPT', 4)
		local del = resp == 7 and r.DeleteExtState(scr_cmd_ID, 'PARM_LIST', true) -- persist true
		else -- if restored within the same script run
		r.DeleteExtState(scr_cmd_ID, 'PARM_LIST', true) -- persist true
		end

	end

end


function Select_FX_UI_in_FXChain(object, take_idx, fx_idx, want_input_mon_fx)
-- mainly keeping FX chain closed, but if it's open keeps it open
-- another method of doing that is via chunk, won't work for Monitor FX as from chunk they
-- can only be updated by restarting REAPER

-- r.PreventUIRefresh(1) -- doesn't prevent a short FX chain flick
local master = r.GetMasterTrack(0) == object
local tr = r.ValidatePtr(object, 'MediaTrack*')
local take = r.ValidatePtr(object, ' MediaItem_Take*')
local item = r.ValidatePtr(object, ' MediaItem*')
	if (master or tr) and fx_idx then
	local fx_idx = want_input_mon_fx and 0x1000000+fx_idx or fx_idx
	r.TrackFX_SetOpen(object, fx_idx, true) -- open true; open fx UI and fx chain
--	r.TrackFX_Show(object, fx_idx, 3) -- showFlag 3 show floating window // doesn't make FX UI selected in the chain
	local is_vis = want_input_mon_fx and r.TrackFX_GetRecChainVisible(object) or r.TrackFX_GetChainVisible(object)
	local close = is_vis ~= -1 and r.TrackFX_Show(object, fx_idx, 0) -- showFlag 0 hide chain // if FX chain is open and then gets closed the switch to the desired FX UI doesn't occur; so keep open if the chain is already open
	elseif (item or take) and fx_idx then
	local object = take and object or item and take_idx and r.GetTake(object, take_idx) or item and r.GetActiveTake(object)
	local open = object and r.TakeFX_SetOpen(object, fx_idx, true) -- open true; open fx UI and fx chain
--	r.TakeFX_Show(object, fx_idx, 3) -- showFlag 3 show floating window // doesn't make FX UI selected in the chain
	local is_vis = object and r.TakeFX_GetChainVisible(object)
	local close = is_vis ~= -1 and r.TakeFX_Show(object, fx_idx, 0) -- showFlag 0 hide chain // if FX chain is open and then gets closed the switch to the desired FX UI doesn't occur; so keep open if the chain is already open
	end
-- r.PreventUIRefresh(-1) -- doesn't prevent a short FX chain flick

end


function GetLastTouchedFX1() -- means last even if no longer focused // Mon FX aren't supported by the API function
-- Returns true if the last touched FX parameter is valid, false otherwise.
-- Always returns true as long as FX was touched at least once during a session and that FX is still present, unless the edit cursor is over an item or a TCP
-- To make RS5k last touched its parameter must be changed whereas in plugins with sliders a touch of a slider siffices,
-- could be bacause of a float value change invisible in the UI
--The low word of tracknumber is the 1-based track index -- 0 means the master track, 1 means track 1, etc. If the high word of tracknumber is nonzero, it refers to the 1-based item index (1 is the first item on the track, etc). For track FX, the low 24 bits of fxnumber refer to the FX index in the chain, and if the next 8 bits are 01, then the FX is record FX. For item FX, the low word defines the FX index in the chain, and the high word defines the take number.
-- https://stackoverflow.com/questions/10493411/what-is-bit-masking
-- hight word is 16 bits on the left, low word is 16 bits on the right
local is_last_touched, src_track_num, src_fx_num, src_param_num = r.GetLastTouchedFX() -- doesn't support Mon FX
local track_num = src_track_num&0xFFFF -- low word (16 bits out of 32) masked by 0xFFFF = 1111111111111111 (16 set bits) in binary; 0 master, > 0 regular
local tr = track_num == 0 and r.GetMasterTrack(0) or r.GetTrack(0,track_num-1)
local item_num = src_track_num>>16 -- high word (16 bits out of 32) right shifted; item in track, 1 based
local item = item_num >= 1 and r.GetTrackMediaItem(tr, item_num-1)
local fx_num_tr = src_fx_num&0xFFFFFF -- low 24 bits (out of 32) masked by 0xFFFFFF = 111111111111111111111111 (24 set bits) in binary, fx idx
local is_input_fx = src_fx_num>>24 == 1 -- right shift by 24 bits to only leave 8 high bits intact
local fx_num_take = src_fx_num&0xFFFF -- low word (16 bits out of 32) masked as above // 0 based
local fx_num = item and src_fx_num&0xFFFF or is_input_fx and fx_num_tr+0x1000000 or fx_num_tr -- unlike in GetFocusedFX() input/Mon fx index isn't returned directly and must be calculated
local take_num = item and src_fx_num>>16 -- high word (16 bits out of 32) right shifted as above // 0 based
local take = item and r.GetTake(item, take_num)
return is_last_touched, track_num-1, tr, item_num-1, item, take_num, take, fx_num, src_param_num -- indices are 0 based; track_num = -1 means Master; item_num = -1 or take_num or take = false means not take FX
end

is_last_touched, track_num, tr, item_num, item, take_num, take, fx_num, parm_num = GetLastTouchedFX() -- example


function GetLastTouchedFX2() -- DOESN'T SUPPORT Monitoring FX since native GetLastTouchedFX() doesn't support them
-- Always returns true as long as FX was touched at least once during a session and that FX is still present, unless the edit cursor is over an item or a TCP
-- To make RS5k last touched its parameter must be changed whereas in plugins with sliders a touch of a slider siffices,
-- could be bacause of a float value change invisible in the UI
-- returns false if the last touched parameter is invalid
-- 131072 = binary 0100000000000000000, hex 20000, 65536*2, 0xFFFF*2
-- 0xFFFF = binary 0001111111111111111, decimal 65536

local is_last_touched, tr_bitfield, fx_bitfield, parm_idx = r.GetLastTouchedFX()

	if is_last_touched then
	local item_idx = tr_bitfield>>16 > 0 and tr_bitfield>>16 -- If the high word of tr_bitfield is nonzero, it refers to the 1-based item index (1 is the first item on the track, etc)
	local tr_idx = tr_bitfield&0xFFFF or -1 -- The low word of tr_bitfield is the 1-based track index -- 0 means the master track, 1 means track 1, etc // 0xFFFF = binary 1111111111111111 (16 bit mask) // 'or -1' to simplify next statement
	local tr = tr_idx == 0 and r.GetMasterTrack(0) or tr_idx > 0 and r.GetTrack(0, tr_idx-1)
	local item = item_idx and r.GetTrackMediaItem(tr, item_idx-1)
	local fx_idx = item and fx_bitfield&0xFFFF or tr and fx_bitfield&0xFFFFFF -- For item FX, the low word of fx_bitfield defines the FX index in the chain; For track FX, the low 24 bits of fx_bitfield refer to the FX index in the chain, and if the next 8 bits are 01, then the FX is record FX; 0xFFFF = binary 1111111111111111 = dec 65535 (16 bit mask), 0xFFFFFF = binary 111111111111111111111111 = dec 16777215 (24 bit mask); each hexadecimal digit stands for four bits
	local fx_idx = tr and fx_bitfield>>24 == 01 and fx_idx+0x1000000 or fx_idx -- For track FX if the next (high) 8 bits are 01, then the FX is record FX // to get high 8 bits of a 32 bit number it must be shifted 24 bits rightwards
	local take_idx = item and fx_bitfield>>16 -- For item FX, the high word defines the take number
	local take = take_idx and r.GetTake(item, take_idx)
	return is_last_touched, tr_idx == -1 and tr_idx or tr_idx-1, tr, item_idx and item_idx-1, item, take_idx, take, fx_idx, parm_idx -- tr_idx -1 is Master track; item_idx is index on a track
	end

end

is_last_touched, tr_idx, tr, item_idx, item, take_idx, take, fx_idx, parm_idx = GetLastTouchedFX() -- example


function Collect_FX_Output_Data(tr) -- fx index and output channels // blueprint of dealing with output channels
local t, rs5k_cnt = {}, 0
	for fx_idx = 0, r.TrackFX_GetCount(tr)-1 do
	local RS5k
		for parm_idx = 0, r.TrackFX_GetNumParams(tr, fx_idx)-1 do
		local retval, parm_name = r.TrackFX_GetParamName(tr, fx_idx, parm_idx, '')
			if parm_name == 'Gain for minimum velocity' then RS5k = 1 break end
		end
		if RS5k then
		rs5k_cnt = rs5k_cnt+1
		t[fx_idx+1] = {} -- storing 1-based fx index as key
		local tr_ch_cnt = r.GetMediaTrackInfo_Value(tr, 'I_NCHAN')
			for ch_idx = 0, tr_ch_cnt-1 do
			-- thanks to MPL and EUGEN
			-- https://forum.cockos.com/showthread.php?t=233640
			-- https://github.com/EUGEN27771/ReaScripts/blob/master/FX/gen_TrackFX%20Routing%20Matrix.lua
			-- isoutput value must be > 0 throughout, it doesn't represent actual output index, seem to function as a boolean
			-- pin is the horizonal row of checkboxes, 2 for each output, 0-based
			-- high32 bits become grater than 0 starting with channel 33 (1-based), at this stage low32 bits become 0, channel count restarts from 1; so there're 1-32 channels (1-based) for low 23 bits and 1-32 channels for high 32 bits
			local lo32pin1, hi32pin1 = r.TrackFX_GetPinMappings(tr, fx_idx, 1, 0) -- isoutput 1, pin 0
			local lo32pin2, hi32pin2 = r.TrackFX_GetPinMappings(tr, fx_idx, 1, 1) -- isoutput 1, pin 1
				local function select_bitfield(ch_idx, lo32, hi32)
				return ch_idx <= 31 and lo32 or hi32
				end
			local bitmask = ch_idx <= 31 and 2^ch_idx or 2^(ch_idx-32) -- restart channel count for high 32 bits
			local bitfield1, bitfield2 = select_bitfield(ch_idx, lo32pin1, hi32pin1), select_bitfield(ch_idx, lo32pin2, hi32pin2)
			local pin1_ch, pin2_ch = bitfield1&bitmask==bitmask and ch_idx+1, bitfield2&bitmask==bitmask and ch_idx+1 -- using 1-based channel indices
			local ch_t = pin1_ch and pin2_ch and (pin1_ch ~= pin2_ch and {pin1_ch, pin2_ch} or {pin1_ch}) or pin1_ch and {pin1_ch} or pin2_ch and {pin2_ch} -- in theory both pins can point at the same channel hence both are evaluated for each channel
				if ch_t then
				local len = #t[fx_idx+1] -- for legibility and brevity
					for _, ch in ipairs(ch_t) do
					t[fx_idx+1][len+1] = ch
					end
				end
			end
		end
	end
return t, rs5k_cnt
end


function Is_TrackFX_Open(obj, fx_index) -- open in the fx chain and in a floating window
local tr = r.ValidatePtr(obj, 'MediaTrack*')
local take = r.ValidatePtr(obj, 'MediaItem_Take*')
local GetCount, GetOpen, GetFloatingWindow = table.unpack(take and {r.TakeFX_GetCount, r.TakeFX_GetOpen, r.TakeFX_GetFloatingWindow} or tr and {r.TrackFX_GetCount, r.TrackFX_GetOpen, r.TrackFX_GetFloatingWindow})
return GetOpen(obj, fx_index), GetFloatingWindow(obj,fx_index)
--[[-- not clear why i used this // this is useful when searching if there're ANY fx selected in the chain and/or open in floating window
	if tr or take then
		for fx_idx = 0, GetCount(obj)-1 do
			if GetOpen(obj, fx_idx) and fx_idx == fx_index then
			return true, GetFloatingWindow(obj,fx_index)
			end
		end
		if tr then
			for fx_idx = 0, r.TrackFX_GetRecCount(tr)-1 do
				if r.TrackFX_GetOpen(tr, fx_idx+0x1000000) and fx_idx+0x1000000 == fx_index then
				return true, GetFloatingWindow(obj,fx_index)
				end
			end
		end
	end
	]]
end


local function Count_FX(sel_trk_cnt, sel_itms_cnt)
-- Count all FX in selected objects to determine if FX were added
-- provided destination objects were initially empty
-- idea borrowed from MPL's Open FX browser and close FX browser when FX is inserted.lua
local fx_cnt = 0
	if sel_trk_cnt > 0 then
		for i = 0, sel_trk_cnt-1 do
		local tr = r.GetSelectedTrack(0,i) or r.GetMasterTrack(0)
		fx_cnt = fx_cnt + r.TrackFX_GetCount(tr) + (TRACK_INPUT_MON_FX and r.TrackFX_GetRecCount(tr))
		end
	end
	if sel_itms_cnt > 0 then
		for i = 0, sel_itms_cnt-1 do
		local take = r.GetActiveTake(r.GetSelectedMediaItem(0,i))
		fx_cnt = fx_cnt + r.TakeFX_GetCount(take)
		end
	end
	return fx_cnt
end



function Get_FX_Env_Src_Parameter(env) -- get fx parameter the envelope belongs to
local tr = r.GetEnvelopeInfo_Value(env, 'P_TRACK') -- if take env is selected returns 0.0, otherwise pointer
local take = r.GetEnvelopeInfo_Value(env, 'P_TAKE') -- if track env is selected returns 0.0, otherwise pointer
local tr, take = tr ~= 0 and tr, take ~= 0 and take -- validate
local retval, env_name = r.GetEnvelopeName(env)
-- capture fx name displayed in the fx chain, fx env name format is 'parm name / fx name'
local fx_name = env_name:match('.+ / (.+)') -- clean name, without the plugin type prefix
local cur_val, minval, maxval, step
local CountFX, GetFXName, GetNumParams, GetFXEnvelope, GetFXParam, GetParamStepSizes = table.unpack(tr and {r.TrackFX_GetCount, r.TrackFX_GetFXName, r.TrackFX_GetNumParams, r.GetFXEnvelope, r.TrackFX_GetParam, r.TrackFX_GetParameterStepSizes} or take and {r.TakeFX_GetCount, r.TakeFX_GetFXName, r.TakeFX_GetNumParams, r.TakeFX_GetEnvelope, r.TakeFX_GetParam, r.TakeFX_GetParameterStepSizes})
local obj = take or tr
	for fx_idx = 0, CountFX(obj)-1 do
	local retval, name = GetFXName(obj, fx_idx)
		if name:match(': (.+) %(') == fx_name or name == fx_name then -- either default or custom plugin name
			for parm_idx = 0, GetNumParams(obj, fx_idx)-1 do
		--	local retval, parm_name = r.TrackFX_GetParamName(tr, fx_idx, parm_idx, '')
			local parm_env = GetFXEnvelope(obj, fx_idx, parm_idx, false) -- create false
				if parm_env == env -- and parm_name == env_name:match('(.+) /')
				then
				local cur_val, minval, maxval = GetFXParam(obj, fx_idx, parm_idx)
				local retval, step, smallstep, largestep, istoggle = GetParamStepSizes(obj, fx_idx, parm_idx) -- if no step retval is false
				return cur_val, minval, maxval, step ~= 0 and step
				end
			end
		end
	end

end



function Check_If_FX_Selected_In_FX_Browser()

r.PreventUIRefresh(1)
r.InsertTrackAtIndex(r.GetNumTracks(), false) -- wantDefaults false // insert new track at end of track list and hide it
local temp_track = r.GetTrack(0,r.CountTracks(0)-1)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINMIXER', 0)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINTCP', 0)
r.TrackFX_AddByName(temp_track, 'FXADD:', false, -1)
local fx_list
	if r.TrackFX_GetCount(temp_track) == 0 then
	r.MB('No FX have been selected in the FX browser.', 'ERROR', 0)
	else
	fx_list = ''
		for i = 0, r.TrackFX_GetCount(temp_track)-1 do
		fx_list = fx_list..'\n'..select(2,r.TrackFX_GetFXName(temp_track, i, ''))
		end
	end
r.DeleteTrack(temp_track)
r.PreventUIRefresh(-1)
return fx_list:sub(3) -- removing leading line break // mainly for display in a prompt

end



function Get_FX_Type(obj, fx_idx)
-- https://forum.cockos.com/showthread.php?t=277103
local plug_types_t = {[0] = 'DX', [1] = 'LV2', [2] = 'JSFX', [3] = 'VST',
[4] = '', [5] = 'AU', [6] = 'Video processor', [7] = 'CLAP', [8] = 'Container'}
local GetIOSize = obj and (r.ValidatePtr(obj, 'MediaItem_Take*') and r.TakeFX_GetIOSize or r.ValidatePtr(obj, 'MediaTrack*') and r.TrackFX_GetIOSize)
	if GetIOSize then
	local plug_type, inputPins_cnt, outputPins_cnt = GetIOSize(obj, fx_idx)
	return plug_types_t[plug_type]
	end
end


function Is_Same_Plugin(src_obj, src_fx_idx, dest_obj, dest_fx_idx) -- obj is either track or take
-- input/Monitoring FX index must be fed in the API format, i.e. 0x1000000+idx or 16777216+idx
-- may not be good for JSFX plugins, because they may have too few params to reliably compare
-- while having common wet, bypass, delta params

	local function get_fx_parms(obj, fx_idx)
	local take = r.ValidatePtr(obj, 'MediaItem_Take*')
	local tr = r.ValidatePtr(obj, 'MediaTrack*')
	local GetNumParams, GetParamName = table.unpack(take and {r.TakeFX_GetNumParams, r.TakeFX_GetParamName}
	or tr and {r.TrackFX_GetNumParams, r.TrackFX_GetParamName} or {})
		if obj then
		local t = {}
			for idx = 0, GetNumParams(obj, fx_idx)-1 do
			local ret, parm_name = GetParamName(obj, fx_idx, idx, '')
			t[#t+1] = parm_name
			end
		return t
		end
	end

local src_parm_t = get_fx_parms(src_obj, src_fx_idx)
local dest_parm_t = get_fx_parms(dest_obj, dest_fx_idx)

	if src_parm_t and dest_parm_t and #src_parm_t == #dest_parm_t then
	math.randomseed(math.floor(r.time_precise())*1000) -- math.floor() because the seeding number musr be integer
		for i = 1, #src_parm_t do -- compare the entire parm list
		local src, dest = src_parm_t[r], dest_parm_t[r]
			if src ~= 'Wet' and src ~= 'Bypass' and src ~= 'Delta' then -- not stock parameters
				if src ~= dest then return false
			end
		end
	--[[ OR
	local r, r_init
		for i = 1, 3 do	-- 3 random comparisons
			if #src_parm_t > 4 then -- if 4 or less the loop might get stuck when none of the 'until' conditions is met, so math.random must be allowed to alternate between at least two values other than the 3 stock params
				repeat
				r = math.random(1,#src_parm_t)
				local parm = src_parm_t[r]
				until r ~= r_init and parm ~= 'Wet' and parm ~= 'Bypass' and parm ~= 'Delta'
			r_init = r
			else
			r = math.random(1,#src_parm_t)
			end
		local src, dest = src_parm_t[r], dest_parm_t[r]
			if src ~= 'Wet' and src ~= 'Bypass' and src ~= 'Delta' then -- not stock parameters
				if src ~= dest then return false
			end
		end
	--]]
	return true
	end

end


function Check_FX_In_Focused_FX_Chain(take, track, fx_idx) -- whether any plugin contains presets
-- take is evaluated first because if take is true track is true as well
-- fx_idx is used to condition targeting input/Monitoring fx since their index format is different
local GetCount, GetPresetIndex, GetFXName = table.unpack(take and {r.TakeFX_GetCount, r.TakeFX_GetPresetIndex, r.TakeFX_GetFXName} or track and {fx_idx < 16777216 and r.TrackFX_GetCount or r.TrackFX_GetRecCount, r.TrackFX_GetPresetIndex, r.TrackFX_GetFXName} or {})
local obj = take or track
local fx_cnt = GetCount(obj)
local fx_list, valid_fx_cnt, _129 = '', 0
	if obj then
		for idx = 0, fx_cnt-1 do
		local idx = fx_idx < 16777216 and idx or 16777216+idx -- or 0x1000000+idx, input/monitoring fx
		local retval, pres_cnt = GetPresetIndex(obj, idx)
		_129 = pres_cnt > 128 and 1 or _129 -- verifying if any of the plugins contains more than 128 presets
			if pres_cnt > 0 then -- retval > -1 // only names of pluguns with presets are stored
			valid_fx_cnt = valid_fx_cnt+1
			local ret, name = GetFXName(obj, idx, '')
				if not fx_list:match(Esc(name)) then -- only collect unique names excluding duplicates, i.e. one instance per plugin
				fx_list = fx_list..'\n'..name
				end
			end
		end
	end

	if fx_cnt > 0 and #fx_list == 0 then
	r.MB('No presets in FX of the focused FX chain.', 'ERROR', 0)
	end
return fx_list:sub(2), valid_fx_cnt, _129 -- removing leading line break from fx_list
end


function Check_FX_Selected_In_FX_Browser() -- whether any is selected and whether at least 1 contains presets using temporary track

r.PreventUIRefresh(1)

r.InsertTrackAtIndex(r.GetNumTracks(), false) -- wantDefaults false // insert new track at end of track list and hide it
local temp_track = r.GetTrack(0,r.CountTracks(0)-1)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINMIXER', 0)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINTCP', 0)
r.TrackFX_AddByName(temp_track, 'FXADD:', false, -1)
local fx_cnt = r.TrackFX_GetCount(temp_track)
local fx_list, valid_fx_cnt, _129 = '', 0

	for i = 0, fx_cnt-1 do
	local retval, pres_cnt = r.TrackFX_GetPresetIndex(temp_track, i)
	valid_fx_cnt = pres_cnt > 0 and valid_fx_cnt+1 or valid_fx_cnt
	_129 = pres_cnt > 128 and 1 or _129 -- verifying if any of the plugins contains more than 128 presets
		if r.TrackFX_SetPresetByIndex(temp_track, i, 0) -- preset idx 0 -- returns true on success // check if there're presets // admissible on a temporary track but not in the actual focused FX chain which will mess up preset selection
	--	local retval, pres_cnt = r.TrackFX_GetPresetIndex(temp_track, i) -- preset count could be used as a condition // safe, suitable for all cases
		then
		fx_list = fx_list..'\n'..select(2,r.TrackFX_GetFXName(temp_track, i, ''))
		end
	end

r.DeleteTrack(temp_track)
r.PreventUIRefresh(-1)

local err = fx_cnt == 0 and 'No FX have been selected in the FX browser.' or fx_cnt > 0 and #fx_list == 0 and 'No presets in selected FX'
	if err then
	r.MB(err, 'ERROR', 0)
	end

return fx_list:sub(2), valid_fx_cnt, _129 -- removing leading line break from fx_list

end


-- TWO ABOVE COMBINED
function Check_Selected_FX(take, track, fx_idx) -- presence of arguments makes the function target the focused FX chain, otherwise selected plugins in the open FX browser are targeted, uses temporary track // -- relies on GetObjChunk() and Retrieve_Orig_Plugin_Names() see below

r.PreventUIRefresh(1)
r.InsertTrackAtIndex(r.GetNumTracks(), false) -- insert new track at end of track list and hide it; action 40702 creates undo point
local temp_track = r.GetTrack(0,r.CountTracks(0)-1)
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINMIXER', 0) -- hide in Mixer
r.SetMediaTrackInfo_Value(temp_track, 'B_SHOWINTCP', 0) -- hide in Arrange

-- Copy FX from the source track/take/FX browser to the temporary track

	if fx_idx then -- only copy if arguments are provided, without arguments instantiated from FX browser below
	-- take is evaluated first because if take is true track is true as well
	local GetFXCount, CopyToTrack = table.unpack(take and {r.TakeFX_GetCount, r.TakeFX_CopyToTrack} or track and {fx_idx < 16777216 and r.TrackFX_GetCount or r.TrackFX_GetRecCount, r.TrackFX_CopyToTrack} or {})
	local obj = take or track
		for idx = 0, GetFXCount(obj)-1 do
		local src_idx = fx_idx < 16777216 and idx or 16777216+idx -- or 0x1000000+idx, input/monitoring fx
		CopyToTrack(obj, src_idx, temp_track, idx, false) -- is_move false // when copying FX envelopes don't follow, only when moving
		end
	else
	r.TrackFX_AddByName(temp_track, 'FXADD:', false, -1) -- recFX false, instantiate -1: specify a negative value for instantiate to always create a new effect
	end

local ret, chunk = GetObjChunk(temp_track)
local plugin_name_t = chunk and #chunk > 0 and Retrieve_Orig_Plugin_Names(chunk) -- to pevent error because when ret == 'err_mess' chunk isn't returned by GetObjChunk()
local fx_cnt = r.TrackFX_GetCount(temp_track)
local fx_list, valid_fx_cnt, _129 = '', 0

	-- Collect FX instances names, excluding duplicate plugin instances
	for fx_idx = 0, fx_cnt-1 do
	local retval, pres_cnt = r.TrackFX_GetPresetIndex(temp_track, fx_idx)
		if pres_cnt > 0 then
		local ret, fx_name = r.TrackFX_GetFXName(temp_track, fx_idx, '')
		local fx_name = (not plugin_name_t or plugin_name_t[fx_idx+1]) and '\n'..fx_name or '' -- if original names weren't retrieved from the chunk and so duplicates weren't filtered inside Retrieve_Orig_Plugin_Names() use all displayed names, it were retrieved only use names of unique instances, duplicates will have been set to nil in the plugin_name_t table
		valid_fx_cnt = #fx_name > 0 and valid_fx_cnt+1 or valid_fx_cnt -- counting plugins with presets only honoring unique instances
		_129 = #fx_name > 0 and pres_cnt > 128 and 1 or _129 -- verifying if any of the unique instances contains more than 128 presets
		fx_list = fx_list..fx_name
		end
	end

r.DeleteTrack(temp_track)
r.PreventUIRefresh(-1)

local err = not fx_idx and (fx_cnt == 0 and 'No FX have been selected in the FX browser.' or fx_cnt > 0 and #fx_list == 0 and 'No presets in selected FX.')
local err = not err and fx_idx and fx_cnt > 0 and #fx_list == 0 and 'No presets in FX of the focused FX chain.' or err
	if err then
	r.MB(err, 'ERROR', 0)
	end

return fx_list:sub(2), valid_fx_cnt, _129 -- removing leading line break from fx_list

end


function Retrieve_Orig_Plugin_Names(chunk) -- relies on GetObjChunk()
-- for non-JSFX plugins get name currently applied in the FX browser
-- which may differ from plugin original name
local t = {}
	for line in chunk:gmatch('[^\n\r]+') do
	local name = line and ( line:match('<.-"([ACDLPSTUVX23i:]+ .-)"') -- AU,CLAP,DX,LV2,VST
	or line:match('<JS "(.-)" ') or line:match('<JS (.-) ') -- spaces or no spaces in the path
	or line:match('<VIDEO_EFFECT "(Video processor)"') )
		if name then
			if line:match('<JS') then -- JSFX bank header will include the name from 'desc:' tag inside of the JSFX file and the file path or only the file path if the name couldn't be retrived
			local path = r.GetResourcePath()
			local sep = path:match('[\\/]')
				if name:match('<Project>') then -- JSFX local to the project only if project is saved; for the local JSFX to load presets its file in the /presets folder must be named js-_Project__(JSFX file name).ini
				local retval, proj_path = r.EnumProjects(-1) -- -1 active project
				local proj_path = proj_path:match('.+[\\/]') -- excluding the file name // OR proj_path:match('.+'..Esc(r.GetProjectName(0, '')))
				local file_name = name:match('<Project>/(.+)')
				local path = proj_path..'Effects'..sep..file_name -- proj_path includes the separator
					if r.file_exists(path) then
						for line in io.lines(path) do
						local name_local = line:match('^desc:') and line:match('desc:%s*(.+)') -- ignoring commented out 'desc:' tags if any // isolate name in this routine so that in case the actual name isn't found in the JSFX file the file name fetched from the chunk will be used
							if name_local then name = 'JS '..name_local..' ['..path..']' break end
						end
				--	else name = '' -- if wishing to exclude JSFX which has been deleted during the session without updating the FX browser or the FX chain // should be evaluated in Collect_FX_Preset_Names() with string length count
					end
				elseif r.file_exists(path..sep..'Effects'..sep..name) then -- JSFX at the regular location
				-- if JSFX name was changed in the plugin file but REAPER wasn't re-started
				-- or FX browser wasn't refreshed with F5, reaper-jsfx.ini will still contain the old name
					for line in io.lines(path..sep..'reaper-jsfx.ini') do
					local name_local = line and line:match(Esc(name)) and line:match('NAME.+ "(.+)"') -- name_local to prevent clash with name
						if name_local then name = name_local break end
					end
			--	else name = '' -- if wishing to exclude JSFX which has been deleted during the session without updating the FX browser or the FX chain // should be evaluated in Collect_FX_Preset_Names() with string length count
				end
			end
		t[#t+1] = name -- the table indexing must match FX indices in the FX chain so all must be collected with no skips
		end
	end
-- disable duplicate entries, will be evaluated in the preset extraction routine in Check_Selected_FX() and in Collect_FX_Preset_Names()
	for k1, v1 in pairs(t) do
		for k2, v2 in pairs(t) do -- pairs because the table will contain nils
			if v1 == v2 and k1 ~= k2 then
			t[k2] = nil -- keeping indices intact so that correspondence with fx indices in the FX chain is maintained
			end
		end
	end
return t
end



function Re_Store_Float_FX_Wnds(obj, t, idx)
-- idx comes from FX loop and serves as a storage routine condition
local tr = r.ValidatePtr(obj, 'MediaTrack*')
local take = r.ValidatePtr(obj, 'MediaItem_Take*')
	if idx then
	GetFloatingWindow = take and r.TakeFX_GetFloatingWindow or tr and r.TrackFX_GetFloatingWindow
	local t = {}
		if GetFloatingWindow(obj, idx) then
		t[#t+1] = idx
		end
	return t
	elseif t then
		for _, idx in ipairs(t) do
		FX_Show(obj, idx, 3) -- 3 (show floating)
		end
	end
end
-- USAGE:
-- local t = {}
-- for i = 0, fx_cnt-1 do -- store
-- t = Re_Store_Float_FX_Wnds(obj, t, i)
-- end
-- Re_Store_Float_FX_Wnds(obj,t) -- restore



function FX_Has_Envelopes(take, tr, fx_idx) -- or (obj, fx_idx) and the uncomment the next lines
--local tr = r.ValidatePtr(env, 'MediaTrack*')
--local take = r.ValidatePtr(env, 'MediaItem_Take*')
local obj = take or tr
local GetNumParams, GetFXEnvelope = table.unpack(take and
{r.TakeFX_GetNumParams,r.TakeFX_GetEnvelope}
or tr and {r.TrackFX_GetNumParams, r.GetFXEnvelope})
	for i = 0, GetNumParams(obj,fx_idx)-1 do
	local env = GetFXEnvelope(obj, fx_idx, i, false) -- create false
		if env and (r.ValidatePtr(env, 'TrackEnvelope*')
		or r.CountEnvelopePoints(env) > 0)
		then return true
		end
	end
end



function TrackFX_GetRecChainVisible1(tr)
-- when fx is both selected in the fx chain and its is UI floating
-- in track main and take fx chains such fx is determined
-- with TrackFX_GetChainVisible() but it doesn't support input and monitoring fx chains
	if not tr or not r.ValidatePtr(tr, 'MediaTrack*') then return end
	if tr then
	local t = {}
	local CountFX = r.TrackFX_GetRecCount
	r.PreventUIRefresh(1)
		for i = 0, CountFX(tr)-1 do -- close and store all floating windows
		local idx = 0x1000000+i
			if r.TrackFX_GetFloatingWindow(tr, idx) then
			r.TrackFX_SetOpen(tr, idx, false) -- open false // close floating window
			-- OR
			-- r.TrackFX_Show(tr, idx, 2) -- showFlag 2 - close floating window
			t[#t+1] = idx
			end
		end
	local open_fx_idx -- get fx whose UI is open in FX chain
		for i = 0, CountFX(tr)-1 do
		local idx = i+0x1000000
			if r.TrackFX_GetOpen(tr, idx) then 
			open_fx_idx = idx break end
		end
	-- restore floating windows	// z-order and focused window won't be restored, the foreground will be occupied but the window of the fx selected in the fx chain if its window was floating, otherwise the windows are loaded in the fx order
		for _, fx_idx in ipairs(t) do
		r.TrackFX_Show(tr, fx_idx, 3) -- showFlag 3 - open in a floating window
		end
	r.PreventUIRefresh(-1)
	return open_fx_idx
	end
end


function TrackFX_GetRecChainVisible2(tr) -- only returns fx chain window status
	if not tr or not r.ValidatePtr(tr, 'MediaTrack*') then return end
r.PreventUIRefresh(1)
local chain_open, shown_fx
	for i = 0, r.TrackFX_GetRecCount(tr)-1 do
	local i = i+0x1000000
		if r.TrackFX_GetOpen(tr, i)
		and not r.TrackFX_GetFloatingWindow(tr, i)
		then chain_open = true
		elseif r.TrackFX_GetOpen(tr, i) then
		shown_fx = i
		end
	end
	if not chain_open then -- retry in case the chain is open but empty or the fx open in the chain but also floating which in itself isn't reliable because it returns true even when the chain is closed	
	r.TrackFX_AddByName(tr, 'ReaGate', true, -1000) -- recFX true, instantiate -1000 (1st slot) // insert temporary stock fx to evaluate against it, its UI will be automatically shown in the chain
	local idx = 0x1000000 -- 1st slot
	chain_open = r.TrackFX_GetOpen(tr, idx)
	r.TrackFX_Delete(tr, idx)
	local restore = shown_fx and r.TrackFX_SetOpen(tr, shown_fx, true) -- open true // restore // will bring the fx floating window, if any, to the fore
	end
r.PreventUIRefresh(-1)
return chain_open
end



function Re_Store_FX_Windows_Visibility(t)
-- restores positions if screenset wasn't changed
-- doesn't restore focus and z-order
-- take fx windows are linked to track to be able to ignore them when the track is hidden
-- to restore positions and focus use Re_Store_Windows_Props_By_Names()
-- see implementation in Restore FX windows after screenset change.lua
	if not t then
	local t = {}
		for i = -1, r.CountTracks(0)-1 do
		local tr = r.GetTrack(0,i) or r.GetMasterTrack(0)
		t[tr] = {trackfx = {}, takefx = {}}
			for i = 0, r.TrackFX_GetCount(tr)-1 do
				if r.TrackFX_GetOpen(tr, i) then -- is open in the FX chain window or a floating window
				local len = #t[tr].trackfx+1
				-- storing floating status and fx chain UI visibility status even if the UI is floating
				t[tr].trackfx[len] = {idx=i, float=r.TrackFX_GetFloatingWindow(tr, i), ui=r.TrackFX_GetChainVisible(tr)==i} 
				end
			end
			for i = 0, r.TrackFX_GetRecCount(tr)-1 do
			local i = i+0x1000000
			local open_fx_idx = Get_InputMonFX_Chain_Truely_SelectedFX(tr)
				if r.TrackFX_GetOpen(tr, i) then -- is open in the FX chain window or a floating window
				local len = #t[tr].trackfx+1
				t[tr].trackfx[len] = {idx=i, float=r.TrackFX_GetFloatingWindow(tr, i), ui=open_fx_idx==i} 
				end
			end
			for i = 0, r.GetTrackNumMediaItems(tr)-1 do
			local itm = r.GetTrackMediaItem(tr,i)
			t[tr].takefx[itm] = {}
				for i = 0, r.CountTakes(itm)-1 do
				local take = r.GetTake(itm, i)
				t[tr].takefx[itm][take] = {}				
					for i = 0, r.TakeFX_GetCount(take)-1 do					
						if r.TakeFX_GetOpen(take, i) then -- is open in the FX chain window or a floating window
						local len = #t[tr].takefx[itm][take]+1
						t[tr].takefx[itm][take][len] = {idx=i, float=r.TakeFX_GetFloatingWindow(take, i), ui=r.TakeFX_GetChainVisible(take)==i}						
						end
					end				
				end
			end
		end
	return t
	elseif t then
		for tr in pairs(t) do
	--[[script specific
		local mixer_vis = r.GetToggleCommandStateEx(0, 40078) == 1 -- View: Toggle mixer visible
		local master_vis_flag = r.GetMasterTrackVisibility()
		local master_vis_TCP, master_vis_MCP = master_vis_flag&1 == 1, master_vis_flag&2 == 2
		local is_master_tr = tr == r.GetMasterTrack(0)
	--]]
			if r.ValidatePtr(tr, 'MediaTrack*')
			--[[ script specific
			and (not mixer_vis and (is_master_tr and master_vis_TCP or r.IsTrackVisible(tr, false)) -- mixer false // visible in the TCP // IsTrackVisible DOESN'T APPLY TO MASTER TRACK, always returns true
			or mixer_vis and (is_master_tr and master_vis_MCP or r.IsTrackVisible(tr, true)) ) -- mixer true // visible in the MCP // IsTrackVisible DOESN'T APPLY TO MASTER TRACK, always returns true
			or IGNORE_VISIBILITY
			--]]
			then
				for _, fx_data in ipairs(t[tr].trackfx) do
					if fx_data.ui then r.TrackFX_Show(tr, fx_data.idx, 1) end -- showFlag 1 (open FX chain with fx ui shown) // OR r.TrackFX_SetOpen(tr, fx_idx, true) -- open true
					if fx_data.float then r.TrackFX_Show(tr, fx_data.idx, 3) end -- showFlag 3 (open in a floating window)				
				end
				for itm, takes_t in pairs(t[tr].takefx) do
					for take, fx_t in pairs(takes_t) do
						for _, fx_data in ipairs(fx_t) do
							if fx_data.ui then r.TakeFX_Show(take, fx_data.idx, 1) end -- showFlag 1 (open FX chain with fx ui shown) // OR r.TakeFX_SetOpen(take, fx_data.idx, true) -- open true
							if fx_data.float then r.TakeFX_Show(take, fx_data.idx, 3) end -- showFlag 3 (open in a floating window)
						end
					end
				end
			end
		end	
end

end



--================================================  F X  E N D  ==============================================


--================================ I T E M S ==================================

local Get_Item_By_Take_GUID(take_GUID)
return r.GetMediaItemTake_Item(r.GetMediaItemTakeByGUID(0, take_GUID))
end


-- temporary disable options when manipulating items in the background, edit curs pos in these cases may need storage and restoration as well if Preferences -> Editing Behavor -> Move edit cursor when pasting/insering media is enabled
function Re_Store_Options_Togg_States(state1, state2) -- to disable and store run without the args to be on the safe side
	if not state1 and not state2 then
	local state1 = r.GetToggleCommandStateEx(0,40070) == 1 -- Options: Move envelope points with media items
		if state1 then r.Main_OnCommand(40070,0) end -- disable
	local state2 = r.GetToggleCommandStateEx(0,41117) == 1 -- Options: Trim content behind media items when editing
		if state2 then r.Main_OnCommand(41117,0) end -- disable
	return state1, state2
	else
	local re_enable = state1 and r.Main_OnCommand(40070,0)
	local re_enable = state2 and r.Main_OnCommand(41117,0)
	end
end
-- USE:
-- state1, state2 = Re_Store_Options_Togg_States()
-- DO STUFF
-- Re_Store_Options_Togg_States(state1, state2)



local x, y = r.GetMousePosition()
local item = r.GetItemFromPoint(x, y, true) -- allow_locked is true

function Toggle_Item_Selection(item) -- under mouse
--local item = r.GetMediaItem(0,0)
r.SetMediaItemSelected(item, not r.IsMediaItemSelected(item)) -- select if not selected and vice versa; doesn't affect the rest
end


function Display_Item_Name(item) -- for monitoring
r.ShowConsoleMsg('NAME = '..({r.GetSetMediaItemTakeInfo_String(r.GetActiveTake(itm), 'P_NAME', '', false)})[2])
end


function Rename_Item_Take_Src_File(item, ACT)

local take = r.GetActiveTake(item)
local old_fn = r.GetMediaSourceFileName(r.GetMediaItemTake_Source(take), '') -- extract file path and name

local f_path, f_name = old_fn:match('^(.+[\\/])([^\\/]+)$') -- isolate file path and name

local f_name_new = '...' -- SOME STRING OR MODIFIED f_name
local new_fn = f_path..f_name_new

ACT(40289) -- Item: Unselect all items
r.SetMediaItemSelected(item, true)
ACT(40440) -- Item: Set selected media temporarily offline
os.rename(old_fn, new_fn) -- apply a new name
local new_src = r.PCM_Source_CreateFromFile(new_fn)
r.SetMediaItemTake_Source(take, new_src) -- assign the renamed file as a source
ACT(40439) -- Item: Set selected media online
local ok, message = #r.GetPeakFileName(f_path..f_name, '') > 0 and os.remove(f_path..f_name..'.reapeaks') -- remove old file name peak file

end


function Rename_Item_Take_Src_File(take)
-- Thanks to cfillion and MPL
-- https://forum.cockos.com/showthread.php?t=211250 file rename
-- https://forum.cockos.com/showthread.php?p=1889202 file rename

local old_src = r.GetMediaItemTake_Source(take)
local old_src = r.GetMediaSourceParent(src) or src -- in case the item is a section or a reversed source
local old_fn = r.GetMediaSourceFileName(old_src, "") -- extract rendered file path and name
--local rend_file_ext = old_fn:match("%.%w+") -- extract rendered file extension
--local rend_file_path = old_fn:match("^(.+[\\/])") -- extract rendered file path
local rend_file_path, rend_file_ext = old_fn:match("^(.+[\\/]).+(%.%w)$") -- extract rendered file index and extension

-- Concatenate a new file name and rename the rendered fil
local f_name_new = '...' -- CONCATENATE NAME
local new_fn = f_path..f_name_new

-- Rename source file and reapply

r.Main_OnCommand(40440,0) -- Item: Set selected media temporarily offline
os.rename(old_fn, new_fn) -- apply a new name
local new_src = r.PCM_Source_CreateFromFile(new_fn)
r.SetMediaItemTake_Source(take, new_src) -- assign the renamed file as a source
r.Main_OnCommand(40439,0) -- Item: Set selected media online
os.remove(old_fn..'.reapeaks') -- remove old file name peak file

end


function Delete_Take_Src(take)
ACT(40440) -- Item: Set selected media temporarily offline // if source is removed before take is removed
-- Thanks to cfillion and MPL
-- https://forum.cockos.com/showthread.php?t=211250
-- https://forum.cockos.com/showthread.php?p=1889202
local src = r.GetMediaItemTake_Source(take)
local src = r.GetMediaSourceParent(src) or src -- in case the item is a section or a reversed source
local file_name = r.GetMediaSourceFileName(src, '')
os.remove(file_name)
os.remove(file_name..'.reapeaks')
ACT(40439) -- Item: Set selected media online // if source is removed before take is removed
end



function Count_Track_Sel_Items1(tr)

local itm_cnt = r.CountTrackMediaItems(tr)
	if itm_cnt > 0 then
	local t = {}
		for i = 0, itm_cnt-1 do
		local item = r.GetTrackMediaItem(tr,i)
			if r.IsMediaItemSelected(item) then t[#t+1] = item end
		end
	end

return itm_cnt > 0, #t

end


local function Count_Track_Sel_Items2(tr, tr_itm_cnt)
local counter = 0
	for i = 0, tr_itm_cnt-1 do
	local item = r.GetTrackMediaItem(tr, i)
		if r.IsMediaItemSelected(item) then counter = counter+1 end
	end
return counter
end


function Get_Folder_Rightmost_Item_RightEdge(tr)

local is_folder = ({r.GetTrackState(tr)})[2]&1 == 1
local par_tr_depth = r.GetTrackDepth(tr)
local idx = r.CSurf_TrackToID(tr, false)
local rightmost_itm_r_edge = 0
	if is_folder then
		for i = idx, r.CountTracks(0)-1 do
		local tr = r.GetTrack(0,i) -- next track after folder parent/1st child track
		local tr_depth = r.GetTrackDepth(tr)
			if tr_depth <= par_tr_depth or tr_depth == 0 then break end -- either the same or higher nested level within higher level folder or a regular track (outside of the folder)
		local tr_item_cnt = r.CountTrackMediaItems(tr)
			if tr_item_cnt > 0 then
			local tr_last_itm = r.GetTrackMediaItem(tr, r.CountTrackMediaItems(tr)-1)
			local tr_last_itm_r_edge = r.GetMediaItemInfo_Value(tr_last_itm, 'D_POSITION') + r.GetMediaItemInfo_Value(tr_last_itm, 'D_LENGTH')
			rightmost_itm_r_edge = tr_last_itm_r_edge > rightmost_itm_r_edge and tr_last_itm_r_edge or rightmost_itm_r_edge
			end
		end
	end

return rightmost_itm_r_edge

end


function Generate_Consistent_IID_Sequence(itm) -- for items overlapping the one passed in the arg, included // uses chunk functions
-- same as using native actions:
--ACT(40068) -- Item lanes: Move item up one lane (when showing overlapping items in lanes)
--ACT(40107) -- Item lanes: Move item down one lane (when showing overlapping items in lanes)
-- only works in builds up until 6.53, since then the behavior drastically changed
-- https://forum.cockos.com/showthread.php?t=267390

	if not itm then return end

local tr = r.GetMediaItemTrack(itm)
local is_tr_sel = r.IsTrackSelected(tr)

	if not is_tr_sel then r.SetTrackSelected(tr, true) end -- selected true

	for i = 1, 50 do -- expand track height so overlapping item heights differ, i.e. none is collapsed
	-- may affect other selected tracks, but all are restored later
	r.Main_OnCommand(41325, 0) -- View: Increase selected track heights
	end

local get_item_props = r.GetMediaItemInfo_Value
local start = get_item_props(itm, 'D_POSITION')
local length = get_item_props(itm, 'D_LENGTH')
local t = {}
	for i = 0, r.GetTrackNumMediaItems(tr)-1 do
	local itm = r.GetTrackMediaItem(tr, i)
	local st = get_item_props(itm, 'D_POSITION')
	local len = get_item_props(itm, 'D_LENGTH')
	local I_LASTY = get_item_props(itm, 'I_LASTY')
	local overlap = st < start+length and st+len > start
		if overlap then -- overlaps item passed in the argument
		t[#t+1] = {itm = itm, I_LASTY = I_LASTY}
		elseif not overlap and #t > 0 then break -- past overlapping items cluster
		end
	end

	table.sort(t, function(a, b) return a.I_LASTY < b.I_LASTY end) -- sort by height

	for k, v in ipairs(t) do -- assign IIDs according to the height
	local itm = v.itm
	local ret, chunk = GetObjChunk2(itm)
	local chunk = not chunk:match('\nIID %d+') and chunk:gsub('IGUID .-\n', '%0IID '..(k-1)..'\n') or chunk:gsub('\nIID %d+', '\nIID '..k-1) -- -1 because IID sequence is 0 based white table index is 1 based
	SetObjChunk2(itm, chunk)
	end

	for i = 1, 50 do -- restore original track height
	r.Main_OnCommand(41326, 0) -- View: Decrease selected track heights
	end

	if not is_tr_sel then r.SetTrackSelected(tr, false) end -- selected true // deselect item track if it wasn't selected originally

end


function Are_There_Overlapping_Itms(sel_itm) -- find if there're items overlapping the selected one // returns boolean and a table
local get_item_props = r.GetMediaItemInfo_Value
local t = {}
local start = get_item_props(sel_itm, 'D_POSITION')
local length = get_item_props(sel_itm, 'D_LENGTH')
local tr = r.GetMediaItemTrack(sel_itm)
	for i = 0, r.GetTrackNumMediaItems(tr)-1 do
	local itm = r.GetTrackMediaItem(tr, i)
	local st = get_item_props(itm, 'D_POSITION')
	local len = get_item_props(itm, 'D_LENGTH')
		if st < start+length and st+len > start then -- covers both full and partial overlap
	--	return true -- or any other valid data type: 1, '', {} -- if table isn't needed
		local ret, chunk = GetObjChunk2(itm)
			if ret == 'err_mess' then Err_mess('data in one of the items') return r.defer(function() do return end end)
			else
			local chunk = not chunk:match('IID %d+') and chunk:gsub('IGUID .-\n', '%0IID 0\n') or chunk -- replace nil IID with 0 so the sequence can be used for table sorting
			t[#t+1] = chunk -- // or t[#t+1] = itm -- depending on the design
			end
		end
	end

return #t > 0, t

end


function Are_Itms_Overlapping(itm, want_count) -- find if there're items overlapping one passed as the argument
-- if want_count arg is true returns count of overlapping items less the one passed as itm arg or returns false
-- otherwise returns true if there're at least 1 overlapping item
local get_item_props = r.GetMediaItemInfo_Value
local tr = r.GetMediaItemTrack(itm)
local start = get_item_props(itm, 'D_POSITION')
local length = get_item_props(itm, 'D_LENGTH')
local cnt = 0
	for i = 0, r.GetTrackNumMediaItems(tr)-1 do
	local tr_itm = r.GetTrackMediaItem(tr, i)
	local st = get_item_props(tr_itm, 'D_POSITION')
	local len = get_item_props(tr_itm, 'D_LENGTH')
		if tr_itm ~= itm and st < start+length and st+len > start then
		cnt = cnt + 1
			if not want_count then return true end -- if at least one overlapping
		end
	end
return cnt > 0 and cnt
end


function Are_Two_Items_Overlapping(itm1, itm2)
	if not itm1 or not itm2 then return end -- false
local get_item_props = r.GetMediaItemInfo_Value
local get_track = r.GetMediaItemTrack
local st1 = get_item_props(itm1, 'D_POSITION')
local len1 = get_item_props(itm1, 'D_LENGTH')
local st2 = get_item_props(itm2, 'D_POSITION')
local len2 = get_item_props(itm2, 'D_LENGTH')
	return st2 < st1+len1 and st2+len2 > st1 and get_track(itm1) == get_track(itm2) -- true
end


function Count_Selected_Overlapping_Itms(itm) -- for 'explode' routine
-- including the item in the argument
local get_item_props = r.GetMediaItemInfo_Value
local start = get_item_props(itm, 'D_POSITION')
local length = get_item_props(itm, 'D_LENGTH')
local tr = r.GetMediaItemTrack(itm)
local selected_cntr = 0
	for i = 0, r.GetTrackNumMediaItems(tr)-1 do
	local tr_itm = r.GetTrackMediaItem(tr, i)
	local st = get_item_props(tr_itm, 'D_POSITION')
	local len = get_item_props(tr_itm, 'D_LENGTH')
	local itms_overlapping = st < start+length and st+len > start
		if itms_overlapping and r.IsMediaItemSelected(tr_itm) then
		selected_cntr = selected_cntr + 1
		end
	end
return selected_cntr
end


function Get_Outermost_Overlapping_Item(are_lanes_collapsed, tr, start, length) -- for 'explode' and 'crop' when item lanes are collapsed
local overlap_itm_cnt, outermost_itm = 0
	if are_lanes_collapsed then	-- get the outermost item to be able to crop everything to it if it happens to be selected
		for i = 0, r.GetTrackNumMediaItems(tr)-1 do -- tr is sel_itm track
		local tr_itm = r.GetTrackMediaItem(tr, i)
		local st = get_item_props(tr_itm, 'D_POSITION')
		local len = get_item_props(tr_itm, 'D_LENGTH')
		local overlap = st < start+length and st+len > start -- start & length are sel_itm properties
			if overlap then
			outermost_itm = tr_itm
			overlap_itm_cnt = overlap_itm_cnt+1
			end
		end
	end
return outermost_itm, outermost_itm and r.IsMediaItemSelected(outermost_itm), overlap_itm_cnt > 1 and overlap_itm_cnt-1 or 0 -- accounting for the item against which evaluation is being done to exclude it
end


function Overlapping_Itms_Props(itm, count_overlap, count_sel)
-- combines Are_Itms_Overlapping() and Count_Selected_Overlapping_Itms()
-- count_overlap and count_sel are booleans, return vals are integers
-- if both count_overlap and count_sel are true return val is boolean
-- indicating whether all overlapping items are selected
	if not count_overlap and not count_sel then return end
--local count_overlap = not count_sel
--local count_sel = not count_overlap
local get_item_props = r.GetMediaItemInfo_Value
local start = get_item_props(itm, 'D_POSITION')
local length = get_item_props(itm, 'D_LENGTH')
local tr = r.GetMediaItemTrack(itm)
local cntr = 0 -- excluding the item in the argument
local selected_cntr = 0 -- including the item in the argument
	for i = 0, r.GetTrackNumMediaItems(tr)-1 do
	local tr_itm = r.GetTrackMediaItem(tr, i)
	local st = get_item_props(tr_itm, 'D_POSITION')
	local len = get_item_props(tr_itm, 'D_LENGTH')
	local itms_overlapping = st < start+length and st+len > start
		if count_overlap and itms_overlapping and tr_itm ~= itm then
		cntr = cntr+1
		end
		if count_sel and itms_overlapping and r.IsMediaItemSelected(tr_itm) then
		selected_cntr = selected_cntr+1
		end
	end
return count_overlap and count_sel and cntr > 0 and cntr+1 == selected_cntr
or count_overlap and not count_sel and cntr
or count_sel and not count_overlap and selected_cntr
end


function Are_Itms_Overlapping_Selected_Collapsed(t) -- t is an array storing selected items, optional
-- returns 5 boolean values:
-- true if there's at least one item overlapping each of those stored in the table or currently selected
-- true if there're no non-selected items among items overlapping each of those stored in the table or currently selected
-- first 2 return values must both be true to conclude that in all targeted clusters of overlapping items all items are selected
-- true if there're no items overlapping any of those stored in the table or currently selected
-- true if overlapping and non-overlapping items are all selected
-- true if selected item lanes are collapsed excluding non-overlapping items

local is_build_6_54_onward = tonumber(r.GetAppVersion():match('(.+)/')) >= 6.54
local lanes_collapsed_cnt = 0

local get_item_props = r.GetMediaItemInfo_Value
local overlap_cnt, non_selected = 0, 0
local cnt = t and #t or r.CountSelectedMediaItems(0)
	for i = 1, cnt do
	local sel_itm = t and t[i] or r.GetSelectedMediaItem(0, i-1)
	local start = get_item_props(sel_itm, 'D_POSITION')
	local length = get_item_props(sel_itm, 'D_LENGTH')
	local tr = r.GetMediaItemTrack(sel_itm)
	local prev_itm = r.GetSelectedMediaItem(0, i-2)
	local prev_itm_tr = t and t[i-1] and r.GetMediaItemTrack(t[i-1]) or prev_itm and r.GetMediaItemTrack(prev_itm)
	local overlap = true -- condition count of overlapping items below
	local I_LASTY_init = 0
		for i = 0, r.GetTrackNumMediaItems(tr)-1 do
		local tr_itm = r.GetTrackMediaItem(tr, i)
		local st = get_item_props(tr_itm, 'D_POSITION')
		local len = get_item_props(tr_itm, 'D_LENGTH')
		local I_LASTY = get_item_props(tr_itm, 'I_LASTY')
		local itms_overlapping = st < start+length and st+len > start
			if overlap and tr_itm ~= sel_itm and itms_overlapping then -- covers both full and partial overlap, excluding the actual item being evaluated
			overlap_cnt = overlap_cnt + 1 -- for each selected only 1 will be counted
			overlap = false -- one is enough; all next cycles will be ignored
			end
			if itms_overlapping then
			non_selected = not r.IsMediaItemSelected(tr_itm) and non_selected + 1 or non_selected -- accurate counting of selected items is problematic so it's easier to count non-selected
			I_LASTY_init = tr_itm ~= sel_itm and (not is_build_6_54_onward and (I_LASTY > 15 and I_LASTY or I_LASTY_init)) or I_LASTY_init -- seek the greatest, excluding non-overlapping items with tr_itm ~= sel_itm because otherwise they too satisfy itms_overlapping boolean
			end
		end
	lanes_collapsed_cnt = I_LASTY_init and I_LASTY_init <= 15 and lanes_collapsed_cnt+1 or lanes_collapsed_cnt -- if no greater than 15 is found then register
	end


local all_overlap, all_sel, all_non_overlap, mixed = overlap_cnt == cnt, non_selected == 0, overlap_cnt == 0, overlap_cnt ~= 0 and overlap_cnt < cnt and non_selected == 0 -- all_non_overlap return value is required because overlap_cnt == cnt being false doesn't necessarily mean that there're no items overlapping the selected, the selection could be mixed, likewise overlap_cnt > 0 for the same reason doesn't always mean that all items are being overlapped

local lanes_collapsed = not is_build_6_54_onward and lanes_collapsed_cnt > 0  -- relevant when overlapping item lanes are collapsed at certain TCP height or only 1 lane is set in Preferences -> Appearance in builds prior to 6.54
--or is_build_6_54_onward and Check_reaper_ini('itemoverlap_offspct', '0') -- or 'Offset by' is 0 at Preferences -> Appearance -> Media Item Positioning in builds 6.54 onward // doesn't make sense as overlapping items feature doesn't work since 6.54

return all_overlap, all_sel, all_non_overlap, mixed, lanes_collapsed -- the last value will be used to offset all_sel because in collapsed lanes selection of all is allowed by design

end


function Are_Overlapping_Itm_Lanes_Collapsed(...)
-- arguments must be either tr, itm OR tr, itm_start, itm_length
-- start, length args are selected item props // returns true when in builds prior to 6.54 I_LASTY val of every overlapping item <= 15 when TCP is at certain height, when Preferences -> Appearance -> Maximum number of lanes when showing overlapping items in lanes option is set to 1, and when in builds 6.54 onward Preferences -> Appearance -> Media Item Positioning -> Offset by is set to 0 // for items in FIPM only works if TCP is fully collapsed for REAPER builds prior to 6.54 or when the track height is less than the value at Preferences -> Appearance -> Media Item Positioning -> Collapse free item positioning when track height is less than since build 6.54

local tr, itm, start, length
local get_item_props = r.GetMediaItemInfo_Value

	if #(...) == 2 then
	tr, itm = table.unpack(...)
	start = get_item_props(itm, 'D_POSITION')
	length = get_item_props(itm, 'D_LENGTH')
	elseif #(...) == 3 then
	tr, start, length = table.unpack(...)
	else break
	end

local build = tonumber(r.GetAppVersion():match('(.+)/'))

local function Get_reaper_ini(key)
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
	return cont:match(key..'=(%d+)')
end

	if build < 6.54 then
	local f = io.open(r.get_ini_file(),'r')
	local cont = f:read('*a')
	f:close()
		if Get_reaper_ini('maxitemlanes') == '1' then return true -- Preferences -> Appearance -> Maximum number of lanes is 1
		else
		local overlap_cnt = 0
		local I_LASTY_cnt = 0
			for i = 0, r.GetTrackNumMediaItems(tr)-1 do
			local itm = r.GetTrackMediaItem(tr, i)
			local st = get_item_props(itm, 'D_POSITION')
			local len = get_item_props(itm, 'D_LENGTH')
				if st < start+length and st+len > start then -- covers both full and partial overlap
				overlap_cnt = overlap_cnt+1
					if get_item_props(itm, 'I_LASTY') <= 15 then
				-- 	if get_item_props(itm, 'I_LASTH') <= 15 then -- I_LASTY and I_LASTH values always seem identical
					I_LASTY_cnt = I_LASTY_cnt+1
					end
				end
			end
			if overlap_cnt == I_LASTY_cnt then return true end -- collapsed when I_LASTY val of every overlapping item <= 15 // 15 seems to be valid across different themes // the condition is also true when only 1 lane is set at Preferences -> Appearance -> Maximum number of lanes when showing overlapping items in lanes, 'maxitemlanes' value in reaper.ini
	--[[
	elseif -- 6.54 onward // doesn't make sense as overlapping items feature doesn't work since 6.54
	local f = io.open(r.get_ini_file(),'r')
	local cont = f:read('*a')
	f:close()
		if Get_reaper_ini('itemoverlap_offspct') == '0' then return true -- Preferences -> Appearance -> Media Item Positioning -> Offset by is 0
	]]
	end

--[[ UNNECESSARY
-- If the above expression is false, check if total number of overlapping items is less than the number of lanes set at Preferences -> Appearance -> Maximum number of lanes when showing overlapping items in lanes
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local maxitemlanes = cont:match('maxitemlanes=(%d+)')
-- https://forums.cockos.com/showpost.php?p=2422782&postcount=20
	if tonumber(maxitemlanes) < overlap_cnt then return true end
]]

end



function Shift_Overlapping_Items_Together(sel_itm, val) -- overlapping the selected one, shift by val
local start = r.GetMediaItemInfo_Value(sel_itm, 'D_POSITION')
local length = r.GetMediaItemInfo_Value(sel_itm, 'D_LENGTH')
local tr = r.GetMediaItemTrack(sel_itm)
local t = {} -- table to avoid chaos in items order when they start being moved, otherwise moving rightwards the loop must be reversed and moving leftwards - direct
	for i = 0, r.GetTrackNumMediaItems(tr)-1 do
	local itm = r.GetTrackMediaItem(tr, i)
	local st = r.GetMediaItemInfo_Value(itm, 'D_POSITION')
	local len = r.GetMediaItemInfo_Value(itm, 'D_LENGTH')
		if st < start+length and st+len > start then
		t[#t+1] = itm
		end
	end
	for _, itm in ipairs(t) do
	local st = r.GetMediaItemInfo_Value(itm, 'D_POSITION')
	r.SetMediaItemInfo_Value(itm, 'D_POSITION', st+val)
	end
end


function Count_Sel_Itms_Unique_Tracks(t)
local cnt = 0
local tr_init
local fin = t and #t or r.CountSelectedMediaItems(0)
	for i = 1, fin do
	local itm = t and t[i] or r.GetSelectedMediaItem(0,i-1)
	local tr = r.GetMediaItemTrack(itm)
	cnt = tr ~= tr_init and cnt + 1 or cnt
	tr_init = tr
	end
return cnt
end


function Get_Item_Greatest_And_1st_Availab_Group_IDs1()
local t = {}
	for i = 0, r.CountMediaItems(0)-1 do
	local group_id = r.GetMediaItemInfo_Value(r.GetMediaItem(0,i), 'I_GROUPID')
		if group_id > 0 then t[#t+1] = group_id end
	end
table.sort(t)
return t[#t], t[#t]+1
end


function Get_Item_Greatest_And_1st_Availab_Group_IDs2()
local group_id_store = 0
	for i = 0, r.CountMediaItems(0)-1 do
	local group_id = r.GetMediaItemInfo_Value(r.GetMediaItem(0,i), 'I_GROUPID')
		if group_id > group_id_store then group_id_store = group_id end
	end
return group_id_store, group_id_store+1
end


function Insert_Empty_Item_To_Display_Text1(output) -- relies on Re_Store_Selected_Objects(); for the item notes to recognize line breaks in the output they must be replaced with '\r\n' if the string wasn't previously formatted in the notes field https://forum.cockos.com/showthread.php?t=214861#2
local sel_itms_t, sel_trk_t = Re_Store_Selected_Objects() -- store
local cur_pos = r.GetCursorPosition() -- store
r.InsertTrackAtIndex(r.GetNumTracks(), false) -- wantDefaults false
r.SetOnlyTrackSelected(r.GetTrack(0,r.GetNumTracks()-1)) -- select the newly inserted track
r.SetEditCurPos(-3600, true, false) -- moveview true, seekplay false // move to -3600 or -1 hour mark in case project time start is negative, will surely move cursor to the very project start to reveal the notes item
r.SelectAllMediaItems(0, false) -- selected false // deselect all
r.Main_OnCommand(40142,0) -- Insert empty item
local item = r.GetSelectedMediaItem(0,0)
	--[[
	local path = r.GetResourcePath()
	local temp_file = path..path:match('[\\//]')..'preset_list_temp'
	local f = io.open(temp_file, 'w')
	f:write(output); f:close()
	local f = io.open(temp_file, 'r')
	local output = f:read('*a')
	f:close(); os.remove(temp_file)
	]]
r.GetSetMediaItemInfo_String(item, 'P_NOTES', output, true) -- setNewValue true
-- Open the empty item notes
r.SetMediaItemSelected(r.GetSelectedMediaItem(0,0),true) -- selected true
r.Main_OnCommand(40850,0) -- Item: Show notes for items...
Re_Store_Selected_Objects(sel_itms_t, sel_trk_t) -- restore originally selected objects
r.SetEditCurPos(cur_pos, false, false) -- moveview, seekplay false; restore position
end


function Insert_Empty_Item_To_Display_Text2(tr) -- tr is the target track whose notes are to be edited
-- relies on Re_Store_Selected_Objects(); for the item notes to recognize line breaks in the output they must be replaced with '\r\n' if the string wasn't previously formatted in the notes field https://forum.cockos.com/showthread.php?t=214861#2

local tr_GUID = r.GetTrackGUID(tr)

local retval, tr_name = r.GetTrackName(tr)
local ret, notes = r.GetSetMediaTrackInfo_String(tr, 'P_EXT:NOTES', '', false)
local notes = not ret and ACCESS_SWS_TRACK_NOTES and Load_SWS_Track_Notes(tr):gsub('\n\n','\r\n\r\n') or notes -- load SWS track notes if no notes and the setting is enabled, adding carriage retun char to the notes edition warning divider, if any, for correct display in the item notes window
local notes = notes:match('([\0-\255]+)\n \n%d+') or notes -- exlude date if there're stored notes

local sel_itms_t, sel_trk_t = Re_Store_Selected_Objects() -- store
local cur_pos = r.GetCursorPosition() -- store

-- Insert notes track and configure
local tr_idx = r.CSurf_TrackToID(tr, false) -- mcpView false
local tr_idx = tr_idx == 0 and 0 or tr_idx -- CSurf_TrackToID returns idx 0 for the master track and 1-based idx for the rest
r.InsertTrackAtIndex(tr_idx, false) -- wantDefaults false
local notes_tr = r.CSurf_TrackFromID(tr_idx+1, false) -- mcpView false
r.GetSetMediaTrackInfo_String(notes_tr, 'P_NAME', 'Track '..tr_idx..' notes', true) -- setNewValue true
r.GetSetMediaTrackInfo_String(notes_tr, 'P_EXT:NOTES_TRACK', '+', true) -- setNewValue true // add extended data to be able to find the track later if left undeleted

-- Insert notes item and configure
r.SetEditCurPos(-3600, false, false) -- moveview seekplay false // move to -3600 or -1 hour mark in case project time start is negative, will surely move cursor to the very project start to reveal the notes item // thanks to moveview false the notes item will be accessible from anywehere in the project since its length will be set to full project length below

local notes_item = r.AddMediaItemToTrack(notes_tr)
r.SetMediaItemSelected(notes_item, true) -- selected true // to be able to open notes with action
local proj_len = r.GetProjectLength(0)
	
r.SetMediaItemInfo_Value(notes_item, 'D_LENGTH', proj_len == 0 and 5 or proj_len) -- set notes item length to full project length if there're time line objects, if there's none and so proj length is 0 then set to 5 sec
r.AddTakeToMediaItem(notes_item) -- creates a quasi-MIDI item so label can be added to it since label (P_NAME) is a take property // the item is affected by actions 'SWS/BR: Add envelope points...', 'SWS/BR: Insert 2 envelope points...' and 'SWS/BR: Insert envelope points on grid...' when applied to the Tempo envelope which cause creation of stretch markers in the item
r.GetSetMediaItemTakeInfo_String(r.GetActiveTake(notes_item), 'P_NAME', 'track "'..tr_name..'"', true) -- setNewValue true // add label to the notes item
r.GetSetMediaItemInfo_String(notes_item, 'P_NOTES', notes, true) -- setNewValue true // load notes
r.GetSetMediaItemInfo_String(notes_item, 'P_EXT:NOTES_ITEM', tr_GUID, true) -- setNewValue true // add extended data to be able to find the item later if left undeleted and to find the target track to store the notes to
-- Open the empty item notes
r.Main_OnCommand(40850,0) -- Item: Show notes for items... -- CAUSES CRASH IF THE ITEM IS CLICKED RAPIDLY

Re_Store_Selected_Objects(sel_itms_t, sel_trk_t) -- restore originally selected objects
r.SetEditCurPos(-3600, true, false) -- moveview true, seekplay false // move to -3600 or -1 hour mark in case project time because the Arrange view may move when the item is inserted in case Preferences -> Editing behavior -> Move edit cursor when pasing/insering media is enabled
r.SetEditCurPos(cur_pos, false, false) -- moveview, seekplay false; restore position

end


function Get_Item_Edge_At_Mouse() -- Combined with Get_Arrange_and_Header_Heights2() can be used to get 4 item corners at the mouse cursor
local cur_pos = r.GetCursorPosition()
local x, y = r.GetMousePosition()
local item, take = r.GetItemFromPoint(x,y, false) -- allow_locked false
local left_edge, right_edge
	if item then
	r.PreventUIRefresh(1)
	local px_per_sec = r.GetHZoomLevel() -- 100 px per 1 sec = 1 px per 0.01 sec or 10 ms
	local left = r.GetMediaItemInfo_Value(item, 'D_POSITION')
	local right = left + r.GetMediaItemInfo_Value(item, 'D_LENGTH')
	r.Main_OnCommand(40514, 0) -- View: Move edit cursor to mouse cursor (no snapping)
	local new_cur_pos = r.GetCursorPosition()
		if math.abs(left - new_cur_pos) <= 0.01*(1000/px_per_sec) -- condition the minimal distance by the zoom resolution, the greater the zoom-in the smaller is the required distance, the base value of 10 ms or 1 px which is valid for zoom at 100 px per 1 sec seems optimal, 1000/px_per_sec is ms per pixel; OR 0.01/(px_per_sec/1000) px_per_sec/1000 is pixels per ms // only cursor position inside item is respected
		then
		left_edge = true
		elseif math.abs(right - new_cur_pos) <= 0.01*(1000/px_per_sec) then
		right_edge = true
		end
	r.SetEditCurPos(cur_pos, false, false) -- moveview, seekplay false // restore orig edit cursor pos
	r.PreventUIRefresh(-1)
	end
return left_edge, right_edge
end


function is_same_track() -- whether all selected items belong to the same track
local sel_itm_cnt = r.CountSelectedMediaItems(0)
	if sel_itm_cnt > 0 then
	local ref_tr = r.GetMediaItemTrack(r.GetSelectedMediaItem(0,0))
		for i = 0, sel_itm_cnt-1 do
			if r.GetMediaItemTrack(r.GetSelectedMediaItem(0,i)) ~= ref_tr then return false end
		end
	end
return true
end


function REVERSE_TAKES_VIA_CHUNK(item)
local ret, chunk = GetItemChunk(item) -- FUNCTION
	if ret == 'error' then Err_mess() return end -- FUNCTION
local take_cnt = r.CountTakes(item)
	if take_cnt > 1 then
	local chunk_t = {chunk:match('(.+)(NAME[%W].-)'..string.rep('(TAKE[%W].-)', take_cnt-2)..'(TAKE[%W].+)>')} -- GET TAKE CHUNKS; repeat as many times as take count -2 since first and last take chunks are different; [%W] makes sure that only 'TAKE' tag is captured disregarding words which contain it of which there're a few, that is must be followed by anything but alphanumeric characters
	local part_one = chunk_t[1] -- store first part before takes
	table.remove(chunk_t,1) -- remove it
	local take_chunk_t = reverse_indexed_table(chunk_t) -- reverse, FUNCTION
	table.insert(take_chunk_t, #take_chunk_t, 'TAKE\n') -- add to the formerly 1st take now being the last as 1st take doesn't have 'TAKE' tag
	local take_chunk = table.concat(take_chunk_t):match('TAKE.-\n(.+)') -- concatenate, removing TAKE tag from the formerly last take now being the 1st, as 1st take shouldn't have 'TAKE' tag
	Msg(part_one..take_chunk..'>')
	r.SetItemStateChunk(item, part_one..take_chunk..'>', false) -- isundo is false // adding chunk closure since it wasn't stored in the table
	r.UpdateItemInProject(item)
	end
end


------------------------ GET ITEM SEGMENTS AT MOUSE -------------------

-- Combined with Get_Item_Edge_At_Mouse() can be used to get 4 item corners at the mouse cursor

function Get_Arrange_and_Header_Heights1() 
-- fetches data from a temporary project tab, WORKS, but isn't ideal because of being way too intrusive, project loading process is usually visible 
-- if no SWS estension only works if the program window is fully open 
-- only runs when there's track or item under mouse cursor
-- relies on round() function

-- !!!!!!!!!!! since build 6.76 there's a new preference for maximum vertical zoom (reaper.ini key maxvzoom=0.50000000) which will break the function if not 100% as if affects the action 'View: Toggle track zoom to maximum height' used here to get Arrange height; it will still be possible to calculate it using the action, e.g. (track_height/max_height)*100 to find 100% value
-- a very convoluted alternative way is using actions 'Ruler: Set to default/max/min height', then checking toppane value in reaper.ini, checking where transport is located and toggling it temporarily off if on top, checking in reaper.ini for any toolbars/windows docked at the top, temporarily toggling it off, then adding about 90 px to toppane value and subtracting this from the screen or program window height depending on whether SWS extension is installed

local lt_scr, top_scr, rt_scr, bot_scr = r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true) -- true - work area, false - the entire screen // https://forum.cockos.com/showthread.php?t=195629#4
local sws = r.APIExists('BR_Win32_GetWindowRect')
local retval, rt, top, lt, bot = table.unpack(sws and {r.BR_Win32_GetWindowRect(r.GetMainHwnd())} or {nil})
--[[
local dimens_t = sws and {r.BR_Win32_GetWindowRect(r.GetMainHwnd())}
or {r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true)} -- true - work area, false - the entire screen // https://forum.cockos.com/showthread.php?t=195629#4
	if #dimens_t == 5 then table.remove(dimens_t, 1) end -- remove retval value if BR's function
local rt, top, lt, bot = table.unpack(dimens_t)
]]
local wnd_h = sws and bot-top or bot_scr
local retval, proj_state = r.GetProjExtState(0,'WINDOW DIMS','window_dims')
local state = not retval and r.GetExtState('WINDOW DIMS','window_dims') or proj_state
local window_h, arrange_h = state:match('(.+);(.+)')
local wnd_h_offset = sws and top or 0 -- to add when calculating absolute track top edge coordinate inside Get_Item_Track_Segment_At_Mouse() function when the sws extension is installed to be able to get segments in the shrunk program window, in this case 'top' value represents difference between program window top and full screen top coordinates which is needed to match mouse cursor Y coordinate which is absolute i.e. is relative to the full screen size // !!!! MIGHT NOT WORK ON MAC since there Y axis starts at the bottom

	if sws and window_h ~= wnd_h..'' or not window_h then -- either only update if sws extension is installed and program window height has changed or initially store
	
	-- get 'Maximum vertical zoom' set at Preferences -> Editing behavior, which affects max track height set with 'View: Toggle track zoom to maximum height', introduced in build 6.76
	local cont
		if tonumber(r.GetAppVersion():match('(.+)/')) >= 6.76 then
		local f = io.open(r.get_ini_file(),'r')
		cont = f:read('*a')
		f:close()
		end
	local max_zoom = cont and cont:match('maxvzoom=([%.%d]+)\n') -- min value is 0.125 (13%), max is 8 (800%)
	local max_zoom = not max_zoom and 100 or max_zoom*100 -- ignore in builds prior to 6.76 by assigning 100 so that when track height is divided by 100 and multiplied by 100% nothing changes, otherwise convert to conventional percentage value; if 100 can be divided by the percentage (max_zoom) value without remainder (such as 50, 25, 20) the resulting value is accurate, otherwise there's ±1 px diviation, because the actual track height in pixels isn't fractional like the one obtained through calculation therefore some part is lost
		
	-- Get Arrange and window header height
	local cur_proj, projfn = r.EnumProjects(-1) -- store cur project pointer
	-- r.PreventUIRefresh(1) -- PREVENTS GetMediaTrackInfo_Value RETURN VALUE PROBABLY BECAUSE THE HIGHT ISN'T UPDATED AFTER ACTION
	r.Main_OnCommand(41929, 0) -- New project tab (ignore default template) // open new proj tab
	local dock_open = r.GetToggleCommandStateEx(0,40279) -- View: Show docker // the result of the action 'View: Toggle track zoom to maximum height' depends on the visibility of the bottom docker so if open it needs to be temporarily closed, the action 40279 applies to all dockers
		if dock_open then r.Main_OnCommand(40279,0) end -- View: Show docker // close docks
	r.InsertTrackAtIndex(0, false) -- wantDefaults false
	local ref_tr = r.GetTrack(0,0)
--	r.SetTrackSelected(ref_tr, true) -- selected true // not needed, the next actions are global
		if r.GetToggleCommandStateEx(0,40113) == 0 then
		r.Main_OnCommand(40113, 0) -- View: Toggle track zoom to maximum height (i.e. height of the Arrange) // selection isn't needed, all are toggled
		end
	local tr_height = r.GetMediaTrackInfo_Value(ref_tr, 'I_TCPH')/max_zoom*100 -- not including envelopes, action 40113 doesn't take envs into account; calculating track height as if it were zoomed out to the entire Arrange height by taking into account 'Maximum vertical zoom' setting at Preferences -> Editing behavior
	local tr_height = round(tr_height) -- round; if 100 can be divided by the percentage (max_zoom) value without remainder (such as 50, 25, 20) the resulting value is integer, otherwise the calculated Arrange height is fractional because the actual track height in pixels is integer which is not what it looks like after calculation based on percentage (max_zoom) value, which means the value is rounded in REAPER internally because pixels cannot be fractional and the result is ±1 px diviation compared to the Arrange height calculated at percentages by which 100 can be divided without remainder
	r.SetExtState('WINDOW DIMS','window_dims', wnd_h..';'..tr_height, false) -- persist false
	r.SetProjExtState(cur_proj, 'WINDOW DIMS', 'window_dims', wnd_h..';'..tr_height)
	-- Close temp project tab without save prompt; when a freshly opened project closes there's no prompt
	-- the problem may emerge if the script is bound to a shortcut where Ctrl & Shift are used because this modifier combination is used to generate a prompt to load project with fx offlined, so the script shortcut must not include this combination; in reaper-kb.ini KEY codes Ctrl+Shift code (the first number) seems to be consistently 13, Ctrl+Alt+Shift is 29
	-- using dummy project doesn't help to overcome Ctrl+Shift issue
	r.Main_openProject('noprompt:'..projfn)
	r.Main_OnCommand(40860, 0) -- Close current project tab
	r.SelectProjectInstance(cur_proj) -- re-open orig proj tab
		if dock_open then r.Main_OnCommand(40279,0) end -- View: Show docker // re-open docks
	-- r.PreventUIRefresh(-1)
	local header_height = bot - tr_height - 23 -- size between program window top edge and Arrange // 18 is horiz scrollbar height (regardless of the theme) and 'bot / window_h' value is greater by 4 px than the actual program window height hence 18+4 = 22 has to be subtracted + 1 more pixel for greater precision in targeting item top/bottom edges
	return tr_height, header_height, wnd_h_offset-- tr_height represents Arrange height // return updated data

	else return tonumber(arrange_h), window_h - arrange_h - 23, wnd_h_offset -- return previously stored data // calculation explication see above

	end

end


function Is_Ctrl_And_Shift()
-- check if the script is bound to a shortcut containing both Ctrl & Shift
-- which is not advised when the version of Get_Arrange_and_Header_Heights() function is used which creates temporary project tab to fetch the Arrange height data because in this case if the key combination is long pressed a prompt will appear offering to load project with FX offline
-- only relevant if SWS and js_ReaScriptAPI extensions are not installed
-- because only in this case to get the Arrange height a track max zoom is used in a temp proj tab
local is_new_value,filename,sectID,cmdID,mode,resol,val = r.get_action_context()
local named_ID = r.ReverseNamedCommandLookup(cmdID) -- convert numeric returned by get_action_context to alphanumeric listed in reaper-kb.ini
local res_path = r.GetResourcePath()..r.GetResourcePath():match('[\\/]') -- path with separator
local s,R = ' ', string.rep
	for line in io.lines(res_path..'reaper-kb.ini') do
		if line:match('_'..named_ID) then -- in the shortcut data section command IDs are preceded with the underscore
		local modif = line:match('KEY (%d+)')
			if modif == '13' or modif == '29' then -- Ctrl+Shift or Ctrl+Shift+Alt
			r.MB(R(s,3)..'The script is bound to a shotrcut\n\n'..R(s,5)..'containing Ctrl and Shift keys.\n\n'..R(s,12)..'This will unfortunately\n\n intefere with the script performance.\n\n'..R(s,7)..'It\'s strongly advised to remap\n\n'..R(s,6)..'the script to another shortcut.\n\n\tSincere apologies!','ERROR',0)
			return true
			end
		end
	end
end
-- if Is_Ctrl_And_Shift(cmdID) then return r.defer(no_undo) end


function Get_Arrange_and_Header_Heights2() 
-- if no SWS extension only works if the program window is fully open
-- only runs when there's track or item under mouse cursor
-- relies on round() function

-- !!! in newer builds, at least since 6.79 but likely since 6.76 when zoom height preference was added (from the changelog: Vertical zoom: overhaul, allow more fractional zoom state), actions 'View: Increase/Decrease selected track heights' don't work sharply any more in a loop so the change in track height when heights are restored is visible and ugly, especially when there're many tracks, so because of that Get_Arrange_and_Header_Heights1() version might be prefereable

-- !!!!!!!!!!! since build 6.76 there's a new preference for maximum vertical zoom (reaper.ini key maxvzoom=0.50000000) which will break the function if not 100% as if affects the action 'View: Toggle track zoom to maximum height' used here to get Arrange height; it will still be possible to calculate it using the action, e.g. (track_height/max_height)*100 to find 100% value
-- a very convoluted alternative way is using actions 'Ruler: Set to default/max/min height', then checking toppane value in reaper.ini, checking where transport is located and toggling it temporarily off if on top, checking in reaper.ini for any toolbars/windows docked at the top, temporarily toggling it off, then adding about 90 px to toppane value and subtracting this from the screen or propgarm window height depending on whether SWS extension is installed

local lt_scr, top_scr, rt_scr, bot_scr = r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true) -- true - work area, false - the entire screen // https://forum.cockos.com/showthread.php?t=195629#4
local sws = r.APIExists('BR_Win32_GetWindowRect')
local retval, rt, top, lt, bot = table.unpack(sws and {r.BR_Win32_GetWindowRect(r.GetMainHwnd())} or {nil})

--[[
local dimens_t = sws and {r.BR_Win32_GetWindowRect(r.GetMainHwnd())}
or {r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true)} -- true - work area, false - the entire screen // https://forum.cockos.com/showthread.php?t=195629#4
	if #dimens_t == 5 then table.remove(dimens_t, 1) end -- remove retval value if BR's function
local rt, top, lt, bot = table.unpack(dimens_t)
]]
local wnd_h = sws and bot-top or bot_scr
local retval, proj_state = r.GetProjExtState(0,'WINDOW DIMS','window_dims')
local state = not retval and r.GetExtState('WINDOW DIMS','window_dims') or proj_state
local window_h, arrange_h = state:match('(.+);(.+)')
local wnd_h_offset = sws and top or 0 -- to add when calculating absolute track top edge coordinate inside Get_Item_Track_Segment_At_Mouse() function when the sws extension is installed to be able to get segments in the shrunk program window, in this case 'top' value represents difference between program window top and full screen top coordinates which is needed to match mouse cursor Y coordinate which is absolute i.e. is relative to the full screen size // !!!! MIGHT NOT WORK ON MAC since there Y axis starts at the bottom

-- Item condition isn't necessary, works perfectly without it // on the other hand it makes sure that there's at least one track so that ref_tr var below is valid
local x, y = r.GetMousePosition() -- the coordinates are absolute, relative to the full screen size
local item, take = r.GetItemFromPoint(x, y, false) -- allow_locked false // item is needed to have some anchor to restore scroll state after track heights restoration, item under cursor is 100% within view so is a good reference
local track, info = r.GetTrackFromPoint(x, y)

	if (item or track) and (sws and window_h ~= wnd_h..'' or not window_h) then -- either only update if sws extension is installed and program window height has changed or initially store
	
	-- get 'Maximum vertical zoom' set at Preferences -> Editing behavior, which affects max track height set with 'View: Toggle track zoom to maximum height', introduced in build 6.76
	local cont
		if tonumber(r.GetAppVersion():match('(.+)/')) >= 6.76 then
		local f = io.open(r.get_ini_file(),'r')
		cont = f:read('*a')
		f:close()
		end
	local max_zoom = cont and cont:match('maxvzoom=([%.%d]+)\n') -- min value is 0.125 (13%), max is 8 (800%)
	local max_zoom = not max_zoom and 100 or max_zoom*100 -- ignore in builds prior to 6.76 by assigning 100 so that when track height is divided by 100 and multiplied by 100% nothing changes, otherwise convert to conventional percentage value; if 100 can be divided by the percentage (max_zoom) value without remainder (such as 50, 25, 20) the resulting value is accurate, otherwise there's ±1 px diviation, because the actual track height in pixels isn't fractional like the one obtained through calculation therefore some part is lost

	-- Store track heights
	local dock_open = r.GetToggleCommandStateEx(0,40279) -- View: Show docker // the result of the action 'View: Toggle track zoom to maximum height' depends on the visibility of the bottom docker so if open it needs to be temporarily closed, the action 40279 applies to all dockers
		if dock_open then r.Main_OnCommand(40279,0) end -- View: Show docker // close docks // placed before getting track heights to get the actual data unaffected by the docker visibility because it might be
	local t = {}
		for i=0, r.CountTracks(0)-1 do
		local tr = r.GetTrack(0,i)
		t[#t+1] = {height=r.GetMediaTrackInfo_Value(tr, 'I_TCPH'), sel=r.IsTrackSelected(tr)}
		end
	local ref_tr = r.GetTrack(0,0) -- reference track (any) to scroll back to in order to restore scroll state after track heights restoration
	local ref_tr_y = r.GetMediaTrackInfo_Value(ref_tr, 'I_TCPY')

	-- Get the data
	-- When the actions are applied the UI jolts, but PreventUIRefresh() is not suitable because it blocks the function GetMediaTrackInfo_Value() from getting the return value
	-- toggle to minimum and to maximum height are mutually exclusive // selection isn't needed, all are toggled
	r.Main_OnCommand(40110, 0) -- View: Toggle track zoom to minimum height
	r.Main_OnCommand(40113, 0) -- View: Toggle track zoom to maximum height
	local tr_height = r.GetMediaTrackInfo_Value(ref_tr, 'I_TCPH')/max_zoom*100 -- not including envelopes, action 40113 doesn't take envs into account; calculating track height as if it were zoomed out to the entire Arrange height by taking into account 'Maximum vertical zoom' setting at Preferences -> Editing behavior
	local tr_height = round(tr_height) -- round; if 100 can be divided by the percentage (max_zoom) value without remainder (such as 50, 25, 20) the resulting value is integer, otherwise the calculated Arrange height is fractional because the actual track height in pixels is integer which is not what it looks like after calculation based on percentage (max_zoom) value, which means the value is rounded in REAPER internally because pixels cannot be fractional and the result is ±1 px diviation compared to the Arrange height calculated at percentages by which 100 can be divided without remainder
	r.Main_OnCommand(40110, 0) -- View: Toggle track zoom to minimum height
	r.SetExtState('WINDOW DIMS','window_dims', wnd_h..';'..tr_height, false) -- persist false // UNCOMMENT
	r.SetProjExtState(0, 'WINDOW DIMS', 'window_dims', wnd_h..';'..tr_height) -- // UNCOMMENT

	-- Restore
		for k, data in ipairs(t) do -- restore track heights
		local height = data.height
		local tr = r.GetTrack(0,k-1)
		local tr_h = r.GetMediaTrackInfo_Value(tr, 'I_TCPH')
			if tr_h ~= height then
			local bigger, smaller = tr_h > height, tr_h < height
			local action = bigger and 41326 -- View: Decrease selected track heights
			or smaller and 41325 -- View: Increase selected track heights
			--[[ WORKED perfectly in 6.56 and earlier, but since vertical zoom overhaul in 6.76 TCP height change is visible during the loop https://forum.cockos.com/showthread.php?t=278646
			r.SetOnlyTrackSelected(tr)			
				repeat
				r.Main_OnCommand(action, 0)
				local tr_h = r.GetMediaTrackInfo_Value(tr, 'I_TCPH')
				until bigger and tr_h <= height or smaller and tr_h >= height
			]]
			-- Very slight improvement, only change in height isn't invisible, but change in selection still is despite SetOnlyTrackSelected() being enclosed between PreventUIRefresh()
			local tr_h = r.GetMediaTrackInfo_Value(tr, 'I_TCPH')
			r.PreventUIRefresh(1)
			r.SetOnlyTrackSelected(tr)
				repeat
				r.Main_OnCommand(action, 0)
				tr_h = bigger and tr_h-8 or tr_h+8 -- 8 px is the amount TCP height is changed by with actions 41325/41326
				until bigger and tr_h <= height or smaller and tr_h >= height
				end
			r.PreventUIRefresh(-1)
		end
		for k, data in ipairs(t) do
		local tr = r.GetTrack(0,k-1)
		r.SetTrackSelected(tr, data.sel)
		end
	r.PreventUIRefresh(1)
		repeat -- restore track scroll
		r.CSurf_OnScroll(0, -1) -- negatve to scroll up because after track heights restoration the tracklist ends up being scrolled all the way down // 1 vert scroll unit is 8 px
		until r.GetMediaTrackInfo_Value(ref_tr, 'I_TCPY') >= ref_tr_y
	r.PreventUIRefresh(-1)

		if dock_open then r.Main_OnCommand(40279,0) end -- View: Show docker // re-open docks if were open initially

	local header_height = bot - tr_height - 23 -- size between program window top edge and Arrange // 18 is horiz scrollbar height (regardless of the theme) and 'bot / window_h' value is greater by 4 px than the actual program window height hence 18+4 = 22 has to be subtracted + 1 more pixel for greater precision in targeting item top/bottom edges
	return tr_height, header_height, wnd_h_offset -- tr_height represents Arrange height // return updated data

	elseif window_h then -- Return the data already stored and not needing update
	return tonumber(arrange_h), window_h - arrange_h - 23, wnd_h_offset -- return previously stored data // calculation explication see above

	end

end


local arrange_h, header_h, wnd_h_offset = Get_Arrange_and_Header_Heights2()

function Get_Item_Track_Segment_At_Mouse(header_h, wnd_h_offset, want_item, want_takes) -- horizontal segments, targets item or track under mouse cursor, supports overlapping items displayed in lanes // want_item is boolean in which case item under mouse is considered otherwise segments will be valid along the entire time line for the track under mouse; want_takes is boolean and only relevant if want_item is true, if true and the item arg is true and the item is multi-take, each take will be divided into 2 segments

local x, y = r.GetMousePosition()
local item, take = table.unpack(item and {r.GetItemFromPoint(x, y, false)} or {nil}) -- allow_locked false
local tr, info = table.unpack(not item and {r.GetTrackFromPoint(x, y)} or {nil})

	if item then -- without item the segments will be relevant for the track along the entire timeline which is also useful, in which case item parameters aren't needed; if limited to TCP with Get_TCP_Under_Mouse() can be used to divide TCP to segments
	local tr = r.GetMediaItemTrack(item)
	local tr_y = r.GetMediaTrackInfo_Value(tr, 'I_TCPY')
	local tr_h = r.GetMediaTrackInfo_Value(tr, 'I_TCPH') -- no envelopes
	local itm_y = r.GetMediaItemInfo_Value(item, 'I_LASTY') -- within track
	local itm_h = r.GetMediaItemInfo_Value(item, 'I_LASTH')
	local take_cnt = r.CountTakes(item)
	--[[ These are only working for non-overlapping items or overlapping which aren't displayed in lanes
	local tr_h_glob = tr_y + tr_h + header_h -- distance between the program window top and the track bottom edge
	local itm_h_glob = tr_h_glob - 4 -- same for the item // -4 because item height is always smaller that its track height by 4 px regadless of icons and text on item's top, track I_TCPH = item I_LASTY + item I_LASTH + 4 is a universal formula
	]]
	local tr_y_glob = tr_y + header_h + wnd_h_offset -- distance between the screen top and the track top edge accounting for shrunk program window if sws extension is installed
	local itm_y_glob = tr_y_glob + itm_y -- distance between the screen top and the item top edge
	local itm_h_glob = itm_y_glob + itm_h -- distance between the screen top and the item bottom edge // only needed if table isn't used below

		if take_cnt == 1 then
		local itm_segm_h = itm_h/3 -- item segment height // can be divided by more than 3 in which case the following vars and return values must be adjusted accordingly
		--[-[ if the table isn't used
		local segm_bot = y <= itm_h_glob and y >= itm_h_glob - itm_segm_h
		local segm_mid = y <= itm_h_glob - itm_segm_h and y >= itm_h_glob - itm_segm_h*2
		local segm_top = y <= itm_h_glob - itm_segm_h*2 and y >= itm_h_glob - itm_h
		return segm_top, segm_mid, segm_bot
		--]]
		--[[ OR same as for takes below
		-- The tables collect truths/falses
		local t = {}
			for i = 1, 3 do
			t[i] = y >= itm_y_glob+itm_segm_h*(i-1) and y <= itm_y_glob+itm_segm_h*i
			end
		return t
		--]]

		elseif take_cnt > 1 and want_takes then
		local itm_segm_h = item_h/take_cnt/2 -- two segments per take, can be more
		local segm_cnt = 2*take_cnt -- multiply by segments per take
		local t = {}
			for i = 1, segm_cnt do
			t[i] = y >= itm_y_glob+itm_segm_h*(i-1) and y <= itm_y_glob+itm_segm_h*i
			end
		return t
		end

	elseif tr then -- if limited to TCP with Get_TCP_Under_Mouse() can be used to divide TCP to segments
	local tr_y = r.GetMediaTrackInfo_Value(tr, 'I_TCPY')
	local tr_h = r.GetMediaTrackInfo_Value(tr, 'I_TCPH') -- no envelopes
	local tr_y_glob = tr_y + header_h + wnd_h_offset -- distance between the screen top top and the track top edge accounting for shrunk program window if sws extension is installed
	local tr_segm_h = tr_h/3 -- 3 segments
	local t = {}
		for i = 1, 3 do
		t[i] = y >= tr_y_glob+tr_segm_h*(i-1) and y <= tr_y_glob+tr_segm_h*i
		end
	return t
	end

end

-- Process the segment table // can be integrated into the loops inside Get_Item_Segment_At_Mouse() function // see example in my_Indicate cursor position within item with a tooltip.lua
	for k, truth in ipairs(t) do
		if truth then
			if #t == 3 then -- 1 take, 3 segments
				if k == 1 then -- DO STUFF
				break -- break because only 1 segment can be targeted at a time so no point to continue
				elseif k == 2 then -- DO STUFF
				break
				elseif k == 3 then -- DO STUFF
				break
				end
			elseif #t > 3 then -- multi-take, 2 segments per take
				if k%2 ~= 0 then -- odd number, upper segment of a take
				-- DO STUFF
				break
				else -- even number, lower segment of a take
				-- DO STUFF
				break
				end
			end
		end
	end



------------------------ GET ITEM SEGMENTS AT MOUSE END ---------------------

--[[

Calculate take actual length for take marker operations using edit cursor

* convert timeline pos to pos within take

local cur_pos = r.GetCursorPosition()

local item_pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
OR
local item_pos = r.GetMediaItemInfo_Value(r.GetMediaItemTake_Item(take), 'D_POSITION')

local offset = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')
local playrate = r.GetMediaItemTakeInfo_Value(take, 'D_PLAYRATE') -- affects take start offset and take marker pos
local mark_pos = (cur_pos - item_pos + offset)*playrate

* convert pos within take to timeline pos

local ret_pos, name, color = r.GetTakeMarker(take, idx) -- ret_pos = -1 or position in item source
local mark_pos = item_pos + (ret_pos - offset)/playrate

ALSO RELEVANT FOR STRETCH MARKERS AND TRANSIENT GUIDES BAR offset value which for stretch markers only relevant
if its position in source is used, its position in item is already relative to the item start

]]


function Proj_Time_2_Item_Time(proj_time, item, take)
-- e.g. edit/play cursor, proj markers/regions time to take, stretch markers and transient guides time

--local cur_pos = r.GetCursorPosition()
local item_pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
--OR
--local item_pos = r.GetMediaItemInfo_Value(r.GetMediaItemTake_Item(take), 'D_POSITION')
local offset = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')
local playrate = r.GetMediaItemTakeInfo_Value(take, 'D_PLAYRATE') -- affects take start offset and take marker pos
local item_time = (proj_time - item_pos + offset)*playrate
return item_time
end


function Item_Time_2_Proj_Time(item_time, item, take) -- such as take, stretch markers and transient guides time, item_time is their position within item returned by the corresponding functions
-- e.g. take, stretch markers and transient guides time to edit/play cursor, proj markers/regions time

--local cur_pos = r.GetCursorPosition()
local item_pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
--OR
--local item_pos = r.GetMediaItemInfo_Value(r.GetMediaItemTake_Item(take), 'D_POSITION')
local offset = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')
local playrate = r.GetMediaItemTakeInfo_Value(take, 'D_PLAYRATE') -- affects take start offset and take marker pos
local proj_time = item_pos + (item_time - offset)/playrate
end


---------------------------- TRIMMING ITEM EDGES --------------------------

-- Only works on selected item

-- necessity of positive or negative values depends on the reverse arg being true or false - reverse: in nudge mode, nudges left (otherwise ignored)

r.ApplyNudge(0, 0, 1, 1, negative value, false, 0) -- 0 - curr proj, 0 nudge by value, 1 - left trim, 1 - nudgeunits sec, reverse false, copies 0 (ignored) // trim left edge, negative value
-- OR r.ApplyNudge(0, 0, 1, 1, positive value, true, 0) -- 0 - curr proj, 0 nudge by value, 1 - left trim, 1 - nudgeunits sec, reverse true, copies 0 (ignored) // trim left edge, positive value

r.ApplyNudge(0, 0, 3, 1, positive value, true, 0) -- 0 - curr proj, 0 nudge by value, 3 - right edge, 1 - nudgeunits sec, reverse true, copies 0 (ignored) // trim right edge, positive value

r.ApplyNudge(0, 0, 1, 1, negative value, false, 0) -- 0 - curr proj, 0 nudge by value, 1 - left trim, 1 - nudgeunits sec, reverse false, copies 0 (ignored) // UNtrim left edge, negative value
-- OR r.ApplyNudge(0, 0, 1, 1, positive value, true, 0) -- 0 - curr proj, 0 nudge by value, 1 - left trim, 1 - nudgeunits sec, reverse true, copies 0 (ignored) // UNtrim left edge, positive value

r.ApplyNudge(0, 0, 3, 1, positive value, false, 0) -- 0 - curr proj, 0 nudge by value, 3 - right edge, 1 - nudgeunits sec, reverse false, copies 0 (ignored) // UNtrim right edge, positive value

---------------------------- TRIMMING ITEM EDGES END --------------------------

function Fades_Exist(itm)

-- D_FADEINLEN_AUTO and D_FADEOUTLEN_AUTO are only relevant when auto-crossfade is ON; doesn't make sense setting them without crossfade because this doesn't affect regular fades and when auto-crossfade occurs the values will change automatically to suit the conditions; when auto-crossfade is ON once items no longer overlap these values are reset to 0 regardless of what they were set to prior to the crossfade and lengths of regular fades which existed prior to crossfade are restored; if auto-crossfade is OFF the length values which were used during the crossfade aren't reset and replace regular fade lengths which existed prior to the crossfade, although regular fade ghost data can still be fetched via D_FADEOUTLEN/D_FADEINLEN; if after separation of items with auto-crossfade OFF, thems are made to overlap again and auto-crossfade is turned ON, after next item separation their original regular fade length is restored and auto-crossfade lengths are reset to 0 as described above;
-- Auto-crossfade in REAPER only creates crossfades with the length of each side being equal to the overlap size
-- Auto-crossfade replaces original fade if existed but doesn't remove it, when items are separated original fades are restored
-- D_FADEOUTLEN, D_FADEINLEN -- regular fade out and in, fade exists when these are greater than 0, setting these params doesn't affect fade out and in of a crossfade if D_FADEOUTLEN_AUTO/D_FADEINLEN_AUTO are greater than 0, so the latter override the former in a crossfade, but regular fade-in and fade-out lengths will change in the background
-- When auto-crossfade is OFF it doesn't matter what to fashion the crossfade with D_FADEOUTLEN_AUTO/D_FADEINLEN_AUTO or D_FADEOUTLEN/D_FADEINLEN but if items prior to being crossfaded have had fade-in/out then using D_FADEOUTLEN_AUTO/D_FADEINLEN_AUTO ensures that the length of these is restored after items are separated while auto-crossfade is turned ON, their shape and curve will still be affected by the crossfade, and their length will also be affected if crossfade was expanded manually

-- D_FADEOUTDIR, D_FADEINDIR are what's called 'curve' in the Crossfade editor and Item properties
-- C_FADEINSHAPE, C_FADEOUTSHAPE -- with regard to getting, shapes selected in the item properties
-- !!!!!! NATIVE AUTO-CROSSFADE MAKES FADE-IN SHORTER THAN THE FADE-OUT AND THE INTERSECTION AREA (which are always equal) by a tiny fraction not reflected in the Console where their values are identical due to being truncated down to 14 decimal places; the difference only transpires after subtracting fade-in length from the length of the intersection area; this doesn't happen when crossfade out and in lengths are set via API; to test equality reliably fade-in value must be converted to a string, which works perhaps because it truncates the values down to the size at which they're equal


local Get = r.GetMediaItemInfo_Value
local itm_start = Get(itm, 'D_POSITION')
local itm_end = itm_start + Get(itm, 'D_LENGTH')
local fadein_len = Get(itm, 'D_FADEINLEN')
local fadeout_len = Get(itm, 'D_FADEOUTLEN')
local itm_xfade_in_len = Get(itm, 'D_FADEINLEN_AUTO')
local itm_xfade_in_len = itm_xfade_in_len > 0 and itm_xfade_in_len or Get(itm, 'D_FADEINLEN')
local itm_xfade_in_len = itm_xfade_in_len > 0 and itm_xfade_in_len or fadein_len -- do prefer auto-crossfade fade-in value but if 0 get regular fade-in
local itm_xfade_out_len = Get(itm, 'D_FADEOUTLEN_AUTO')
local itm_xfade_out_len = itm_xfade_out_len > 0 and itm_xfade_out_len or fadeout_len -- do prefer auto-crossfade fade-out value but if 0 get regular fade-out
local itm_idx = Get(itm, 'IP_ITEMNUMBER')
local itm_tr = r.GetMediaItemTrack(itm)
local prev_itm = r.GetTrackMediaItem(itm_tr, itm_idx-1)
local prev_itm_end = prev_itm and Get(prev_itm, 'D_POSITION') + Get(prev_itm, 'D_LENGTH')
local prev_itm_xfade_out_len = prev_itm and Get(prev_itm, 'D_FADEOUTLEN_AUTO')
local prev_itm_xfade_out_len = prev_itm and (prev_itm_xfade_out_len > 0 and prev_itm_xfade_out_len or Get(prev_itm, 'D_FADEOUTLEN'))
local next_itm = r.GetTrackMediaItem(itm_tr, itm_idx+1)
local next_itm_start = next_itm and Get(next_itm, 'D_POSITION')
local next_itm_xfade_in_len = next_itm and Get(next_itm, 'D_FADEINLEN_AUTO')
local next_itm_xfade_in_len = next_itm and (next_itm_xfade_in_len > 0 and next_itm_xfade_in_len or Get(next_itm, 'D_FADEINLEN'))
local start_xfade_overlap_size = prev_itm and prev_itm_end-itm_start
local end_xfade_overlap_size = next_itm and itm_end-next_itm_start

local xfade_in = prev_itm and prev_itm_end > itm_start and prev_itm_xfade_out_len == start_xfade_overlap_size and tostring(itm_xfade_in_len) == tostring(start_xfade_overlap_size) -- both prev item fadeout and target item fadein and each of these fades is equal to the overlap size
local xfade_out = next_itm and next_itm_start < itm_end and itm_xfade_out_len == end_xfade_overlap_size and tostring(next_itm_xfade_in_len) == tostring(end_xfade_overlap_size) -- both target item fadeout and next item fadein and each of these fades is equal to the overlap size

-- Non-uniform crossfade is one in which one or both fades have length different from items intersection area length and/or from each other's, unlike regular crossfade in which fade-out and fade-in both have the length of the intersection area
local xfade_in_nonuniform = prev_itm and prev_itm_end > itm_start and not xfade_in and itm_xfade_in_len > 0 and itm_xfade_in_len + prev_itm_xfade_out_len > start_xfade_overlap_size
local xfade_out_nonuniform = next_itm and next_itm_start < itm_end and not xfade_out and itm_xfade_out_len > 0 and itm_xfade_out_len + next_itm_xfade_in_len > end_xfade_overlap_size

local fade_in = not xfade_in and not xfade_in_nonuniform and fadein_len > 0
local fade_out = not xfade_out and not xfade_out_nonuniform and fadeout_len > 0

return fade_in, fade_out, xfade_in, xfade_out, xfade_in_nonuniform, xfade_out_nonuniform -- booleans

end

local fade_in, fade_out, xfade_in, xfade_out, xfade_in_nonuniform, xfade_out_nonuniform = Fades_Exist(r.GetSelectedMediaItem(0,0))


function Get_Take_Src_Props(take)
	if take then
	local src = r.GetMediaItemTake_Source(take)
	local sect, startoffs, len, rev = r.PCM_Source_GetSectionInfo(src) -- if sect is false src_startoffs and src_len are 0
	local src = (sect or rev) and r.GetMediaSourceParent(src) or src -- retrieve original media source if section or reversed
	local filename = r.GetMediaSourceFileName(src, '') -- source pointer in takes with the same source is different therefore for comparison file name must be retrieved
	return sect, startoffs, len, rev, filename
	end
end


function Select_Items_With_Same_Src_Media(src_take) -- select only items where active take has the same media source as the source take, don't select the source take parent item if it's unselected
local src_take_file = ({Get_Take_Src_Props(src_take)})[5]
r.PreventUIRefresh(1)
r.SelectAllMediaItems(0, false) -- selected false // deselect all
	for i = 0, r.CountMediaItems(0)-1 do
	local item = r.GetMediaItem(0,i)
	local act_take = r.GetActiveTake(item)
		if act_take ~= src_take and src_take_file == ({Get_Take_Src_Props(act_take)})[5] then
		r.SetMediaItemSelected(item, true) -- selected true
		r.UpdateItemInProject(item)
		end
	end
r.PreventUIRefresh(-1)
end


function Audio_Or_MIDI_Takes(item) -- only returns valid value if all takes are either audio or midi
local audio, midi
	for i = 0, r.CountTakes(item)-1 do
	local is_midi = r.TakeIsMIDI(r.GetTake(item,i))
		if is_midi then
		midi = true
		else
		audio = true
		end
	end
return audio and not midi and 'audio' or midi and not audio and 'midi'
end


function Get_Src_Orig_Length(take)
local src = r.GetMediaItemTake_Source(take)
-- retrieve original media source if section or reversed
local sect, startoffs, sect_len, rev = r.PCM_Source_GetSectionInfo(src)
local src = (sect or rev) and r.GetMediaSourceParent(src) or src
local file = r.GetMediaSourceFileName(src, '')
local src = r.PCM_Source_CreateFromFile(file) -- must be re-created because source length within take depends of section properties if enabled and is likely to be inaccurate
local sect, startoffs, src_len, rev = r.PCM_Source_GetSectionInfo(src) -- re-get data from the mint source
--[[ OR
local src_len, lengthIsQN = r.GetMediaSourceLength(src) -- (If the media source is beat-based, the length will be in quarter notes, otherwise it will be in seconds); ONLY RETURNS FULL SOURCE LENGTH when section isn't enabled otherwse it's equal to section length, basically does what PCM_Source_GetSectionInfo() does
local sec_per_QN = 60/r.Master_GetTempo() -- sec per quarter note
local src_len = lengthIsQN and src_len*QN_per_sec or src_len
]]
r.PCM_Source_Destroy(src)
return src_len
end


function Is_Take_Source_Trimmed(take)

local src = r.GetMediaItemTake_Source(take)
local sect, startoffs, sect_len, rev = r.PCM_Source_GetSectionInfo(src) -- sect is true if 'Section' checkbox is checkmarked in 'Item Properties' (can be checkmarked with action 'Item properties: Loop section of audio item source'); when not sect startoffs is 0 and sect_len is full source length, that's because src pointer stems from a specific take; startoffs and sect_len values are raw, i.e. without accounting for the playrate just as they are displayed in the Item Properties
local src = (sect or rev) and r.GetMediaSourceParent(src) or src -- retrieve original media source if section or reversed
local playrate = r.GetMediaItemTakeInfo_Value(take, 'D_PLAYRATE')
local GET = r.GetMediaItemInfo_Value
local item = r.GetMediaItemTake_Item(take)
local itm_start = GET(item,'D_POSITION')
local itm_end = itm_start + GET(item,'D_LENGTH')
local take_startoffs = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')

local src_start, src_end

	if not sect then
	-- when not sect sect_len is entire source length, equal to the original source length, and section startoffs must be ignored
	src_start = itm_start - take_startoffs/playrate
	src_end = src_start + sect_len/playrate
	elseif sect then

	-- Get the source original length unaffected by section // do block to prevent overwriting the section
	local file = r.GetMediaSourceFileName(src, '')
	local src = r.PCM_Source_CreateFromFile(file) -- must be re-created because source length within take depends on section properties if enabled and is likely to be inaccurate
	local _, _, src_len, _ = r.PCM_Source_GetSectionInfo(src) -- re-get data from the mint source
	r.PCM_Source_Destroy(src)

	-- The part of the source included in the section may be shorter than the original source
	local src_sect_len = startoffs > 0 and (sect_len > src_len-math.abs(startoffs) and src_len-math.abs(startoffs) or sect_len) -- trimmed down on the start; startoffs must be subtracted from the section length and source length
	or startoffs <= 0 and (sect_len-math.abs(startoffs) >= src_len and src_len or sect_len-math.abs(startoffs)) -- trimmed out on the start or no change; startoffs must be subtracted from the section length but not source length because in this case source start isn't trimmed down // in both cases use the shortest length, trimmed down source ends are considered its current ends, but if they're trimmed out original source ends are used; math.abs is used to rectify the negative startoffs value when the source left edge is extended because it needs to be subtracted from the section or source length to arrive at the source start within the item
	src_start = itm_start - take_startoffs/playrate - (startoffs < 0 and startoffs/playrate or 0) -- when startoffs < 0 the source left edge is extended therefore the difference beween the extended edge and the source edge must be eliminated, when startoffs >= 0 the section start is already the source start or later; in looped items src start is the start of the 1st visible loop iteration
	src_end = src_start + src_sect_len/playrate
		if rev then
		local sect_start = itm_start - take_startoffs/playrate
		local sect_end = sect_start + sect_len/playrate
		local midline = sect_start + (sect_end - sect_start)/2
		-- swap start and end distances relative to the section midline
		local src_start_dist, src_end_dist = midline - src_start, src_end - midline
		src_start, src_end = midline - src_end_dist, midline + src_start_dist
		end
	end

return sect, itm_start > src_start, itm_end < src_end, src_start, src_end -- src_start & src_end are those within the item, not of the original source

end

-- USE EXAMPLE
-- local sect, trimmed_down_start, trimmed_down_end, src_start, src_end = Is_Take_Source_Trimmed(take)


function Create_Take_Source_Section(item, take, trim_left, trim_right) -- trim_left & trim_right vars can be positive and negative
local src = r.GetMediaItemTake_Source(src_take)
local sect, startoffs, len, rev = r.PCM_Source_GetSectionInfo(src_src) -- sect_src is true if 'Section' checkbox is checkmarked in 'Item Properties' (can be checkmarked with action 'Item properties: Loop section of audio item source')
local src = (sect or rev) and r.GetMediaSourceParent(src) or src -- retrieve original media source if section or reversed
	if sect then r.Main_OnCommand(40547,0) end -- Item properties: Loop section of audio item source // uncheck if checked
Set_Take(take, 'D_STARTOFFS', trim_left)
Set_Item(item, 'D_LENGTH', trim_right) -- set to the desired section length
r.Main_OnCommand(40547,0) -- Item properties: Loop section of audio item source // check to enable section in the dest take // ADDS 10 ms OF SECTION FADE, can only be modified via item chunk as OVERLAP parameter in <SOURCE SECTION section
end


function Get_Take_Phase(take, item) -- relies on GetObjChunk2() function

local idx = r.GetMediaItemTakeInfo_Value(take, 'IP_TAKENUMBER')
local _, GUID = r.GetSetMediaItemTakeInfo_String(take, 'GUID', '', false) -- setNewValue false
local ret, chunk = GetObjChunk2(item)

	if ret then -- if chunk size exceeds the limit without the SWS extension the return val will be nil
	local t, found = {}
		for line in chunk:gmatch('[^\n\r]+') do
			if idx == 0 or line:match(Esc(GUID)) then found = 1 end
			if idx ~= 0 then t[#t+1] = line end -- if take idx is not 0, collect chunk lines to be able to iterate over them in reverse since TAKEVOLPAN parameter precedes take GUID
			if line and found and (line:match('VOLPAN') or #t > 0) then
			local src_phase
				if idx == 0 then
				src_phase = line:match('VOLPAN .- .- ([%d%.%-]+)')
				else
					for i = #t,1,-1 do -- in reverse since TAKEVOLPAN parameter precedes take GUID
						if t[i]:match('TAKEVOLPAN') then
						src_phase = t[i]:match('TAKEVOLPAN .- ([%d%.%-]+)') break
						end
					end
				end
			return src_phase+0 < 0, -- phase is on
			chunk -- return chunk to be re-used at the propagation stage if to_all_takes option is enabled to avoid getting chunk repeatedly for each take of the same item
			end
		end
	end

end


function MPL_Set_Startoffs_With_Stretch_Mrkrs(take, startoffs)
-- overcomes the limitation which prevents changing start offset when there're stretch markers
-- https://forum.cockos.com/showthread.php?t=180571#3

--local item =  r.GetMediaItem(0, 0)
--local take = r.GetActiveTake(item)
r.SetMediaItemTakeInfo_Value(take, "D_STARTOFFS", startoffs)

	for i = 0, r.GetTakeNumStretchMarkers(take)-1 do
	local retval, pos, srcpos = r.GetTakeStretchMarker(take, i)
	r.SetTakeStretchMarker(take, i, pos-startoffs, srcpos)
	end

r.UpdateItemInProject(r.GetMediaItemTake_Item(take))
end


function Re_Store_Apply_Stretch_Markers(src_take, dest_take, t)
-- stretch markers are stored and applied relative to the media source start within take, playrate is taken into account automatically; one scenario it doesn't work as expected is when the source take has a section created after adding SMs and the start is trimmed in either direction which makes the media source shift and leave empty space behind some SMs, in this scenario when the source take is trimmed out the SMs are still pasted to the dest take telative to its media source start as they're supposed to but by this they don't replicate their relative position in the src take, when the src take is trimmed down SMs are pasted starting before the dest take media source and kind of do replicate their relative position in the src take being placed over empty space which however isn't how they are designed to be pasted with this function; in this scenario calculation of the media source start in the source take produces the same result as when this scenario doesn't take place as if the source start got pinned by the SMs, so not sure there's a way to calculate the actual new source start; overall these seem like extremely edge cases (whoever creates sections after adding SMs?) so not worth addressing at this stage

-- https://github.com/ReaTeam/Doc/blob/master/X-Raym_Working%20with%20Stretch%20Markers%20ReaScript%20API.md
-- https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Items%20Properties/X-Raym_Reset%20stretch%20marker%20under%20mouse%20position.lua
-- https://forum.cockos.com/showthread.php?t=248801

	local function get_values_for_offset_calc(take)
	-- Calculate source position within take to adjust markers position if the former doesn't coincide with the item start
	local take_startoffs = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')
	local src = r.GetMediaItemTake_Source(take)
	local sect, src_startoffs, sect_len, rev = r.PCM_Source_GetSectionInfo(src) -- when sect is false src_startoffs is 0, sect_len equals full source length
	local item = r.GetMediaItemTake_Item(take)
	local itm_start = r.GetMediaItemInfo_Value(item,'D_POSITION')
	local src_start = itm_start - take_startoffs - (src_startoffs < 0 and src_startoffs or 0) -- when src_startoffs < 0 the source left edge is extended therefore the difference beween the extended edge and the source edge must be eliminated, when src_startoffs >= 0 the
	return itm_start, src_start, src_startoffs
	end

local mrkrs_cnt = r.GetTakeNumStretchMarkers(src_take)
	if not t and mrkrs_cnt > 0 then
	local t = {}
	local itm_start, src_start = get_values_for_offset_calc(src_take)
	local diff = src_start - itm_start
		for idx = 0, mrkrs_cnt-1 do
		local retval, posInitm, posInsrc = r.GetTakeStretchMarker(src_take, idx) -- posInitm is relative to the item start, posInsrc value is equal to posInitm value when no slope and rate is 1, it's constant and independent of slopes and rates
		local slope = r.GetTakeStretchMarkerSlope(src_take, idx)
		t[#t+1] = {posInitm=posInitm-diff, posInsrc=posInsrc, slope=slope} -- adjusting posInitm so it becomes relative to the media source start because it will be pasted relative to it as well, posInsrc apparently doesn't need adjustment
		end
	--[[OR
	local i = -1
		repeat
		local retval, posInitm, posInsrc = r.GetTakeStretchMarker(src_take, i)
			if retval then
			local slope = r.GetTakeStretchMarkerSlope(src_take, retval)
			t[#t+1] = {posInitm=posInitm-diff, posInsrc=posInsrc, slope=slope} -- adjusting posInitm so it becomes relative to the media source start because it will be pasted relative to it as well, posInsrc apparently doesn't need adjustment
			end
		i = i+1
		until retval == -1
	]]
	return t
	elseif t then
	local mrkrs_cnt = r.GetTakeNumStretchMarkers(dest_take)
		if mrkrs_cnt > 0 then -- delete all stretch markers from the dest take
			for i = mrkrs_cnt-1,0,-1 do
			r.DeleteTakeStretchMarkers(dest_take, i, 1) -- countIn 1, don't know what this argument is for but 0 prevents deletion, any INTEGER greater than 0 will do, i-1 leaves first 2 markers undeleted, i-2 leaves first 3 and so on
			end
		end
	-- OR
	-- r.Main_OnCommand(41844, 0) -- Item: Remove all stretch markers // removes from the active take BUT the item must be selected and take activated

	local itm_start, src_start, src_startoffs = get_values_for_offset_calc(dest_take)
	local diff1, diff2
		for k, props in ipairs(t) do -- paste stretch markers relative to current media source start within item accounting for section
		diff1 = not diff1 and src_start - itm_start or diff1 -- only calculate once
		diff2 = not diff2 and (src_startoffs ~= 0 and src_startoffs or 0) or diff2 -- only assign value once
		r.SetTakeStretchMarker(dest_take, -1, props.posInitm + diff1, props.posInsrc - diff2) -- idx is -1 to add a marker
		end
		for idx, props in ipairs(t) do -- setting slope only makes sense when all markers are added because it requires two markers
		r.SetTakeStretchMarkerSlope(dest_take, idx-1, props.slope)
		end

	r.UpdateItemInProject(r.GetMediaItemTake_Item(dest_take))

	end

end

-- USAGE
-- local t = Re_Store_Apply_Stretch_Markers(src_take, dest_take)
-- Re_Store_Apply_Stretch_Markers(src_take, dest_take, t)


function Find_And_Get_New_Items(t)
	if not t then
	local t = {}
		for i = 0, r.CountMediaItems(0)-1 do
		t[r.GetMediaItem(0,i)] = '' -- dummy field
		end
	return t
	elseif t then
	local t2 = {}
		for i = 0, r.CountMediaItems(0)-1 do
		local itm = r.GetMediaItem(0,i)
			if not t[itm] then -- track wasn't stored so is new
			t2[#t2+1] = itm
			end
		end
	return #t2 > 0 and t2
	end
end


function Is_Item_Looped_In_Arrange(item) -- or extended beyond its non-looped source

local src = r.GetMediaItemTake_Source(take)
local is_source_looped = r.GetMediaItemInfo_Value(item, 'B_LOOPSRC') == 1
local is_sect, start_offset_sect, len_sect, is_reversed = r.PCM_Source_GetSectionInfo(src) -- works for both section and full source
local start_offset_take = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS') -- negative if start is extended beyond a non-looped source
local len_item = r.GetMediaItemInfo_Value(item, 'D_LENGTH')

return start_offset_take < 0, -- non-looped extended beyond start // true or false
not is_source_looped and len_item > len_sect - start_offset_take, -- non-looped extended beyond end // same
is_source_looped and start_offset_take >= 0 and len_item > len_sect - start_offset_take -- looped in Arrange // same

end



function Import_Item_To_RS5k(item, track, rs5k_idx) -- doesn't set sample Mode and doesn't map to a keyboard key

local is_source_looped = r.GetMediaItemInfo_Value(item, 'B_LOOPSRC') == 1
local take = r.GetActiveTake(item)
local pitch_shift = r.GetMediaItemTakeInfo_Value(take, 'D_PITCH') -- in semitones
local env = r.GetTakeEnvelopeByName(take, 'Pitch')
local pitch_env_val
	if env then -- pitch of only the 1st point in the envelope is respected
	retval, time, pitch, shape, tens, is_sel = r.GetEnvelopePointEx(env, -1, 0)
	pitch_env_val = pitch ~= 0 and pitch or 0
	end

-- get origial media source to calculate unit for convertion of item boundaries into region boundaries within RS5k
local src = r.GetMediaItemTake_Source(take)
local src = r.GetMediaSourceParent(src) or src -- in case the item is a section or a reversed source; if item is a section the next function will return actual item length rather than the source's, hence unsuitable for unit calculation (for which full source length is required) neither suitable for file name retrieval and parent source must be retrieved
-- convert source length to sample region units used in rs5k (0 - 1)
local len_src, is_lengthInQN = r.GetMediaSourceLength(src)
local unit = 1/len_src

local file_name = r.GetMediaSourceFileName(src, '')

local src = r.GetMediaItemTake_Source(take) -- re-initialize to get the actual length of the section in Arrange, if any, rather than the source's which was retrieved above for the sake of unit calculation
local is_sect, start_offset_sect, len_sect, is_reversed = r.PCM_Source_GetSectionInfo(src) -- works for both section and full source
local start_offset_take = r.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS') -- negative if start is extended beyond a non-looped source
local take_playrate = r.GetMediaItemTakeInfo_Value(take, 'D_PLAYRATE')
local len_item = r.GetMediaItemInfo_Value(item, 'D_LENGTH')*take_playrate
local vol_item = r.GetMediaItemInfo_Value(item, 'D_VOL')
local vol_item_dB = 20*math.log(vol_item,10)
local vol_take = r.GetMediaItemTakeInfo_Value(take, 'D_VOL')
local vol_take_dB = 20*math.log(vol_take,10)
local vol = 10^((vol_item_dB + vol_take_dB)/20)
-- val and dB conversion forumula from SPK77
-- https://forum.cockos.com/showthread.php?p=1608719

-- When item is looped only the very first iteration, which can be partial due to trim, is translated into RS5k sample area
-- Enabling reverse in Item Properties turns item into section even when Section option isn't explicitly checkmarked
-- After import into RS5k of a reversed item, section or not, trimmed or not, looped or not, the sample region accurately reflects boundaries of the non-reversed source; for original section boundaries to be respected special calculations are required which are pointless because the sample area won't match item playback anyway due to reverse
-- If a non-looped item is untrimmed from the left, start_offset_take value is negative throwing the region start position off in RS5k since RS5k respects the negative offset, so it must be accounted for

-- Start is either Section: (first field) or 'Start in source' value in the Media Item Properties window; len is either Length (under Position) or Section: Length in Media Item Properties window; accounting for left and right edges trim
local start = start_offset_take >= 0 and start_offset_sect + start_offset_take or start_offset_sect -- accounting for extension or trim of the left edge; when item source is looped item's left (and right for that matter) edge can't be extended beyond source, otherwise extension is ignored
local len = is_source_looped and len_item > len_sect - start_offset_take and len_sect - start_offset_take -- item is looped in Arrange
or start_offset_take < 0 and len_item + start_offset_take > len_sect and len_sect -- item is extended beyond its source at the start and at the end
or start_offset_take >= 0 and len_item > len_sect - start_offset_take and len_sect - start_offset_take -- item is extended beyond its source at the end
or start_offset_take < 0 and len_item + start_offset_take -- item is extended beyond its source at the start
or len_sect >= len_item and len_item -- item is or isn't trimmed at either end

r.TrackFX_SetNamedConfigParm(track, rs5k_idx, 'FILE0', file_name)
local set_inf = vol < 1 and r.TrackFX_SetParam(track, rs5k_idx, 2, 0) -- 'Gain for minimum velocity' aka 'Min vol' // set to -inf if item/take voulume < 0 so negative vol can be set
r.TrackFX_SetParam(track, rs5k_idx, 0, vol) -- 'Volume' // Normalized type of function must not be used since take (and item) volume scale isn't linear
-- no difference between the result of using functions below with or without Normalized
r.TrackFX_SetParamNormalized(track, rs5k_idx, 13, start*unit) -- 'Sample start offset'
-- r.TrackFX_SetParam(track, rs5k_idx, 13, start*unit)
r.TrackFX_SetParamNormalized(track, rs5k_idx, 14, (start+len)*unit) -- 'Sample end offset'
--r.TrackFX_SetParam(track, rs5k_idx, 14, (start+len)*unit)
r.TrackFX_SetParam(track, rs5k_idx, 15, 0.5+pitch_shift+pitch_env_val*1/160) -- 'Pitch offset' aka Pitch adjust
--r.TrackFX_SetParamNormalized(track, rs5k_idx, 15, 0.5+pitch_shift+pitch_env_val*1/160) -- 'Pitch offset' aka Pitch adjust
end



--================================ I T E M S   E N D ==================================


--=================================== C O L O R =======================================

function Validate_HEX_Color_Setting(HEX_COLOR)
local HEX_COLOR = type(HEX_COLOR) == 'string' and HEX_COLOR:gsub('%s','') -- remove empty spaces just in case

-- default to black if color is improperly formatted
local HEX_COLOR = (not HEX_COLOR or type(HEX_COLOR) ~= 'string' or HEX_COLOR == '' or #HEX_COLOR < 4 or #HEX_COLOR > 7) and '#000' or HEX_COLOR

--[[ alternative to defaulting to black color above, abort color setting if HEX_COLOR var is malformed
local HEX_COLOR = type(HEX_COLOR) == 'string' and #HEX_COLOR >= 4 and #HEX_COLOR <= 7 and HEX_COLOR
	if not HEX_COLOR then return end
]]

-- extend shortened (3 digit) hex color code, duplicate each digit
local HEX_COLOR = #HEX_COLOR == 4 and HEX_COLOR:gsub('%w','%0%0') or not HEX_COLOR:match('^#') and '#'..HEX_COLOR or HEX_COLOR -- adding '#' if absent
return HEX_COLOR -- TO USE THE RETURN VALUE AS ARG IN hex2rgb() function UNLESS IT'S INCLUDED IN THIS ONE AS FOLLOWS
--local R,G,B = hex2rgb(HEX_COLOR) -- R because r is already taken by reaper, the rest is for consistency
--return R, G, B
end

function hex2rgb(HEX_COLOR)
-- https://gist.github.com/jasonbradley/4357406
    local hex = HEX_COLOR:sub(2) -- trimming leading '#'
    return tonumber('0x'..hex:sub(1,2)), tonumber('0x'..hex:sub(3,4)), tonumber('0x'..hex:sub(5,6))
end


function HexToNormRGB(color) -- by FTC
-- https://github.com/iliaspoulakis/Reaper-Tools/blob/master/Media%20explorer/MX%20Tuner.lua
    local r, g, b = r.ColorFromNative(color)
    return {r / 255, g / 255, b / 255}
end

function rgb2hex(r, g, b)
-- https://gist.github.com/yfyf/6704830
    return string.format("#%0.2X%0.2X%0.2X", r, g, b)
end


function RANDOM_RGB_COLOR()
math.randomseed(math.floor(r.time_precise()*1000)) -- math.floor() because the seeding number musr be integer; seems to facilitate greater randomization at fast rate thanks to milliseconds count
--[[
local RGB = {}
	for i = 1, 3 do
	RGB[i] = math.random(1,256)-1 -- seem to produce 2 digit numbers more often than (0, 255), but could be my imagination
	end
--]]
--[-[
local RGB = {r = 0, g = 0, b = 0}
	for k in pairs(RGB) do -- adds randomization (i think) thanks to pairs which traverses in no particular order // once it picks up a particular order it keeps at it throughout the entire main repeat loop when multiple colors are being set
	RGB[k] = math.random(1,256)-1 -- seems to produce 2 digit numbers more often than (0,255), but could be my imagination
--Msg(k)
	end
--Msg(RGB.r); Msg(RGB.g); Msg(RGB.b)
--]]
return RGB
end


function zaibuyidao_RGBHexToDec(R, G, B)
-- https://raw.githubusercontent.com/zaibuyidao/ReaScripts/239ebd6a73cf5e7b124ef6f65b21e8eae63acd61/Regions/zaibuyidao_Set%20Region%20Color.lua
  local red = string.format("%x", R)
  local green = string.format("%x", G)
  local blue = string.format("%x", B)
  if (#red < 2) then red = "0" .. red end
  if (#green < 2) then green = "0" .. green end
  if (#blue < 2) then blue = "0" .. blue end
  local color = "01" .. blue .. green .. red
  return tonumber(color, 16)
end


------------------- ENCODE RGB TO AND DECODE FROM INTEGER ------------------

--https://github.com/ReaTeam/ReaScripts/blob/master/Regions/stepanhlavsa_Big%20region%20progress%20bar%20for%20live%20use.lua

local function rgb2num(r, g, b)
  g = g * 256
  b = b * 256 * 256
  return r + g + b
end

local function num2rgb(integer)
   local R = integer & 255
   local G = (integer >> 8) & 255
   local B = (integer >> 16) & 255
   local R = R/255
   local G = G/255
   local B = B/255
   return R,G,B
end


function RGB_To_From_Integer(r,g,b,integer)
-- based on https://stackoverflow.com/a/19277438/8883033
	if not integer and r and g and b then
	local blueMask, greenMask, redMask = 0xFF0000, 0xFF00, 0xFF
	local r, g, b = 12, 13, 14
	return bgrValue = (b << 16) + (g << 8) + r
	elseif integer then
	local b = bgrValue & blueMask) >> 16
	local g = (bgrValue & greenMask) >> 8
	local r = bgrValue & redMask
	return r, g, b
	end
end

function RGB_To_From_Integer(r,g,b,integer)
-- based on https://stackoverflow.com/a/29130472/8883033
-- local r, g, b = 111, 222, 121
	if not integer and r and g and b then
	local code = red*256*256 + green*256 + blue
	return code
	elseif integer then
	local red = (code - blue - green*256)/(256*256)
	local green = (code%(256*256) - blue)/256
	local blue = code%256
	return r, g, b
	end
end


-------------- ENCODE RGB TO AND DECODE FROM INTEGER END ------------------


--================================ C O L O R   E N D ==================================


--============================ C L O S U R E S  S T A R T =============================

-- 'Set all selected video items to Ignore Audio.lua' by Claudiohbsantos
function LoopOverSelectedItems(proj) -- iterator function, doesn't depend on items count, doesn't produce error when no (more) items
	local i = -1 -- to begin iterator with 0 below
	return function() i = i+1; return r.GetSelectedMediaItem(proj, i) end
end
-- USAGE
for item in LoopOverSelectedItems(0) do -- if no items, the loop doesn't start
end


function return_captures(src_str, capt_str, patt) -- patt is boolean, true = pattern, false = literal string
local capt_str = patt and capt_str or capt_str:gsub('[%(%)%+%-%[%]%.%^%$%*%?%%]','%%%0') -- do not escape if pattern; escape if literal string
local i = 1
	return function()
	local st, fin, capt = src_str:find('('..capt_str..')',i)
		if i == fin then i = i + 1 -- allow capturing single chracters advancing by 1
		elseif fin then i = fin+1 end -- allow capturing series of characters
	return capt
	end
end

-- USAGE
-- if no captures the loop doesn't start
for capt in count_captures(str, 'find') do
-- OR
--for capt in count_captures(str, '%a+', 1) do -- with 3d argument to enable pattern '%a+'
Msg(capt)
end


--================================ C L O S U R E S  E N D ==============================


--======================= M A R K E R S  &  R E G I O N S ==========================


--local retval, isrgn, pos, rgnend, name, markID, color = r.EnumProjectMarkers3(0, i)
function is_region_within_time_sel(start, fin, pos, rgnend)
-- start/fin are of time sel, pos/rgnend are of the region
local start, fin = r.GetSet_LoopTimeRange(false, false, 0, 0, false) -- isSet, isLoop  false; start, end - 0, allowautoseek false
local time_sel = start ~= fin
	if time_sel then
	return pos >= start and pos <= fin or rgnend >= start and rgnend <= fin
	end
end


function get_region_at_edit_or_mouse_cursor()

	local function get_region(cur_pos)
	--[[
	local _, regionidx = r.GetLastMarkerAndCurRegion(0, cur_pos) -- DOESN'T RETURN REGION INDEX IF THE EDIT CURSOR IS ALIGNED WITH ITS END, seems like a bug https://forums.cockos.com/showthread.php?t=271806
		if regionidx > -1 then
		local retval, isrgn, pos, rgnend, name, idx, color = r.EnumProjectMarkers3(0, regionidx) -- markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
Msg(name, 'name')
		return {name=name:match('%s*(.+[%w%p]+)') or name, color=color, pos=pos, rgnend=rgnend} -- trimming leading and trailing spaces from the name
		end
	]]
	--[-[-- same as 'if regionidx > -1' statement, would be if it wasn't for the GetLastMarkerAndCurRegion() bug
	local i = 0
		repeat
		local retval, isrgn, pos, rgnend, name, idx, color = r.EnumProjectMarkers3(0, i) -- markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
			if isrgn and cur_pos >= pos and cur_pos <= rgnend then
			-- DO STUFF --
			return idx end
		i = i+1
		until retval == 0 -- until no more markers/regions
	--]]
	end

local cur_pos_init = r.GetCursorPosition()
local found

local idx = get_region(cur_pos_init)

	if not idx then -- edit cursor isn't at a region
	ACT(40514) -- View: Move edit cursor to mouse cursor (no snapping)
	local cur_pos = r.GetCursorPosition()
	local return_val = get_region(cur_pos)
	r.SetEditCurPos(cur_pos_init, false, false) -- moveview, seekplay false // restore orig edit curs pos
	end

end



function GetRegion()
local cur_pos = r.GetCursorPosition()
local _, regionidx = r.GetLastMarkerAndCurRegion(0, cur_pos)
	if regionidx == -1 then
	_, regionidx = r.GetLastMarkerAndCurRegion(0, cur_pos-.1^10) -- an attempt to overcome the bug https://forums.cockos.com/showthread.php?t=271806 where the region end isn't recognized by the function as part of the region
	return retval, isrgn, pos, rgnend, name, idx, color = r.EnumProjectMarkers3(0, regionidx) -- markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
	end
end


-- ONLY MARKERS
local function Store_Delete_Restore_Proj_Markers(t)	-- the function is to be used twice, first to store markers then to restore them; t is marker table created with this function which is fed at the restration stage
	if not t then -- store and delete
	---------------------------METHOD 1: Store and delete markers within one loop in descending order ------------------------
	local retval, num_markers, num_regions = r.CountProjectMarkers(0)
	local i = num_markers + num_regions-1 -- -1 isn't necessary, if there's no marker with the initial index no error occurs, just one extra loop cycle
	local markers_t = {}
	repeat -- store and delete in decscending order
		local retval, is_rgn, pos, rgn_end, name, mrk_idx, color = r.EnumProjectMarkers3(0, i) -- mrk_id is the actual marker ID displayed in Arrange which may differ from retval // markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
			if not is_rgn then -- only consider markers
			markers_t[#markers_t+1] = {mrk_idx, pos, name, color}
			end
		r.DeleteProjectMarker(0, mrk_idx, false) -- isrgn is false
		i = i - 1
		until i == -1 -- OR retval == 1 and not is_rgn -- until the iterator is less than the 1st marker index or until the 1st marker
--[[---------------------------METHOD 2: Store and delete markers within one loop in ascending order --------------------
	local i = 0
	local markers_t = {}
	repeat -- store and delete in acscending order
		local retval, is_rgn, pos, rgn_end, name, mrk_idx, color = r.EnumProjectMarkers3(0,i) -- mrk_id is the actual marker ID displayed in Arrange which may differ from retval // markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
			if retval > 0 and not is_rgn then -- only consider markers
			markers_t[#markers_t+1] = {mrk_idx, pos, name, color}
			r.DeleteProjectMarker(0, mrk_idx, false) -- isrgn is false; can be put outside of the block since only markers are targeted
			i = i - 1 -- compensate i count after each deletion so it keeps matching the indices of the remaining markers
			end
		i = i + 1
		until retval == 0
---------------------METHOD 3: First store markers then delete in a separate loop -----------------
	local i = 0
	local markers_t = {}
		repeat -- store markers
		local retval, is_rgn, pos, rgn_end, name, mrk_idx, color = r.EnumProjectMarkers3(0, i) -- mrk_id is the actual marker ID displayed in Arrange which may differ from retval // markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
			if retval > 0 and not is_rgn then -- only consider markers
			markers_t[#markers_t+1] = {mrk_idx, pos, name, color}
			end
		i = i + 1
		until retval == 0 -- until no more markers/regions
		for _, v in ipairs(markers_t) do -- delete in a separate loop
		r.DeleteProjectMarker(0, v[1], false) -- isrgn is false; v[1] is mrk_idx, the actual marker ID displayed in Arrange
		end
		]]
	return markers_t
	else -- restore
		for _,v in ipairs(t) do
		local mrk_idx, pos, name, color = table.unpack(v) -- extra step for clarity
		r.AddProjectMarker2(0, false, pos, 0, name, mrk_idx, color) -- isrgn is false
		end
	end
end


-- MARKERS AND REGIONS
local function Store_Delete_Restore_Proj_Mark_Regions(t) -- the function is to be used twice, first to store markers/regions then to restore them; t is marker/region table created with this function which is fed at the restration stage
	if not t then -- store and delete
	---------------------------METHOD 1: Store and delete markers/regions within one loop in descending order ------------------------
	local retval, num_markers, num_regions = r.CountProjectMarkers(0)
	local i = num_markers + num_regions-1 -- -1 isn't necessary, if there's no marker with the initial index no error occurs, just one extra loop cycle
	local mark_reg_t = {}
	repeat -- store and delete in decscending order
		local retval, is_rgn, pos, rgn_end, name, mrk_idx, color = r.EnumProjectMarkers3(0, i) -- mrk_id is the actual marker ID displayed in Arrange which may differ from retval // markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
			if retval > 0 then
			local rgn_end = is_rgn and rgn_end
			mark_reg_t[#mark_reg_t+1] = {mrk_idx, pos, rgn_end, name, color}
			end
		-- the cond is needed to avoid deleting objects (markers/regions) with the same index ahead of time
		local del = not is_rgn and r.DeleteProjectMarker(0, mrk_idx, false) -- isrgn is false, markers only
		local del = is_rgn and r.DeleteProjectMarker(0, mrk_idx, true) -- isrgn is true, regions only
		i = i - 1
		until i == -1 or retval == 0 -- OR retval == 1 or retval == 0 -- until the iterator is less than the 1st marker/region index or until the 1st marker/region or until retval == 0 if no markers/regions
--[[---------------------------METHOD 2: Store and delete markers/regions within one loop in ascending order --------------------
	local i = 0
	local  mark_reg_t = {}
	repeat -- store and delete in acscending order
		local retval, is_rgn, pos, rgn_end, name, mrk_idx, color = r.EnumProjectMarkers3(0,i) -- mrk_id is the actual marker ID displayed in Arrange which may differ from retval // markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
			if retval > 0 then
			local rgn_end = is_rgn and rgn_end
			mark_reg_t[#mark_reg_t+1] = {mrk_idx, pos, rgn_end, name, color}
			-- the cond is needed to avoid deleting objects (markers/regions) with the same index ahead of time
			local del = not is_rgn and r.DeleteProjectMarker(0, mrk_idx, false) -- isrgn is false, markers only; can be put outside of the block
			local del = is_rgn and r.DeleteProjectMarker(0, mrk_idx, true) -- isrgn is true, regions only
			i = i - 1 -- compensate i count after each deletion so it keeps matching the indices of the remaining markers/regions
			end
		i = i + 1
		until retval == 0
---------------------METHOD 3: First store markers/regions then delete in a separate loop -----------------
	local i = 0
	local mark_reg_t = {}
		repeat
		local retval, is_rgn, pos, rgn_end, name, mrk_idx, color = r.EnumProjectMarkers3(0, i) -- mrk_id is the actual marker ID displayed in Arrange which may differ from retval // markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
			if retval > 0 then
			local rgn_end = is_rgn and rgn_end
			mark_reg_t[#mark_reg_t+1] = {mrk_idx, pos, rgn_end, name, color}
			end
		i = i + 1
		until retval == 0 -- until no more markers/regions
		for _, v in ipairs(mark_reg_t) do -- delete in a separate loop since doing it in descending or ascending order in the loop above is pretty complicated due to regions interference with the count
		local del = not v[3] and r.DeleteProjectMarker(0, v[1], false) -- isrgn is false, markers only; v[3] is region end, v[1] is mrk_idx, the actual marker ID displayed in Arrange
		local del = v[3] and r.DeleteProjectMarker(0, v[1], true) -- isrgn is true, regions only
		end
		]]
	return mark_reg_t
	else -- restore
		for _,v in ipairs(t) do
		local mrk_idx, pos, rgn_end, name, color = table.unpack(v) -- extra step for clarity
		-- the cond is needed to avoid inserting markers with region start point and regions with the end point being nil which will throw an error
		local marker = not rgn_end and r.AddProjectMarker2(0, false, pos, 0, name, mrk_idx, color) -- isrgn is false, markers only
		local region = rgn_end and r.AddProjectMarker2(0, true, pos, rgn_end, name, mrk_idx, color) -- isrgn is true, regions only
		end
	end
end



function lexaproductions_Region_IsSelected(idx)
-- https://forum.cockos.com/showthread.php?t=255987#9
local title = r.JS_Localize('Region/Marker Manager', 'common')
local hwnd = r.JS_Window_Find(title, true)
local isOpened = hwnd
	if not hwnd then -- Open Region Manager window if not found,
		r.Main_OnCommand(40326) -- View: Show region/marker manager window
		hwnd = r.JS_Window_Find(title, true)
		if not hwnd then return end
	end
r.DockWindowActivate(hwnd) -- OPTIONAL: Select/show manager if docked
r.JS_Window_SetForeground(hwnd)-- Set focus on Manager window
local lv = reaper.JS_Window_FindChildByID(hwnd, 1071)
	if not isOpened then r.Main_OnCommand(40326) end -- View: Show region/marker manager window
return reaper.JS_ListView_GetItemState(lv, idx-1) > 0
end



function Get_First_MarkerOrRgn_After_Time(time, USE_REGIONS, KEYWORD) -- time in sec // accounting for all overlaps
local i, mrkr_idx, rgn_idx = 0, -1, -1 -- -1 to count as 0-based
local ret_idx, ret_pos, ret_name, ret_rgn_end--, ref_time
	repeat
	local retval, isrgn, pos, rgn_end, name, idx, color = r.EnumProjectMarkers3(0, i) -- markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
	mrkr_idx = retval > 0 and not isrgn and mrkr_idx+1 or mrkr_idx -- this counting method is used to conform with the type of index expected by the GoToMarker() function
	rgn_idx = retval > 0 and isrgn and rgn_idx+1 or rgn_idx -- relic of the prev version because GoToRegion() was discarded
		if retval > 0 then
			if not USE_REGIONS and not isrgn then
				if not ret_pos and pos > time or ret_pos and pos == ret_pos then -- find 1st then look for overlaps
				ret_idx = mrkr_idx; ret_pos = pos; ret_name = name
				end
			elseif USE_REGIONS and isrgn then
				if not ret_pos and pos > time or ret_pos and pos == ret_pos and rgn_end >= ret_rgn_end then -- find 1st then look for overlaps // automatically respects the longest region
				ret_idx = rgn_idx; ret_pos = pos; ret_name = name; ret_rgn_end = rgn_end
				end
			end
		end
	i = i+1
	until retval == 0 -- until no more markers/regions

	if ret_name and ret_name:lower():match(Esc(KEYWORD)) then -- no overlaps or overlaps, the last of which contains the KEYWORD
	return ret_idx, ret_pos, ret_name, ret_rgn_end
	elseif ret_name then -- no overlaps and no KEYRORD or overlaps, the last of which doesn't contain the KEYWORD, search for next which does
	local ret_idx, ret_pos, ret_name, ret_rgn_end = Get_First_MarkerOrRgn_After_Time(ret_pos, USE_REGIONS, KEYWORD)
	return ret_idx, ret_pos, ret_name, ret_rgn_end
	end

end


function Find_Next_MrkrOrRgn_By_Name(ref_idx, ref_pos, USE_REGIONS, KEYWORD) -- or by the lack of elements in the name; ref_idx is 0-based // accounting for all overlaps

-- when markers are ovelapping and their lanes are collapsed, the displayed index
-- is that of the marker with the lowest index among the overlaping ones,
-- while the name is that of the marker with the highest index,
-- with overlapping regions the name and the index of the region with the greater index
-- covers the name and the index of the region with the smaller index,
-- since in this script the name defines the marker role we need to make sure that
-- the marker with the KEYWORD isn't overlapped by a marker with a greater index without the KEYWORD
-- because in this case the KEYWORD won't be visible and the marker must be treated as a regular one,
-- and that on the other hand a marker without the KEYWORD (the one to jump to) is not overlapped
-- by a marker with a greater index with the KEYWORD, because in this case the KEYWORD will be visible
-- and the marker will have to be treated as the skip trigger

	if not ref_idx then return end
local i, mrkr_idx, rgn_idx = 0, -1, -1 -- -1 to count as 0-based
local ret_idx, ret_pos, ret_name, ret_rgn_end
	repeat
	local retval, isrgn, pos, rgn_end, name, idx, color = r.EnumProjectMarkers3(0, i) -- markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
	mrkr_idx = retval > 0 and not isrgn and mrkr_idx+1 or mrkr_idx -- this counting method is used to conform with the type of index expected by the GoToMarker() function
	rgn_idx = retval > 0 and isrgn and rgn_idx+1 or rgn_idx -- relic of the prev version because GoToRegion() was discarded
		if retval > 0 then
			if not USE_REGIONS and not isrgn then
				if not ret_pos and pos > ref_pos or ret_pos and pos == ret_pos then -- find 1st then look for overlaps
				ret_idx = mrkr_idx; ret_name = name; ret_pos = pos
				end
			elseif USE_REGIONS and isrgn then -- only search for continguous regions, for regions ref_pos is region end
				--[[ WORKS, doesn't respect the longest region
				if pos <= ref_pos and (ret_rgn_end and rgn_end >= ret_rgn_end or rgn_end > ref_pos) then -- find 1st then look for overlaps
				ret_idx = rgn_idx; ret_name = name; ret_rgn_end = rgn_end
				end
				]]
				if pos <= ref_pos and rgn_end > ref_pos then
					if not ret_rgn_end or ret_rgn_end and rgn_end >= ret_rgn_end then -- -- find 1st then look for overlaps respecting the longest region
					ret_idx = rgn_idx; ret_name = name; ret_rgn_end = rgn_end;
					end
				end

			end
		end
	i = i+1
	until retval == 0 -- until no more markers/regions

	if not USE_REGIONS and ret_name then
		if not ret_name:lower():match(Esc(KEYWORD)) then -- no overlaps and no KEYWORD or overlaps, the last of which doesn't contain the KEYWORD, return because this one must be skipped to
		return ret_idx, ret_pos
		else -- no overlaps and KEYWORD or overlaps, the last of which contains the KEYWORD, search for the next until the one without the KEYWORD is found, because this one must be skipped over
		local ret_idx, ret_pos = Find_Next_MrkrOrRgn_By_Name(ret_idx, ret_pos, USE_REGIONS, KEYWORD)
		return ret_idx, ret_pos
		end
	elseif USE_REGIONS then
		if ret_name and ret_name:lower():match(Esc(KEYWORD)) then -- no overlaps and KEYWORD or overlaps, the last of which contains the KEYWORD, so is contigous, search for the next until a non-contiguous is found
		local ret_idx, ret_rgn_end = Find_Next_MrkrOrRgn_By_Name(ret_idx, ret_rgn_end, USE_REGIONS, KEYWORD)
		return ret_idx, ret_rgn_end
		else -- no overlaps and no KEYWORD or overlaps, the last of which doesn't contain the KEYWORD, return the same data which was fed in, because this region must not be skipped
		return ref_idx, ref_pos
		end
	end

end



function Monitor_MrkrsOrRgns(USE_REGIONS, ref_t)
local i, mrkr_idx, rgn_idx = 0, -1, -1 -- -1 to count as 0-based
	if not ref_t then
	local ref_t = {markrs={}, regns={}}
		repeat -- store markers and regions time properties
		local retval, isrgn, pos, rgn_end, name, idx, color = r.EnumProjectMarkers3(0, i) -- markers/regions are returned in the timeline order, if they fully overlap they're returned in the order of their displayed indices
		mrkr_idx = retval > 0 and not isrgn and mrkr_idx+1 or mrkr_idx -- this counting method is used to conform with the type of index expected by the GoToMarker() function
		rgn_idx = retval > 0 and isrgn and rgn_idx+1 or rgn_idx -- relic of the prev version because GoToRegion() was discarded
			if retval > 0 and not isrgn then
			ref_t.markrs[mrkr_idx] = ref_t.markrs[mrkr_idx] or {}
			ref_t.markrs[mrkr_idx].pos = pos; ref_t.markrs[mrkr_idx].name = name:lower():match(Esc(KEYWORD))
			elseif retval > 0 and isrgn then
			ref_t.regns[rgn_idx] = ref_t.regns[rgn_idx] or {}
			ref_t.regns[rgn_idx].pos = pos
			ref_t.regns[rgn_idx].rgn_end = rgn_end
			ref_t.regns[rgn_idx].name = name:lower():match(Esc(KEYWORD))
			end
		i = i+1
		until retval == 0
	return ref_t
	else
	repeat -- search for changes in markers and regions time properties
	local retval, isrgn, pos, rgn_end, name, idx, color = r.EnumProjectMarkers3(0, i)
	mrkr_idx = retval > 0 and not isrgn and mrkr_idx+1 or mrkr_idx -- this counting method is used to conform with the type of index expected by the GoToMarker() function
	rgn_idx = retval > 0 and isrgn and rgn_idx+1 or rgn_idx -- relic of the prev version because GoToRegion() was discarded
		if not USE_REGIONS and retval > 0 and not isrgn and ref_t.markrs[mrkr_idx] and (pos ~= ref_t.markrs[mrkr_idx].pos or name:lower():match(Esc(KEYWORD)) ~= ref_t.markrs[mrkr_idx].name)
		or USE_REGIONS and retval > 0 and isrgn and ref_t.regns[rgn_idx] and (pos ~= ref_t.regns[rgn_idx].pos or rgn_end ~= ref_t.regns[rgn_idx].rgn_end or name:lower():match(Esc(KEYWORD)) ~= ref_t.regns[rgn_idx].name)
		then
		return true
		end
	i = i+1
	until retval == 0
	end
end


-- USAGE (in deferred loop):
-- ref_t = update and Monitor_MrkrsOrRgns(USE_REGIONS) or ref_t -- collect markers and regions time data, only update if there's change, otherwise updates constantly and change isn't
-- if update then --[[ SOME ROUTINE ]] end
-- update = Monitor_MrkrsOrRgns(USE_REGIONS, ref_t) -- search for changes in markers and regions time data; update is used as a condition in getting marker/region properties routine above




--========================== M A R K E R S  &  R E G I O N S  E N D =========================

--=======================================  G F X  ===========================================

function GFX_SETFONT_FLAGS(flags)
-- function to calculate multibyte character for gfx.setfont() flags argument
-- flags is a string consisting on up to 4 characters out of: B/b, I/i, O/o, R/r, S/s, U/u, V/v
-- https://www.cuemath.com/numbers/decimal-to-binary/
-- https://flexiple.com/developers/decimal-to-binary-conversion/
-- https://stackoverflow.com/questions/9079853/lua-print-integer-as-a-binary
-- https://www.geeksforgeeks.org/binary-representation-of-a-given-number/
--[[

https://mespotin.uber.space/Ultraschall/Reaper_Api_Documentation.html#lua_gfx.setfont

flags, how to render the text; up to 4 flags can be passed at the same time
a multibyte character, which can include 'i' for italics, 'u' for underline, or 'b' for bold.
These flags may or may not be supported depending on the font and OS.

66 and 98, Bold (B), (b)
73 and 105, italic (I), (i)
79 and 111, white outline (O), (o)
82 and 114, blurred (R), (r)
83 and 115, sharpen (S), (s)
85 and 117, underline (U), (u)
86 and 118, inVerse (V), (v)

To create such a multibyte-character, assume this flag-value as a 32-bit-value.
The first 8 bits are the first flag, the next 8 bits are the second flag,
the next 8 bits are the third flag and the last 8 bits are the second flag.
The flagvalue(each dot is a bit): .... ....   .... ....   .... ....   .... ....
If you want to set it to Bold(B) and Italic(I), you use the ASCII-Codes of both(66 and 73 respectively),
take them apart into bits and set them in this 32-bitfield.
The first 8 bits will be set by the bits of ASCII-value 66(B), the second 8 bits will be set by the bits of ASCII-Value 73(I).
The resulting flagvalue is: 0100 0010   1001 0010   0101 0110   0000 0000
which is a binary representation of the integer value 18754, which combines 66 and 73 in it
]]

local flags = type(flags) == 'string' and flags:sub(1,4) -- only keep 1st 4 characters because that much is suported by the function
	if not flags then return end

local char_t = {'b','i','o','r','s','u','v'}
local t = {}
	for flag in flags:gmatch('%a') do
	local flag1 = flag:lower()
		for idx, flag2 in ipairs(char_t) do
			if flag1 == flag2 then
			t[#t+1] = string.byte(flag1) -- collect ASCII codes
			table.remove(char_t,idx) -- remove to ignore duplicates in the following cycles
			break end
		end
	end


local integer = 0
	for idx, code in ipairs(t) do
	local code = code << 32 - idx*8 -- each new code bits are shifted left, the number of bits to shift by gets reduced with each new code to keep previously set ones unaffected
	integer = integer|code -- bitwise OR to set bits
	-- 1st flag: 00000000 00000000 00000000 <-[11111111] = 11111111 00000000 00000000 00000000 -- (the actual set bits are of course different)
	-- then adding it to 0, i.e. 00000000 00000000 00000000 00000000 + 11111111 00000000 00000000 00000000 = 11111111 00000000 00000000 00000000
	-- 2nd flag: 00000000 00000000 00000000 <-[11111111] = 00000000 11111111 00000000 00000000
	-- then adding it to the last integer, that is 11111111 00000000 00000000 00000000, i.e.
	-- 11111111 00000000 00000000 00000000 + 00000000 11111111 00000000 00000000 = 11111111 11111111 00000000 00000000
	-- and so on each time shiting left by 8 bits less because previous slots are already taken and must remain intact
	end

return integer

end


function RGB_To_Normalized(R,G,B)
local unit = 1/255
return R and unit*R or 255, G and unit*G or 255, B and unit*B or 255
end
--[[EXAMPLE

local R,G,B = table.unpack((not R and not G and not B) and {255,255,255} or {R,G,B}) -- defaults to white if none is supplied
gfx.r, gfx.g, gfx.b = RGB_To_Normalized(R, G, B)

]]


function Prevent_Floating_Window_Resize1(w,h)	-- auto-restore GUI window dimensions
-- w and h are original GUI window dimensions
	if gfx.w ~= w or gfx.h ~= h then gfx.init('', w, h) end -- the crucial part is the empty window name
-- Thanks to Justin & amagalma
-- https://www.askjf.com/?q=5895s
-- https://forum.cockos.com/showpost.php?p=2493416&postcount=40
end


function Prevent_Floating_Window_Resize2(w, h, expand, contract) -- auto-restore GUI window dimensions
-- w and h are original GUI window dimensions
-- expand, contract are booleans to prevent either expanding or contracting or both or none
-- doesn't work with docked windows
local condition
	if expand then
	condition = gfx.w > w or gfx.h > h
	elseif contract then
	condition = gfx.w < w or gfx.h < h
	else
	condition = gfx.w ~= w or gfx.h ~= h
	end
	if condition then gfx.init('', w, h) end -- the crucial part is the empty window name
-- Thanks to Justin & amagalma
-- https://www.askjf.com/?q=5895s
-- https://forum.cockos.com/showpost.php?p=2493416&postcount=40
end


function gfx_drawstring(text, cent_h, cent_v, r_just, bot_just, x_right, y_bot)
-- formatting arguments (cent_h, cent_v, r_just, bot_just) are booleans, can be nil, otherwise they can be combined but not all are compatible with each other, incompatible are:
-- cent_v and bot_just, if both are valid cent_v takes precedence being earlier in the arg sequence
-- cent_h and r_just, if both are valid cent_h takes precedence being earlier in the arg sequence
-- if x_right, y_bot aren't supplied they default to the GUI window dimensions, these are only relevant if at least one formatting arg is supplied
-- 1|256 proper horizontal centering
local cent_h, cent_v, r_just, bot_just =
cent_h and 1 or 0, cent_v and 4 or 0, r_just and 2 or 0, bot_just and 8 or 0 -- value of 256 to ignore right & bottom isn't needed, not supplying either x_right or y_bot or both will make them default to the GUI window dimensions as per the line below which amounts to ignoring any custom values
local x_right, y_bot = x_right or 0+gfx.w, y_bot or 0+gfx.h -- if not supplied the GUI window dimensions are used
gfx.drawstr(text, cent_h|cent_v|r_just|bot_just|256, x_right, y_bot) -- each arg can be used by itself, to combine them bitwise OR is employed to set additional bits, thanks to cfillion's snippet https://forum.cockos.com/showthread.php?t=226916#2
end


function Get_Store_GFX_Wnd_Dock_State(bool) -- run to get without the arg, then pass any valid value directly as the arg to store
	if not bool then
	local ret, dock_state = r.GetProjExtState(0, 'PROPAGATE PARAMETERS', 'dock')
	local dock_state = (not ret or #dock_state == 0) and r.GetExtState('PROPAGATE PARAMETERS', 'dock') or dock_state
	gfx.dock(dock_state,wx,wy,ww,wh)
	else
	local dock_state = gfx.dock(-1,wx,wy,ww,wh) -- query with -1
	r.SetExtState('PROPAGATE PARAMETERS', 'dock', dock_state, false) -- !!!!! persist false, in the final version MUST BE true to store in reaper-extstate.ini
	r.SetProjExtState(0, 'PROPAGATE PARAMETERS', 'dock', dock_state)
	end
end

-- EXAMPLE:
-- Get_Store_GFX_Dock_State() -- load
-- RUN ROUTINE
-- Get_Store_GFX_Dock_State(1) -- store
-- terminate the script


function Get_Store_GFX_Wnd_Coordinates(bool) -- run to get without the arg, then pass any valid value directly as the arg to store
	if not bool then
	local ret, wnd_coord = r.GetProjExtState(0, 'PROPAGATE PARAMETERS', 'wnd_coordinates')
	local wnd_coord = (not ret or #wnd_coord == 0) and r.GetExtState('PROPAGATE PARAMETERS', 'wnd_coordinates') or wnd_coord
	return wnd_coord:match('(.+), (.+)') -- x & y to be used in gfx.init()
	else
	local x, y = gfx.clienttoscreen(0,0)
	r.SetExtState('PROPAGATE PARAMETERS', 'wnd_coordinates', x..', '..y, false) -- !!!!! persist false, in the final version MUST BE true to store in reaper-extstate.ini
	r.SetProjExtState(0, 'PROPAGATE PARAMETERS', 'wnd_coordinates', x..', '..y)
	end
end

--==================================== G F X  E N D ==================================

--==================================== W I N D O W S =================================

function Loka_Window_At_Mouse(w, h) -- Lokasenna // https://forum.cockos.com/showpost.php?p=1689028&postcount=15
-- This will open a window centered on the mouse cursor, adjusted to make sure it's all on the screen and clear of the taskbar
local mouse_x, mouse_y = reaper.GetMousePosition()
local x, y = mouse_x - (w / 2), mouse_y - (h / 2)
local l, t, r, b = x, y, x + w, y + h
local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1) -- https://forum.cockos.com/showthread.php?t=195629#4

	if l < 0 then x = 0 end
	if r > screen_w then x = (screen_w - w - 16) end
	if t < 0 then y = 0 end
	if b > screen_h then y = (screen_h - h - 40) end

gfx.init("My window", w, h, 0, x, y)

end


function Loka_Window_At_Center(w, h) -- Lokasenna // https://forum.cockos.com/showpost.php?p=1689028&postcount=15
-- if you just want a window centered on the screen
local l, t, r, b = 0, 0, w, h
local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1)
local x, y = (screen_w - w) / 2, (screen_h - h) / 2

gfx.init("My window", w, h, 0, x, y)

end



-- https://forum.cockos.com/showthread.php?t=257766 SWS windows state // may apply to native as well in the reaper-screensets.ini
--[[
input = '6B010000F900000039040000030200000000000000000000A7'
data = input:gsub('%x%x', function(byte) return string.char(tonumber(byte, 16)) end)
left, top, right, bottom, state, whichdock = string.unpack('<iiiiII', data) -- state is a bitfield: 1=open, 2=docked
]]
function SWS_wnd_open(input)
local data = input:gsub('%x%x', function(byte) return string.char(tonumber(byte, 16)) end)
return ({string.unpack('<iiiiII', data)})[5] == '1'
end

function SWS_wnd_data(input)
local data = input:gsub('%x%x', function(byte) return string.char(tonumber(byte, 16)) end)
local left, top, right, bottom, state, dockermode = string.unpack('<iiiiII', data) -- state is a bitfield: 1=open, 2=docked
return left, top, right, bottom, state&1 == 1, state&2 == 2, dockermode
end


local wnd_ident_t1 = {
-- transport docked pos in the top or bottom dockers can't be ascertained;
-- transport_dock=0 any time it's not docked at its reserved positions in the main window (see below) 
-- which could be floating or docked in any other docker;
-- When 'Dock transport in the main window' option is enabled the values of the 'transport_dock_pos' key 
-- corresponding to options under 'Docked transport position' menu item are:
-- 0 - Below arrange (default) [above bottom docker]; 1 - Above ruler [below top docker]; 
-- 2 - Bottom of main window [below bottom docker]; 3 - Top of main window [above top docker]
--	[40279] = 'Docker', -- View: Show docker ('Docker') // not supported by the script
[40078] = 'mixwnd_vis', -- View: Toggle mixer visible ('Mixer')
[40605] = 'actions', -- Show action list ('Actions') // doesn't keep size		
--=============== 'Project Bay' // 8 actions // dosn't keep size ===============
[41157] = 'projbay_0', -- View: Show project bay window
[41628] = 'projbay_1', -- View: Show project bay window 2
[41629] = 'projbay_2', -- View: Show project bay window 3
[41630] = 'projbay_3', -- View: Show project bay window 4
[41631] = 'projbay_4', -- View: Show project bay window 5
[41632] = 'projbay_5', -- View: Show project bay window 6
[41633] = 'projbay_6', -- View: Show project bay window 7
[41634] = 'projbay_7', -- View: Show project bay window 8
--============================== Matrices ======================================
[40768] = 'routingwnd_vis', -- View: Show track grouping matrix window ('Grouping Matrix')
[40251] = 'routingwnd_vis', -- View: Show routing matrix window ('Routing Matrix')
[42031] = 'routingwnd_vis', -- View: Show track wiring diagram ('Track Wiring Diagram')
--===========================================================================
[40326] = 'regmgr', -- View: Show region/marker manager window ('Region/Marker Manager')	// doesn't keep size
[50124] = 'reaper_explorer', -- Media explorer: Show/hide media explorer ('Media Explorer') // doesn't keep size
[40906] = 'trackmgr', -- View: Show track manager window ('Track Manager')	// doesn't keep size
[40327] = 'grpmgr' -- View: Show track group manager window ('Track Group Manager')
[40378] = 'bigclock', -- View: Show big clock window ('Big Clock') // doesn't keep size
[50125] = 'reaper_video', -- Video: Show/hide video window ('Video Window')
[40240] = 'perf', -- View: Show performance meter window ('Performance Meter') // doesn't keep size
[40268] = 'navigator', -- View: Show navigator window ('Navigator') // doesn't keep size
[40377] = 'vkb', -- View: Show virtual MIDI keyboard ('Virtual MIDI Keyboard') // doesn't keep size
--	[41226] = 'nudge_vis', -- Item edit: Nudge/set... // non-toggle
[41827] = 'fadeedit', -- View: Show crossfade editor window ('Crossfade Editor')
[40072] = 'undownd_vis', -- View: Show undo history window ('Undo History')
[41076] = 'converter', -- File: Batch file converter ('Batch File/Item Converter')
-- !!! the ident string seems to be wrong as the value isn't updated --
--	[40271] = 'fxadd_vis', -- View: Show FX browser window ('Add FX to Track #')
--	[40271] = 'fxadd_vis', -- View: Show FX browser window ('Add FX to: Item')
--	[40271] = 'fxadd_vis', -- View: Show FX browser window ('Browse FX')
[40271] = 'fxadd_vis', -- View: Show FX browser window ('Add FX to Track #' or 'Add FX to: Item' or 'Browse FX')
[41589] = 'itemprops', -- Item properties: Toggle show media item/take properties ('Media Item Properties')
--=========== TOOLBARS // don't keep size; the ident strings are provisional ==========
-- when a toolbar is positioned at the top of the main window its dock and visibility states are 0
[41679] = 'toolbar:1', -- Toolbar: Open/close toolbar 1 ('Toolbar 1')
[41680] = 'toolbar:2', -- Toolbar: Open/close toolbar 2 ('Toolbar 2')
[41681] = 'toolbar:3', -- Toolbar: Open/close toolbar 3 ('Toolbar 3')
[41682] = 'toolbar:4', -- Toolbar: Open/close toolbar 4 ('Toolbar 4')
[41683] = 'toolbar:5', -- Toolbar: Open/close toolbar 5 ('Toolbar 5')
[41684] = 'toolbar:6', -- Toolbar: Open/close toolbar 6 ('Toolbar 6')
[41685] = 'toolbar:7', -- Toolbar: Open/close toolbar 7 ('Toolbar 7')
[41686] = 'toolbar:8', -- Toolbar: Open/close toolbar 8 ('Toolbar 8')
[41936] = 'toolbar:9', -- Toolbar: Open/close toolbar 9 ('Toolbar 9')
[41937] = 'toolbar:10', -- Toolbar: Open/close toolbar 10 ('Toolbar 10')
[41938] = 'toolbar:11', -- Toolbar: Open/close toolbar 11 ('Toolbar 11')
[41939] = 'toolbar:12', -- Toolbar: Open/close toolbar 12 ('Toolbar 12')
[41940] = 'toolbar:13', -- Toolbar: Open/close toolbar 13 ('Toolbar 13')
[41941] = 'toolbar:14', -- Toolbar: Open/close toolbar 14 ('Toolbar 14')
[41942] = 'toolbar:15', -- Toolbar: Open/close toolbar 15 ('Toolbar 15')
[41943] = 'toolbar:16', -- Toolbar: Open/close toolbar 16 ('Toolbar 16')
[42404] = 'toolbar:17', -- Toolbar: Open/close media explorer toolbar ('Toolbar 17')
--	[41084] = 'Toolbar Docker' -- Toolbar: Show/hide toolbar docker // not supported by the script
--====================== NON-TOGGLE WINDOWS // for restoration stage only, on the evaluation stage these are taken care of with wnds_extra_t =========================================
[41888] = 'routingwnd_vis', -- View: Show region render matrix window ('Region Render Matrix') // non-toggle
[41226] = 'nudge_vis', -- Item edit: Nudge/set... ('Nudge/set items') // non-toggle
[40604] = 'recopts', -- Track: View track recording settings (MIDI quantize, file format/path) for last touched track ('Track Recording Settings: Track #') // var. name, not toggle // the ident name seems wrong as its value doesn't change but since it's been allowed through at the restoration stage anyway, the ident name doesn't matter
-- >>>>>>>> MIDI Editor has been excluded from wnds_extra_t on the evaluation stage, so the following two entries won't be used <<<<<<<<<<<<
--	[40153] = 'MIDI take:', -- Item: Open in built-in MIDI editor (set default behavior in preferences) ('MIDI take:' or 'Edit MIDI (docked)' occasionally appears when MIDI Editor is in a floating docker but the tab name is the former) // var. name, not toggle
--	[40153] = 'Edit MIDI', -- see above
--[[======================== SWS EXTENSION ======================================
-- SWS extension windows which don't need resizing or pos changed since they maintain them, excluded since there's no way to get their state from reaper.ini, the value which can be extracted from there with the above function SWS_wnd_data() is not updated or updated inconsistently when window state changes, from reaper.ini it's possible to get the dockermode and visibility from the action toggle state but the actual dock state is not;
_SWSAUTOCOLOR_OPEN = 'SWSAutoColor', -- SWS: Open auto color/icon/layout window ('Auto Color/Icon/Layout')
_BR_CONTEXTUAL_TOOLBARS_PREF = 'BR - ContextualToolbars WndPos', -- SWS/BR: Contextual toolbars... ('Contextual toolbars')
['_S&M_CYCLEDITOR'] = 'SnMCyclaction', -- SWS/S&M: Open/close Cycle Action editor ('Cycle Actions') // doesn't remember section selection BUT all 3 actions toggle
['_S&M_SHOWFIND'] = 'SnMFind', -- SWS/S&M: Find ('Find')
_FNG_GROOVE_TOOL = 'FNGGroove', -- SWS/FNG: Show groove tool ('Groove')
['_S&M_SHOWMIDILIVE'] = 'SnMLiveConfigs', -- SWS/S&M: Open/close Live Configs window ('Live Config')
_BR_ANALAYZE_LOUDNESS_DLG = 'BR - AnalyzeLoudness WndPos', -- SWS/BR: Analyze loudness... ('Loudness')
_SWSMARKERLIST1 = 'SWSMarkerList', -- SWS: Open marker list ('Marker List')
['_S&M_SHOW_NOTES_VIEW'] = 'SnMNotesHelp', -- SWS/S&M: Open/close Notes window ('Notes') // does remember notes type selection so other 11 actions will likely be redundant
_SWS_PROJLIST_OPEN = 'SWSProjectList', -- SWS: Open project list ('Project List')
_SWSCONSOLE = 'ReaConsole', -- SWS: Open console ('ReaConsole')
['_S&M_SHOW_RGN_PLAYLIST'] = 'SnMRgnPlaylist', -- SWS/S&M: Open/close Region Playlist window ('Region Playlist')
['_S&M_SHOW_RESOURCES_VIEW'] = 'SnMResources', -- SWS/S&M: Open/close Resources window ('Resources') // does remember resource type selection so other 7 actions will likely be redundant
_SWSSNAPSHOT_OPEN = 'SWSSnapshots' -- SWS: Open snapshots window ('Snapshots') // (caused redraw problem)
]]
}


local wnd_ident_t = { -- to be used in Get_Mixer_Wnd_Dock_State() function
-- the keys are those appearing in reaper.ini [REAPERdockpref] section
-- transport docked pos in the top or bottom dockers can't be ascertained;
-- transport_dock=0 any time it's not docked at its reserved positions in the main window (see below) 
-- which could be floating or docked in any other docker;
-- When 'Dock transport in the main window' option is enabled the values of the 'transport_dock_pos' key 
-- corresponding to options under 'Docked transport position' menu item are:
-- 0 - Below arrange (default) [above bottom docker]; 1 - Above ruler [below top docker]; 
-- 2 - Bottom of main window [below bottom docker]; 3 - Top of main window [above top docker]
-- window 'dock=0' keys do not get updated if the window was undocked before a screenset where it's docked was (re)loaded which leads to false positives
-- The following key names are keys used in [REAPERdockpref] section
-- % escapes are included for use within string.match()
mixer = {'mixwnd_vis', 'mixwnd_dock'}, -- 40078 View: Toggle mixer visible ('Mixer')
actions = {'%[actions%]', 'wnd_vis', 'dock'}, -- Show action list ('Actions')
--=============== 'Project Bay' // 8 actions // dosn't keep size ===============
projbay_0 = {'%[projbay_0%]', 'wnd_vis', 'dock'}, -- View: Show project bay window
projbay_1 = {'%[projbay_1%]', 'wnd_vis', 'dock'}, -- View: Show project bay window 2
projbay_2 = {'%[projbay_2%]', 'wnd_vis', 'dock'}, -- View: Show project bay window 3
projbay_3 = {'%[projbay_3%]', 'wnd_vis', 'dock'}, -- View: Show project bay window 4
projbay_4 = {'%[projbay_4%]', 'wnd_vis', 'dock'}, -- View: Show project bay window 5
projbay_5 = {'%[projbay_5%]', 'wnd_vis', 'dock'}, -- View: Show project bay window 6
projbay_6 = {'%[projbay_6%]', 'wnd_vis', 'dock'}, -- View: Show project bay window 7
projbay_7 = {'%[projbay_7%]', 'wnd_vis', 'dock'}, -- View: Show project bay window 8
--============================== Matrices ======================================
routing = {'routingwnd_vis', 'routing_dock'}, -- View: Show track grouping matrix window ('Grouping Matrix'); View: Show routing matrix window ('Routing Matrix'); View: Show track wiring diagram ('Track Wiring Diagram')
--===========================================================================
regmgr = {'%[regmgr%]', 'wnd_vis', 'dock'}, -- View: Show region/marker manager window ('Region/Marker Manager')
explorer = {'%[reaper_explorer%]', 'visible', 'docked'}, -- Media explorer: Show/hide media explorer ('Media Explorer')
trackmgr = {'%[trackmgr%]', 'wnd_vis', 'dock'}, -- View: Show track manager window ('Track Manager')
grpmgr = {'%[grpmgr%]', 'wnd_vis', 'dock'} -- View: Show track group manager window ('Track Group Manager')
bigclock = {'%[bigclock%]', 'wnd_vis', 'dock'}, -- View: Show big clock window ('Big Clock')
video = {'%[reaper_video%]', 'visible', 'docked'}, -- Video: Show/hide video window ('Video Window')
perf = {'%[perf%]', 'wnd_vis', 'dock'}, -- View: Show performance meter window ('Performance Meter')
navigator = {'%[navigator%]', 'wnd_vis', 'dock'}, -- View: Show navigator window ('Navigator')
vkb = {'%[vkb%]', 'wnd_vis', 'dock'}, -- View: Show virtual MIDI keyboard ('Virtual MIDI Keyboard')
fadeedit = {'%[fadeedit%]', 'wnd_vis', 'dock'}, -- View: Show crossfade editor window ('Crossfade Editor')
undo = {'undownd_vis', 'undownd_dock'}, -- View: Show undo history window ('Undo History')
fxbrowser = {40271, 'fxadd_dock'}, -- View: Show FX browser window ('Add FX to Track #' or 'Add FX to: Item' or 'Browse FX') // fxadd_vis value doesn't change hence action to check visibility
itemprops = {'%[itemprops%]', 'wnd_vis', 'dock'}, -- Item properties: Toggle show media item/take properties ('Media Item Properties')
midiedit = {'%[midiedit%]', 'dock'}, -- there's no key for MIDI Editor visibility
--=========== TOOLBARS // don't keep size; the ident strings are provisional ==========
toolbar = {'toolbar', 'wnd_vis', 'dock'} -- Toolbar: Open/close toolbar X ('Toolbar X')
}


function Get_Mixer_Wnd_Dock_State(wnd_ident_t, wantDockPos) -- get Mixer dock state WHEN the SWS extension IS NOT INSTALLED to verify whether there're other windows sharing a docker with the Mixer in the split mode and so whether its full window width can be used; returns false if there's a window which shares a docker with the Mixer, otherwise true

-- dockermode of closed docked windows isn't updated, so when the Mixer doesn't share docker with any other windows
-- in the split mode at a given moment because these windows are closed, to ensure that its full width, obtained with
-- my_getViewport(), can be used, these closed windows visibility toggle state must be evaluated as well
-- a more reliable method would be to read screenset data

local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local mixwnd_dock = r.GetToggleCommandStateEx(0, 40083) == 1 -- or cont:match('mixwnd_dock=1') -- Mixer: Toggle docking in docker // mixwnd_dock value is likely to not update when state changes hence alternative
local mixer_dockermode = cont:match('%[REAPERdockpref%].-%f[%a]mixer=[%d%.]-%s(%d+)\n') -- find mixer dockermode number // the frontier operator %f is needed to avoid false positive of 'mastermixer' which refers to the Master track
local mixer_dock_pos = cont:match('dockermode'..mixer_dockermode..'=(%d+)') -- get mixer docker position

	if wantDockPos then return mixer_dock_pos end -- if requested, return pos in case the entire docker is closed and not the Mixer window itself, to condition the rightmost position routine because in this case it won't work, but nevertheless will run because Mixer toggle state will still be OFF and hence true; plus if dockerpos is not 0 (bottom) or 2 (top) the rightmost position won't be needed anyway as without SWS extension in other docks and in floating window only the leftmost pos is honored by the script; must come before the next condition so it's not blocked by it if the latter is true
	if not mixwnd_dock -- in floating Mixer window wihtout SWS extension only use leftmost position
	or (mixer_dock_pos ~= '0' and mixer_dock_pos ~= '2') -- if sits in side dockers, only use leftmost position because the Mixer window cannot have full width anyway
	then return false
	elseif mixwnd_dock and mixer_dockermode and (mixer_dock_pos == '0' or mixer_dock_pos == '2') -- bottom or top, where Mixer window can stretch to the full width of the main window
	then
	local temp = cont -- temp var to perform repeats count below without risking to affect the orig. data
	local _, reps = temp:gsub('dockermode','%0') -- get number of repeats
	local dockermode_t = {cont:match(string.rep('.-(dockermode%d+=%d)', reps))} -- collect all dockermode entries
	local adjacent_dockermode_t = {}
		for _, v in ipairs(dockermode_t) do -- collect dockermode indices of all windows which share the docker with the Mixer in the split mode
			if v:match('(%d+)=') ~= mixer_dockermode -- exclude mixer's own dockermode entry
			and v:match('=(%d)') == mixer_dock_pos then -- if positon is the same as that of Mixer which means the docker is split and causes change in Mixer window size
			adjacent_dockermode_t[#adjacent_dockermode_t+1] = v:match('(%d+)=')
			end
		end
		if #adjacent_dockermode_t > 0 then -- if there're dockermodes which share docker with the Mixer
		local REAPERdockpref = cont:match('%[REAPERdockpref%](.-)%[')
		local REAPERdockpref_t = {}
			for line in REAPERdockpref:gmatch('\n?(.-%s%d+)\n?') do -- extract all [REAPERdockpref] section entries
			REAPERdockpref_t[#REAPERdockpref_t+1] = line
			end
		local adjacent_wnd_t = {}
			for _, v1 in ipairs(adjacent_dockermode_t) do -- collect names of windows sitting in a split docker with the Mixer (having dockermode with the same position as that of the Mixer) whether visible or not
				for _, v2 in ipairs(REAPERdockpref_t) do
					if v1 == v2:match('.+%s(%d+)') then
					adjacent_wnd_t[#adjacent_wnd_t+1] = v2:match('(.+)=') end
				end
			end
			for _, v in ipairs(adjacent_wnd_t) do -- evaluate the collected windows visibility and dock state
			local t = wnd_ident_t[v] or wnd_ident_t[v:match('toolbar')] -- toolbar key is separate since in adjacent_wnd_t toolbar keys contain numbers and can't select the table nested inside wnd_ident_t directly; match to isolate 'toolbar' word specifically since the list may include SWS window identifiers
				if t and #t == 3 and t[1] ~= 'toolbar' then -- or if v ~= 'toolbar'; windows with a dedicated section in reaper.ini besides toolbars which are treated below // additional t truthfulness evaluation because if the adjacent_wnd_t list contains SWS window identifiers the t will be false
				local sect = cont:match(t[1]..'(.-)%[') or cont:match(t[1]..'(.-)$') -- capture section content either followed by another section or at the very end of the file
					if sect:match(t[2]..'=1') and sect:match(t[3]..'=1') then return false end
				elseif t and #t == 2 and tonumber(t[1]) then -- fxbrowser command ID and a key
					if r.GetToggleCommandStateEx(0, t[1]) == 1 and cont:match(t[2]..'=1') then return false end
				elseif t and #t == 2 and v == 'midiedit' then -- MIDI Editor, always returns false if docked in the same docker as the Mixer regardless of visibility because the latter cannot be ascertained from reaper.ini
					local sect = cont:match(t[1]..'(.-)%[') or cont:match(t[1]..'(.-)$') -- capture section content either followed by another section or at the very end of the file
						if sect:match(t[2]..'=1') then return false end
				elseif t and #t == 2 then -- windows without a dedicated section
					if cont:match(t[1]..'=1') and cont:match(t[2]..'=1') then
					return false end
				elseif t and t[1] == 'toolbar' then -- or if v == 'toolbar'
				local sect = cont:match('%['..v..'%](.-)%[') or cont:match('%['..v..'%](.-)$') -- capture section content either followed by another section or at the very end of the file
					if sect and sect:match(t[2]..'=1') and sect:match(t[3]..'=1') then return false end -- sect can be false if the stored toolbar has no section, in particular 'toolbar' (without a number) representing Arrange main toolbar
				end
			end
		end
	end

return true

end







function GetTCP_Width(content) -- LIKELY OBSOLETE DUE TO time_pos_to_pixels() FUNCTION

local left_docker_on
-- find dockermode(s) keys assigned position value 1 - left
	for mode in content:gmatch('dockermode(%d*)=1') do
		if mode then
		-- find if windows/toobars keys assigned the found dockermode in the [REAPERdockpref] section
		local REAPERdockpref = content:match('REAPERdockpref%](.-)\n%[') -- isolate this section contents
			for str in REAPERdockpref:gmatch('[^\n\r]*') do
--Msg(str:match('.-=[%-%.%d]*%s'..v..'$'))
			local key = str:match('.-=[%-%.%d]*%s'..mode..'$') and str:match('^(.-)=')
			-- determine if windows/toolbars found in the [REAPERdockpref] section are docked and visible in the lefthand docker
			local sect = key and content:match('(%['..key..'%].-)%[') or (key and content:match('(%['..key..'%].-)$'))
				if sect then -- keys which have a dedicated section
				vis, dock = sect:match('wnd_vis=(%d)') or sect:match('visible=(%d)'), sect:match('dock=(%d)') or sect:match('docked=(%d)')
				else -- keys without a dedicated section, not exhaustive
					if key == 'fxbrowser' then vis, dock = content:match('fxadd_vis=(%d)'), content:match('fxadd_dock=(%d)')
					elseif key == 'mixer' then vis, dock = content:match('mixwnd_vis=(%d)'), content:match('mixwnd_dock=(%d)')
					elseif key == 'transport' then vis, dock = content:match(key..'_vis=(%d)'), content:match(key..'_dock=(%d)')
					end
				end
				if vis == '1' and vis == dock then left_docker_on = true break end
			end
		end
		if left_docker_on == true then break end
	end

--Msg('DOCKER = '..tostring(left_docker_on))

local TCP_width = content:match('leftpanewid=(.-)\n')
local dockheight_l = content:match('dockheight_l=(.-)\n') -- if left docker is open  https://forums.cockos.com/showpost.php?p=1991096&postcount=11

-- https://forum.cockos.com/showpost.php?p=2303259&postcount=4 thanks to IXix
-- https://forum.cockos.com/showthread.php?t=238128

	if left_docker_on then TCP_width = TCP_width + dockheight_l end -- shifted righwards TCP right edge

--Msg(dockheight_l)
--Msg(TCP_width)

return TCP_width

end


function Re_Store_Windows_Props_By_Names1(names_t, t) -- relies on Esc() function
-- works if screenset was changed because in this case window nandles will change as well while names won't
-- doesn't support docked windows since they're not top level and won't be detected by JS_Window_ArrayAllTop()
-- https://forums.cockos.com/showthread.php?p=2538915
-- https://forum.cockos.com/showthread.php?t=249817
	if not t then
	local main_HWND = r.GetMainHwnd()
	local array = r.new_array({}, 1023)
	r.JS_Window_ArrayAllTop(array) -- docked windows are not top level hence won't be listed
	local array = array.table()
	local t = {}
		for k, address in ipairs(array) do -- duplicate names with different hwnd may occur, such as FX chain windows, so the number of windows which satisfy the search may be greater than the number of visible windows
		local hwnd = r.JS_Window_HandleFromAddress(address)
		local title = r.JS_Window_GetTitle(hwnd)
			for _, name in pairs(names_t) do
				if title:match(Esc(name)) and r.JS_Window_IsVisible(hwnd) -- FX chain windows may happen to be visible even when closed, there're no fx and the object is hidden in Arrange, fx floating window are only visible when floating
				then
				local retval, lt, tp, rt, bt = r.JS_Window_GetRect(hwnd)
				local w, h = rt-lt, r.GetOS():match('OSX') and tp-bt or bt-tp -- isn't necessary if r.JS_Window_Move() is used for restoration rather than r.JS_Window_SetPosition()
				t[#t+1] = {tit=title, lt=lt, tp=tp, w=w, h=h, foregrnd=r.JS_Window_GetForeground()==hwnd}
				end
			end
		end
	return t
	else
		for _, wnd in ipairs(t) do
		local hwnd = r.JS_Window_Find(wnd.tit, true) -- exact true
		local dock_idx, isFloatingDocker = r.DockIsChildOfDock(hwnd)
			if dock_idx == -1 then -- not docked to prevent undocking window in which case it'll become invisible
			r.JS_Window_Move(hwnd, wnd.lt, wnd.tp)
		--  OR	
		--	r.JS_Window_SetPosition(hwnd, wnd.lt, wnd.tp, wnd.w, wnd.h) -- ZOrder, flags are ommitted
				--	if wnd.focus then r.JS_Window_SetFocus(hwnd) end -- focus is not stored above but it's more granular and targets elements in the foreground window which isn't really necessary
				if wnd.foregrnd then r.JS_Window_SetForeground(hwnd) end -- only restored if the script is run via a shortcut because clicking changes foreground window, r.JS_Window_SetZOrder() should be avoided as it's global to the OS
			end
		end
	end
end


function Re_Store_Windows_Props_By_Names2(names_t, t)
-- works if screenset was changed because in this case window nandles will change as well while names won't
-- supports docked windows
-- https://forums.cockos.com/showthread.php?p=2538915
-- https://forum.cockos.com/showthread.php?t=249817
	if not t then
	local main_HWND = r.GetMainHwnd()
--	local name_t = {'FX:','- Track','- Item'}
	local t = {}
	for k, name in pairs(names_t) do
	local array = r.new_array({}, 1023)
	r.JS_Window_ArrayFind(name, false, array) -- exact false
	local array = array.table()
		for k, address in ipairs(array) do -- duplicate names with different hwnd may occur, such as FX chain windows, so the number of windows which satisfy the search may be greater than the number of visible windows
		local hwnd = r.JS_Window_HandleFromAddress(address)
			if r.JS_Window_IsVisible(hwnd) -- FX chain windows may happen to be visible even when closed, there're no fx and the object is hidden in Arrange, fx floating window are only visible when floating
			local title = r.JS_Window_GetTitle(hwnd)
			local retval, lt, tp, rt, bt = r.JS_Window_GetRect(hwnd)
			local w, h = rt-lt, r.GetOS():match('OSX') and tp-bt or bt-tp -- isn't necessary if r.JS_Window_Move() is used for restoration rather than r.JS_Window_SetPosition()
			t[#t+1] = {tit=title, lt=lt, tp=tp, w=w, h=h, focus=r.JS_Window_GetForeground()==hwnd}
			end
		end
	end
	return t
	else
		for _, wnd in ipairs(t) do
		local hwnd = r.JS_Window_Find(wnd.tit, true) -- exact true
		local dock_idx, isFloatingDocker = r.DockIsChildOfDock(hwnd)
			if dock_idx == -1 then -- not docked to prevent undocking window in which case it'll become invisible
			r.JS_Window_Move(hwnd, wnd.lt, wnd.tp)
		--  OR	
		--	r.JS_Window_SetPosition(hwnd, wnd.lt, wnd.tp, wnd.w, wnd.h) -- ZOrder, flags are omitted
				--	if wnd.focus then r.JS_Window_SetFocus(hwnd) end -- focus is not stored above but it's more granular and targets elements in the foreground window which isn't really necessary
				if wnd.foregrnd then r.JS_Window_SetForeground(hwnd) end -- only restored if the script is run via a shortcut because clicking changes foreground window, r.JS_Window_SetZOrder() should be avoided as it's global to the OS
			end
		end
	end
end


function Re_Store_Windows_Props_By_Names_And_Handles1(names_t, t) -- relies on Esc() function
-- store by names, restore by handles
-- works if screenset was NOT changed because in this case window handles won't change and can be used to restore windows
-- doesn't support docked windows since they're not top level and won't be detected by JS_Window_ArrayAllTop()
-- https://forums.cockos.com/showthread.php?p=2538915
-- https://forum.cockos.com/showthread.php?t=249817
	if not t then
	local main_HWND = r.GetMainHwnd()
	local array = r.new_array({}, 1023)
	r.JS_Window_ArrayAllTop(array) -- docked windows are not top level hence won't be listed
	local array = array.table()
	local t = {}
		for k, address in ipairs(array) do -- duplicate names with different hwnd may occur, such as FX chain windows, so the number of windows which satisfy the search may be greater than the number of visible windows
		local hwnd = r.JS_Window_HandleFromAddress(address)
		local title = r.JS_Window_GetTitle(hwnd)
			for _, name in pairs(names_t) do
				if title:match(Esc(name)) and r.JS_Window_IsVisible(hwnd) -- FX chain windows may happen to be visible even when closed, there're no fx and the object is hidden in Arrange, fx floating window are only visible when floating
				then
				local retval, lt, tp, rt, bt = r.JS_Window_GetRect(hwnd)
				local w, h = rt-lt, r.GetOS():match('OSX') and tp-bt or bt-tp -- isn't necessary if r.JS_Window_Move() is used for restoration rather than r.JS_Window_SetPosition()
				t[#t+1] = {id=hwnd, lt=lt, tp=tp, w=w, h=h, foregrnd=r.JS_Window_GetForeground()==hwnd}
				end
			end
		end
	return t
	else
		for _, wnd in ipairs(t) do
		local dock_idx, isFloatingDocker = r.DockIsChildOfDock(wnd.id)
			if dock_idx == -1 then -- not docked to prevent undocking window in which case it'll become invisible
			r.JS_Window_Move(wnd.id, wnd.lt, wnd.tp)
		--  OR
		--	r.JS_Window_SetPosition(wnd.id, wnd.lt, wnd.tp, wnd.w, wnd.h) -- ZOrder, flags are ommitted
				--	if wnd.focus then r.JS_Window_SetFocus(hwnd) end -- focus is not stored above but it's more granular and targets elements in the foreground window which isn't really necessary
				if wnd.foregrnd then r.JS_Window_SetForeground(hwnd) end -- only restored if the script is run via a shortcut because clicking changes foreground window, r.JS_Window_SetZOrder() should be avoided as it's global to the OS
			end
		end
	end
end


function Re_Store_Windows_Props_By_Names_And_Handles2(names_t, t)
-- store by names, restore by handles
-- works if screenset was NOT changed because in this case window handles won't change and can be used to restore windows
-- supports docked windows
-- https://forums.cockos.com/showthread.php?p=2538915
-- https://forum.cockos.com/showthread.php?t=249817
	if not t then
	local main_HWND = r.GetMainHwnd()
--	local name_t = {'FX:','- Track','- Item'}
	local t = {}
	for k, name in pairs(names_t) do
	local array = r.new_array({}, 1023)
	r.JS_Window_ArrayFind(name, false, array) -- exact false
	local array = array.table()
		for k, address in ipairs(array) do -- duplicate names with different hwnd may occur, such as FX chain windows, so the number of windows which satisfy the search may be greater than the number of visible windows
		local hwnd = r.JS_Window_HandleFromAddress(address)
			if r.JS_Window_IsVisible(hwnd) -- FX chain windows may happen to be visible even when closed, there're no fx and the object is hidden in Arrange, fx floating window are only visible when floating
			local retval, lt, tp, rt, bt = r.JS_Window_GetRect(hwnd)
			local w, h = rt-lt, r.GetOS():match('OSX') and tp-bt or bt-tp -- isn't necessary if r.JS_Window_Move() is used for restoration rather than r.JS_Window_SetPosition()
			t[#t+1] = {id=hwnd, lt=lt, tp=tp, w=w, h=h, foregrnd=r.JS_Window_GetForeground()==hwnd}
			end
		end
	end
	return t
	else
		for _, wnd in ipairs(t) do
		local dock_idx, isFloatingDocker = r.DockIsChildOfDock(wnd.id)
			if dock_idx == -1 then -- not docked to prevent undocking window in which case it'll become invisible
			r.JS_Window_Move(wnd.id, wnd.lt, wnd.tp)
		--  OR
		--	r.JS_Window_SetPosition(wnd.id, wnd.lt, wnd.tp, wnd.w, wnd.h) -- ZOrder, flags are omitted
				--	if wnd.focus then r.JS_Window_SetFocus(hwnd) end -- focus is not stored above but it's more granular and targets elements in the foreground window which isn't really necessary
				if wnd.foregrnd then r.JS_Window_SetForeground(hwnd) end -- only restored if the script is run via a shortcut because clicking changes foreground window, r.JS_Window_SetZOrder() should be avoided as it's global to the OS
			end
		end
	end
end


function Window_Is_Visible(hwnd)
-- takes advantage of the fact that the following functions don't affect invisible windows
-- docked windows will be considered invisible because focus and foreground status can't be applied to them, they're children windows
-- r.JS_Window_IsVisible() isn't suitable since it may return true for invisible (closed) windows as well, such as FX chain;
-- may not be sutable when many windows are open because it changes foreground window or focus
-- OK if windows will get closed anyway
-- r.JS_Window_GetForeground() is safer when the window is surely closed because it doesn't remove focus from children of the currently focused window, e.g. list entry active status
--[-[
local ForeGrnd = r.JS_Window_GetForeground
local foregrnd = ForeGrnd() 
	if foregrnd == hwnd then return true end
r.JS_Window_SetForeground(hwnd)
local foregrnd = ForeGrnd()
return foregrnd == hwnd
--]]
--[[ OR
Msg(r.JS_Window_GetTitle(hwnd))
local Focus = r.JS_Window_GetFocus
local focus = Focus()
	if focus == hwnd then return true end
r.JS_Window_SetFocus(hwnd)
local focus = Focus()
return focus == hwnd
--]]
end


function Exclude_Visible_Windows(t) -- t stems from Re_Store_Windows_Props_By_Names[_And_Handles]() functions
	for i=#t,1,-1 do
	local wnd = t[i]
	local hwnd = r.JS_Window_Find(wnd.tit, true) -- exact true
		if Window_Is_Visible(hwnd) then
		table.remove(t,i)
		end
	end
end


function Move_Window_To_Another_Dock(wnd_id, new_pos, cur_pos)
-- wnd_id is window identifier string found in reaper.ini, see table keys below,
-- if routing, add digit without space: routing1 - routing matrix;
-- routing2 - group matrix; routing3 - track wiring; 
-- routing4 - region render matrix -- non-toggle
-- cur_pos and new_pos args are integer: 0 - bottom, 1 - left, 2 - top, 3 - right, 4 - floating
-- cur_pos is optional, if passed, docker position will only be changed of the window's current pos matches cur_pos value, otherwise position will be changed regardless of the current one
-- also to figure out how to toggle midi editor visibility
-- some info on docks https://forum.cockos.com/showthread.php?t=207081

	if not new_pos or not tonumber(new_pos)
	or tonumber(new_pos) < 0 or tonumber(new_pos) > 4 then
	return end
	
	if cur_pos and (not tonumber(new_pos)
	or tonumber(new_pos) < 0 or tonumber(new_pos) > 4) then
	return end

local dockermode = r.GetConfigWantsDock(wnd_id) -- ger dockermode the window is currently assigned to
	
	if cur_pos and r.DockGetPosition(dockermode) ~= cur_pos then return end -- compare the position the dockermode belongs to with the cur_pos value if any

-- in actual Routing menu order
local routing = {40251, -- View: Show routing matrix window ('Routing Matrix')
42031, -- View: Show track wiring diagram ('Track Wiring Diagram')
40768, -- View: Show track grouping matrix window ('Grouping Matrix')
41888 -- View: Show region render matrix window ('Region Render Matrix') -- non-toggle
}

local function is_region_render_vis(routing)
	for _, commID in ipairs(routing) do
		if r.GetToggleCommandStateEx(0,commID) == 1 
		then -- one of the other 3 windows which have toggle state is visible
		return end -- so region render matrix visibility is false
	end
-- if the function didn't exit early, all windows with toggle action are closed
-- 'View: Show region render matrix window' is not a toggle, so evaluate that via reaper,ini 
	for line in io.lines(r.get_ini_file()) do
		if line:match('routingwnd_vis') and line:sub(-1) == '1' then 
		-- the key has value 1 when region render matrix is open as well	
		return true
		end
	end
end

local t = {transport = 40259, mixer = 40078, actions = 40605, 
projbay_0 = 41157, projbay_1 = 41628, projbay_2 = 41629, 
projbay_3 = 41630, projbay_4 = 41631, projbay_5 = 41632, 
projbay_6 = 41633, projbay_7 = 41634, --routing = rout,
regmgr = 40326, explorer = 50124, trackmgr = 40906, grpmgr = 40327, 
bigclock = 40378, video = 50125, perf = 40240, navigator = 40268, 
vkb = 40377, fadeedit = 41827, undo = 40072, fxbrowser = 40271, 
itemprops = 41589, midiedit = '', ['toolbar:1'] = 41679, 
['toolbar:2'] = 41680, ['toolbar:3'] = 41681, ['toolbar:4'] = 41682, 
['toolbar:5'] = 41683, ['toolbar:6'] = 41684, ['toolbar:7'] = 41685, 
['toolbar:8'] = 41686, ['toolbar:9'] = 41936, ['toolbar:10'] = 41937, 
['toolbar:11'] = 41938, ['toolbar:12'] = 41939, ['toolbar:13'] = 41940,
['toolbar:14'] = 41941, ['toolbar:15'] = 41942, ['toolbar:16'] = 41943, 
['toolbar:17'] = 42404, -- MX toolbar
SWSAutoColor = '_SWSAUTOCOLOR_OPEN', -- SWS: Open auto color/icon/layout window ('Auto Color/Icon/Layout')
['BR - ContextualToolbars WndPos'] = '_BR_CONTEXTUAL_TOOLBARS_PREF', -- SWS/BR: Contextual toolbars... ('Contextual toolbars')
SnMCyclaction = '_S&M_CYCLEDITOR', -- SWS/S&M: Open/close Cycle Action editor ('Cycle Actions') // doesn't remember section selection BUT all 3 actions toggle
SnMFind = '_S&M_SHOWFIND', -- SWS/S&M: Find ('Find')
FNGGroove = '_FNG_GROOVE_TOOL', -- SWS/FNG: Show groove tool ('Groove')
SnMLiveConfigs = '_S&M_SHOWMIDILIVE', -- SWS/S&M: Open/close Live Configs window ('Live Config')
SnMLiveConfigMonitor1 = '_S&M_OPEN_LIVECFG_MONITOR1', -- SWS/S&M: Live Config #1 - Open/close monitoring window
SnMLiveConfigMonitor2 = '_S&M_OPEN_LIVECFG_MONITOR2', -- SWS/S&M: Live Config #2 - Open/close monitoring window
SnMLiveConfigMonitor3 = '_S&M_OPEN_LIVECFG_MONITOR3', -- SWS/S&M: Live Config #3 - Open/close monitoring window
SnMLiveConfigMonitor4 = '_S&M_OPEN_LIVECFG_MONITOR4', -- SWS/S&M: Live Config #4 - Open/close monitoring window
SnMLiveConfigMonitor5 = '_S&M_OPEN_LIVECFG_MONITOR5', -- SWS/S&M: Live Config #5 - Open/close monitoring window
SnMLiveConfigMonitor6 = '_S&M_OPEN_LIVECFG_MONITOR6', -- SWS/S&M: Live Config #6 - Open/close monitoring window
SnMLiveConfigMonitor7 = '_S&M_OPEN_LIVECFG_MONITOR7', -- SWS/S&M: Live Config #7 - Open/close monitoring window
SnMLiveConfigMonitor8 = '_S&M_OPEN_LIVECFG_MONITOR8', -- SWS/S&M: Live Config #8 - Open/close monitoring window
['BR - AnalyzeLoudness WndPos'] = '_BR_ANALAYZE_LOUDNESS_DLG', -- SWS/BR: Analyze loudness... ('Loudness')
SWSMarkerList = '_SWSMARKERLIST1', -- SWS: Open marker list ('Marker List')
SnMNotesHelp = '_S&M_SHOW_NOTES_VIEW', -- SWS/S&M: Open/close Notes window ('Notes') // does remember notes type selection so other 11 actions will likely be redundant
SWSProjectList = '_SWS_PROJLIST_OPEN', -- SWS: Open project list ('Project List')
ReaConsole = '_SWSCONSOLE', -- SWS: Open console ('ReaConsole')
SnMRgnPlaylist = '_S&M_SHOW_RGN_PLAYLIST', -- SWS/S&M: Open/close Region Playlist window ('Region Playlist')
SnMResources = '_S&M_SHOW_RESOURCES_VIEW', -- SWS/S&M: Open/close Resources window ('Resources') // does remember resource type selection so other 7 actions will likely be redundant
SWSSnapshots = '_SWSSNAPSHOT_OPEN' -- SWS: Open snapshots window ('Snapshots') // (caused redraw problem)
}

local function wrapper(func,...)
-- https://forums.cockos.com/showthread.php?t=218805 Lokasenna
local t = {...}
return function() func(table.unpack(t)) end
end

--[[ WORKS isn't sutable for Region Render matrix window
local function wait_and_reopen(commandID)
	if r.GetToggleCommandStateEx(0,commandID) == 1 then
	r.defer(wrapper(wait_and_reopen, commandID))
	else
	r.Main_OnCommand(commandID, 0) -- re-open /// must be inside defer loop, for some reason when the defer loop stops commandID  is not accessible to Main_OnCommand() function outside
	end
end
--]]
--[-[ WORKS
local function wait_and_reopen(commandID)
	if commandID ~= 41888 and r.GetToggleCommandStateEx(0,commandID) == 0 then
	r.Main_OnCommand(commandID, 0) -- re-open // must be inside defer loop, for some reason when the defer loop stops commandID  is not accessible to Main_OnCommand() function outside
	return 
	elseif commandID == 41888 then
		for line in io.lines(r.get_ini_file()) do
			if line:match('routingwnd_vis') and 
			-- the key has value 0 when region render matrix is closed as well
			line:sub(-1) == '0' then	
			r.Main_OnCommand(commandID, 0) return end
		end
	end
r.defer(wrapper(wait_and_reopen, commandID))
end
--]]

-- extract index if routing and select command ID
local commandID = wnd_id:match('routing') and routing[wnd_id:sub(-1)+0] or r.NamedCommandLookup(t[wnd_id]) -- accounting for SWS ext command IDs
local vis = commandID ~= 41888 and r.GetToggleCommandStateEx(0,commandID) == 1 
or commandID == 41888 and is_region_render_vis(routing)

	if not vis then return end -- only update visible windows
	
local wnd_id = wnd_id:match('routing') and 'routing' or wnd_id	
	
	for i = 0, 15 do -- there're 16 dockermode indices in total
		if r.DockGetPosition(i) == new_pos then -- find dockermode associated with the desired position
		-- in reaper.ini it's e.g. dockermode5=0;
		-- update dockermode to which the window is assigned in reaper.ini;
		-- in [REAPERdockpref] section
		r.Dock_UpdateDockID(wnd_id, i)
	--	r.UpdateArrange() -- doesn't work to visually update window position
		-- must be refreshed for the change to become visible, that is its visibility toggled
			if commandID ~= 41888 and r.GetToggleCommandStateEx(0,commandID) == 1 
			or commandID == 41888 and is_region_render_vis(routing)
			then -- visible // will work when updating dock position of a window regardless of visibility if 'if not vis then' condition isn't used above, in which case only if a window is visible it will be reloaded, the rest will be moved in the background
			r.Main_OnCommand(commandID, 0) -- close
			wait_and_reopen(commandID) -- toggle state is updated slower than the function runs hence the need to wait and only then re-open, the same is true for routingwnd_vis value update in reaper.ini
		-- 	OR
		--	r.defer(wrapper(wait_and_reopen, commandID)) -- re-open
			end
		break end
	end
end


function Get_Arrange_Dims() 
-- requires SWS or js_ReaScriptAPI extensions
local sws, js = r.APIExists('BR_Win32_FindWindowEx'), r.APIExists('JS_Window_Find')
	if sws or js then -- if SWS/js_ReaScriptAPI ext is installed
	-- thanks to Mespotine https://github.com/Ultraschall/ultraschall-lua-api-for-reaper/blob/master/ultraschall_api/misc/misc_docs/Reaper-Windows-ChildIDs.txt
	local main_wnd = r.GetMainHwnd()
	-- trackview wnd height includes bottom scroll bar, which is equal to track 100% max height + 17 px, also changes depending on the header height and presence of the bottom docker
	local arrange_wnd = sws and r.BR_Win32_FindWindowEx(r.BR_Win32_HwndToString(main_wnd), 0, '', 'trackview', false, true) -- search by window name // OR r.BR_Win32_FindWindowEx(r.BR_Win32_HwndToString(main_wnd), 0, 'REAPERTrackListWindow', '', true, false) -- search by window class name
	or js and r.JS_Window_Find('trackview', true) -- exact true // OR r.JS_Window_FindChildByID(r.GetMainHwnd(), 1000) -- 1000 is 'trackview' window ID
	local retval, rt1, top1, lt1, bot1 = table.unpack(sws and {r.BR_Win32_GetWindowRect(arrange_wnd)} 
	or js and {r.JS_Window_GetRect(arrange_wnd)})
	local retval, rt2, top2, lt2, bot2 = table.unpack(sws and {r.BR_Win32_GetWindowRect(main_wnd)} or js and {r.JS_Window_GetRect(main_wnd)})
	local top2 = top2 == -4 and 0 or top2 -- top2 can be negative (-4) if window is maximized
	local arrange_h, header_h, wnd_h_offset = bot1-top1-17, top1-top2, top2  -- header_h is distance between arrange and program window top, wnd_h_offset is a coordinate of the program window top which is equal to its distance from the screen top when shrunk // !!!! MAY NOT WORK ON MAC since there Y axis starts at the bottom
	return arrange_h, header_h, wnd_h_offset
	end
end


--==================================== W I N D O W S   E N D ====================================


--========================================== F I L E S =========================================

local _, scr_name, sect_ID, cmd_ID, _,_,_ = r.get_action_context()
local scr_name = scr_name:match('([^\\/]+)%.%w+') -- without path and extension
local scr_name = scr_name:match('([^\\/_]+)%.%w+') -- without path & scripter name
local scr_name = scr_name:match('[^\\/]+_(.+)%.%w+') -- without path, scripter name & ext
local scr_name = scr_name:match('.+[\\/](.+)') -- whole script name without path
local named_ID = r.ReverseNamedCommandLookup(cmd_ID) -- to ensure more unique extended state section name, diff sections may probably have identical numeric cmd_IDs // script aplhanumeic command IDs in different Action list sections differ in the alphabetic prefix
local path = r.GetResourcePath()
local sep = r.GetResourcePath():match('[\\/]')
local sep = r.GetOS():match('Win') and '\\' or '/'


function get_script_path() -- same as ({r.get_action_context()})[2]:match('.+[\\/]')
-- https://forum.cockos.com/showthread.php?t=159547
local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
-- OR
-- local script_path = info.source:match('@(.+[\\/]')
return script_path
end


function get_package_path_for_require()
-- https://forums.cockos.com/showthread.php?p=1668756
-- https://github.com/ReaTeam/ReaScripts-Templates/blob/master/Files/Require%20external%20files%20for%20the%20script.lua
-- https://www.gammon.com.au/scripts/doc.php?lua=package.path
local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
	if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
	package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
	else
	package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
	end
end
require("X-Raym_Functions - console debug messages")


-- Undo with only the script name
r.Undo_EndBlock(({r.get_action_context()})[2]:match('([^\\/_]+)%.%w+$'), -1)


function Get_Script() -- by name elements, by command ID, by section, from reaper-kb.ini
local sep = r.GetResourcePath():match('[\\/]')
local res_path = r.GetResourcePath()..r.GetResourcePath():match('[\\/]') -- path with separator
local cont
local f = io.open(res_path..'reaper-kb.ini', 'r')
	if f then -- if file available, just in case
	cont = f:read('*a')
	f:close()
	end
	if cont and cont ~= '' then
		for line in cont:gmatch('[^\n\r]*') do -- parse reaper-kb.ini code
		local sect, comm_ID, scr_path = line:match('SCR %d+ (%d+) (.+) "Custom: .+_Exclusive dummy toggle %d+%.lua" "(.+)"') -- line:match('SCR %d+ '..sect..' '..comm_ID..' "Custom: .+_Exclusive dummy toggle %d+%.lua" "(.+)"')
			if comm_ID then
			-- get subset assignment of a found dummy toggle script
			local f = io.open(res_path..'Scripts'..sep..scr_path, 'r') -- get script code
			local cont = f:read('*a')
			f:close()
			end
		end
	end
end




function set_script_instances_mode(path, sep, cmd_ID, scr_name, Esc)
-- set script mode to 260 to terminate deferred instances without the pop-up dialogue
local cmd_ID = r.ReverseNamedCommandLookup(cmd_ID)
local cmd_ID = cmd_ID:match('RS.-_') and cmd_ID:sub(8) or cmd_ID:sub(3) -- only look for ID without the prefix and the infix
local cont
local f = io.open(path..sep..'reaper-kb.ini', 'r')
	if f then -- if file available, just in case
	cont = f:read('*a')
	f:close()
	end
	if cont and cont ~= '' then
	local cont_new = cont -- to make sure the var data is updated along with the loop
		for line in cont:gmatch('[^\n\r]*') do
		local line = line:match('SCR 4.+'..cmd_ID..'.+')
			if line	then -- MIDI Editor section script
			local line_new = line:gsub('SCR 4', 'SCR 260')
			local line = Esc(line)
			cont_new = cont_new:gsub(line, line_new)
			end
		end
		if cont_new ~= cont then
		local f = io.open(path..sep..'reaper-kb.ini', 'w')
		f:write(cont_new)
		f:close()
		end
	end

end



function Get_Script_Name(scr_name)
local t = {'top','bottom','all up','all down','next','previous','explode','implode','crop'} -- EXAMPLE
local t_len = #t -- store here since with nils length will be harder to get
	for k, elm in ipairs(t) do
	t[k] = scr_name:match(Esc(elm)) --or false -- to avoid nils in the table, although still works with the method below
	end
-- return table.unpack(t) -- without nils
return table.unpack(t,1,t_len) -- not sure why this works, not documented anywhere, but does return all values if some of them are nil even without the n value (table length) in the 1st field
-- found mentioned at
-- https://stackoverflow.com/a/1677358/8883033
-- https://stackoverflow.com/questions/1672985/lua-unpack-bug
-- https://uopilot.tati.pro/index.php?title=Unpack_(Lua)
end
-- USAGE EXAMPLE:
-- local top, bottom, up, down, nxt, prev, explode, implode, crop = Get_Script_Name(scr_name)


function Invalid_Script_Name1(scr_name,...)
-- check if necessary elements are found in script name
-- if more than 1 match is needed run twice with different sets of elements which are supposed to appear in the same name, but elements within each set must not be expected to appear in the same name
-- if running twice the error message and Rep() function must be used outside of this function after expression 'if no_elm1 or no_elm2 then'

local t = {...}

local found
	for k, elm in ipairs(t) do
		if scr_name:match(Esc(elm)) then found = 1 end
	end

	if #t > 0 and not found then -- no keyword was found in the script name
		local function Rep(n) -- number of repeats, integer
		return (' '):rep(n)
		end
	local br = '\n\n'
	r.MB([[The script name has been changed]]..br..Rep(7)..[[which renders it inoperable.]]..br..
	[[   please restore the original name]]..br..[[  referring to the list in the header,]]..br..
	Rep(9)..[[or reinstall it.]], 'ERROR', 0)
	return true
	end

end
-- USAGE EXAMPLE:
-- Invalid_Script_Name(scr_name, 'right', 'left', 'tracks', 'items')
-- EXAMPLE when several matches are required:
--[[
-- validate script name
local no_elm1 = Invalid_Script_Name(scr_name,table.unpack(type_t))
local no_elm2 = Invalid_Script_Name(scr_name,'left','right')
	if no_elm1 or no_elm2 then
	local br = '\n\n'
	r.MB([[The script name has been changed]]..br..Rep(7)..[[which renders it inoperable.]]..br..
	[[   please restore the original name]]..br..[[  referring to the list in the header,]]..br..
	Rep(9)..[[or reinstall the package.]], 'ERROR', 0)
	return r.defer(function() do return end end) end
]]


function Invalid_Script_Name2(scr_name,...)
-- check if necessary elements are found in script name
-- if more than 1 match is needed, run twice with different sets of elements which are supposed to appear in the same name, but elements within each set must not be expected to appear in the same name
-- if running twice the error message and Rep() function must be used outside of this function after expression 'if no_elm1 or no_elm2 then'

local t = {...}

	for k, elm in ipairs(t) do
		if scr_name:match(Esc(elm)) then return end -- at least one match was found
	end

	local function Rep(n) -- number of repeats, integer
	return (' '):rep(n)
	end

-- either no keyword was found in the script name or no keyword arguments were supplied
local br = '\n\n'
r.MB([[The script name has been changed]]..br..Rep(7)..[[which renders it inoperable.]]..br..
[[   please restore the original name]]..br..[[  referring to the list in the header,]]..br..
Rep(9)..[[or reinstall it.]], 'ERROR', 0)
return true

end


function Invalid_Script_Name3(scr_name,...)
-- check if necessary elements are found in script name and return the one found
-- only execute once
local t = {...}

	for k, elm in ipairs(t) do
		if scr_name:match(Esc(elm)) then return elm end -- at least one match was found
	end

	local function Rep(n) -- number of repeats, integer
	return (' '):rep(n)
	end

-- either no keyword was found in the script name or no keyword arguments were supplied
local br = '\n\n'
r.MB([[The script name has been changed]]..br..Rep(7)..[[which renders it inoperable.]]..br..
[[   please restore the original name]]..br..[[  referring to the name in the header,]]..br..
Rep(9)..[[or reinstall it.]], 'ERROR', 0)

end
-- USE:
--[[
local keyword = Invalid_Script_Name3(scr_name, 'right', 'left', 'up', 'down')
	if not keyword then r.defer(no_undo) end
	
	if keyword == 'right' then 
	-- DO STUFF
	elseif keyword == 'left' then
	-- DO STUFF
	-- ETC.
	end
]]


function Dir_Exists(path)
-- check if directory exists, if not returns nil, if yes and no files - empty string
-- 2nd return value error message, if no match then nil

-- path evaluation can be added

-- fix path lacking closing separator and with leading/trailing spaces
--local sep = r.GetOS():match('Win') and '\\' or '/'
--local path = not path:match('.+[\\/]%s*$') and path:match('^%s*(.-)%s*$')..sep or path:match('^%s*(.+'..sep..')%s*$') -- add last separator if none and remove leading/trailing spaces

local path = path:match('^%s*(.-)%s*$') -- remove leading/trailing spaces
local sep = path:match('[\\/]')
local path = path..(not path:match('.+[\\/]$') and path:match('[\\/]') or '') -- add last separator if none

local path = path:match('.+[\\/]$') and path:sub(1,-2) or path -- if there's separator remove it // not always necessary
local _, mess = io.open(path:sub(1,-2)) -- last separator is removed to return 1 (valid)
local result = mess:match('Permission denied') and 1 -- or 'and path..sep' // dir exists // this one is enough
or mess:match('No such file or directory') and 2
or mess:match('Invalid argument') and 3 -- leading and/or trailing spaces in the path or empty string
return result
end


function Dir_Exists(path) -- short
local path = path:match('^%s*(.-)%s*$') -- remove leading/trailing spaces
local sep = path:match('[\\/]')
local path = path:match('.+[\\/]$') and path:sub(1,-2) or path -- last separator is removed to return 1 (valid)
local _, mess = io.open(path)
return mess:match('Permission denied') and path..sep -- dir exists // this one is enough
end


-- Validate path supplied in the user settings
function Validate_Folder_Path(path) -- returns empty string if path is empty and nil if it's not a string
	if type(path) == 'string' then
	local path = path:match('^%s*(.-)%s*$') -- remove leading/trailing spaces
	-- return not path:match('.+[\\/]$') and path:match('[\\/]') and path..path:match('[\\/]') or path -- add last separator if none
-- more efficient:
	return path..(not path:match('.+[\\/]$') and path:match('[\\/]') or '') -- add last separator if none
	end
end

--[[ EXAMPLE OF USAGE to validate custom path

CUSTOM_FX_CHAIN_DIR = #CUSTOM_FX_CHAIN_DIR:gsub(' ','') > 0 and CUSTOM_FX_CHAIN_DIR

local fx_chain_dir = CUSTOM_FX_CHAIN_DIR and Dir_Exists(Validate_Folder_Path(CUSTOM_FX_CHAIN_DIR)) or path..sep..'FXChains'..sep

	if CUSTOM_FX_CHAIN_DIR and fx_chain_dir == path..sep..'FXChains'..sep then
	Error_Tooltip('\n\n        custom fx chain \n\n     directory isn\'t valid \n\n opening default directory \n\n')
	end

]]


function print_or_write_to_file(str, PATH_TO_DUMP_FILE, file_name) -- PATH_DO_DUMP_FILE is a directory path; uses 2 additional functions Dir_Exists() and open_dir_in_file_browser() // the routine is used in 'List all linked FX parameters in the project.lua'

	if #str <= 16380 then -- print to ReaConsole
	-- ReaScript console can display maximum of 16,382 (almost 16,384) bytes. Couldn't go any higher. Once this number is exceeded the printed content is cut by 2,052 (a little over 2,048) bytes. And as far as i understand the process is repeated from there on out.
	-- https://forum.cockos.com/showthread.php?t=216979#5
Msg(str)
	else -- dump to a file because ReaScript Console won't display the whole list
	local dir = Dir_Exists(PATH_TO_DUMP_FILE)
		if not dir then -- if dir is empty or otherwise invalid dump into the REAPER resource directory
		dir = r.GetResourcePath()..r.GetResourcePath():match('[\\/]') end
	local f = io.open(dir..file_name, 'w')
	f:write(str)
--	local f_exists = io.input(dir..file_name) -- must come before close(); throws generic lua error message on failure hence unsuitable
	f:close()
	local f_exists = r.file_exists(dir..file_name)
		if f_exists then
--Msg(dir:sub(1,-1))
		local path = (dir == PATH_TO_DUMP_FILE or dir:sub(1,-2) == PATH_TO_DUMP_FILE) and 'designated' -- user dir either with or without the last separator
		or 'REAPER resource'
		local space = path == 'designated' and (' '):rep(5) or ''
		local resp = r.MB(' The list has been saved to a file\n\n'..space..'in the '..path..' directory.\n\n       Open the directory now?', 'PROMPT', 4)
			if resp == 6 then open_dir_in_file_browser(dir) end -- if dir is system root with slash, e.g. 'C:/' opens 'My Documents' on Windows, must be either 'C:\\'
		end
	end

end


local path = reaper.GetResourcePath()
function ScanPath(path)
-- Recursve fetching of directory structure and files // MPL, Lokasenna // https://forum.cockos.com/showthread.php?t=206933 // the path must not end with a separator
    local t = {} -- must be clean otherwise the path will each time be added twice, as a main path and as a subdir
    local subdirindex, fileindex = 0,0
    local path_child
    repeat
        path_child = reaper.EnumerateSubdirectories(path, subdirindex )
        if path_child then
            table.insert(t,path_child)
            local tmp = ScanPath(path .. "/" .. path_child)
            for i = 1, #tmp do
                --table.insert(t, path .. "/" .. path_child .. "/" .. tmp[i])
                table.insert(t, tmp[i])
            end
        end
        subdirindex = subdirindex+1
    until not path_child

    repeat
        fn = reaper.EnumerateFiles( path, fileindex )
        if fn then
            --t[#t+1] = path .. "/" .. fn
            t[#t+1] = fn
        end
        fileindex = fileindex+1
    until not fn

    return t
end

local t = ScanPath(path)


-- My version
function ScanPath(path)
local path = path:match('^%s*(.-)%s*$') -- trim spaces
local path = #path > 0 and path:match('.+[\\/]$') and path:match('(.+)[\\/]$') or path -- remove last separator if any
local sep = path:match('[\\/]') and path:match('[\\/]') or '' -- extract the separator
    local t = {}
    local subdir_idx, file_idx = 0, 0
    local subdir
    repeat
    local subdir = r.EnumerateSubdirectories(path, subdir_idx)
        if subdir then
		t[#t+1] = path..sep..subdir..sep -- for file scan separator isn't needed as EnumerateFiles() works without it
        local tmp = ScanPath(path..sep..subdir)
	table.sort(tmp, function(a,b) return tonumber(a:match('.+[\\/](.-)$')) < tonumber(b:match('.+[\\/](.-)$')) end) -- sort paths by the last folder name IF IT'S NUMERIC in case the numbers aren't preceded with 0 and 10 appears earlier than 2, alphabetical names are sorted automatically
			for i = 1, #tmp do
            t[#t+1] = tmp[i]
            end
        end
    subdir_idx = subdir_idx + 1
    until not subdir

	repeat
	local fn = r.EnumerateFiles(path, file_idx)
		if fn then
        t[#t+1] = path..sep..fn
        end
	file_idx = file_idx + 1
	until not fn

    return t
end


function Count_Files_In_Folder(path,ext)
--r.EnumerateFiles(path..'..', 0) -- reset EnumerateFiles() cache by accessing a dummy dir
--r.EnumerateFiles(path, -1) -- since 6.20
local i = 0
local f_cnt = 0
	repeat
	local file_n = r.EnumerateFiles(path, i)
		if file_n and file_n:match('%.reapeaks') then os.remove(path..file_n) end -- delete .reapeaks files
	i = i + 1
		if file_n and file_n:match(''..ext..'$') then f_cnt = f_cnt+1 end
	until not file_n
return f_cnt
end


function Remove_Peak_Files(path)
local i = 0
	repeat
	local file_n = r.EnumerateFiles(path, i)
		if file_n and file_n:match('%.reapeaks') then os.remove(path..file_n) end -- delete .reapeaks files
	i = i + 1
	until not file_n
end



function get_file_timestamp(file_name) -- without seconds // Windows only
-- https://superuser.com/questions/1277743/fast-built-in-command-to-get-the-last-modified-date-of-a-file-in-windows
-- https://stackoverflow.com/questions/33296834/how-can-i-get-last-modified-timestamp-in-lua
-- https://stackoverflow.com/questions/2111333/how-to-get-last-modified-date-on-windows-command-line-for-a-set-of-files
-- https://www.windows-commandline.com/dir-command-line-options/
-- https://www.windows-commandline.com/find-files-based-on-modified-time/
-- https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir
-- https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/forfiles
-- https://ab57.ru/cmdlist/forfiles.html
-- https://stackoverflow.com/questions/515309/what-does-cmd-c-mean
-- https://forum.cockos.com/showpost.php?p=1867737&postcount=6
local path = r.GetResourcePath()
local file = '"'..path..path:match('[\\/]')..file_name..'"'--'reaper-screensets.ini"'
return r.ExecProcess('cmd.exe /C dir \tw '..file, 0):match('.+\n(.-%d+:%d+)') -- command is a command line string, timeout is number in ms timeout is 0, command will be allowed to run indefinitely (for large amounts of returned output), timeout -1 for no wait/terminate, -2 for no wait and minimize
end


function get_file_timestamp(file_name, dir) -- both args are strings // dir MUST NOT end with separator, if dir isn't provided file arg must be full path // Windows only // special chars in args must either be escaped or the args inclosed in [[]]
-- https://www.dostips.com/forum/viewtopic.php?t=6063#p38222 which helped to figure out the forfiles syntax
	if not dir then -- time without seconds
	return r.ExecProcess('cmd.exe /C dir \tw "'..file_name..'"', 0):match('.+\n(.-%d+:%d+)')
	else -- time with seconds
	local dir = #dir == 3 and dir or '"'..dir..'"' -- when not root as root doesn't allow quotes
	return r.ExecProcess('forfiles /P '..dir..' /M "'..file_name..'" /C "cmd /c echo @fdate @ftime"', 0):match('.+\n(.+)\n') -- excluding trailing empty line // in command prompt quotes around the dir path are only allowed if it's not root and required when it contains spaces, in file name they are required when it contains spaces; so basically they should be there as a safeguard except when the dir is root // can in fact be the only one syntax BUT dir and file must be splat up
	end
end

-- streamlined
function get_file_timestamp(file_name, dir) -- both args are strings // dir MUST NOT end with separator, if dir isn't provided file arg must be full path // Windows only // special chars in args must either be escaped or the args inclosed in [[]]
local command
local capt
	if not dir then -- time without seconds
	command, capt = 'cmd.exe /C dir \tw "'..file_name..'"', '.+\n(.-%d+:%d+)'
	return r.ExecProcess('cmd.exe /C dir \tw "'..file_name..'"', 0):match('.+\n(.-%d+:%d+)')
	else -- time with seconds
	local dir = #dir > 3 and dir:match('.+[\\/]$') and dir:match('(.+)[\\/]') or dir -- remove last separator if any in dir other than the root
	local dir = #dir == 3 and dir or '"'..dir..'"' -- when not root as root doesn't allow quotes
	command, capt = 'forfiles /P '..dir..' /M "'..file_name..'" /C "cmd /c echo @fdate @ftime"', '.+\n(.+)\n' -- excluding trailing empty line
	end
return r.ExecProcess(command, 0):match(capt)
end

-- streamlined +
function get_file_timestamp(full_file_path) -- time with seconds
local dir, file_name = full_file_path:match('(.+)[\\/](.+)') -- makes sure that dir doesn't end with separator
local dir = #dir == 3 and dir or '"'..dir..'"' -- when not root as root doesn't allow quotes
return r.ExecProcess('forfiles /P '..dir..' /M "'..file_name..'" /C "cmd /c echo @fdate @ftime"', 0):match('.+\n(.+)\n') -- excluding trailing empty line
end


function open_dir_in_file_browser(dir)
-- REAPER Profile terminal_CLEAN.lua
local OS = r.GetOS():sub(1,3)
local command = OS == 'Win' and {'explorer'} or (OS == 'OSX' or OS == 'mac') and {'open'} or {'nautilus', 'dolphin', 'gnome-open', 'xdg-open', 'gio open', 'caja', 'browse'}
-- https://askubuntu.com/questions/31069/how-to-open-a-file-manager-of-the-current-directory-in-the-terminal
	for k,v in ipairs(command) do
	local result = r.ExecProcess(v..' '..dir, -1) -- timeoutmsec is -1 = no wait/terminate // -- if dir is system root with slash, e.g. C:/ opens 'My Documents' on Windows, must be either 'C:' or 'C:\\'
		if result then return end
	end
end


function delete_string_from_file(f_path, to_delete) -- to_delete arg is a string
-- f_path = r.GetResourcePath()..r.GetResourcePath():match('[\\/]')..'reaper-extstate.ini
local f = io.open(f_path', 'r')
local cont = f:read('*a')
f:close()
local cont_new = cont:gsub(to_delete, '')
local f = io.open(f_path, 'w')
f:write(cont_new)
f:close()
end


function Read_Lines(file_path) -- same as io.lines()
local f = io.open(file_path,'r')
	return function(f)
		   return f:read('*l') -- although the Lua function returns nil at the end of file (EOF), this function does not
	       end
end
-- to use:
-- for line in Read_Lines(file_path) do
-- STUFF
-- end


function get_ini_file_path(ini_file_name)
	if not ini_file_name or #ini_file_name == 0 then return '' end
local path = r.GetResourcePath()
return path..path:match('[\\/]')..ini_file_name
end


function get_proj_path()
local _, projfn = r.EnumProjects(-1) -- active
return projfn
-- OR
--local path = r.GetProjectPath('')
--return path..path:match('[\\/]')..r.GetProjectName(0,'')
end


function get_proj_title(projpath) -- local _, projpath = r.EnumProjects(idx) -- -1 current

	local function get_from_file(projpath)
	local f = io.open(projpath,'r')
	local cont = f:read('*a')
	f:close()
	return cont:match('TITLE "?(.-)"?\n') -- quotation marks only if there're spaces in the title
	end

local proj_title, retval

local i = 0
	repeat
	local ret, projfn = r.EnumProjects(i) -- find if the project is open in a tab
		if projfn == projpath then retval = ret break end
	i = i+1
	until not ret
	if retval then -- the project is open in a tab
		if tonumber(r.GetAppVersion():match('(.+)/')) >= 6.43 then -- if can be retrieved via API regardless of being saved to the project file // API for getting title was added in 6.43
		retval, proj_title = r.GetSetProjectInfo_String(retval, 'PROJECT_TITLE', '', false) -- is_set false // retval is a proj pointer, not an index
		else -- retrieve from file which in theory may be different from the latest title in case the project hasn't been saved
		proj_title = get_from_file(projpath)
		end
	else
	proj_title = get_from_file(projpath)
	end

	return proj_title and proj_title:match('[%w]+') and proj_title -- if there're any alphanumeric chars // proj_title can be nil when extracted from .RPP file because without the title there's no TITLE key, if returned by the API function it's an empty string, when getting, retval is useless because it's always true unless the attribute, i.e. 'PROJECT_TITLE', is an empty string or invalid

end


function get_ini_cont()
local f = io.open(r.get_ini_file(), 'r')
local cont = f:read('*a')
f:close()
return cont
end


function Check_reaper_ini(key,value) -- the args must be strings
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local val = cont:match(key..'=([%.%d]+)') == value -- OR '=(.-)\n'
return val
-- OR SIMPLY: return cont:match(key..'=([%.%d]+)') == value
end


function Extract_reaper_ini_val(key) -- the arg must be string
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
return cont:match(key..'=(.-)\n')
end


function Get_File_Cont(f_path)
local f = io.open(f_path,'r')
local cont = f:read('*a')
f:close()
return cont
end


function scandir(dir) -- not for Mac; REAPER API already has r.EnumerateSubdirectories()
-- https://forum.cockos.com/showthread.php?t=159547
-- A less elegant solution to get a directory list in lua without additional libraries is to use the os.execute and write the lines to a buffer. Works like a charm but you do get a very quick terminal window popping open to execute it. I used it a few times on my File Manager script if you want to see an example. This works on Mac. Instead of os.execute the native r.ExecProcess() could probably be used
local i, t, popen = 0, {}, io.popen
    for filename in popen('dir "'..dir..'" /b'):lines() do
        msg(filename)
        i = i + 1
        t[i] = filename
    end
    return t
end


function Create_Dummy_Project_File()
local _, scr_name, sect_ID, cmd_ID, _,_,_ = r.get_action_context()
local dummy_proj = scr_name:match('.+[\\/]')..'BuyOne_dummy project (do not rename).RPP'
	if not r.file_exists(dummy_proj) then -- create a dummy project file next to the script
	local f = io.open(dummy_proj,'w')
	f:write('<REAPER_PROJECT\n>')
	f:close()
	end
return dummy_proj
end


--=================================== F I L E S   E N D =========================================

--===============================  M E A S U R E M E N T S  =====================================


function Get_Arrange_Len_In_Pixels()
local start_time, end_time = r.GetSet_ArrangeView2(0, false, 0, 0, start_time, end_time) -- isSet false, screen_x_start & screen_x_end both 0 = GET // https://forum.cockos.com/showthread.php?t=227524#2 the function has 6 arguments; screen_x_start and screen_x_end (3d and 4th args) are not return values, they are for specifying where start_time and stop_time should be on the screen when non-zero when isSet is true
local len = (end_time-start_time)*r.GetHZoomLevel()-17 -- GetHZoomLevel() returns px/sec // 17 is the vertical scrollbar which is included in the Arrange length in sec but is outside of the visible time line
return math.floor(len+0.5) -- return rounded since fractional pixel values are invalid
-- OR
-- return len -- if rounding will be done outside of the function after additional calculations
end


function Beat_To_Pixels()
return math.floor(60/r.Master_GetTempo()*r.GetHZoomLevel()+0.5) -- GetHZoomLevel() returns px/sec; return rounded since fractional pixel values are invalid
end


function Grid_Div_Dur_In_Sec() -- in sec
-- grid division (div) is the one set in the Snap/Grid settings
local retval, div, swingmode, swingamt = r.GetSetProjectGrid(0, false, 0, 0, 0) -- proj is 0, set is false, division, swingmode & swingamt are 0 (disabled for the purpose of fetching the data)
--local convers_t = {[0.015625] = 0.0625, [0.03125] = 0.125, [0.0625] = 0.25, [0.125] = 0.5, [0.25] = 1, [0.5] = 2, [1] = 4} -- number of quarter notes in grid division; conversion from div value
--return grid_div_time = 60/r.Master_GetTempo()*convers_t[div] -- duration of 1 grid division in sec
-- OR
--local grid_div_time = 60/r.Master_GetTempo()*div/0.25 -- duration of 1 grid division in sec; 0.25 corresponds to a quarter note as per GetSetProjectGrid()
--return grid_div_time
-- OR
return 60/r.Master_GetTempo()*div/0.25 -- duration of 1 grid division in sec; 0.25 corresponds to a quarter note as per GetSetProjectGrid()
end


function Music_Div_To_Sec(val)
-- val is either integer (whole bars/notes) or quotient of a fraction x/x, i.e. 1/2, 1/3, 1/4, 2/6 etc
	if not val or val == 0 then return end
return 60/r.Master_GetTempo()*4*val -- multiply crotchet's length by 4 to get full bar length and then multiply the result by the note division
end


function Music_Div_To_Pixels(val)
-- val is either integer (whole bars/notes) or quotient of a fraction x/x, i.e. 1/2, 1/3, 1/4, 2/6 etc
	if not val or val == 0 then return end
return math.floor(60/r.Master_GetTempo()*4*val*r.GetHZoomLevel()+0.5) -- multiply crotchet's length by 4 to get full bar length and then multiply the result by the note division
end


function Scale_Time_By_Horiz_Zoom_Level(val, base_zoom)
-- mainly for scaling distance of mouse cursor from object
-- val is distance in sec/ms, base_zoom is pixels per sec at which the value isn't scaled
-- e.g. if base_zoom is 100 the value isn't scaled at 100 px/sec (or rather in the neighbourhood since zoom value is never this exact) because 100/100 is 1, if the zoom decreases (goes below the base_zoom, zoom out) the value will be increased, if increases (goes above the base_zoom, zoom in) it will be decreased, because the greater the zoom the more precisely can the target value be hit thanks to greater resolution and smaller distance from the target is permissible
-- the base_zoom value could be precise if extracted directly from GetHZoomLevel() at a specific zoom level beforehand
return val/(r.GetHZoomLevel()/base_zoom)
end


function frames2ms(frames_num) -- depends on round() function
local fps, isdropFrame = r.TimeMap_curFrameRate(0)
local ms_per_frame = 1000/fps
return round(f*ms_per_frame)
end


function time_pos_to_pixels(posInSec) -- posInSec is an absolute value in project; without SWS extension only accurate when the program window is fully open

--[[ NOT NEEDED WHEN TCP_width var is not in use
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
--]]

--local rt, top, lt, bot = r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true) -- true - work area, false - the entire screen
local sws = r.APIExists('BR_Win32_GetWindowRect')
local dimens_t = sws and {r.BR_Win32_GetWindowRect(r.GetMainHwnd())}
or {r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true)} -- true - work area, false - the entire screen // https://forum.cockos.com/showthread.php?t=195629#4
	if #dimens_t == 5 then table.remove(dimens_t, 1) end -- remove retval value if BR's function
local rt, top, lt, bot = table.unpack(dimens_t)
local start_time, end_time = r.GetSet_ArrangeView2(0, false, 0, 0, start_time, end_time) -- isSet false, screen_x_start & screen_x_end both 0 = GET // https://forum.cockos.com/showthread.php?t=227524#2 the function has 6 arguments; screen_x_start and screen_x_end (3d and 4th args) are not return values, they are for specifying where start_time and stop_time should be on the screen when non-zero when isSet is true
--local TCP_width = tonumber(cont:match('leftpanewid=(.-)\n')) -- only changes in reaper.ini when dragged
local Top_area_h = sws and top + 65 or tonumber(cont:match('toppane=(.-)\n')) or 65 -- 'toppane' only changes in reaper.ini when dragged so not reliable // Y coordinate, OPTIONAL, can be changed on a case by case basis
-- https://forums.cockos.com/showpost.php?p=1991096&postcount=11 thanks to mespotine
--local arrange_w_px = lt - TCP_width -- accurate
--local sec_in_arrange = arrange_w/r.GetHZoomLevel() -- accurate
local arrange_w_px = (end_time - start_time)*r.GetHZoomLevel() -- get width of Arrange in pixels; GetHZoomLevel() returns pixels per second
local TCP_w_dockheight_l = lt - arrange_w_px -- seems more accurate than TCP_width (leftpanewid) by about 10 px upward when left docker is closed; otherwise accounts for open docker as well; plus TCP_width value is not reliable as it only changes when TCP edge is dragged
local pos_in_arrange_sec = posInSec - start_time
local pos_in_arrange_px = pos_in_arrange_sec*r.GetHZoomLevel() + TCP_w_dockheight_l -- + TCP_width // X coordinate
return math.ceil(pos_in_arrange_px) - pos_in_arrange_px <= pos_in_arrange_px - math.floor(pos_in_arrange_px) and math.ceil(pos_in_arrange_px) or math.floor(pos_in_arrange_px), -- round up or down
Top_area_h -- OPTIONAL, can be changed on a case by case basis, see above

end


function pixel_to_sec(val) -- converts interval in pixels to interval in seconds, val can be either integer or decimal number
return val/r.GetHZoomLevel()
end


function Horiz_Scroll_Distance(SEC, VALUE) -- SEC is boolean to use seconds as scroll unit when VALUE is in seconds; otherwise musical division
-- relies on Music_Div_To_Sec() function
local px_per_sec = r.GetHZoomLevel()
return SEC and VALUE and px_per_sec*VALUE or -- seconds
VALUE and px_per_sec*Music_Div_To_Sec(VALUE) or -- musical interval
px_per_sec*Music_Div_To_Sec(1/4) -- empty, 0 or non-numeric input so it defaults to 1 beat
end


function Get_Screen_Dims()
local f = io.open(reaper.get_ini_file(), 'r') -- load reaper.ini for parsing
local f_cont = f:read('*a') -- read the entire content
f:close()
--local wnd_w = f_cont:match('(wnd_w=%d*)');
--local wnd_w = tonumber(wnd_w:match('=(%d*)'))
-- OR local wnd_w = tonumber(f_cont:match('wnd_w=(%d*)'))
--local wnd_h = f_cont:match('(wnd_h=%d*)');
--local wnd_h = tonumber(wnd_h:match('=(%d*)'))
-- OR wnd_h = tonumber(f_cont:match('wnd_h=(%d*)'))
-- https://forums.cockos.com/showthread.php?t=203785
return tonumber(f_cont:match('wnd_w=(%d*)')), tonumber(f_cont:match('wnd_h=(%d*)')) -- width and height
end
-- OR
local dimens_t = {r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true)} -- wantWorkArea true // 1 - L, 2 - T, 3 - R, 4 - B // https://forum.cockos.com/showthread.php?t=195629#4


--====================== M E A S U R E M E N T S   E N D =======================================


function timed_tooltip(tooltip, x, y, time) -- local x, y = r.GetMousePosition()
-- sticks for the duration of time in sec if the script is run from a floating toolbar button
-- so it's overrides button own tooltip which interferes

local _ = r.TrackCtl_SetToolTip

local lt, top, rt, bot = r.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, true) -- screen dimensions; wantWorkArea is true // https://forum.cockos.com/showthread.php?t=195629#4

	if r.GetCursorContext() == -1 -- when a floating toolbar button is pressed,
	-- doesn't apply to the Main toolbar docked toolbars since they do register context
	or r.GetCursorContext() > -1 and (x <= 200 or rt - x <= 200 or y <= 200 or bot - y <= 200) -- when docked or Main toolbar button is pressed, affects also calling the script from menu and via a shortcut in other areas (Mixer/TCP bottom, ruler, focused toolbar/window); won't work if the program window is shrunk
	then
	_(tooltip, x, y+10, true) -- initial display; topmost true
	local t = os.clock()
		repeat -- freezes UI so the tooltip sticks
	--	while os.clock() - t <= time do -- alternative
	--	end
		until os.clock() - t > time -- greater > sign instead of == because the exact time stamp might not get caught due to speed and the decimal value
	else _(tooltip, x, y+10, true) -- topmost is true
	end

end



function timed_tooltip(x,y) -- deferred, all used vars must be global and come from outside, 'start' in particular
local x, y = r.GetMousePosition()
	if r.time_precise - start < 1 -- 1 sec
	then r.defer(timed_tooltip) end
r.TrackCtl_SetToolTip('TEXT', x, y, true) -- topmost is true; if x and y are taken from screen/window dimensions and divided use math.floor() so values are integers
end


function Error_Tooltip(text, caps, spaced) -- caps and spaced are booleans
local x, y = r.GetMousePosition()
local text = caps and text:upper() or text
local text = spaced and text:gsub('.','%0 ') or text
r.TrackCtl_SetToolTip(text, x, y, true) -- topmost true
-- r.TrackCtl_SetToolTip(text:upper(), x, y, true) -- topmost true
-- r.TrackCtl_SetToolTip(text:upper():gsub('.','%0 '), x, y, true) -- spaced out // topmost true
--[[
-- a time loop can be added to run until certain condition obtains, e.g.
local time_init = r.time_precise()
repeat
until condition and r.time_precise()-time_init >= 0.7 or not condition
]]
end


function Error_Tooltip2(text, format) -- format must be true
local x, y = r.GetMousePosition()
local text = text and type(text) == 'string' and (format and text:upper():gsub('.','%0 ') or text) or 'not a valid "text" argument'
r.TrackCtl_SetToolTip(text, x, y, true) -- topmost true
end


function Get_Tooltip_Settings()
-- Preferences -> Appearance - Appearance settings - Tooltips:
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local val = cont:match('tooltips=(.-)\n')
local delay = cont:match('tooltipdelay=(.-)\n') -- likely in ms
local val, delay = tonumber(val), tonumber(delay)
local UI, itm_env, env_hov
-- Thanks to Mespotine
-- https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
	if val then
	UI, itm_env, env_hov = val&2 == 0, val&1 == 0, val&4 == 0 -- UI elements, Items/envelopes, Envs on hover -- enabled
	end
return UI, itm_env, env_hov, delay
end


-- for keeping user stored parameter a limited amount of time, e.g. when two script runs must follow each other in close succession so that if the follow-up run isn't performed the value is invalid for the next run
function Keep_ExtState_For_X_Mins1(Sect, Key, Val, Minutes, Set) -- Minutes is number, Set is boolean whether to set or get
	if Set then
	r.SetExtState(Sect, Key, Val..':'..os.clock(), false) -- persist false
	else
	local state = r.GetExtState(Sect, Key)
	local time_init = state:match(':(.+)')
		if (os.clock() - (time_init+0))/60 >= Minutes then return
		else
		return state:match('(.+):')
		end
	end
end

-- this version is to be used as a boolean to determine whether to run GetExtState() to retrieve the stored value
function Keep_ExtState_For_X_Mins2(Minutes, Set) -- Minutes is number, Set is boolean whether to set or get
	if Set then
	r.SetExtState('KEEP EXT STATE FOR X MINS', 'TIME INIT', os.clock(), false) -- persist false
	else
	local time_init = r.GetExtState('KEEP EXT STATE FOR X MINS', 'TIME INIT')
		if (os.clock() - (time_init+0))/60 >= Minutes then return
		else
		return true
		end
	end
end
--[[ USASE EXAMPLE:
Keep_ExtState_For_X_Mins2(1, true) -- Set true, Minutes argument isn't used at this stage
local elapsed = Keep_ExtState_For_X_Mins2(1) -- Set is false, Minutes argument is used
	if elapsed then (some message) return end
local state = not elapsed and r.GetExtState(section, key)
--]]


function Set_Get_Delete_ExtState_Series(Set, Get, Del, t) -- all args are booleans, t is a table containing values to be stored, ommission of t argument disables Set arg
local _, scr_name, sect_ID, cmd_ID, _,_,_ = r.get_action_context()
local named_ID = r.ReverseNamedCommandLookup(cmd_ID)
	if Set and t and type(t) == 'table' then
		for k, v in ipairs(itm_t) do
		r.SetExtState(named_ID, k, v, false) -- persist false
		end
	elseif Get then
	local t = {}
	local i = 1
		repeat -- construct table from extended states
		t[#t+1] = r.GetExtState(named_ID, i)
		i = i+1
		until r.GetExtState(named_ID, i) == '' -- first key without stored value
	return t
	elseif Del then
	local i = 1
		repeat
		r.DeleteExtState(sect, i, true) -- persist true
		i = i+1
		until r.GetExtState(sect, i) == '' -- first key without stored value
	end
end



function WAIT(duration_in_sec)
-- https://stackoverflow.com/questions/1034334/easiest-way-to-make-lua-script-wait-pause-sleep-block-for-a-few-seconds other suggestions
local t = os.clock()
	repeat -- freezes UI so the tooltip sticks
	until os.clock() - t > duration_in_sec
-- 	OR
--	while os.clock() - t <= duration_in_sec do
--	end
end

DURATION_IN_SEC = ""
function DEFERRED_WAIT()
-- https://stackoverflow.com/questions/1034334/easiest-way-to-make-lua-script-wait-pause-sleep-block-for-a-few-seconds other suggestions
local t = os.clock()
	if os.clock() - t > tonumber(DURATION_IN_SEC) then
	-- DO STUFF
	return end
r.defer(DEFERRED_WAIT)
end


function Archie_WAIT()
-- https://rmmedia.ru/threads/110165/post-2519952
-- https://rmmedia.ru/threads/110165/post-2520017 explanation + further below
x = x + 1
	if x >= 10 then
	-- DO STUFF, OR KEEP IDLE
	return
	end
r.defer(Archie_WAIT)
end
--r.defer(Archie_WAIT)


-- REAPER version check
function REAPER_Ver_Check(build) -- build is REAPER build number, the function must be followed by 'do return end'
	if tonumber(r.GetAppVersion():match('(.+)/')) < build then -- or match('[%d%.]+')
	local x,y = r.GetMousePosition()
	local mess = '\n\n   THE SCRIPT REQUIRES\n\n  REAPER '..build..' AND ABOVE  \n\n '
	local mess = mess:gsub('.','%0 ')
	r.TrackCtl_SetToolTip(mess, x, y+10, true) -- topmost true
	return true
	end -- 'ReaScript:Run' caption is displayed in the menu bar but no actual undo point is created because Undo_BeginBlock() isn't yet initialized, here and elsewhere
end


function REAPER_Ver_Eval(some_build) -- some_build is a string/number
local some_build = some_build and tonumber(some_build)
local cur_build = tonumber(r.GetAppVersion():match('(.+)/'))
	if some_build then -- return full table
	return {current = cur_build, earlier = cur_build < some_build, later = cur_build > some_build, same = cur_build == some_build}
	end
	return {current = cur_build} -- if not some_build or it's not a number, only current build number
end


function how_recently_the_project_was_saved()
local retval, projfn = r.EnumProjects(-1) -- -1 current project
local last_save_time
	for line in io.lines(projfn) do
		if line:match('REAPER_PROJECT') then last_save_time = line:match('.+ (%d+)') break end -- the integer represents Unix time at the moment the project was last saved https://www.askjf.com/index.php?q=6650s
	end
--os.setlocale ('', 'time') -- set, otherwise timestamp doesn't use current locale https://www.gammon.com.au/scripts/doc.php?lua=os.date // doesn't set custom date format
local diff = os.time() - last_save_time
return diff, -- seconds
math.floor(diff/60+0.5), -- minutes, rounded
math.floor(diff/3600+0.5), -- hours, rounded
math.floor(diff/(3600*24)+0.5), -- days, rounded
os.date('%x %X',last_save_time), -- last save date & time in current locale format
os.date('%x %X',os.time()) -- current date & time in current locale format
end
-- USE:
-- local sec, mins, hrs, days, timestamp_save, timestamp_cur = how_recently_the_project_was_saved()



function Enum_RS5k_files(tr, fx_idx)
local i = 0
	repeat
	local retval, name = r.TrackFX_GetNamedConfigParm(tr, fx_idx, "FILE"..i)
	local name = name:match('.+[\\/](.+)')
		if name then ... end -- if retval then .... end // ... means some operation
	i = i + 1
	until not retval or not name or name == ''
end


for key in pairs(reaper) do _G[key] = reaper[key] end  -- MPL: get rid of 'reaper.' table key in functions



function Close_Tab_Without_Save_Prompt()
-- Close temp project tab without save prompt; when a freshly opened project closes there's no prompt
local cur_proj, projfn = r.EnumProjects(-1) -- store cur project pointer
r.Main_OnCommand(41929, 0) -- New project tab (ignore default template) // open new proj tab
-- DO STUFF
r.Main_openProject('noprompt:'..projfn) -- open the stored project in the temp tab
r.Main_OnCommand(40860, 0) -- Close current project tab // won't generate a save prompt
r.SelectProjectInstance(cur_proj) -- re-open orig proj tab
end



function All_Proj_Change_Cnt() -- get proj change count accounting for all open projects // hardly necessary as changes are only registered in the active one
local i = 0
local count = 0
	repeat
	local retval, projfn = r.EnumProjects(i)
	count = retval and count + r.GetProjectStateChangeCount(retval) or count
	i = i+1
	until not retval
return count
end


function Count_Proj_Tabs()
local i = 0
	repeat
	local retval, projfn = r.EnumProjects(i)
	i = retval and i+1 or i
	until not retval
return i
end



function GetPlayPosition3() -- using r.GetPlayPosition2() only when transport runs because the function runs independently of it
-- https://forum.cockos.com/showthread.php?p=2617467
-- https://forum.cockos.com/showthread.php?t=273086
-- r.GetPlayPosition2() initial time depends on the edit cursor position, so once transport starts the value changes to the one corresponding to the current edit cursor position
local pos
	if r.GetPlayState() > 0 then
	pos = r.GetPlayPosition2()
	else
	pos = r.GetCursorPosition()
	end
return pos
end


function GetRulerTimeUnit(main) -- main is boolean
-- thanks to Mespotine https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
-- https://github.com/mespotine/ultraschall-and-reaper-docs/blob/master/Docs/Reaper-ConfigVariables-Documentation.txt
-- can be extracted from the listed toggle actions state
local main_t = {
40365, -- Minutes:Seconds 40365
40366, -- Measures.Beats / Minutes:Seconds 40366
41918, -- Measures.Beats (minimal) / minutes:Seconds 41918
40367, -- Measures.Beats 40367
41916, -- Measures.Beats (minimal) 41916
40368, -- Seconds 40368
40369, -- Samples 40369
40370, -- Hours:Minutes:Seconds:Frames 40370
41973  -- Absolute Frames 41973
}
local second_t = {
42360, -- None 42360
42361, -- Minutes:Seconds 42367
42362, -- Seconds 42362
42363, -- Samples 42363
42364, -- Hours:Minutes:Seconds:Frames 42364
42365  -- Absolute Frames 42365
}
local t = main and main_t or second_t
	for k, ID in ipairs(t) do
	t[k] = r.GetToggleCommandStateEx(0, ID) == 1
	end
return t

end


function GetTransportTimeUnit(main) -- main is boolean
-- thanks to Mespotine https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
-- https://github.com/mespotine/ultraschall-and-reaper-docs/blob/master/Docs/Reaper-ConfigVariables-Documentation.txt
local main_t = {
40379, -- Use ruler time unit 40379
40410, -- Minutes:Seconds 40410
40534, -- Measures.Beats / Minutes:Seconds 40534
40411, -- Measures.Beats 40411
40412, -- Seconds 40412
40413, -- Samples 40413
40414, -- Hours:Minutes:Seconds:Frames 40414
41972  -- Absolute Frames 41972
}
local second_t = {
42366, -- None 42366
42367, -- Minutes:Seconds 42367
42368, -- Seconds 42368
42369, -- Samples 42369
42370, -- Hours:Minutes:Seconds:Frames 42370
42371  -- Absolute Frames 42371
}
local t = main and main_t or second_t
	for k, ID in ipairs(t) do
	t[k] = r.GetToggleCommandStateEx(0, ID) == 1
	end
return t

end


function Get_Armed_Action_Name(path, sep)

	local function script_exists(line, name)
	-- how paths external to \Scripts folder may look on MacOS
	-- https://github.com/Samelot/Reaper/blob/master/reaper-kb.ini
	local f_path = line:match(esc(name)..' "(.+)"$') or line:match(esc(name)..' (.+)$') -- path either with or without spaces, in the former case it's enclosed within quotation marks
	local f_path = f_path:match('^%u:') and f_path or path..sep..'Scripts'..sep..f_path -- full (starts with the drive letter and a colon) or relative file path; in reaper-kb.ini full path is stored when the script resides outside of the 'Scripts' folder of the REAPER instance being used // NOT SURE THE FULL PATH SYNTAX IS VALID ON OSs OTHER THAN WIN
--	script_exists = r.file_exists(f_path)
	return r.file_exists(f_path)
	end

local sws = r.APIExists('CF_GetCommandText')

local sect_t = {['']=0,['MIDI Editor']=32060,['MIDI Event List Editor']=32061,
				['MIDI Inline Editor']=32062,['Media Explorer']=32063}

	if r.GetToggleCommandStateEx(0,40605) == 1 then -- Show action list // only if Action list window is open to force deliberate use of action notes and prevent accidents in case some action is already armed for other purposes
	local cmd, section = r.GetArmedCommand() -- cmd is 0 when no armed action, empty string section is 'Main' section
	r.ArmCommand(0, section) -- 0 unarm all
		if cmd > 0 then
		local named_cmd = r.ReverseNamedCommandLookup(cmd) -- if the cmd belongs to a native action or is 0 the return value is nil
		local name, scr_exists, mess = false, true -- mess is nil // scr_exists is true by default to accomodate actions which can't be removed
			if cmd > 0 and not named_cmd and not sws then -- native action is armed; without CF_GetCommandText() there's no way to retrieve native action name, only script and custom action names via reaper-kb.ini; without the sws extension cycle actions aren't available
			mess = space(6)..'since the sws extension \n\n'..space(11)..'is not installed \n\n only non-cycle custom actions \n\n'..space(4)..'and scripts are supported'
			elseif named_cmd and not sws then -- without CF_GetCommandText() there's no way to retrieve the sws extension action names, only custom actions and scripts from reaper-kb.ini; without the sws extension cycle actions aren't available anyway
				for line in io.lines(path..sep..'reaper-kb.ini') do -- much quicker than using io.read() which freezes UI
				name = line:match('ACT.-("'..esc(named_cmd)..'" ".-")') or line:match('SCR.-('..esc(named_cmd)..' ".-")') -- extract command ID and name
					if name then
						if line:match('SCR') then -- evaluate if script exists
						scr_exists = script_exists(line, name)
						end
					name = name:gsub('Custom:', 'Script:', 1) -- make script data retrieved from reaper-kb.ini conform to the name returned by CF_GetCommandText() which prefixes the name with 'Script:' following their appearance in the Action list instead of 'Custom:' as they're prefixed in reaper-kb.ini file
					break end
				end
			elseif cmd > 0 then -- sws extension is installed
			name = cmd > 0 and (named_cmd or cmd)..' "'..r.CF_GetCommandText(sect_t[section], cmd)..'"' -- add quotes to match data being retrieved form reaper-kb.ini to simplify creation of section title // if script, returns name with prefix 'Script:' as they're listed in the Action list even though in reaper-kb.ini script names are prefixed with 'Custom:' just like custom action names
				if name and name:match('Script') then
				local scr_name = name:gsub('Script:', 'Custom:') -- evaluate if script exists having made a replacement to conform to the reaper-kb.ini syntax
					for line in io.lines(path..sep..'reaper-kb.ini') do
						if line:match(esc(scr_name)) then
						scr_exists = script_exists(line, scr_name)
						break end
					end
				end
			end
		return name, scr_exists, mess
		end
	end

end


-- val and dB conversion forumula from SPK77
-- http://forum.cockos.com/showpost.php?p=1608719&postcount=6
-- OR https://forum.cockos.com/showthread.php?p=1608719
-- spotted in 'Thonex_Adjust selected items vol by greatest peak overage'
-- https://forums.cockos.com/showthread.php?t=210811
local Track_Vol_dB = 20*math.log(val, 10) -- same as 20*math.log10(val) but math.log10 isn't supported in REAPER
local Track_Vol_val = 10^(dB_val/20)


function Calc_New_Vol_Value(old_val, add_val) -- add_val is positive or negative
local old_val_dB = 20*math.log(old_val, 10)
local new_val_dB = old_val_dB + add_val
return 10^(new_val_dB/20)
end

-- Converting volume envelope values
-- https://forum.cockos.com/showthread.php?t=253381 jkooks
-- returns a dB value as the envelope/item volume value equivalent
function DbToVal(db)
	local LN10_OVER_TWENTY = 0.11512925464970228420089957273422
	return math.exp(db*LN10_OVER_TWENTY)
end
--returns an envelope/item volume value as the dB equivalent
function ValToDb(val)
	if val < 0.0000000298023223876953125 then
		return -150
	else
		return math.max(-150, math.log(val)* 8.6858896380650365530225783783321)
	end
end

-- https://github.com/ReaTeam/ReaScripts-Templates/blob/master/Values/X-Raym_Val%20to%20dB%20-%20dB%20to%20Val.lua
function dBFromVal(val)
return 20*math.log(val, 10)
end

function ValFromdB(dB_val)
return 10^(dB_val/20)
end

-- spotted in MPL's script // https://forum.cockos.com/showthread.php?t=217951
function WDL_DB2VAL(x) return math.exp((x)*0.11512925464970228420089957273422) end  -- https://github.com/majek/wdl/blob/master/WDL/db2val.h

function WDL_VAL2DB(x, reduce) -- https://github.com/majek/wdl/blob/master/WDL/db2val.h
	if not x or x < 0.0000000298023223876953125 then return -150.0 end
local v = math.log(x)*8.6858896380650365530225783783321
	if v < -150.0 then return -150.0
	else
		if reduce then return string.format('%.2f', v)
		else return v
		end
	end
end


function Un_Set_MW_Config_Flags(TCP, focused_fx, all_faders, TCP_faders) -- TCP and focused_fx are booleans, all_faders, TCP_faders are for restoration
-- Preferences -> Editing behavior -> Mouse
-- 'Ignore mousewheel on all faders'
-- 'Ignore mousewheel on track panel faders'
-- Thanks to Mespotine
-- https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
	if not all_faders and not TCP_faders then -- clear flags
	local MW_mode = r.SNM_GetIntConfigVar('mousewheelmode', 0)
	local all_faders, TCP_faders = MW_mode&2 == 2, MW_mode&4 == 4
-- https://stackoverflow.com/questions/63158929/how-can-i-clear-multiple-bits-at-once-in-c
	local MW_mode_new = all_faders and TCP_faders and TCP and MW_mode&~2&~4 -- or MW_mode&~(2|4)
	or all_faders and focused_fx and MW_mode&~2 or TCP_faders and TCP and MW_mode&~4
	local unset = MW_mode_new and r.SNM_SetIntConfigVar('mousewheelmode', MW_mode_new)
	return all_faders, TCP_faders
	else -- re-enable flags
	local MW_mode = r.SNM_GetIntConfigVar('mousewheelmode', 0)
	local MW_mode_new = all_faders and TCP_faders and TCP and MW_mode|2|4
	or all_faders and focused_fx and MW_mode|2 or TCP_faders and TCP and MW_mode|4
	local unset = MW_mode_new and r.SNM_SetIntConfigVar('mousewheelmode', MW_mode_new)
	end
end


function Get_Mousewheel_Mode()
-- Preferences -> Editing behavior -> Mouse
-- 'Ignore mousewheel on all faders'
-- 'Ignore mousewheel on track panel faders'
-- Thanks to Mespotine
-- https://mespotin.uber.space/Ultraschall/Reaper_Config_Variables.html
local f = io.open(r.get_ini_file(),'r')
local cont = f:read('*a')
f:close()
local val = cont:match('mousewheelmode=(%d+)\n')
local all_faders, TCP_faders = val&2 == 2, val&4 == 4
return all_faders, TCP_faders
end


-- Can be used in defer functions to prevent script activity in project tabs other than the one it was launched under
-- when the project is switched the script will terminate
proj_init, projfn_init = r.EnumProjects(-1)
function RUN()
local proj, projfn = r.EnumProjects(-1)
-- MAIN CODE
	if projfn == projfn_init then
	defer(RUN)
	end
end
-- RUN()



function Get_Mouse_Time_Pos() -- isn't suitable for use during playback as it stops it
local cur_pos_init = r.GetCursorPosition()
r.Main_OnCommand(40514, 0) -- View: Move edit cursor to mouse cursor (no snapping)
local cur_pos = r.GetCursorPosition()
r.SetEditCurPos(cur_pos_init, false, false) -- moveview, seekplay false // restore orig edit curs pos
return cur_pos
end



function Note_Format_Check(note) -- string
-- note is either whole 1,2,3 etc or fractional 1/2, 3/4, 7/12 etc
	for i = 1, 8 do
	local denom = 2^i -- straight note value in all major note divisions is a power of 2
	local straight = tostring(denom):match('(.+)%.') -- truncating decimal 0 with string function
	local triplet = tostring(denom+denom/2):match('(.+)%.') -- a triplet note denominator is a sum of straight note denominator + half of the straight note denominator: 1/3 = 1/2 + 1; 1/6 = 1/4 + 2; 1/12 = 1/8 + 4; 1/24 = 1/16 + 8; 1/48 = 1/32 + 16; 1/96 = 1/64 + 32
		if note:match('%-?%d+/'..straight) or note:match('%-?%d+/'..triplet)
		or tonumber(note) and tonumber(note) == math.floor(tonumber(note)) -- whole
		then
		return true end
	end
return note:match('^/$')
end


function Custom_Horiz_Scroll(x, y, SEC, VALUE, mousewheel_dir, mousewheel_reverse, auto_zoom) -- x and y are integers representing the number of pixels; mousewheel_reverse, auto_zoom are boolean // relies on the round() function, Horiz_Scroll_Distance() function for x value and r.get_action_context() for mousewheel_dir ('val' return value) as this function doesn't work inside a user function !!! SEC and VALUE are passed to Horiz_Scroll_Distance() function below (SEC is boolean to use seconds as scroll unit when VALUE is in seconds; otherwise musical division)

-- in CSurf_OnScroll() minimum possble x step is 16 px, not 1 px; minimum possble y step is 8 px; each next increment adds 16 or 8 px respectively, so the input value is multiplied by 16 or 8, e.g. value 16 means 256 px = 16 x 16

--local is_new_value,filename,sectionID,cmdID,mode,resolution,val = r.get_action_context() -- if mouse scrolling up val = 15 - righwards, if down then val = - 15 - leftwards // THE FUNCTION DOESN'T WORK WITHIN A USER FUNCTION
--Msg(val, 'VAL')

local val = mousewheel_dir -- 15 or -15

	if mousewheel_reverse then
	val = val > 0 and -1 or val < 0 and 1 -- down (forward) - leftwards or up (backwards) - rightwards
	else -- default
	val = val > 0 and 1 or val < 0 and -1 -- down (forward) - rightwards or up (backwards) - leftwards
	end

local x = x < 16 and 0 or round(x/16) -- either round up to 1 since pixels cannot be fractional or keep the value, or keep 0 if that's what was passed as the argument
local y = y < 8 and 0 or round(y/8) -- same

-- Auto-zoom in or prompt to zoom in

	if x == 0 and auto_zoom then -- INCREMENT setting is too fine for the current zoom amount (minimum possible for horizontal scroll is 16 px as per the limit of CSurf_OnScroll() function), so zoom in until it fits
	r.Main_OnCommand(40514,0) -- View: Move edit cursor to mouse cursor (no snapping) // centermode arg of adjustZoom() function is only known to support default setting of Preferences -> Editing Behavior -> Horizontal zoom center; what integer makes it hone in on the mouse cursor is not documented, hence the use of the edit cursor to point to the mouse cursor // overall seems to work with mouse cursor as the zoom center if either edit or mouse cursor are set in the Preferences, center view doesn't seem to work well with the routine

		repeat -- zoom in until the resolution is sufficient
		r.adjustZoom(5, 0, true, -1) -- amt, forceset, doupd, centermode // HORIZONTAL ZOOM ONLY // amt > 0 zooms in, < 0 zooms out, the greater the value the greater the zoom; forceset ~= 0 zooms out, if amt value is 1 then zooms out fully, if amt is greater then depends on the amt value but the relationship isn't clear, if bound to mousewheel, amt must be modified by val return value of get_action_context() function to change direction of the zoom, positive IN, negative OUT; doupd false no zoomming; centermode ?????
		-- forceset=0,doupd=true (do update),centermode=-1 for default
		until Scroll_Distance(SEC, VALUE) >= 16 -- minimum required for horizontal scroll in CSurf_OnScroll()

	elseif x == 0 then -- when auto_zoom is false
	Error_Tooltip('\n\n     low resolution, \n\n zoom in horizontally. \n\n')
	end

r.CSurf_OnScroll(x*val,y*val)

end


function Mouse_Wheel_Direction(val, mousewheel_reverse) -- mousewheel_reverse is boolean
local is_new_value,filename,sectionID,cmdID,mode,resolution,val = r.get_action_context() -- if mouse scrolling up val = 15 - righwards, if down then val = -15 - leftwards // val seems to not be able to co-exist with itself retrieved outside of the function, in such cases inside the function it's returned as 0 
	if mousewheel_reverse then
	return val > 0 and -1 or val < 0 and 1 -- wheel up (forward) - leftwards/downwards or wheel down (backwards) - rightwards/upwards
	else -- default
	return val > 0 and 1 or val < 0 and -1 -- wheel up (forward) - rightwards/upwards or wheel down (backwards) - leftwards/downwards
	end
end


function format_time_given_in_sec(num_sec) -- same as reaper.format_timestr()
	local function add_lead_zero(num)
	return #(num..'') == 1 and '0'..num or num
	end
local hrs = math.modf(num_sec/3600) -- 3600 sec in an hour
local sec = num_sec%3600 -- remainder in sec
local mnt = math.modf(sec/60) -- 60 sec in a min
local sec_ms = sec%60 -- remainder in sec and ms as a decimal part
local dec_places = 10^3
local sec_ms = math.floor(sec_ms * dec_places + 0.5) / dec_places -- round ms down to 3 dec places
local col = ':'
return add_lead_zero(hrs)..col..add_lead_zero(mnt)..col..sec_ms
end


function Time_in_Sec_to_List(time_in_sec, sep) -- sep is a string of a character to be used as a separator, if ommitted comma will be used
local sep = sep or ','
local time_in_sec = r.format_timestr(time_in_sec, '')
local min, sec, ms = time_in_sec:match('(%d+):(%d+)%.(%d+)') -- min, sec and ms are always included in format_timestr() return value
local hr = time_in_sec:sub(1,-#(':'..min..':'..sec..'.'..ms)-1) or ''
-- OR
-- local hr = edit_curs_pos:match('(%d+):'..min..':'..sec..'.'..ms) or ''
--local sep = ';' -- since semicolon is used in the GetUserInputs() as fields separator to be able to catch decimal entries, which are invalid, and truncate
return hr..sep..min..sep..sec..sep..ms -- to autofill the dialogue
end



function Is_Project_Start(time) -- for use with time selection / loop / edit cursor pos / item pos values to prevent them getting aligned with the project start and ruining their position relative to the grid when moving leftwards (the concept is used in scripts 'Move edit cursor left by one grid unit' and 'Scroll horizontally and;or move loop and;or time selection by user defined interval')
-- proj end cannot be reached by the cursor hence alignment with it isn't a problem
local start_time, end_time = r.GetSet_ArrangeView2(0, false, 0, 0) -- isSet false // https://forum.cockos.com/showthread.php?t=227524#2 the function has 6 arguments; screen_x_start and screen_x_end (3d and 4th args) are not return values, they are for specifying where start_time and stop_time should be on the screen when non-zero when isSet is true
--local TCP_width = tonumber(cont:match('leftpanewid=(.-)\n')) -- only changes in reaper.ini when dragged
local proj_offset_time = r.GetProjectTimeOffset(0, false) -- rndframe false
return start_time == proj_offset_time
end


function Ad_Hoc_Setting()
-- used in Scroll horizontally and;or move loop and;or time selection by user defined interval.lua
local x, y = r.GetMousePosition()
	if x <= 100 and y <= 100 then
	local retval, output = r.GetUserInputs('AD-HOC INCREMENT SETTING, default: '..incr_default, 1, 'extrawidth=25,Type in value ( musical or sec )', (INCREMENT ~= incr_default and INCREMENT or '')) -- only autofill if the value is different from the default set in the USER SETTINGS
	local output = output:gsub(' ','')
		if #output > 0 then
			if output:match('^[Xx]+') then -- remove ad-hoc INCREMENT setting to go back to the one defined in the script
			r.DeleteExtState(cmdID, 'INCREMENT', true) -- persist true
			else
			output = output:match('^[1-9/]+') and output or '1/4' -- if 0 or non-numeric input use default which is 1 beat
				if output ~= INCREMENT then -- only store if different from the default or previously stored ad-hoc INCREMENT setting
				r.SetExtState(cmdID, 'INCREMENT', output, false) -- store ad-hoc increment setting // persist false
				end
			end
		end
	end
end
Ad_Hoc_Setting()
return r.defer(function() do return end end) end


-- amagalma breakpoint for debugging
local function Break(msg) -- msg is a string
-- https://forum.cockos.com/showthread.php?t=262893
-- https://forum.cockos.com/showthread.php?p=2528121#post2528121
local line = "Breakpoint at line " .. debug.getinfo(2).currentline
local ln = "\n" .. string.rep("=", #line) .. "\n"
local trace = debug.traceback(ln .. line)
trace = trace:gsub("(stack traceback:\n).*\n", "%1")
reaper.ShowConsoleMsg(trace .. ln .. "\n" )
reaper.MB(tostring(msg) .. "\n\nContinue?", line, 0 )
end


function J_Reverb_randomizer()
-- https://forum.cockos.com/showthread.php?t=249923 + discussion
-- schwa: Any random number implementation is going to have some resolution so if you want a particular exact number to occur before the heat death of the universe, you need to reduce the resolution.
math.randomseed(reaper.time_precise()*os.time()/1e3) -- 1e3 = 10^3 = 1000
local rnd = math.random(11000)/10000
if rnd > 1 then return rnd = 1 else return rnd = math.random(10000)/10000 end
end



function Mespotine_Base64_Encoder(source_string, remove_newlines, remove_tabs)
--[[
https://forum.cockos.com/showthread.php?t=260054

Meo-Ada Mespotine - licensed under MIT-license

converts string into Base64-representation:

Parameters:
string source_string - the string that you want to convert into Base64
optional integer remove_newlines - 1, removes \n-newlines(including \r-carriage return) from the string
                                 - 2, replaces \n-newlines(including \r-carriage return) from the string with a single space
optional integer remove_tabs     - 1, removes \t-tabs from the string
                                 - 2, replaces \t-tabs from the string with a single space
--]]

  -- check parameters and prepare variables
  if type(source_string)~="string" then return nil end
  if remove_newlines~=nil and math.type(remove_newlines)~="integer" then return nil end
  if remove_tabs~=nil and math.type(remove_tabs)~="integer" then return nil end

  local tempstring={}
  local a=1
  local temp

  -- this is probably the future space for more base64-encoding-schemes
  local base64_string="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  -- if source_string is multiline, get rid of \r and replace \t and \n with a single whitespace
  if remove_newlines==1 then
    source_string=string.gsub(source_string, "\n", "")
    source_string=string.gsub(source_string, "\r", "")
  elseif remove_newlines==2 then
    source_string=string.gsub(source_string, "\n", " ")
    source_string=string.gsub(source_string, "\r", "")
  end

  if remove_tabs==1 then
    source_string=string.gsub(source_string, "\t", "")
  elseif remove_tabs==2 then
    source_string=string.gsub(source_string, "\t", " ")
  end

  -- tear apart the source-string into bits
  -- bitorder of bytes will be reversed for the later parts of the conversion!
  for i=1, source_string:len() do
    temp=string.byte(source_string:sub(i,i))
    temp=temp
    if temp&1==0 then tempstring[a+7]=0 else tempstring[a+7]=1 end
    if temp&2==0 then tempstring[a+6]=0 else tempstring[a+6]=1 end
    if temp&4==0 then tempstring[a+5]=0 else tempstring[a+5]=1 end
    if temp&8==0 then tempstring[a+4]=0 else tempstring[a+4]=1 end
    if temp&16==0 then tempstring[a+3]=0 else tempstring[a+3]=1 end
    if temp&32==0 then tempstring[a+2]=0 else tempstring[a+2]=1 end
    if temp&64==0 then tempstring[a+1]=0 else tempstring[a+1]=1 end
    if temp&128==0 then tempstring[a]=0 else tempstring[a]=1 end
    a=a+8
  end

  -- now do the encoding
  local encoded_string=""
  local temp2=0

  -- take six bits and make a single integer-value off of it
  -- after that, use this integer to know, which place in the base64_string must
  -- be read and included into the final string "encoded_string"
  for i=0, a-2, 6 do
    temp2=0
    if tempstring[i+1]==1 then temp2=temp2+32 end
    if tempstring[i+2]==1 then temp2=temp2+16 end
    if tempstring[i+3]==1 then temp2=temp2+8 end
    if tempstring[i+4]==1 then temp2=temp2+4 end
    if tempstring[i+5]==1 then temp2=temp2+2 end
    if tempstring[i+6]==1 then temp2=temp2+1 end
    encoded_string=encoded_string..base64_string:sub(temp2+1,temp2+1)
  end

  -- if the number of characters in the encoded_string isn't exactly divideable
  -- by 3, add = to fill up missing bytes
  if encoded_string:len()%4==2 then encoded_string=encoded_string.."=="
  elseif encoded_string:len()%2==1 then encoded_string=encoded_string.."="
  end

  return encoded_string
end


--====================== B A S E 6 4  E N / D E C O D E R ==============================

function Mespotine_Base64_Decoder(source_string)
-- Meo-Ada Mespotine - licensed under MIT-license
-- decodes a Base-64-string into its original representation
-- https://forum.cockos.com/showthread.php?t=260054

  if type(source_string)~="string" then return nil end

  -- this is probably the place for other types of base64-decoding-stuff
  local base64_string="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  -- remove =
  source_string=string.gsub(source_string,"=","")

  local L=source_string:match("[^"..base64_string.."]")
  if L~=nil then ultraschall.AddErrorMessage("Base64_Decoder", "source_string", "no valid Base64-string: invalid characters", -3) return nil end

  -- split the string into bits
  local bitarray={}
  local count=1
  local temp
  for i=1, source_string:len() do
    temp=base64_string:match(source_string:sub(i,i).."()")-2
    if temp&32~=0 then bitarray[count]=1 else bitarray[count]=0 end
    if temp&16~=0 then bitarray[count+1]=1 else bitarray[count+1]=0 end
    if temp&8~=0 then bitarray[count+2]=1 else bitarray[count+2]=0 end
    if temp&4~=0 then bitarray[count+3]=1 else bitarray[count+3]=0 end
    if temp&2~=0 then bitarray[count+4]=1 else bitarray[count+4]=0 end
    if temp&1~=0 then bitarray[count+5]=1 else bitarray[count+5]=0 end
    count=count+6
  end

  -- combine the bits into the original bytes and put them into decoded_string
  local decoded_string=""
  local temp2=0
  for i=0, count-1, 8 do
    temp2=0
    if bitarray[i+1]==1 then temp2=temp2+128 end
    if bitarray[i+2]==1 then temp2=temp2+64 end
    if bitarray[i+3]==1 then temp2=temp2+32 end
    if bitarray[i+4]==1 then temp2=temp2+16 end
    if bitarray[i+5]==1 then temp2=temp2+8 end
    if bitarray[i+6]==1 then temp2=temp2+4 end
    if bitarray[i+7]==1 then temp2=temp2+2 end
    if bitarray[i+8]==1 then temp2=temp2+1 end
    decoded_string=decoded_string..string.char(temp2)
  end
  if decoded_string:sub(-1,-1)=="\0" then decoded_string=decoded_string:sub(1,-2) end
  return decoded_string
end

--====================== B A S E 6 4  E N / D E C O D E R  E N D ==============================

--====================== U N I C O D E  --  U T F - 8   C O N V E R T E R =====================

-- functions from IvoDueblin's MC_CollabControl.lua
-- https://github.com/ReaTeam/ReaScripts/Various/ivodblin_MusiCollaboration/MC_CollabControl.lua
-- https://www.mucol.ch/
-- Conversion functions found here:
-- https://stackoverflow.com/questions/41855842/converting-utf-8-string-to-ascii-in-pure-lua

local char, byte, pairs, floor = string.char, string.byte, pairs, math.floor
local table_insert, table_concat = table.insert, table.concat
local unpack = table.unpack or unpack

local function unicode_to_utf8(code)
   -- converts numeric UTF code (U+code) to UTF-8 string
   local t, h = {}, 128
   while code >= h do
      t[#t+1] = 128 + code%64
      code = floor(code/64)
      h = h > 32 and 32 or h/2
   end
   t[#t+1] = 256 - 2*h + code
   return char(unpack(t)):reverse()
end

local function utf8_to_unicode(utf8str, pos)
   -- pos = starting byte position inside input string (default 1)
   pos = pos or 1
   local code, size = utf8str:byte(pos), 1
   if code >= 0xC0 and code < 0xFE then
      local mask = 64
      code = code - 128
      repeat
         local next_byte = utf8str:byte(pos + size) or 0
         if next_byte >= 0x80 and next_byte < 0xC0 then
            code, size = (code - mask - 2) * 64 + next_byte, size + 1
         else
            code, size = utf8str:byte(pos), 1
         end
         mask = mask * 32
      until code < mask
   end
   -- returns code, number of bytes in this utf8 char
   return code, size
end
local map_1252_to_unicode = {[0x80] = 0x20AC, [0x81] = 0x81, [0x82] = 0x201A, [0x83] = 0x0192, [0x84] = 0x201E, [0x85] = 0x2026, [0x86] = 0x2020, [0x87] = 0x2021, [0x88] = 0x02C6, [0x89] = 0x2030, [0x8A] = 0x0160, [0x8B] = 0x2039, [0x8C] = 0x0152, [0x8D] = 0x8D, [0x8E] = 0x017D, [0x8F] = 0x8F, [0x90] = 0x90, [0x91] = 0x2018, [0x92] = 0x2019, [0x93] = 0x201C, [0x94] = 0x201D, [0x95] = 0x2022, [0x96] = 0x2013, [0x97] = 0x2014, [0x98] = 0x02DC, [0x99] = 0x2122, [0x9A] = 0x0161, [0x9B] = 0x203A, [0x9C] = 0x0153, [0x9D] = 0x9D, [0x9E] = 0x017E, [0x9F] = 0x0178, [0xA0] = 0x00A0, [0xA1] = 0x00A1, [0xA2] = 0x00A2, [0xA3] = 0x00A3, [0xA4] = 0x00A4, [0xA5] = 0x00A5, [0xA6] = 0x00A6, [0xA7] = 0x00A7, [0xA8] = 0x00A8, [0xA9] = 0x00A9, [0xAA] = 0x00AA, [0xAB] = 0x00AB, [0xAC] = 0x00AC, [0xAD] = 0x00AD, [0xAE] = 0x00AE, [0xAF] = 0x00AF, [0xB0] = 0x00B0, [0xB1] = 0x00B1, [0xB2] = 0x00B2, [0xB3] = 0x00B3, [0xB4] = 0x00B4, [0xB5] = 0x00B5, [0xB6] = 0x00B6, [0xB7] = 0x00B7, [0xB8] = 0x00B8, [0xB9] = 0x00B9, [0xBA] = 0x00BA, [0xBB] = 0x00BB, [0xBC] = 0x00BC, [0xBD] = 0x00BD, [0xBE] = 0x00BE, [0xBF] = 0x00BF, [0xC0] = 0x00C0, [0xC1] = 0x00C1, [0xC2] = 0x00C2, [0xC3] = 0x00C3, [0xC4] = 0x00C4, [0xC5] = 0x00C5, [0xC6] = 0x00C6, [0xC7] = 0x00C7, [0xC8] = 0x00C8, [0xC9] = 0x00C9, [0xCA] = 0x00CA, [0xCB] = 0x00CB, [0xCC] = 0x00CC, [0xCD] = 0x00CD, [0xCE] = 0x00CE, [0xCF] = 0x00CF, [0xD0] = 0x00D0, [0xD1] = 0x00D1, [0xD2] = 0x00D2, [0xD3] = 0x00D3, [0xD4] = 0x00D4, [0xD5] = 0x00D5, [0xD6] = 0x00D6, [0xD7] = 0x00D7, [0xD8] = 0x00D8, [0xD9] = 0x00D9, [0xDA] = 0x00DA, [0xDB] = 0x00DB, [0xDC] = 0x00DC, [0xDD] = 0x00DD, [0xDE] = 0x00DE, [0xDF] = 0x00DF, [0xE0] = 0x00E0, [0xE1] = 0x00E1, [0xE2] = 0x00E2, [0xE3] = 0x00E3, [0xE4] = 0x00E4, [0xE5] = 0x00E5, [0xE6] = 0x00E6, [0xE7] = 0x00E7, [0xE8] = 0x00E8, [0xE9] = 0x00E9, [0xEA] = 0x00EA, [0xEB] = 0x00EB, [0xEC] = 0x00EC, [0xED] = 0x00ED, [0xEE] = 0x00EE, [0xEF] = 0x00EF, [0xF0] = 0x00F0, [0xF1] = 0x00F1, [0xF2] = 0x00F2, [0xF3] = 0x00F3, [0xF4] = 0x00F4, [0xF5] = 0x00F5, [0xF6] = 0x00F6, [0xF7] = 0x00F7, [0xF8] = 0x00F8, [0xF9] = 0x00F9, [0xFA] = 0x00FA, [0xFB] = 0x00FB, [0xFC] = 0x00FC, [0xFD] = 0x00FD, [0xFE] = 0x00FE, [0xFF] = 0x00FF,}

local map_unicode_to_1252 = {}
for code1252, code in pairs(map_1252_to_unicode) do
   map_unicode_to_1252[code] = code1252
end

function string.fromutf8(utf8str)
   local pos, result_1252 = 1, {}
   while pos <= #utf8str do
      local code, size = utf8_to_unicode(utf8str, pos)
      pos = pos + size
      code = code < 128 and code or map_unicode_to_1252[code] or ('?'):byte()
      table_insert(result_1252, char(code))
   end
   return table_concat(result_1252)
end

function string.toutf8(str1252)
   local result_utf8 = {}
   for pos = 1, #str1252 do
      local code = str1252:byte(pos)
      table_insert(result_utf8, unicode_to_utf8(map_1252_to_unicode[code] or code))
   end
   return table_concat(result_utf8)
end

------------------------------------------------------------------------

-- https://stackoverflow.com/questions/7983574/how-to-write-a-unicode-symbol-in-lua
-- encoder for Lua that takes a Unicode code point and produces a UTF-8 string for the corresponding character

do
  local bytemarkers = { {0x7FF,192}, {0xFFFF,224}, {0x1FFFFF,240} }
  function utf8(decimal)
    if decimal<128 then return string.char(decimal) end
    local charbytes = {}
    for bytes,vals in ipairs(bytemarkers) do
      if decimal<=vals[1] then
        for b=bytes+1,2,-1 do
          local mod = decimal%64
          decimal = (decimal-mod)/64
          charbytes[b] = string.char(128+mod)
        end
        charbytes[1] = string.char(vals[2]+decimal)
        break
      end
    end
    return table.concat(charbytes)
  end
end

c=utf8(0x24)    print(c.." is "..#c.." bytes.") --> $ is 1 bytes.
c=utf8(0xA2)    print(c.." is "..#c.." bytes.") --> ¢ is 2 bytes.
c=utf8(0x20AC)  print(c.." is "..#c.." bytes.") --> € is 3 bytes.
c=utf8(0x24B62) print(c.." is "..#c.." bytes.") --> 𤭢 is 4 bytes.

--------------------------------------------------

function FromUTF8(pos)
local mod = math.mod
local function charat(p)

local v = editor.CharAt[p]

	if v < 0 then v = v + 256 end; return v end

local v, c, n = 0, charat(pos), 1

	if c < 128 then v = c
	elseif c < 192 then
	error("Byte values between 0x80 to 0xBF cannot start a multibyte sequence")
	elseif c < 224 then v = mod(c, 32); n = 2
	elseif c < 240 then v = mod(c, 16); n = 3
	elseif c < 248 then v = mod(c,  8); n = 4
	elseif c < 252 then v = mod(c,  4); n = 5
	elseif c < 254 then v = mod(c,  2); n = 6
	else
	error("Byte values between 0xFE and OxFF cannot start a multibyte sequence")
	end

	for i = 2, n do
	pos = pos + 1; c = charat(pos)
		if c < 128 or c > 191 then
		  error("Following bytes must have values between 0x80 and 0xBF")
		end
	v = v * 64 + mod(c, 64)
	end

return v, pos, n

end

-- " Lua os. functions with Unicode. How?" https://forum.cockos.com/showthread.php?t=215773 -- more resources
-- http://lua-users.org/wiki/LuaUnicode


--=================== U N I C O D E  --  U T F - 8   C O N V E R T E R   E N D ==================


--===================================================================================


-- Get take source

r.GetMediaSourceFileName(r.GetMediaItemTake_Source(r.GetActiveTake(r.GetSelectedMediaItem(0,0))), '')

--===================================================================================

-- Functions to get number of tracks

reaper.CountTracks(0)

reaper.GetNumTracks()

reaper.CSurf_NumTracks(boolean mcpView)

--===================================================================================

-- Functions to get track name

retval, name = reaper.GetTrackName(tr)

retval, string = reaper.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', false)

retval, flags = reaper.GetTrackState(track) -- retval returns name

--===================================================================================

-- Functions to find Master track

-- don't depend on the Master track visibility
reaper.CSurf_TrackToID(tr, true) == 0 -- mcpView true
reaper.CSurf_TrackToID(tr, false) == 0 -- mcpView false

select(2,reaper.GetTrackName(tr)) == 'MASTER'

select(2,reaper.GetSetMediaTrackInfo_String(tr, 'P_NAME', '', false)) == 'MASTER'

reaper.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER') == -1

tr == r.GetMasterTrack(0)


--===================================================================================

-- Functions to get track index


reaper.CSurf_TrackToID(track, boolean mcpView)

reaper.GetMediaTrackInfo_Value(tr, 'IP_TRACKNUMBER')


--===================================================================================

-- Functions to get track pointer from index


reaper.CSurf_TrackFromID(idx, boolean mcpView)

reaper.GetTrack(0, idx)


-- store selected track pointer irrespective of its selection

tr = reaper.CSurf_TrackToID(r.GetSelectedTrack(0,0), false) -- false is mcpView
tr = reaper.GetTrack(0, tr-1)


--===================================================================================

-- Functions to get track GUID

reaper.GetSetMediaTrackInfo_String(tr, 'GUID', '', false) -- setNewValue false

reaper.GetTrackGUID(tr)


--===================================================================================

-- Functions to get track folder state


reaper.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')
-- 0=normal, 1=track is a folder parent, -1=track is the last in the innermost folder,
-- -2=track is the last in the innermost and next-innermost folders, etc

reaper.GetParentTrack(track)

retval, number = reaper.GetTrackState(track)
number&1 = 1 -- folder

reaper.GetTrackDepth(tr) -- 0 = folder or regular, 1 = child under 1st folder, 2 = child under the 2nd etc

--===================================================================================

-- Functions to get track color


reaper.GetTrackColor(track)

reaper.GetMediaTrackInfo_Value(tr, 'I_CUSTOMCOLOR')

--===================================================================================

-- Functions to set track color


reaper.SetMediaTrackInfo_Value(tr, 'I_CUSTOMCOLOR', r.ColorToNative(r,g,b)|0x100000)

reaper.SetTrackColor(tr, r.ColorToNative(r,g,b)|0x100000)


--===================================================================================

-- Functions to get track visibility

local ret, flags = r.GetTrackState(tr)
local TCP_vis = flags&512 ~= 512 -- 512 is hidden from TCP
local MCP_vis = flags&1024 ~= 1024 -- 1024 is hidden from MCP

local TCP_vis = r.IsTrackVisible(tr, false) -- mixer false
local MCP_vis = r.IsTrackVisible(tr, true) -- mixer true

-- not for the Master track
local TCP_vis = r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') -- returns 1 if true, 0 is false
local MCP_vis = r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER') -- returns 1 if true, 0 is false

-- to change visiblity

-- not for the Master track
r.SetMediaTrackInfo_Value(tr, 'B_SHOWINTCP', 1) -- show, 0 hide
r.SetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER', 1) -- show, 0 hide


--===================================================================================

-- Functions to query if track/item is selected


reaper.GetMediaTrackInfo_Value(track, "I_SELECTED") -- 0=unselected, 1=selected or false/true

reaper.IsTrackSelected(track)

string retval, flag = reaper.GetTrackState(track)
local is_sel = flag&2 == 2


reaper.GetMediaItemInfo_Value(item, "B_UISEL") -- 0=unselected, 1=selected or false/true

reaper.IsMediaItemSelected(item)

--===================================================================================

-- Functions to set track/item selected

reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", 1) -- true/false or 1/0
reaper.SetTrackSelected(track, 1)
reaper.CSurf_OnTrackSelection(trackid)
reaper.SetOnlyTrackSelected(track)


reaper.SetMediaItemInfo_Value(item, "B_UISEL", 1) -- 1/0 or true/false
reaper.SetMediaItemSelected(item, 1)
reaper.SelectAllMediaItems(0, true)

--===================================================================================

-- Functions to get item parent track


r.GetMediaItemTrack(item)

r.GetMediaItem_Track(item)

r.GetMediaItemInfo_Value(item, 'P_TRACK')

r.MediaItemDescendsFromTrack(item, track) -- Returns 1 if the track holds the item,
2 if the track is a folder containing the track that holds the item, etc


--===================================================================================

-- Functions to count item takes


reaper.GetMediaItemNumTakes(item)

reaper.CountTakes(item)

--==================================================================================

-- Functions to get item take

r.GetTake(item, take_idx)

r.GetMediaItemTake(item, take_idx)

--==================================================================================

-- Functions to get take name


reaper.GetTakeName(take)

retval, string = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', '', false) -- false = get


--===================================================================================

-- Functions to get active take of an item with 1 take only

r.GetTake(item, 0)

r.GetActiveTake(item)


--==================================================================================

-- Functions to get active take number


r.GetMediaItemInfo_Value(item, 'I_CURTAKE')

r.GetMediaItemTakeInfo_Value(take, 'IP_TAKENUMBER')


--===================================================================================

-- Functions to get take PCM source


reaper.GetMediaItemTake_Source(take)

reaper.GetMediaItemTakeInfo_Value(take, 'P_SOURCE') -- returns integer, not pointer

--===================================================================================

--Functions to open fx chain displaying specific fx UI or close FX chain altogether

-- TO OPEN

reaper.TrackFX_SetOpen(reaper.GetMasterTrack(), 0x1000000, true) -- 1st fx in Mon FX chain
reaper.TrackFX_SetOpen(reaper.GetMasterTrack(), 0, true) -- 1st fx in Master track FX chain
reaper.TrackFX_SetOpen(reaper.GetSelectedTrack(0,0), 0x1000000, true) -- 1st fx in track Input FX chain
reaper.TrackFX_SetOpen(reaper.GetSelectedTrack(0,0), 0, true) -- 1st fx in track main FX chain

--OR

reaper.TrackFX_Show(reaper.GetMasterTrack(), 0x1000000, 1)
reaper.TrackFX_Show(reaper.GetMasterTrack(), 0, 1)
reaper.TrackFX_Show(reaper.GetSelectedTrack(0,0), 0x1000000, 1)
reaper.TrackFX_Show(reaper.GetSelectedTrack(0,0), 0, 1)


-- TO CLOSE, fx index could be any

reaper.TrackFX_SetOpen(reaper.GetMasterTrack(), 0x1000000, false) - Mon FX chain
reaper.TrackFX_SetOpen(reaper.GetMasterTrack(), 0, true) -- Master track FX chain
reaper.TrackFX_SetOpen(reaper.GetSelectedTrack(0,0), 0x1000000, true) -- track Input FX chain
reaper.TrackFX_SetOpen(reaper.GetSelectedTrack(0,0), 0, true) -- track main FX chain

--OR

reaper.TrackFX_Show(reaper.GetMasterTrack(), 0x1000000, 0)
reaper.TrackFX_Show(reaper.GetMasterTrack(), 0, 0)
reaper.TrackFX_Show(reaper.GetSelectedTrack(0,0), 0x1000000, 0)
reaper.TrackFX_Show(reaper.GetSelectedTrack(0,0), 0, 0)

--===================================================================================

-- Functions to get project path/directory


reaper.GetProjectPath() returns primary record path and if not set returns project path,

in both cases without the last slash

reaper.EnumProjects(idx) returns full proj path a 2nd value

reaper.EnumProjects(-1) returns full path of the current proj as a 2nd value

proj_full_path = select(2,r.EnumProjects(-1))


===================================================================================


-- Detect undo
-- Set FX UI active in FX chain (via chunk)
