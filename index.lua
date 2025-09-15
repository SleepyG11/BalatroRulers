Rulers = {
	version = "1.0.0",

	visible = false,

	big_step = 1,
	medium_step = 0.5,
	small_step = 0.1,

	size = 3,
	line_size = 2,
	rotate = 0,
	colour = { 0, 1, 1, 1 },
	display = "vh",
}

--

function Rulers:init()
	local success, dpAPI = pcall(require, "debugplus-api")

	if success and dpAPI.isVersionCompatible(1) then
		local debugplus = dpAPI.registerID("Rulers")

		local info_message = [[
rulers [...args] - Configure current Rulers config
Flags (all optional):
 
| Toggle rulers visibility
-v [on | off]
-visible [on | off]
 
| Set length of rulers (in game units)
-l [number]
-l [number]

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
 
| Set rulers to display: v - vertical, h - horizontal, vh or hv - both
-dir [v | h | vh]
-direction [v | h | vh]
]]

		local setters = {
			["-v"] = function(arg)
				Rulers.visible = string.lower(arg) == "on"
			end,
			["-l"] = function(arg)
				Rulers.size = math.max(0, tonumber(arg) or 0) or 0
			end,
			["-s"] = function(arg)
				Rulers.line_size = math.max(0, tonumber(arg) or 0) or 0
			end,
			["-r"] = function(arg)
				Rulers.rotate = tonumber(arg) or 0
			end,
			["-c"] = function(arg)
				pcall(function()
					Rulers.colour = HEX(arg)
				end)
			end,
			["-dir"] = function(arg)
				Rulers.display = arg or ""
			end,
			["-st"] = function(arg)
				local result = {}
				for token in string.gmatch(arg, "([^,]+)") do
					table.insert(result, token)
				end
				if result[1] then
					Rulers.big_step = math.max(0, tonumber(result[1]) or 0)
				end
				if result[2] then
					Rulers.medium_step = math.max(0, tonumber(result[2]) or 0)
				end
				if result[3] then
					Rulers.small_step = math.max(0, tonumber(result[3]) or 0)
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
				local current_setter = function(arg) end

				for _, arg in ipairs(args) do
					if setters[arg] then
						current_setter = setters[arg]
					else
						current_setter(arg)
					end
				end
				return "Rulers updated"
			end,
		})
	end
end

function Rulers:draw()
	if not G.CURSOR or not self.visible then
		return
	end

	local variants = {
		{
			self.big_step,
			0.3,
		},
		{
			self.medium_step,
			0.225,
		},
		{
			self.small_step,
			0.125,
		},
	}

	if Rulers.display:find("v") then
		love.graphics.push()
		love.graphics.translate(G.CURSOR.T.x * G.TILESIZE * G.TILESCALE, G.CURSOR.T.y * G.TILESIZE * G.TILESCALE)
		love.graphics.rotate(math.rad(Rulers.rotate))
		love.graphics.setColor(unpack(Rulers.colour))
		love.graphics.setLineWidth(Rulers.line_size)

		for _, variant in ipairs(variants) do
			local step, width = unpack(variant)
			local total = 0
			while total <= self.size do
				love.graphics.line(
					0,
					total * G.TILESIZE * G.TILESCALE,
					-width * G.TILESIZE * G.TILESCALE,
					total * G.TILESIZE * G.TILESCALE
				)
				total = total + step
			end
		end
		love.graphics.pop()
	end
	if Rulers.display:find("h") then
		love.graphics.push()
		love.graphics.translate(G.CURSOR.T.x * G.TILESIZE * G.TILESCALE, G.CURSOR.T.y * G.TILESIZE * G.TILESCALE)
		love.graphics.rotate(math.rad(Rulers.rotate))
		love.graphics.setColor(unpack(Rulers.colour))
		love.graphics.setLineWidth(Rulers.line_size)

		for _, variant in ipairs(variants) do
			local step, width = unpack(variant)
			local total = 0
			while total <= self.size do
				love.graphics.line(
					total * G.TILESIZE * G.TILESCALE,
					0,
					total * G.TILESIZE * G.TILESCALE,
					-width * G.TILESIZE * G.TILESCALE
				)
				total = total + step
			end
		end
		love.graphics.pop()
	end
end

--

local g_draw_ref = Game.draw
function Game:draw(...)
	g_draw_ref(self, ...)
	Rulers:draw()
end

Rulers:init()
