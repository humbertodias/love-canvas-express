require("bag")
require("bar")
require("label")
require("level")
require("lib/lua-string")
require("player")
require("rectangle")

-- HACK Using alt_blue instead of blue its palette is white... looks weird for the guy to also change skin color when he changes clothes
local TRAINING_COLORS = { "red", "green", "alt_blue" }
local READ_SPEED = 90 -- wpm
local MIN_SHAKE = 0.05
local HURTBOX = { w = 16, h = 32 }
local SPAWNS = {}
SPAWNS[1] = { x = 0.2, y = 0.35 } -- These are scalars of screen width, one per player
SPAWNS[2] = { x = 0.8, y = 0.35 }

function Game(mode, colors)
	local game = {}
	
	game.done = false
	game.exitScene = Menu()

	game.mode = mode
	game.level = Level(game.mode)
	game.players = {}
	game.time = _cfg.round_duration
	game.won = false
	game.warned = false
	game.tip_number = 1
	game.shake_time = 0.0
	game.info_time = 0.0
	game.exit_time = 0.0
	game.warning_sound = love.audio.newSource("share/warning.ogg", "static")
	game.done_sound = love.audio.newSource("share/bell_3.ogg", "static")
	game.paper_sound = love.audio.newSource("share/paper.ogg", "static")
	game.drink_sound = love.audio.newSource("share/drink.ogg", "static")

	-- Players
	if colors[2] and colors[1] == colors[2] then
		colors[2] = "alt_" .. colors[2]
	end

	local bounds = Rectangle(_window.bw * SPAWNS[1].x, _window.bh * SPAWNS[1].y, HURTBOX.w, HURTBOX.h)
	game.players[1] = Player(1, bounds, colors[1], 1)

	if mode == "fight" then
		local bounds = Rectangle(_window.bw * SPAWNS[2].x - HURTBOX.w, _window.bh * SPAWNS[2].y, HURTBOX.w, HURTBOX.h)
		game.players[2] = Player(2, bounds, colors[2], -1)
	elseif mode == "training" then
		game.players[2] = Bag(72, 28, -1)
	end

	-- UI
	local margins = { x = _window.w * 0.033, y = _window.h * 0.075 }
	game.name_labels = {}
	game.follow_labels = {}
	game.bars = {}
	game.time_label = Label("00", _window.w / 2, margins.y, "center")
	game.win_label = Label("", _window.w / 2, _window.h * 0.9, "center")
	game.exit_label = Label("[START]: EXIT\n[UP]: USE", _window.w - margins.x, margins.y, "right")
	game.info_label = Label("", margins.x, _window.h - margins.y - _font:getHeight("0") * 6)

	game.name_labels[1] = Label( _cfg.names[1], margins.x, margins.y)
	game.follow_labels[1] = Label(_cfg.short_names[1], 0, 0, "center")
	game.bars[1] = Bar(_window.bw * 0.033, _window.bh * 0.125, -1, 10, 10)

	if mode == "fight" then
		local name = ("[%s] %s"):format(colors[1]:sub(1, 1):trim("alt_"):upper(), _cfg.names[1])
		game.name_labels[1] = Label(name, margins.x, margins.y)

		local name = ("%s [%s]"):format(_cfg.names[2], colors[2]:trim("alt_"):sub(1, 1):upper())
		game.name_labels[2] = Label(name, _window.w - margins.x, margins.y, "right")
		game.follow_labels[2] = Label(_cfg.short_names[2], 0, 0, "center")
		game.bars[2] = Bar(_window.bw * 0.033, _window.bh * 0.125, 1, 10, 10)
	end
	
	game.update = function(g, dt)
		g.shake_time = g.shake_time - dt
		g.info_time = g.info_time - dt
		g.exit_time = g.exit_time + dt

		-- Update UI
		g.time_label.text = math.ceil(g.time)

		for i, bar in ipairs(g.bars) do
			bar.blink_time = bar.blink_time + dt
			bar.value =g.players[i].hp
			bar.max = g.players[i].max_hp
		end
		
		if g.won then
			-- Set scene as done when enough time has passed after won was set
			if g.exit_time > _cfg.results_time then
				g.done = true
			end
			return
		end
		
		g.time = math.max(g.time - dt, 0) -- Without max 0 it stops at -0, annoying
		
		-- Player stuff (here be dragons)
		for i, player in ipairs(g.players) do
			player:update(dt)

			for _, other in pairs(g.players) do
				if player ~= other then
					-- Correct collisions
					if player.collidable and other.collidable then
						if not player.fixed then
							player.bounds:correct(other.bounds)
						end

						-- Flip if players crossed-up
						if (player.bounds.x - other.bounds.x > 0 and player.side == 1)
							   or (player.bounds.x - other.bounds.x < 0 and player.side == -1) then
							player:queueFlip()
						end
					end

					-- Punches and stuffing based on distance between players
					local distance = other.bounds.x - player.bounds.x
					distance = distance * player.side -- Positive dist. towards facing side

					if player.punch:stuffs(distance) then
						player:stuff()
					end

					if player.punch:hits(distance) then
						local scored = other:getHit(player.punch)
						player:hit(scored)

						-- Win by KO
						if g.mode == "fight" and other.hp <= 0 then
							g:win(i, true)
						end
					end
				end
			end
			
			-- Collisions from walls
			for _, wall in pairs(g.level.geometry) do
				player.bounds:correct(wall)
			end
		end
		
		-- 10 second warning
		if g.mode == "fight" and g.time <= 10 and not g.warned and not g.won then
			love.audio.play(g.warning_sound)
			g.warned = true
		end

		-- Win by time
		if g.mode == "fight" and not g.won and g.time <= 0 then
			local winner = g:leader()
			g:win(ties == #g.players and 0 or winner, false)
		end
	end
	
	game.controlpressed = function(g, control, index)
		if _cfg.allow_exit and not g.won and control == "start" then
			if mode == "fight" then
				g:win()
			else
				g.done = true
			end
			return
		end

		if g.won then
			return
		end

		local player = g.players[index]
		if player then
			player:controlpressed(control)

			-- Interact with training mode props
			if mode == "training" and control == "up" then
				if player.bounds:intersects(g.level.magazines) then
					g:tip(player)
				elseif player.bounds:intersects(g.level.gloves) then
					g:changeColor(player, index)
				elseif player.bounds:intersects(g.level.cooler) then
					g:heal(player)
				end
			end
		end
	end
	
	game.draw = function(g)
		for _, bar in pairs(g.bars) do
			bar:draw()
		end
		
		if not g.won and g.shake_time > MIN_SHAKE then
			local magnitude = _cfg.shake_magnitude
			love.graphics.translate(love.math.random(-magnitude, magnitude), 0)
		end

		love.graphics.draw(g.level.background)
		
		-- FIXME Wrong draw order once flipped
		for _, player in pairs(g.players) do
			g.shake_time = math.max(g.shake_time, player.stun_time)
			player:draw()
		end
		
		-- Debug stuff
--		for _, player in pairs(g.players) do player.bounds:draw() end
--		for _, wall in pairs(g.level.geometry) do wall:draw() end
--		g.level.magazines:draw()
--		g.level.gloves:draw()
--		g.level.cooler:draw()
	end
	
	game.drawText = function(g)
		for _, name in pairs(g.name_labels) do
			name:draw()
		end
		
		if g.time > _cfg.round_duration * 0.9 then
			for i, label in pairs(g.follow_labels) do
				local player = g.players[i]
				label.x = (player.bounds.x + player.bounds.w / 2) * _window.scale
				label.y = player.bounds.y * _window.scale - _font:getHeight("0") * 2
				label:draw()
			end
		end

		if g.mode == "fight" then
			g.time_label:draw()
		end

		if g.won then
			g.win_label:draw()
		end

		if g.mode == "training" then
			g.exit_label:draw()

			if g.info_time > 0 then
				g.info_label:draw()
			end
		end
	end
	
	game.leader = function(g)
		local ties = 0
		local winner = 1
		for i, player in ipairs(g.players) do
			if player.score == g.players[winner].score then
				ties = ties + 1
			end
			if player.score > g.players[winner].score then
				winner = i
			end
		end

		return ties == #g.players and 0 or winner
	end

	game.win = function(g, player, ko)
		g.won = true
		g.exit_time = 0
		love.audio.play(g.done_sound)

		g.win_label.text = "NO CONTEST"

		-- nil is no contest, 0 draw, otherwise winner
		if player then
			if player == 0 then
				g.win_label.text = "DRAW (DECISION)"
			else
				local method = ko and "KO" or "DECISION"
				g.win_label.text = ("PLAYER %s WINS (%s)"):format(player, method)
			end
		end
	end

	game.tip = function(g, player)
		local tips = string.split(love.filesystem.read("share/tips.txt"), "\n\n")
		table.remove(tips, #tips) -- Don't count newline before EOF as a tip
		local tip = ("THE MAGAZINE READS:\n\n%s"):format(tips[g.tip_number])
		g:setInfo(tip)
		g.tip_number = wrap(g.tip_number + 1, 1, #tips)
		love.audio.stop(player.sounds.guard)
		love.audio.stop(g.paper_sound)
		love.audio.play(g.paper_sound)
	end

	game.setInfo = function(g, text)
		local words = #string.split(text, " ")
		game.info_time = words * 60 / READ_SPEED
		game.info_label.text = text
	end

	-- HACK Pretty slow but when color changes the player needs to re-init
	game.changeColor = function(g, player, index)
		local player = g.players[index]

		-- HACK Using alt_blue instead of blue its palette is white... looks
		-- weird for the guy to also change skin color when he changes clothes
		local color = TRAINING_COLORS[wrap(getKey(TRAINING_COLORS, player.color) + 1, 1, #TRAINING_COLORS)]

		g.players[index] = Player(index, player.bounds, color, player.side)

		g:setInfo(("YOU CHANGE CLOTHES TO %s."):format(color:trim("alt_"):upper()))
		love.audio.stop(player.sounds.guard)
		love.audio.stop(player.sounds.dodge)
		love.audio.play(player.sounds.dodge)
	end

	game.heal = function(g, player)
		player.hp = player.max_hp
		g:setInfo("YOU DRINK SOME WATER.\nYOU FEEL REFRESHED.")
		love.audio.stop(player.sounds.guard)
		love.audio.stop(g.drink_sound)
		love.audio.play(g.drink_sound)
	end

	return game
end
