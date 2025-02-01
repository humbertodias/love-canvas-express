function Timer(stages, timestamps, initial)
	local timer = {}

	timer.stages = stages
	timer.stages.done = 9999
	timer.progress = initial or timer.stages.done

	timer.start = function(t, delay)
		t.progress = 0 - (delay or 0)
	end

	timer.stop = function(t)
		t.progress = timer.stages.done
	end

	timer.stage = function(t)
		local current = "done"

		for name, timestamp in pairs(t.stages) do
			if timestamp > t.progress and timestamp < t.stages[current] then
				current = name
			end
		end

		return current
	end

	timer.isPast = function(t, stage)
		return t.stages[stage] < t.progress
	end

	timer.isDone = function(t)
		return t:stage() == "done"
	end

	return timer
end
