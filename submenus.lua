function newSubmenus()
	local submenus = {}

	local line = _font:getHeight("0")

	submenus.main = {
		selected = 1,
		options = {
			newButton("FIGHT", function(m) m.submenu = "colors" end),
			newButton("TRAIN", function(m) m:startTraining() end),
			newButton("HELP", function(m) m.submenu = "controls" end),
			newButton("CONFIGURE", function(m) m.submenu = "configure" end),
			newButton("EXIT", love.event.quit),
		},
		background = love.graphics.newImage("share/menu.png"),
		labels = {
--				Label("[START] TO SELECT", _window.w / 2, _window.h - line * 7 , "center"),
--				Label("[UP] & [DOWN] TO MOVE", _window.w / 2, _window.h - line * 6 , "center"),
			Label("© 2021-2022 RAMIRO BASILE", _window.w / 2, _window.h - line * 3 , "center"),
			Label("SOURCE CODE AVAILABLE UNDER GPLv3", _window.w / 2, _window.h - line * 2, "center"),
		},
	}

	-- TODO Dynamic bindings?
	local controls_text = [[
           DEFAULT BINDINGS

  +--------------------------------+
  | CONTROL | P1  | P2   | PAD     |
  +--------------------------------+
  | [LEFT]    A     LEFT   DPLEFT  |
  |                                |
  | [RIGHT]   D     RIGHT  DPRIGHT |
  |                                |
  | [UP]      W     UP     DPUP    |
  |                                |
  | [DOWN]    S     DOWN   DPDOWN  |
  |                                |
  | [JAB]     F     N      A       |
  |                                |
  | [CROSS]   G     M      B       |
  |                                |
  | [HOOK]    T     K      Y       |
  |                                |
  | [BODY]    Y     L      X       |
  |                                |
  | [START]   RETRN BKSPCE START   |
  +--------------------------------+]]

	submenus.controls = {
		selected = 1,
		options = {
			newButton("NEXT", function(m) m.submenu = "help" end, _window.w / 2, _window.h - line * 3),
		},
		labels = {
			Label(controls_text, line, line * 2),
		},
	}

	local help_text = [[
         HP IS USED TO MOVE & PUNCH
         YOU'RE KO'D WHEN AT 0 HP


         SKIP: 2X PUSH [LEFT]/[RIGHT]

         BLOCK: PUSH [UP] RIGHT BEFORE
                TAKING A PUNCH

         DODGE: PUSH [DOWN]


         JAB: QUICK BUT WEAK

         CROSS: MEDIUM, FAST & LONG

         HOOK: STRONG BUT SHORT & SLOW

         BODY: WEAKENS BUT SHORT


         RED IS A BOXER-PUNCHER
         GREEN IS AN IN-FIGHTER
         BLUE IS AN OUT-BOXER]]

	submenus.help = {
		selected = 1,
		options = {
			newButton("BACK", function(m) m.submenu = "main" end, _window.w / 2, _window.h - line * 3),
		},
		background = love.graphics.newImage("share/help.png"),
		labels = {
			Label(help_text, line, line * 2),
		},
	}

	submenus.configure = {
		selected = 1,
		options = {
			newButton("WINDOW SCALE",	function()
			                            	_window.scale = _window.scale + 1
			                            	resetMode()
			                            end),
			newButton("FULLSCREEN",	function() toggleFullscreen() end),
			newButton("MUSIC",	function()
			                    	if _music:isPlaying() then
			                    		_music:stop()
			                    	else
			                    		_music:play()
		                    		end
	                    		end),
			newButton("REMAP P1 KEYS", 	function(m)
			                           		m.submenu = "remap"
			                           		m.submenus.remap.player = 1
			                           	end),
			newButton("REMAP P2 KEYS", 	function(m)
			                           		m.submenu = "remap"
			                           		m.submenus.remap.player = 2
			                           	end),
			newButton("ADVANCED", function(m) m.submenu = "advanced" end),
			newButton("BACK", function(m) m.submenu = "main" end),
		},
		labels = {
			Label("v" .. _VERSION, _window.w - _font:getWidth("v2.2"), line, "center"),
		},
	}

	submenus.remap = {
		selected = 1,
		player = 1,
		options = {
			newButton("LEFT", function(m) m:remap("left") end),
			newButton("RIGHT", function(m) m:remap("right") end),
			newButton("UP", function(m) m:remap("up") end),
			newButton("DOWN", function(m) m:remap("down") end),
			newButton("JAB", function(m) m:remap("jab") end),
			newButton("CROSS", function(m) m:remap("cross") end),
			newButton("HOOK", function(m) m:remap("hook") end),
			newButton("BODY", function(m) m:remap("body") end),
			newButton("BACK", function(m) m.submenu = "configure" end),
		},
		labels = {},
	}

	local location = love.filesystem.getSaveDirectory() .. "/canvas-express.conf"
	location = location:gsub(string.rep(".", 34), "%1\n")
	local advanced_text = [[
MORE CONFIGURATION OPTIONS ARE
AVAILABLE IN THE GAME'S
CONFIGURATION FILE, LOCATED AT

]] .. location .. "\n\n" .. [[
PLEASE READ THE COMMENTS WITHIN
THE FILE CAREFULLY BEFORE EDITING.]]
	submenus.advanced = {
		selected = 1,
		options = {
			newButton("BACK", function(m) m.submenu = "configure" end, _window.w / 2, _window.h - line * 3),
		},
		labels = {
			Label(advanced_text, line * 3, line * 3),
		},
	}

	submenus.colors = {
		selected = 1,
		options = {},
		background = love.graphics.newImage("share/colors.png"),
		labels = {
			Label("RED", _window.w * 0.2, _window.h / 2 - line, "center"),
			Label("[CROSS]", _window.w * 0.2, _window.h / 2 + line, "center"),
			Label("GREEN", _window.w * 0.5, _window.h / 2 - line, "center"),
			Label("[BODY]", _window.w * 0.5, _window.h / 2 + line, "center"),
			Label("BLUE", _window.w * 0.8, _window.h / 2 - line, "center"),
			Label("[HOOK]", _window.w * 0.8, _window.h / 2 + line, "center"),
			Label("CHOOSE A COLOR", _window.w / 2, _window.h * 0.85, "center"),
		}
	}

	return submenus
end
