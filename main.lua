-- Canvas Express
-- A free as in freedom, minimalistic and fast-paced boxing game.
-- © 2021-2022 Ramiro Basile
--
-- This program is free software licensed under a GPLv3 license, see COPYING
-- for more details.

_VERSION = "2.5"

if arg[1] == "--version" then
	print(_VERSION)
	return 0
end

require("menu")
require("utils")

_cfg = require("config")
_window = {}
_window.bw = 160
_window.bh = 120
_window.scale = _cfg.window_scale or 4
love.window.setFullscreen(_cfg.fullscreen or false)

_font = nil

_remapping = { control = "none", player = 1 } -- none means not remapping

_music = love.audio.newSource("share/music.ogg", "stream")
_music:setVolume(_cfg.volume or 1.0)
_music:setLooping(true)

local FONT_SCALE = 4
local scene = nil

function love.load()
	resetMode()
--	scene = Menu() -- HACK resetMode does it

	if _cfg.music then
		_music:play()
	end
end

function love.update(dt)
	scene:update(dt)
	
	if scene.done then
		scene = scene.exitScene
	end
end

function love.draw()
	love.graphics.translate(_window.x, _window.y)

	love.graphics.push()
	love.graphics.scale(_window.scale, _window.scale)
	scene:draw()
	love.graphics.pop()

	scene:drawText()
end

function love.keypressed(key)
	-- If any control is being remapped, remap it to this key if not taken
	local other = (_remapping.player == 1 and 2) or 1
	local taken = getKey(_cfg.controls.keyboards[other], key)
	if _remapping.control ~= "none" and not taken then
		remap(key)
		return
	end
	
	-- Send key press to menu or game along with the player it belongs to
	local p1_control = getKey(_cfg.controls.keyboards[1], key)
	if p1_control then
		scene:controlpressed(p1_control, 1)
	end
	
	local p2_control = getKey(_cfg.controls.keyboards[2], key)
	if p2_control then
		scene:controlpressed(p2_control, 2)
	end
end

function love.gamepadpressed(joystick, button)
	-- Send button press to menu or game along with the player it belongs to
	local player = getKey(love.joystick.getJoysticks(), joystick)
	local control = getKey(_cfg.controls.gamepad, button, false)

	if player and control then
		scene:controlpressed(control, player)
	end
end

function isControlDown(control, player)
	local joystick = love.joystick.getJoysticks()[player]
	local key = _cfg.controls.keyboards[player][control]
	local button = _cfg.controls.gamepad[control]

	return (joystick and button and joystick:isGamepadDown(button)) or (key and love.keyboard.isDown(key))
end

-- FIXME Throws corrupted double-linked list at random...
function resetMode()
	-- Wait two frames to clear lingering inputs
	local frame = love.timer.getFPS() / 60 / 60
	love.timer.sleep(frame * 2)

	-- Set dimentions and keep them within min and desktop dimentions
	local fullscreen = love.window.getFullscreen()
	local screen_width, screen_height = love.window.getDesktopDimensions()
	_window.min_scale = _cfg.min_window_scale or 1
	_window.max_scale = math.floor(math.min(screen_width / _window.bw, screen_height / _window.bh))
	_window.scale = wrap(_window.scale, _window.min_scale, _window.max_scale)
	_window.w = _window.bw *_window.scale
	_window.h = _window.bh *_window.scale
	_window.x = 0
	_window.y = 0

	-- Center fullscreen window
	if fullscreen then
		_window.x = (screen_width - _window.w) / 2
		_window.y = (screen_height - _window.h) / 2
	end

	love.window.setMode(_window.w, _window.h, { fullscreen = fullscreen, fullscreentype = "desktop", centered = true })
	love.graphics.setDefaultFilter("nearest", "nearest", 1)

	_font = love.graphics.newFont("share/PressStart2P-Regular.ttf", FONT_SCALE * _window.scale)
	love.graphics.setFont(_font)

	-- TODO Only do this when actually on menu
	scene = Menu() -- HACK Slow but label need re-init because positions are based on previous scale
end

function toggleFullscreen()
	local fullscreen = love.window.getFullscreen()
	love.window.setFullscreen(not fullscreen)

	_window.scale = _window.max_scale

	resetMode()
end

function remap(control, player)
	_cfg.controls.keyboards[_remapping.player][_remapping.control] = control
	_remapping.control = "none"
end
