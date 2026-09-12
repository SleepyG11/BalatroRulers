Rulers = {
	version = "1.1.0",

	utils = {},
	pin_mode = false,

	config = {
		default = {
			visible = false,

			big_step = 1,
			medium_step = 0.5,
			small_step = 0.1,
			big_step_pixels = false,
			medium_step_pixels = false,
			small_step_pixels = false,

			size = 3,
			size_pixels = false,
			line_size = 2,
			rotate = 0,
			colour = { 0, 1, 1, 1 },
			display = "vh",

			grid = false,
			numbers = true,

			point_x = false,
			point_y = false,
		},
		current = {},
	},
}

--

--- @generic T
--- @generic S
--- @param target T
--- @param source S
--- @param ... any
--- @return T | S
function Rulers.utils.table_merge(target, source, ...)
	assert(type(target) == "table", "Target is not a table")
	local tables_to_merge = { source, ... }
	if #tables_to_merge == 0 then
		return target
	end

	for k, t in ipairs(tables_to_merge) do
		assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
	end

	for i = 1, #tables_to_merge do
		local from = tables_to_merge[i]
		for k, v in pairs(from) do
			if type(v) == "table" then
				target[k] = Rulers.utils.table_merge(target[k] or {}, v)
			else
				target[k] = v
			end
		end
	end

	return target
end
function Rulers.utils.serialize(t, indent)
	indent = indent or ""
	local str = "{\n"
	for k, v in ipairs(t) do
		str = str .. indent .. "\t"
		if type(v) == "number" then
			str = str .. v
		elseif type(v) == "boolean" then
			str = str .. (v and "true" or "false")
		elseif type(v) == "string" then
			str = str .. string.format("%q", v)
		elseif type(v) == "table" then
			str = str .. Rulers.utils.serialize(v, indent .. "\t")
		else
			-- not serializable
			str = str .. "nil"
		end
		str = str .. ",\n"
	end
	for k, v in pairs(t) do
		if type(k) == "string" then
			str = str .. indent .. "\t" .. "[" .. string.format("%q", k) .. "] = "

			if type(v) == "number" then
				str = str .. v
			elseif type(v) == "boolean" then
				str = str .. (v and "true" or "false")
			elseif type(v) == "string" then
				str = str .. string.format("%q", v)
			elseif type(v) == "table" then
				str = str .. Rulers.utils.serialize(v, indent .. "\t")
			else
				-- not serializable
				str = str .. "nil"
			end
			str = str .. ",\n"
		end
	end
	str = str .. indent .. "}"
	return str
end
function Rulers.utils.normalize_dashes(s)
	if s:sub(1, 1) == "-" then
		return "-" .. s:gsub("^%-+", "")
	end
	return s
end
Rulers.utils.true_string = {
	on = true,
	t = true,
	["true"] = true,
	y = true,
	yes = true,
}
function Rulers.utils.is_true(s)
	s = string.lower(s)
	if Rulers.utils.true_string[s] then
		return true
	end
	local n = tonumber(s)
	if n then
		return n ~= 0
	end
	return false
