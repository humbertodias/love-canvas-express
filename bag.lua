require("rectangle")
require("sprite")

local HURTBOX = { w = 16, h = 32 }

function Bag(x, y, side)
	local bag = {}

	bag.bounds = Rectangle(x, y, HURTBOX.w, HURTBOX.h)
	bag.sprite = Sprite("share/bag/")
	bag.hp = 0
	bag.max_hp = 0
	bag.side = side
	bag.collidable = true
	bag.fixed = true
	bag.stun_time = 0.0
	bag.sounds = {}
	bag.sounds.hurt = love.audio.newSource("share/bag_hit.ogg", "static")

	bag.punch = {}
	bag.punch.hits = function(p) return false end
	bag.punch.stuffs = function(p) return false end

	bag.update = function(b, dt)
		b.sprite:update(dt)

		b.stun_time = b.stun_time - dt

		if b.stun_time <= 0 then
			b.sprite:setAnimation("idle")
		end
	end

	bag.controlpressed = function()
	end

	bag.draw = function(b)
		b.sprite:draw(b.bounds.x + b.bounds.w / 2, b.bounds.y + b.bounds.h / 2)
	end

	bag.getHit = function(b, punch)
		b.stun_time = punch.hit_stun

		love.audio.stop(b.sounds.hurt)
		love.audio.play(b.sounds.hurt)

		local animation = punch.is_body and "hit_body" or "hit_head"
		b.sprite:setAnimation(animation)

		return false
	end

	bag.queueFlip = function(b)
		b.side = -b.side
		b.sprite.side = -b.sprite.side
	end

	return bag
end
