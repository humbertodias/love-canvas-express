require("punch")

function Punches()
	local punches = {}

	-- damage, perma_damage, block_damage, cost
	-- hit_stun, block_stun
	-- hit_range, stuff_range, is_body, auto_limit
	-- startup, active, lag, recovery
	-- animation, sound

	punches.jab = Punch(
		0, 0, 0, 0,
		0.15, 0.075,
		32, 20, false, false,
		0.2, 0.25, 0.25125, 0.4,
		"jab", love.audio.newSource("share/exhale_soft.ogg", "static")
	)

	punches.cross = Punch(
		2, 0, 1, 1,
		0.275, 0.225,
		32, 18, false, false,
		0.3125, 0.3625, 0.5, 0.5,
		"cross", love.audio.newSource("share/exhale_soft.ogg", "static")
	)

	punches.hook = Punch(
		3, 0, 2, 2,
		0.325, 0.275,
		26, 8, false, true,
		0.425, 0.475, 0.525, 0.725,
		"hook", love.audio.newSource("share/exhale_medium.ogg", "static")
	)

	punches.body = Punch(
		2, 2, 0, 1,
		0.275, 0.225,
		24, 8, true, true,
		0.35, 0.4, 0.5, 0.65,
		"body", love.audio.newSource("share/exhale_hard.ogg", "static")
	)

	return punches
end
