function Rectangle(x, y, w, h)
	local rectangle = {}
	
	rectangle.x = x or 0
	rectangle.y = y or 0
	rectangle.w = w or 0
	rectangle.h = h or 0
	
	rectangle.draw = function(rect)
		love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
	end
	
	rectangle.intersects = function(rect, other)
		return 	rect.x < other.x + other.w and rect.x + rect.w > other.x 
				and rect.y < other.y + other.h and rect.y + rect.h > other.y
	end
	
	rectangle.overlap = function(rect, other)
		local overlap = Rectangle()
		
		if rect:intersects(other) then
			local x = math.max(rect.x, other.x)
			local y = math.max(rect.y, other.y)
			local w = math.min(rect.x + rect.w, other.x + other.w) - x
			local h = math.min(rect.y + rect.h, other.y + other.h) - y
			
			overlap = Rectangle(x, y, w, h)
		end
		
		return overlap
	end
	
	rectangle.correct = function(rect, other)
		if rect:intersects(other) then
			local overlap = rect:overlap(other)
			
			-- Always resolve by correcting the smallest overlap
			if math.abs(overlap.w) < math.abs(overlap.h) then
				rect.x = rect.x - overlap.w * sign(other.x - rect.x)
			else
				rect.y = rect.y - overlap.h * sign(other.y - rect.y)
			end
		end
	end
	
	return rectangle
end
