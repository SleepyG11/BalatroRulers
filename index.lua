Rulers = {
	version = "1.1.0",

	utils = {},

	config = {
		default = {
			visible = false,

			big_step = 1,
			medium_step = 0.5,
			small_step = 0.1,

			size = 3,
			line_size = 2,
			rotate = 0,
			colour = { 0, 1, 1, 1 },
			display = "vh",

			grid = false,
			numbers = true,
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
			str = str .. indent .. "\t" .. "[" .. Rulers.utils.serialize_string(k) .. "] = "

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
rulers [...args] - Configure current Rulers config
Flags (all optional):
 
| Reset config to default
-reset
 
| Toggle rulers visibility
-v [on | off]
-visible [on | off]
 
| Set length of rulers (in game units)
-l [number]
-length [number]
 
| Set lines size (in pixels)
-s [number]
-size [number]
 
| Set size for big, medium and small steps respectively (in game units)
-st [number,number,number]
-steps [number,number,number]
 
| Set rotation angle (in degrees clockwise)
-r [angle]
-rotate [angle]
 
| Set colour (input passed to HEX function)
-c [HEX]
-colour [HEX]
 
| Set directions to display: v - vertical, h - horizontal, vh or hv - both
-dir [v | h | vh]
-direction [v | h | vh]

| Toggle grid
-grid [on | off]

| Toggle numbers
-num [on | off]
-numbers [on | off]
]]

		local setters = {
			["-v"] = function(arg)
				Rulers.cc.visible = string.lower(arg) == "on"
			end,
			["-l"] = function(arg)
				Rulers.cc.size = math.max(0, tonumber(arg) or 0) or 0
			end,
			["-s"] = function(arg)
				Rulers.cc.line_size = math.max(0, tonumber(arg) or 0) or 0
			end,
			["-r"] = function(arg)
				Rulers.cc.rotate = (tonumber(arg) or 0) % 360
			end,
			["-c"] = function(arg)
				pcall(function()
					Rulers.cc.colour = HEX(arg)
				end)
			end,
			["-dir"] = function(arg)
				Rulers.cc.display = arg or ""
			end,
			["-grid"] = function(arg)
				Rulers.cc.grid = string.lower(arg) == "on"
			end,
			["-numbers"] = function(arg)
				Rulers.cc.numbers = string.lower(arg) == "on"
			end,
			["-st"] = function(arg)
				local result = {}
				for token in string.gmatch(arg, "([^,]+)") do
					table.insert(result, token)
				end
				if result[1] then
					Rulers.cc.big_step = math.max(0, tonumber(result[1]) or 0)
				end
				if result[2] then
					Rulers.cc.medium_step = math.max(0, tonumber(result[2]) or 0)
				end
				if result[3] then
					Rulers.cc.small_step = math.max(0, tonumber(result[3]) or 0)
				end
			end,
		}
		setters["-visible"] = setters["-v"]
		setters["-length"] = setters["-l"]
		setters["-size"] = setters["-s"]
		setters["-rotate"] = setters["-r"]
		setters["-visible"] = setters["-v"]
		setters["-colour"] = setters["-c"]
		setters["-color"] = setters["-c"]
		setters["-direction"] = setters["-dir"]
		setters["-steps"] = setters["-st"]
		setters["-num"] = setters["-numbers"]
		setters["-nums"] = setters["-numbers"]

		debugplus.addCommand({
			name = "rulers",
			shortDesc = "Configure current Rulers config",
			desc = info_message,
			exec = function(args, rawArgs, dp)
				if #args == 0 then
					return info_message
				end
				if rawArgs == "help" or rawArgs == "-h" or rawArgs == "--help" then
					return info_message
				end
				if rawArgs == "-reset" then
					Rulers.config.current = Rulers.utils.table_merge({}, Rulers.config.default)
					Rulers.cc = Rulers.config.current
					Rulers.config.save()
					return "Rulers config reset to default"
				end
				local current_setter = function(arg) end

				for _, arg in ipairs(args) do
					if setters[arg] then
						current_setter = setters[arg]
					else
						current_setter(arg)
					end
				end
				Rulers.config.save()
				return "Rulers updated"
			end,
		})
	end
end

function Rulers.draw()
	local config = Rulers.cc
	if not config or not G.CURSOR or not config.visible then
		return
	end

	local variants = {
		{
			config.big_step,
			0.3,
		},
		{
			config.medium_step,
			0.225,
		},
		{
			config.small_step,
			0.125,
		},
	}

	local real_scale = G.TILESIZE * G.TILESCALE

	love.graphics.push()
	love.graphics.scale(real_scale)
	love.graphics.setLineWidth(config.line_size / real_scale)
	love.graphics.translate(G.CURSOR.T.x, G.CURSOR.T.y)
	love.graphics.rotate(math.rad(config.rotate))
	love.graphics.setColor(unpack(config.colour))

	local is_v, is_h = config.display:find("v"), config.display:find("h")
	for index, variant in ipairs(variants) do
		local step, width = unpack(variant)
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
						local text = string.format("%.1f", total)
						local font = love.graphics.getFont()
						local textWidth = font:getWidth(text)
						local textHeight = font:getHeight()

						-- Math
						if is_v then
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
						if is_h then
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

--

local g_draw_ref = Game.draw
function Game:draw(...)
	local r = g_draw_ref(self, ...)
	Rulers.draw()
	return r
end

Rulers.init()
