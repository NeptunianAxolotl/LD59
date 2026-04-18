
local roadUtil = {}

function roadUtil.GetCurveLength(radius)
	return math.pi*radius/2
end

function roadUtil.GetCurvePos(sPos, ePos, radius, t, dir)
	if dir == 1 then
		return {sPos[1] + (ePos[1] - sPos[1]) * math.sin(t * math.pi / 2), sPos[2] + (ePos[2] - sPos[2]) * (1 - math.cos(t * math.pi / 2))}
	elseif dir == -1 then
		return {sPos[1] + (ePos[1] - sPos[1]) * (1 - math.cos(t * math.pi / 2)), sPos[2] + (ePos[2] - sPos[2]) * math.sin(t * math.pi / 2)}
	end
end

function roadUtil.GetCurveDir(t, dir)
	return math.pi - (t - (dir - 1)/2) * dir * math.pi / 2
end

return roadUtil
