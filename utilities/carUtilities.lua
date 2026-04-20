
local carUtil = {}


function carUtil.GetDirectionTowards(pos, target)
	if math.abs(pos[1] - target[1]) > math.abs(pos[2] - target[2]) then
		return (pos[1] > target[1]) and 2 or 0
	end
	return (pos[2] > target[2]) and 3 or 1
end

function carUtil.GetBestMatchingDirectionTowards(pos, target, filter, notAllowed)
	local best = carUtil.GetDirectionTowards(pos, target)
	local onlyOneDimension = (pos[2] == target[2]) or (pos[1] == target[1])
	if filter[best] and best ~= notAllowed and (best == 1 or best == 3 or onlyOneDimension) then
		-- Only take the best option if we are done.
		-- Otherwise, take a short leg to get onto the road of the best option.
		return best
	end
	local secondBest
	if best%2 == 0 then
		secondBest = (pos[2] > target[2]) and 3 or 1
	else
		secondBest = (pos[1] > target[1]) and 2 or 0
	end
	if filter[secondBest] and secondBest ~= notAllowed then
		return secondBest
	end
	if filter[best] and best ~= notAllowed then
		return best
	end
	local thirdBest = (secondBest - 2)%4
	if filter[thirdBest] and thirdBest ~= notAllowed then
		return thirdBest
	end
	local worst = (best - 2)%4
	if filter[worst] and thirdBest ~= notAllowed then
		return worst
	end
	return false
end

return carUtil
