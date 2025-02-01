require("timer")

function Punch(damage, perma_damage, block_damage, cost, hit_stun, block_stun, hit_range, stuff_range, is_body, can_auto_combo, startup, active, lag, recovery, animation, sound)
	-- A punch is a kind of timer, so to speak
	local punch = Timer({ startup = startup, active = active, lag = lag, recovery = recovery })
	punch.progress = recovery
	
	punch.damage = damage
	punch.perma_damage = perma_damage
	punch.block_damage = block_damage
	punch.cost = cost
	punch.hit_stun = hit_stun
	punch.block_stun = block_stun
	punch.hit_range = hit_range
	punch.stuff_range = stuff_range
	punch.is_body = is_body
	punch.can_auto_combo = can_auto_combo
	punch.animation = animation
	punch.sound = sound
	
	punch.canInterrupt = function(p, previous)
		return (p.progress >= p.stages.lag and (p ~= previous or p.can_auto_combo)) or p:stage() == "done"
	end
	
	punch.canFeint = function(p)
		return p.progress < math.min(p.stages.startup, _cfg.feint_limit)
	end
	
	punch.hits = function(p, distance)
		-- Distance in this context is positive towards facing side,
		-- negative distance means the target is behind
		return p:stage() == "active" and p.hit_range >= distance and distance >= 0
	end
	
	punch.stuffs = function(p, distance)
		-- Same here as in punch.hits
		return not p:isPast("startup") and p.stuff_range > distance and distance >= 0
	end
	
	punch.interrupt = function(p)
		p.progress = math.max(p.progress, p.stages.active)
	end
	
	punch.cancel = function(p)
		p.progress = math.max(p.progress, p.stages.recovery)
	end
	
	return punch
end
