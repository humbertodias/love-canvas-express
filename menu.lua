require("game")
require("label")
require("submenus")

local MARGIN = 2.5 -- Vertical separation between options
local TRAINING_COLOR = "red"


function newButton(text, ok, x, y)
	local button = {}

	button.label = Label(text, 0, 0, "center")
	button.ok = ok
	button.x = x
	button.y = y
	button.draw = function(b) b.label:draw() end

	return button
end

function Menu()
	local menu = {}
	
	menu.done = false
	menu.exitScene = nil
	menu.move_sound = love.audio.newSource("share/move.ogg", "static")
	menu.ok_sound = love.audio.newSource("share/bell_1.ogg", "static")
	menu.done_sound = love.audio.newSource("share/bell_2.ogg", "static")
	menu.submenus = newSubmenus()
	menu.submenu = "main" -- main, configure, remap or colors
	menu.colors = {}
	
	menu.update = function(m)
		-- Menu done as soon as both players have selected a color
		-- Also wait for color selected sound to finish playing
		if m.colors[1] and m.colors[2] and not m.move_sound:isPlaying() then
			m.done = true
			m.exitScene = Game("fight", m.colors)
			love.audio.play(m.done_sound)
		end
	end
	
	menu.draw = function(m)
		local sm = m.submenus[m.submenu]
		if sm.background then
			love.graphics.draw(sm.background)
		end
	end
		
	menu.drawText = function(m)
		local sm = m.submenus[m.submenu]
		
		-- Draw option buttons centered on both axes and separated by a constant margin
		for i, option in ipairs(sm.options) do
			if i == sm.selected then
				love.graphics.setColor(1, 1, 0)
			end
			
			-- Set position
			local margin = _font:getHeight() * MARGIN
			option.label.x = option.x or _window.w / 2
			option.label.y = option.y or _window.h / 2 - (#sm.options / 2 - i + 1) * margin
			
			-- Change text of option of control being remapped if on remap submenu
			if m.submenu == "remap" and string.lower(option.label.text) == _remapping.control then
				local original = option.label.text
				option.label.text = "PUSH ANY KEY"
				option:draw()
				option.label.text = original
				
			-- Otherwise draw normally
			else
				option:draw()
			end
			
			love.graphics.setColor(1, 1, 1)
		end

		for _, label in pairs(sm.labels) do
			label:draw()
		end
	end
	
	menu.controlpressed = function(m, control, player)
		local sm = m.submenus[m.submenu]
		
		-- Move up and down options
		if control == "up" and m.submenu ~= "colors" then
			sm.selected = (sm.selected - 2) % #sm.options + 1
			love.audio.stop(m.move_sound)
			love.audio.play(m.move_sound)
		end
		if control == "down" and m.submenu ~= "colors" then
			sm.selected = sm.selected % #sm.options + 1
			love.audio.stop(m.move_sound)
			love.audio.play(m.move_sound)
		end
			
		-- OK an option, that is, call its associated function (if any)
		local ok = sm.options[sm.selected] and sm.options[sm.selected].ok
		if control == "start" and ok then
			ok(m)
			love.audio.stop(m.ok_sound)
			love.audio.play(m.ok_sound)
		end
		
		-- Select a color with other buttons if on colors submenu
		-- Set southpaw if holding left
		if m.submenu == "colors" then
			if control == "body" or control == "hook" or control == "cross" then
				love.audio.stop(m.move_sound)
				love.audio.play(m.move_sound)
			end

			if control == "body" then
				m.colors[player] = "red"
			elseif control == "hook" then
				m.colors[player] = "green"
			elseif control == "cross" then
				m.colors[player] = "blue"
			end
		end
	end
	
	menu.remap = function(m, control)
		 _remapping.control = control
		 _remapping.player = m.submenus.remap.player
	end
	
	menu.startTraining = function(m)
		m.done = true
		m.exitScene = Game("training", { TRAINING_COLOR })
	end
	
	return menu
end