end
function Rulers.utils.as_angle(s)
	local result
	local suffix = s:sub(#s - 2, #s)
	if suffix == "rad" then
		s = s:sub(1, #s - 3)
		result = math.deg(tonumber(s) or 0)
	elseif suffix == "deg" then
		s = s:sub(1, #s - 3)
		result = tonumber(s) or 0
	else
		result = tonumber(s) or 0
	end
	return result % 360
end
function Rulers.utils.as_distance_unit(s)
	if s:sub(#s - 1, #s) == "px" then
		s = s:sub(1, #s - 2)
		s = tonumber(s) or 0
		return s / G.TILESIZE / G.TILESCALE, s
	end
	return tonumber(s) or 0, false
end

--

function Rulers.config.load()
	Rulers.config.current = Rulers.utils.table_merge({}, Rulers.config.default)
	local lovely_mod_config = get_compressed("config/Rulers.jkr")
	if lovely_mod_config then
		Rulers.config.current = Rulers.utils.table_merge(Rulers.config.current, STR_UNPACK(lovely_mod_config))
	end
	Rulers.cc = Rulers.config.current
end
function Rulers.config.save()
	if SMODS and SMODS.save_mod_config and Rulers.current_mod then
		Rulers.current_mod.config = Rulers.config.current
		SMODS.save_mod_config(Rulers.current_mod)
	else
		love.filesystem.createDirectory("config")
		local serialized = "return " .. Rulers.utils.serialize(Rulers.config.current)
		love.filesystem.write("config/Rulers.jkr", serialized)
	end
end

--

function Rulers.init()
	local success, dpAPI = pcall(require, "debugplus-api")

	if success and dpAPI.isVersionCompatible(1) then
		Rulers.config.load()
		local debugplus = dpAPI.registerID("Rulers")

		local info_message = [[ 
rulers [OPTIONS]
    Update rulers appearance.
    Each option updates only the corresponding property
    Unspecified properties remain unchanged
 
Options:
    -h, -help                           
        Show this message
    -show                               
        Show rulers
    -hide                               
        Hide rulers
    -v, -visible BOOLEAN                
        Toggle rulers visibility
    -l, -length VALUE                   
        Set rulers length: n - game units, npx - pixels
    -s, -size VALUE                     
        Set lines size: n - in pixels
    -st, -steps BIG,MEDIUM,SMALL        
        Set line steps: n - game units, npx - pixels
    -r, -rotate ANGLE                   
        Set rotation angle (clockwise): n or ndeg - degrees, nrad - radians
    -c, -colour HEX                     
        Set colour (input passed to HEX function)
    -d, -dir, -directions v | h | vh    
        Set directions to display: v - vertical, h - horizontal, vh - both
    -g, -grid BOOLEAN                   
        Toggle grid
    -n, -numbers BOOLEAN                
        Toggle numbers display
    -reset, -default                    
        Reset all options to their default values
    -pin
        Enable pin mode: [Left Mouse] to place persistent rulers on screen
        [Right Mouse] or repeat command to cancel
    -unpin
        Unpin pinned rulers
 
Use "default" keyword to reset a property to its default value
    -l default
    -r default
    -c default
    -st default or -st default,default,default
 
Examples:
    rulers -v on                        
        Display rulers
    rulers -n off -g on                 
        Disable numbers display, and enable grid display
    rulers -l 10 -r 30 -c FFFF00        
        Set length in game units, angle in degrees, and colour
    rulers -l 200px -r 1.5rad -dir v    
        Set length in pixels, angle in radians, and show only vertical ruler
    rulers -l default                   
        Reset rulers length to default
    rulers -st 100px,0.5,0.125          
        Set steps: big in pixels, medium and small in game units
    rulers -st default,,0.125           
        Reset big step to default, keep medium, set small
]]

		local pre_setters = {
			["-help"] = function()
				return info_message
			end,
			["-reset"] = function()
				Rulers.config.current = Rulers.utils.table_merge({}, Rulers.config.default)
				Rulers.cc = Rulers.config.current
				Rulers.config.save()
				return "Rulers reset to default"
			end,
			["-pin"] = function()
				local r
				Rulers.pin_mode = not Rulers.pin_mode
				if Rulers.pin_mode then
					r = "Rulers pin mode: [Left Mouse] to pin, [Right Mouse] or repeat command to cancel"
				else
					r = "Rulers pin cancelled"
				end
				Rulers.cc.point_x = false
				Rulers.cc.point_y = false
				Rulers.config.save()
				return r
			end,
			["-unpin"] = function()
				Rulers.cc.point_x = false
				Rulers.cc.point_y = false
				Rulers.pin_mode = false
				Rulers.config.save()
				return "Rulers unpinned"
			end,
		}

		pre_setters["-h"] = pre_setters["-help"]
		pre_setters["-default"] = pre_setters["-reset"]

		local setters = {
			["-visible"] = function(arg)
				if arg == "default" then
					arg = tostring(Rulers.config.default.visible)
				end
				Rulers.cc.visible = Rulers.utils.is_true(arg)
			end,
			["-length"] = function(arg)
				if arg == "default" then
					arg = tostring(Rulers.config.default.size)
				end
				local size, pixels = Rulers.utils.as_distance_unit(arg)
				Rulers.cc.size = math.max(0, size)
				Rulers.cc.size_pixels = pixels
			end,
			["-size"] = function(arg)
				if arg == "default" then
					arg = tostring(Rulers.config.default.line_size)
				end
				Rulers.cc.line_size = math.max(0, tonumber(arg) or 0) or 0
			end,
			["-rotate"] = function(arg)
				if arg == "default" then
					arg = tostring(Rulers.config.default.rotate)
				end
				Rulers.cc.rotate = Rulers.utils.as_angle(arg) or 0
			end,
			["-colour"] = function(arg)
				pcall(function()
					if arg == "default" then
						Rulers.cc.colour = Rulers.config.default.colour
					else
						if arg:sub(1, 1) == "#" then
							arg = arg:sub(2)
						end
						Rulers.cc.colour = HEX(arg)
					end
				end)
			end,
			["-directions"] = function(arg)
				if arg == "default" then
					arg = tostring(Rulers.config.default.display)
				end
				Rulers.cc.display = arg or ""
			end,
			["-grid"] = function(arg)
				if arg == "default" then
					arg = tostring(Rulers.config.default.grid)
				end
				Rulers.cc.grid = Rulers.utils.is_true(arg)
			end,
			["-numbers"] = function(arg)
				if arg == "default" then
					arg = tostring(Rulers.config.default.numbers)
				end
				Rulers.cc.numbers = Rulers.utils.is_true(arg)
			end,
			["-steps"] = function(arg)
				if arg == "default" then
					arg = "default,default,default"
				end
				local result = {}
				for token in string.gmatch(arg, "([^,]+)") do
					table.insert(result, token)
				end
				if result[1] then
					if result[1] == "default" then
						result[1] = tostring(Rulers.config.default.big_step)
					end
					local size, pixels = Rulers.utils.as_distance_unit(result[1])
					Rulers.cc.big_step = math.max(0, size)
					Rulers.cc.big_step_pixels = pixels
				end
				if result[2] then
					if result[2] == "default" then
						result[2] = tostring(Rulers.config.default.medium_step)
					end
					local size, pixels = Rulers.utils.as_distance_unit(result[2])
					Rulers.cc.medium_step = math.max(0, size)
					Rulers.cc.medium_step_pixels = pixels
				end
				if result[3] then
					if result[3] == "default" then
						result[3] = tostring(Rulers.config.default.small_step)
					end
					local size, pixels = Rulers.utils.as_distance_unit(result[3])
					Rulers.cc.small_step = math.max(0, size)
					Rulers.cc.small_step_pixels = pixels
				end
			end,
		}
		local instant_setters = {
			["-show"] = function()
				Rulers.cc.visible = true
			end,
			["-hide"] = function()
				Rulers.cc.visible = false
			end,
		}

		local aliases_list = {
			["-visible"] = { "-v" },
			["-length"] = { "-l" },
			["-size"] = { "-s" },
			["-rotate"] = { "-r" },
			["-colour"] = { "-c" },
			["-directions"] = { "-d", "-dir" },
			["-grid"] = { "-g" },
			["-numbers"] = { "-n" },
			["-steps"] = { "-st" },
		}

		for command, aliases in pairs(aliases_list) do
			for _, alias in ipairs(aliases) do
				setters[alias] = setters[command]
			end
		end

		debugplus.addCommand({
			name = "rulers",
			shortDesc = "Configure current Rulers",
			desc = info_message,
			exec = function(args, rawArgs, dp)
				if #args == 0 then
					return info_message
				end

				rawArgs = Rulers.utils.normalize_dashes("-" .. rawArgs)
				if pre_setters[rawArgs] then
					return pre_setters[rawArgs]()
				end

				local is_success
				local current_setter
				for _, arg in ipairs(args) do
					local nArg = Rulers.utils.normalize_dashes(arg)
					if current_setter then
						current_setter(arg)
						current_setter = nil
						is_success = true
					elseif instant_setters[nArg] then
						instant_setters[nArg]()
						current_setter = nil
						is_success = true
					elseif setters[nArg] then
						current_setter = setters[nArg]
					end
				end

				Rulers.config.save()
				return is_success and "Rulers updated" or "Rulers not updated: no valid args passed"
			end,
		})
	end
end

function Rulers.draw_rulers(x, y, config)
	config = config or Rulers.cc
	local real_scale = G.TILESIZE * G.TILESCALE

	if config.big_step_pixels then
		config.big_step = config.big_step_pixels / real_scale
	end
	if config.medium_step_pixels then
		config.medium_step = config.medium_step_pixels / real_scale
	end
	if config.small_step_pixels then
		config.small_step = config.small_step_pixels / real_scale
	end
	if config.size_pixels then
		config.size = config.size_pixels / real_scale
	end

	local variants = {
		{
			config.big_step,
			config.big_step_pixels,
			0.3,
		},
		{
			config.medium_step,
			config.medium_step_pixels,
			0.225,
		},
		{
			config.small_step,
			config.small_step_pixels,
			0.125,
		},
	}

	love.graphics.push()
	love.graphics.scale(real_scale)
	love.graphics.setLineWidth(config.line_size / real_scale)
	love.graphics.translate(x, y)
	love.graphics.rotate(math.rad(config.rotate))
	love.graphics.setColor(unpack(config.colour))

	local is_v, is_h = config.display:find("v"), config.display:find("h")
	for index, variant in ipairs(variants) do
		local step, pixels, width = unpack(variant)
		if step > 0 then
			local total = 0
			while total <= config.size do
				if is_v then
					love.graphics.line(0, total, -width, total)
				end
				if is_h then
					love.graphics.line(total, 0, total, -width)
				end

				if index == 1 then
					if Rulers.cc.grid then
						love.graphics.line(0, total, config.size, total)
						love.graphics.line(total, 0, total, config.size)
					end
					if Rulers.cc.numbers then
						love.graphics.scale(1 / real_scale)
						local text
						if pixels then
							text = string.format("%dpx", total * real_scale)
						else
							text = string.format("%.1f", total)
						end
						local font = love.graphics.getFont()
						local textWidth = font:getWidth(text)
						local textHeight = font:getHeight()

						-- Math
						if is_h then
							local r_scale = 1
							if config.rotate > 180 then
								r_scale = -1
							end

							love.graphics.print(
								text,
								total * real_scale - (textHeight * r_scale) / 2,
								-width * real_scale - 0.025 * real_scale - (r_scale == -1 and textWidth or 0),
								-math.pi / 2,
								r_scale,
								r_scale
							)
						end
						if is_v then
							local r_scale = 1
							if config.rotate > 90 and config.rotate <= 270 then
								r_scale = -1
							end

							love.graphics.print(
								text,
								-(r_scale == -1 and 0 or textWidth) - width * real_scale,
								total * real_scale - (r_scale * textHeight / 2),
								0,
								r_scale,
								r_scale
							)
						end
						love.graphics.scale(real_scale)
					end
				end
				total = total + step
			end
		end
	end

	love.graphics.pop()
end

function Rulers.draw()
	local config = Rulers.cc
	if not config or not G.CURSOR then
		return
	end

	if config.point_x and config.point_y then
		Rulers.draw_rulers(config.point_x, config.point_y, config)
	end
	if config.visible or Rulers.pin_mode then
		Rulers.draw_rulers(G.CURSOR.T.x, G.CURSOR.T.y, config)
	end
end

--

do
	local g_draw_ref = Game.draw
	function Game:draw(...)
		local r = g_draw_ref(self, ...)
		Rulers.draw()
		return r
	end

	local r_old_mouseinput = love.mousepressed
	function love.mousepressed(x, y, button, touch, ...)
		if Rulers.pin_mode then
			if button == 1 then
				Rulers.cc.point_x = x / (G.TILESCALE * G.TILESIZE)
				Rulers.cc.point_y = y / (G.TILESCALE * G.TILESIZE)
				Rulers.pin_mode = false
				print(
					string.format(
						"< Rulers pinned at (x=%.2f, y=%.2f) = (x=%dpx, y=%dpx)",
						Rulers.cc.point_x,
						Rulers.cc.point_y,
						x,
						y
					)
				)
				return
			elseif button == 2 then
				Rulers.pin_mode = false
				print("< Rulers pin cancelled")
				return
			end
		end
		return r_old_mouseinput(x, y, button, touch, ...)
	end
end

Rulers.init()
