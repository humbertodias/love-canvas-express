function sign(number)
	if number >= 0 then
		return 1
	else
		return -1
	end
end

function clamp(number, low, high)
	return math.max(low, math.min(number, high))
end

function wrap(n, min, max)
	return min + (n - min) % ((max + 1) - min)
end

function getKey(table, value)
	local first

	for key, v in pairs(table) do
		if v == value and not first then
			first = key
		end
	end

	return first
end

function mergeTables(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			mergeTables(t1[k], t2[k])
		elseif v ~= nil and type(t1[k]) == type(v) then
			t1[k] = v
		end
	end

	return t1
end

