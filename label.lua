function Label(text, x, y, alignment)
	local label = {}
	
	label.text = text or ""
	label.x = x or 0
	label.y = y or 0
	label.alignment = alignment or "left"
	
	label.getPosition = function(label)
		local x = label.x
		
		if label.alignment == "center" then
			x = x - label:getWidth() / 2
		elseif label.alignment == "right" then
			x = x - label:getWidth()
		end
		
		return {x = x, y = label.y}
	end
	
	label.getWidth = function(l)
		return _font:getWidth(l.text)
	end
	
	label.draw = function(l)
		love.graphics.print(l.text, l:getPosition().x, l:getPosition().y)
	end
	
	return label
end
