
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

local function Ease(t)
	local pow2 = t*t
	return pow2*(1 - t*t*t) + pow2*pow2
end

local function EaseFlatter(t)
	local pow2 = t*t
	return pow2*(1 - t) + pow2
end

local function EaseSymetric(t)
	local result = (EaseFlatter(t) + 1 - EaseFlatter(1 - t)) * 0.5
	return result
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
	local offset = util.AverageScalar(enterOffset, destOffset, EaseSymetric(t))
	return {0.5 - t, offset}
end

function roadUtil.InnerCornerPos(t, enterOffset, destOffset)
	local offset = util.AverageScalar(enterOffset, destOffset, EaseSymetric(t/roadUtil.GetInnerLength()))
	t = t/innerLength
	return roadUtil.GetCurvePos({0.5, offset}, {offset, 0.5}, t, 1)
end

function roadUtil.InnerCornerDir(t)
	t = t/innerLength
	if t < 0.12 then
		return math.pi
	elseif t < 0.88 then
		return roadUtil.GetCurveDir((t - 0.14)/0.76, 1)
	else
		return math.pi/2
	end
end

function roadUtil.OuterCornerPos(t, enterOffset, destOffset)
	local offset = util.AverageScalar(enterOffset, destOffset, Ease(t/roadUtil.GetFullOuterLength()))
	if t < 0.25 then
		return {-offset, 0.5 - t}
	elseif t < 0.25 + outLength then
		t = (t - 0.25)/outLength
		return roadUtil.GetCurvePos({-offset, 0.25}, {0.25, -offset}, t, -1)
	else
		return {t - outLength, -offset}
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
	local offset = util.AverageScalar(enterOffset, destOffset, Ease(t/roadUtil.GetFullLanedOuterLength()))
	if t < 0.1 then
		return {-offset, 0.5 - t}
	elseif t < 0.1 + laneOutLength then
		t = (t - 0.1)/laneOutLength
		return roadUtil.GetCurvePos({-offset, 0.4}, {0.35, -offset}, t, -1)
	else
		return {t - laneOutLength + 0.25, -offset}
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

local rayWasHit = false
local function RayHit()
	rayWasHit = true
	return 0
end

function roadUtil.IsOccupied(self, vector)
	local world = PhysicsHandler.GetPhysicsWorld()
	local scale = LevelHandler.TileSize()
	self.ray = {}
	self.ray[1] = util.Add(self.worldPos, util.Mult(scale, util.RotateVector(vector[1], self.worldRot)))
	self.ray[2] = util.Add(self.worldPos, util.Mult(scale, util.RotateVector(vector[2], self.worldRot)))
	rayWasHit = false
	world:rayCast(self.ray[1][1], self.ray[1][2], self.ray[2][1], self.ray[2][2], RayHit)
	world:rayCast(self.ray[2][1], self.ray[2][2], self.ray[1][1], self.ray[1][2], RayHit)
	return rayWasHit
end

local clearZones = {}
clearZones[0] = {{-0.15, -Global.DRIVE_OFFSET*1.5}, {0.5, -Global.DRIVE_OFFSET * 0.6}}
clearZones[1] = {util.RotateVector(clearZones[0][1], math.pi/2), util.RotateVector(clearZones[0][2], math.pi/2)}
clearZones[2] = {util.RotateVector(clearZones[1][1], math.pi/2), util.RotateVector(clearZones[1][2], math.pi/2)}
clearZones[3] = {util.RotateVector(clearZones[2][1], math.pi/2), util.RotateVector(clearZones[2][2], math.pi/2)}

function roadUtil.GetClearZone(direction)
	return clearZones[direction]
end

return roadUtil
