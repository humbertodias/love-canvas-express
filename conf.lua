function love.conf(t)
	t.identity = "canvas-express"
	t.version = "11.4"

	t.window.title = "Canvas Express"
	t.window.icon = "share/icon.png"
	t.window.resizable = false
	t.window.fullscreentype = "exclusive"
	t.window.vsync = 1

	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.mouse = false
	t.modules.physics = false
	t.modules.thread = false
	t.modules.touch = false
end
