require("punches")
require("sprite")
require("timer")

function Player(index, bounds, color, side)
	local player = {}
	
	player.index = index
	player.buffered = ""
	player.buffer_time = 0.0
	player.side = side
	player.color = color
	player.bounds = bounds
	local sprite_dir = string.format("share/fighter/%s/", color)
	local palette = string.format("share/palettes/%s.png", color)
	player.sprite = Sprite(sprite_dir, player.side, palette)
	player.collidable = true
	player.fixed = false
	player.walk_speed = 30.0
	player.score = 0
	player.stun_time = 0.0

	player.max_hp = 10
	player.hp = player.max_hp
	player.regen_kickin = 1.0
	player.regen_rate = 0.8
	player.regen_per = 1
	player.regen_time = 0.0
	player.time_since_hit = 0.0

	player.dodge = Timer({ startup = 0.05, active = 0.3, cancelable = 0.4, recovery = 0.4 })
	player.dodge_cost = 1
	player.hittable = true
	player.flip = Timer({ active = 0.25 })
	player.guard = Timer({ shine = 0.1, active = 0.3, recovery = 0.5 })
	player.punches = Punches(sounds, sprite)
	player.punch = player.punches.jab or player.punches[1] -- HACK Don't want it ever being nil
	player.skip = Timer({ active = 0.425 })
	player.skip_direction = 0
	player.skip_cost = 2
	player.skip_speed = 60.0

	player.sounds = {}
	player.sounds.step = love.audio.newSource("share/step.ogg", "static")
	player.sounds.hurt = love.audio.newSource("share/hurt.ogg", "static")
	player.sounds.block = love.audio.newSource("share/block.ogg", "static")
	player.sounds.stuff = love.audio.newSource("share/no.ogg", "static")
	player.sounds.dodge = love.audio.newSource("share/exhale_medium.ogg", "static")
	player.sounds.guard = love.audio.newSource("share/raise.ogg", "static")

	-- Red is boxer-puncher
	if player.color == "red" or player.color == "alt_red" then
		player.regen_kickin = player.regen_kickin - 0.25
		player.guard.stages.active = player.guard.stages.active + 0.075
		player.skip_cost = player.skip_cost - 1
		player.punches.jab.hit_stun = player.punches.jab.hit_stun + 0.125
		player.punches.jab.block_stun = player.punches.jab.block_stun + 0.075
		player.punches.jab.stages.startup = player.punches.jab.stages.startup + 0.025
		player.punches.jab.stages.active = player.punches.jab.stages.active + 0.025
		player.punches.jab.stages.lag = player.punches.jab.stages.lag + 0.1
		player.punches.jab.stages.recovery = player.punches.jab.stages.recovery + 0.1
	end

	-- Green is in-fighter
	if player.color == "green" or player.color == "alt_green" then
		player.dodge.stages.startup = player.dodge.stages.startup - 0.1
		player.dodge.stages.active = player.dodge.stages.active + 0.05
		player.punches.hook.cost = player.punches.hook.cost - 1
		player.punches.body.block_damage = player.punches.body.block_damage + 1
		player.punches.cross.hit_stun = player.punches.cross.hit_stun + 0.05
		player.punches.cross.block_stun = player.punches.cross.block_stun + 0.05
		player.punches.hook.hit_stun = player.punches.hook.hit_stun + 0.05
		player.punches.hook.block_stun = player.punches.hook.block_stun + 0.05
		player.punches.body.hit_stun = player.punches.body.hit_stun + 0.05
		player.punches.body.block_stun = player.punches.body.block_stun + 0.05
	end
	
	-- Blue is out-boxer
	if player.color == "blue" or player.color == "alt_blue" then
		player.regen_rate = player.regen_rate - 0.2
		player.flip.stages.active = player.flip.stages.active - 0.15
		player.skip_speed = player.skip_speed + 8
		player.skip_cost = player.skip_cost - 1
		player.punches.jab.hit_range = player.punches.jab.hit_range + 2
		player.punches.cross.hit_range = player.punches.cross.hit_range + 2
	end
	
	player.update = function(p, dt)
		p.sprite:update(dt)

		-- Update timers
		p.punch.progress = p.punch.progress + dt
		p.dodge.progress = p.dodge.progress + dt
		p.guard.progress = p.guard.progress + dt
		p.skip.progress = p.skip.progress + dt
		p.flip.progress = p.flip.progress + dt

		p.stun_time = p.stun_time - dt
		if p.stun_time <= 0 then
			p.time_since_hit = p.time_since_hit + dt
		end

		if p.skip:isDone() and p.dodge:isDone() and p.guard:isDone() then
			p.regen_time = p.regen_time + dt
		end

		if p.regen_time > p.regen_rate and p.time_since_hit > p.regen_kickin then
			p.hp = math.min(p.hp + p.regen_per, math.max(p.max_hp, p.hp))
			p.regen_time = 0
		end

		-- Clear control buffer periodically
		p.buffer_time = p.buffer_time + dt
		if p.buffer_time > _cfg.buffer_clear_time then
			p.buffered = ""
			p.buffer_time = 0
		end
		
		dodging = p.dodge:stage() == "active" or p.dodge:stage() == "cancelable"
		p.hittable = not dodging and p.flip:stage() ~= "active"
		p.collidable = p.skip:stage() == "done"

		local moved = false
		local can_move = p.stun_time <= 0 and p.flip:isDone() and p.dodge:isDone() and p.punch:isDone()

		-- Walk
		if can_move and p.skip:isDone() then
			if isControlDown("left", p.index) then
				p.bounds.x = p.bounds.x - p.walk_speed * dt
				moved = true

				-- Don't override guard shine animation
				if p.guard:isPast("shine") then
					p.sprite:setAnimation("walk_left", true)
				end
			elseif isControlDown("right", p.index) then
				p.bounds.x = p.bounds.x + p.walk_speed * dt
				moved = true

				-- Don't override guard shine animation
				if p.guard:isPast("shine") then
					p.sprite:setAnimation("walk_right", true)
				end
			end
		end

		-- Skip
		if can_move and p.skip:stage() == "active" then
			p.bounds.x = p.bounds.x + p.skip_speed * p.skip_direction * dt
			moved = true
			p.sprite:setAnimation("skip", true)
			love.audio.play(p.sounds.step)
		end

		-- Set idle animation when none other applies
		if can_move and not moved and p.guard:isPast("shine") and p.stun_time < 0 then
			p.sprite:setAnimation("idle", true)
		end
	end
	
	player.draw = function(p)
		p.sprite:draw(p.bounds.x + p.bounds.w / 2, p.bounds.y + p.bounds.h / 2)
	end
	
	player.controlpressed = function(p, control)
		-- Raise guard
		-- Can be done during stun
		if control == "up" and p.dodge:isDone() and p.guard:isDone() and p.punch:isDone() then
			p.guard:start()
			p:damage(0)

			-- Don't override hurt animation
			if p.stun_time < 0 then
				p.sprite:setAnimation("guard")
			end

			love.audio.stop(p.sounds.guard)
			love.audio.play(p.sounds.guard)
		end

		-- Ignore inputs other than guard while stunned
		if p.stun_time > 0 or not p.flip:isDone() then
			-- But do buffer the last input, even when stunned
			p.buffered = control
			p.buffer_time = 0.0

			return
		end

		-- Skip
		-- Can interrupt punch after lag
		local double_left = control == "left" and p.buffered == "left"
		local double_right = control == "right" and p.buffered == "right"

		if (double_left or double_right) and p.punch:isPast("lag") and p.dodge:isDone() and p.flip:isDone() and p.skip:isDone() then
			p.skip_direction = double_left and -1 or 1
			p.skip:start()
			p.punch:cancel()
			p:damage(p.skip_cost)
		end

		-- Throw new punch
		-- Can interrupt dodge after startup and other punches after lag IF they can be combo'd into
		local punch = p.punches[control] -- Punches are key'd with a control
		if punch and p.punch:canInterrupt(punch) and p.dodge:isPast("startup") and p.flip:isDone() and p.skip:isDone() then
			p.punch = punch
			p:damage(p.punch.cost)
			p.punch:start()
			p.guard:stop()
			p.sprite:setAnimation(p.punch.animation)
			love.audio.play(p.punch.sound)
		end
		
		if control == "down" then
			-- Dodge
			-- Can interrupt itself after startup
			if p.punch:canInterrupt() and p.dodge:isPast("active") and p.flip:isDone() then
				p:damage(p.dodge_cost)
				p.dodge:start()
				p.guard:stop()
				p.sprite:setAnimation("dodge")
				love.audio.play(p.sounds.dodge)
				
			-- Feint punch if punching and feintable instead
			-- Doesn't check if dodging, flipping, etc. because it should've been done by punch earlier
			elseif p.punch:canFeint() then
				p.hp = math.min(p.hp + p.punch.cost, p.max_hp) -- HACK should cost 0 to begin with
				p.punch:interrupt()
				love.audio.stop(p.punch.sound)
			end
		end

		-- Buffer the last input (when not stunned)
		p.buffered = control
		p.buffer_time = 0.0
	end

	player.damage = function(p, amount, perma, stun, lethal)
		p.hp = math.max(p.hp - (amount or 0), (lethal and 0 or 1))
		p.max_hp = math.max(p.max_hp - (perma or 0), 1)
		p.time_since_hit = 0
		p.regen_time = 0
		p.stun_time = stun or p.stun_time
		p.punch:interrupt()

		-- Extend current buffer when stunned
		if stun then
			p.buffer_time = p.buffer_time + stun + _cfg.buffer_clear_time
		end
	end

	player.getHit = function(p, punch)
		if not p.hittable then
			return false
		end
		
		if p.guard and not p.guard:isPast("active") then
			p:damage(punch.block_damage, 0, punch.hit_stun)

			love.audio.stop(p.sounds.block)
			love.audio.play(p.sounds.block)

			local animation = punch.is_body and "block_body" or "block_head"
			p.sprite:setAnimation(animation)

			return false -- Inform the attacker the punch doesn't score
		else
			p:damage(punch.damage, punch.perma_damage, punch.hit_stun, true)

			love.audio.stop(p.sounds.hurt)
			love.audio.play(p.sounds.hurt)

			local animation = punch.is_body and "hit_body" or "hit_head"
			p.sprite:setAnimation(animation)
		end

		return true -- Inform the attacker the punch scores
	end

	player.hit = function(p, scored)
		local punch_value = (p.punch.damge == 0 and 1 or 2) -- Jabs only score 1
		p.score = p.score + (scored and punch_value or 0)
		p.punch:interrupt()
	end
	
	player.stuff = function(p)
		p.hp = math.min(p.hp + p.punch.cost, p.max_hp) -- Return punch cost
		
		p.punch:interrupt()
		
		love.audio.stop(p.punch.sound)
		love.audio.stop(p.sounds.stuff)
		love.audio.play(p.sounds.stuff)
	end
	
	player.queueFlip = function(p)
		p.side = -p.side
		p.sprite.side = -p.sprite.side
		p.sprite:setAnimation("flip")

		local delay = math.max(0, p.punch.stages["recovery"] - p.punch.progress)
		p.flip:start(delay)
	end

	return player
end
