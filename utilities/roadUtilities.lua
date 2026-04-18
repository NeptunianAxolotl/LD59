
local roadUtil = {}

function roadUtil.GetCurveLength(radius)
	return math.pi*radius/2
end

function roadUtil.GetCurvePos(sPos, ePos, t, dir)
	if dir == 1 then
		return {sPos[1] + (ePos[1] - sPos[1]) * math.sin(t * math.pi / 2), sPos[2] + (ePos[2] - sPos[2]) * (1 - math.cos(t * math.pi / 2))}
	elseif dir == -1 then
		return {sPos[1] + (ePos[1] - sPos[1]) * (1 - math.cos(t * math.pi / 2)), sPos[2] + (ePos[2] - sPos[2]) * math.sin(t * math.pi / 2)}
	end
end

function roadUtil.GetCurveDir(t, dir, entry)
	return math.pi - (t + (entry or 0)) * dir * math.pi / 2
end

local outLength = roadUtil.GetCurveLength(Global.DRIVE_OFFSET + 0.25)
local innerLength = roadUtil.GetCurveLength(0.5 - Global.DRIVE_OFFSET)
local laneOutLength = outLength * 0.8

function roadUtil.GetInnerLength()
	return innerLength
end

function roadUtil.GetFullOuterLength()
	return outLength + 0.5
end

function roadUtil.GetFullLanedOuterLength()
	return laneOutLength + 0.25
end

function roadUtil.GetStraightPos(t, enterOffset, destOffset)
	local offset = util.AverageScalar(enterOffset, destOffset, t)
	return {0.5 - t, offset}
end

function roadUtil.InnerCornerPos(t, enterOffset, destOffset)
	t = t/innerLength
	return roadUtil.GetCurvePos({0.5, enterOffset}, {destOffset, 0.5}, t, 1)
end

function roadUtil.InnerCornerDir(t)
	t = t/innerLength
	return roadUtil.GetCurveDir(t, 1)
end

function roadUtil.OuterCornerPos(t, enterOffset, destOffset)
	if t < 0.25 then
		return {-enterOffset, 0.5 - t}
	elseif t < 0.25 + outLength then
		t = (t - 0.25)/outLength
		return roadUtil.GetCurvePos({-enterOffset, 0.25}, {0.25, -destOffset}, t, -1)
	else
		return {t - outLength, -destOffset}
	end
end

function roadUtil.OuterCornerDir(t)
	if t < 0.25 then
		return -math.pi/2
	elseif t < 0.25 + outLength then
		t = (t - 0.25)/outLength
		return roadUtil.GetCurveDir(t, -1, 1)
	else
		return 0
	end
end

function roadUtil.OuterLanedCornerPos(t, enterOffset, destOffset)
	if t < 0.1 then
		return {-enterOffset, 0.5 - t}
	elseif t < 0.1 + laneOutLength then
		t = (t - 0.1)/laneOutLength
		return roadUtil.GetCurvePos({-enterOffset, 0.4}, {0.35, -destOffset}, t, -1)
	else
		return {t - laneOutLength + 0.25, -destOffset}
	end
end

function roadUtil.OuterLanedCornerDir(t)
	if t < 0.1 then
		return -math.pi/2
	elseif t < 0.1 + laneOutLength then
		t = (t - 0.1)/laneOutLength
		return roadUtil.GetCurveDir(t, -1, 1)
	else
		return 0
	end
end

return roadUtil
