require("utils")

local config = {}

config.version = _VERSION
config.window_scale = 4.0
config.min_window_scale = 2.0
config.fullscreen = false
config.music = true
config.volume = 0.5
config.round_duration = 45
config.allow_exit = true
config.feint_limit = 0.15
config.results_time =  3
config.buffer_clear_time = 0.2
config.names = { "PLAYER 1", "PLAYER 2" }
config.short_names = { "P1", "P2" }
config.shake_magnitude = 2
config.low_hp = 4
config.retro_mode = false

config.controls = {}
config.controls.keyboards = {}
config.controls.keyboards[1] = {
	left = "a",
	right = "d",
	up = "w",
	down = "s",
	jab = "f",
	cross = "g",
	hook = "y",
	body = "t",
	start = "return",
}
config.controls.keyboards[2] = {
	left = "left",
	right = "right",
	up = "up",
	down = "down",
	jab = "n",
	cross = "m",
	hook = "l",
	body = "k",
	start = "backspace",
}
config.controls.gamepad = {
	left = "dpleft",
	right = "dpright",
	up = "dpup",
	down = "dpdown",
	jab = "a",
	cross = "b",
	hook = "y",
	body = "x",
	start = "start",
}

-- HACK Here be dragons
-- Read user configuration file in the save directory and merge default config
-- with user's
local ok, chunk, result
ok, chunk = pcall(love.filesystem.load, "canvas-express.conf")
if not ok then
	print(string.format("Error: Configuration unreadable or malformed (%s)", tostring(chunk)))
	else
		ok, result = pcall(chunk)

		if not ok then
			print(string.format("Error: Configuration unreadable or malformed (%s)", tostring(chunk)))
		else
			-- Merge if versions match, squash with default config otherwise (just to be sure...)
			if result and result.version == config.version then
				config = mergeTables(config, result)
			else
				local default = love.filesystem.read("canvas-express.default.conf")
				love.filesystem.write("canvas-express.conf", default)
				print("Error: User config could not be loaded. Copy of the default user configuration file created.")
			end
	end
end

return config
