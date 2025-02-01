require("rectangle")
	
function Level(mode)
	local level = {}	
		
	level.background = love.graphics.newImage("share/ring.png")
	level.props = {}
	level.geometry = { 
		Rectangle(-_window.bw * 0.9, 0, _window.bw, _window.bh), -- Huge wall so correction won't put you outside
		Rectangle(_window.bw * 0.9, 0, _window.bw, _window.bh), -- Huge wall so correction won't put you outside
	}
	
	if mode == "training" then
		level.background = love.graphics.newImage("share/gym.png")
		level.magazines = Rectangle(20, 42, 8, 16)
		level.gloves = Rectangle(114, 44, 6, 16)
		level.cooler = Rectangle(128, 32, 16, 48)
	end
	
	return level
end
