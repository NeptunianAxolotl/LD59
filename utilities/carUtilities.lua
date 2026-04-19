
local carUtil = {}


function carUtil.GetDirectionTowards(pos, target)
	if math.abs(pos[1] - target[1]) > math.abs(pos[2] - target[2]) then
		return (pos[1] > target[1]) and 2 or 0
	end
	return (pos[2] > target[2]) and 3 or 1
end

function carUtil.GetBestMatchingDirectionTowards(pos, target, filter)
	local best = carUtil.GetDirectionTowards(pos, target)
	if filter[best] then
		return best
	end
	local secondBest
	if best%2 == 0 then
		secondBest = (pos[2] > target[2]) and 3 or 1
	else
		secondBest = (pos[1] > target[1]) and 2 or 0
	end
	if filter[secondBest] then
		return secondBest
	end
	if filter[(secondBest - 2)%4] then
		return (secondBest - 2)%4
	end
	if filter[(best - 2)%4] then
		return (best - 2)%4
	end
	return false
end

return carUtil
