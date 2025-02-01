require("lib/lua-string")

function getAnimations(directory)
	local animations = {}

	-- Look for PNGs and interpret anything before a space as an animation name
	-- and the number after the space as the corresponding frame.
	-- Animations prefixed with alt_ are "alternative" animations, which
	-- play out when the same animation as the current is requested before the
	-- original instance finishes
	for _, file in pairs(love.filesystem.getDirectoryItems(directory)) do
		if string.endswith(file, ".png") then
			local name = string.split(file, " ")[1]
			local alt = string.startswith(name, "alt_")
			if alt then
				name = string.sub(name, 5)
			end

			if not animations[name] then
				animations[name] = {}
				animations[name].frames = {}
				animations[name].alt_frames = {}
			end

			local frame = love.graphics.newImage(directory .. file)

			if alt then
				table.insert(animations[name].alt_frames, frame)
			else
				table.insert(animations[name].frames, frame)
			end
		end
	end
	
	return animations
end
	
function Sprite(directory, side, palette)
	local sprite = {}

	sprite.side = side or 1 -- -1 faces left, 1 faces right
	sprite.fps = 15
	sprite.alt = false
	sprite.looping = false
	sprite.animations = {}
	sprite.frame = 1
	sprite.progress = 0

	-- FIXME
--	if palette then
--		sprite.shader = love.graphics.newShader("palette-swap.glsl")
--		sprite.palette = love.graphics.newImage(palette)
--		sprite.palette:setFilter("nearest", "nearest")
--	end
	
	-- Get animations for the left and right side
	sprite.animations[1] = getAnimations(string.format("%s%s", directory, "right/"))
	sprite.animations[-1] = getAnimations(string.format("%s%s", directory, "left/"))

	sprite.animation = sprite.animations[sprite.side].idle or sprite.animations[sprite.side][1]
	
	sprite.update = function(s, dt)
		s.progress = s.progress + dt
		
		-- Advance frames
		if s.progress > 1 / s.fps then
			if s.looping then
				s.frame = math.fmod(s.frame, #s.animation.frames) + 1
			else
				s.frame = math.min(s.frame + 1, #s.animation.frames)
			end

			s.progress = 0
		end

		-- HACK If anim finishes before last frame weird shit happens. This is a bandaid
		if s.frame > #s.animation.frames then
			s.frame = 1
		end
	end
	
	sprite.draw = function(s, x, y)
		-- FIXME
--		if s.shader and s.palette then
--			love.graphics.draw(s.palette)
--			love.graphics.setShader(s.shader)
--			s.shader:send("palette", s.palette)
--			love.graphics.draw(s.palette, 0, 3)
--		end

		local frame = s.animation.frames[s.frame]
		if s.alt and s.animation.alt_frames[s.frame] then
			frame = s.animation.alt_frames[s.frame]
		end

		love.graphics.draw(frame, x - frame:getWidth() / 2, y - frame:getHeight() / 2)

--		love.graphics.setShader()
	end

	sprite.setAnimation = function(s, new, loops)
		s.looping = loops

		local new_animation = s.animations[s.side][new]

		-- Looping animations are expected to be set every frame, thus
		-- same-name looping animations don't reset the frame counter
		if s.animation ~= new_animation or not loops then
			s.frame = 1
			s.progress = 0
		end

		-- If the same animation as the current one is requested and it's not
		-- done then the alternative version of the animation is set (only if
		-- that animation has an alternative version)
		s.alt = s.animation == new_animation and not s.alt
		s.animation = new_animation
	end

	return sprite
end
