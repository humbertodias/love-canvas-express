local MARGIN = 1
local BLINK = 0.1

function Bar(x, y, direction, max, value)
	local bar = {}
	
	bar.x = x or 0
	bar.y = y or 0
	bar.direction = direction or 1
	bar.original_max = max or 0
	bar.max = bar.original_max
	bar.value = value or 0
	bar.star = love.graphics.newImage("share/star.png")
	bar.nostar = love.graphics.newImage("share/nostar.png")
	bar.blink_time = 0.0
	
	bar.draw = function(hb)
		if hb.blink_time > 2 * BLINK then
			hb.blink_time = 0
		end

		-- Calculate where starts should begin to be drawn in order to get
		-- to hb.x when original_max is met (not max because it also reflects
		-- inflicted perma damage)
		local width
		local x
		if hb.direction == -1 then
			width = (hb.star:getWidth() + MARGIN) * (hb.original_max - 1)
			x = hb.x + width
		elseif hb.direction == 1 then
			width = (hb.star:getWidth() + MARGIN) * hb.original_max
			x = _window.bw - hb.x - width
		end

		-- Draw empty stars
		for i = 0, hb.max - 1 do
			love.graphics.draw(hb.nostar, x + (hb.star:getWidth() + MARGIN) * i * hb.direction, hb.y)
		end
		
		-- Draw full stars. Not drawn low hp when counter less than BLINK
		if hb.value > _cfg.low_hp or hb.blink_time < BLINK then
			for i = 0, hb.value - 1 do
				love.graphics.draw(hb.star, x + (hb.star:getWidth() + MARGIN) * i * hb.direction, hb.y)
			end
		end
	end
	
	return bar
end
