local util = {}

local sqrt = math.sqrt
local pi = math.pi
local cos = math.cos
local sin = math.sin

local self = {}

--------------------------------------------------
-- Initialisation
--------------------------------------------------

function util.SetDefaultWrap(width, height)
	self.wrapWidth = width
	self.wrapHeight = height
end

--------------------------------------------------
-- Vector funcs
--------------------------------------------------

function util.LineGradient(l)
	if l[1][1] == l[2][1] then
		return false
	end
	return (l[2][2] - l[1][2]) / (l[2][1] - l[1][1])
end

function util.GradientPoints(u, v)
	if u[2] == v[2] then
		return false
	end
	return (v[2] - u[2]) / (v[1] - u[1])
end

function util.ExtremelyApproxEqNumber(n1, n2)
	return n1 and n2 and n1 - n2 < 10 and n2 - n1 < 10
end

function util.VeryApproxEqNumber(n1, n2)
	return n1 and n2 and n1 - n2 < 0.01 and n2 - n1 < 0.01
end

function util.ApproxEqNumber(n1, n2)
	return n1 and n2 and n1 - n2 < 0.000001 and n2 - n1 < 0.000001
end

function util.VeryApproxEq(u, v)
	return u and v and u[1] - v[1] < 0.001 and v[1] - u[1] < 0.001 and u[2] - v[2] < 0.001 and v[2] - u[2] < 0.001
end

function util.ExtremelyApproxEq(u, v)
	return u and v and u[1] - v[1] < 10 and v[1] - u[1] < 10 and u[2] - v[2] < 10 and v[2] - u[2] < 10
end

function util.Eq(u, v)
	return u and v and u[1] - v[1] < 0.000001 and v[1] - u[1] < 0.000001 and u[2] - v[2] < 0.000001 and v[2] - u[2] < 0.000001
end

function util.EqCircle(c, d)
	return util.Eq(c, d) and c[3] - d[3] < 0.000001 and d[3] - c[3] < 0.000001
end

local function FallbackCheck(l, m, EqNumber)
	local unitL = util.GetLineUnit(l)
	local unitM = util.GetLineUnit(m)
	local angle = util.GetAngleBetweenUnitVectors(unitL, unitM)
	if not (EqNumber(angle, 0) or EqNumber(angle, math.pi)) then
		return false
	end
	
	local distSq = util.DistanceToLineSq(l[1], m)
	if EqNumber(distSq, 0) then
		return true
	end
	return false
end

function util.EqLine(l, m, veryApprox)
	local Eq = (veryApprox and util.VeryApproxEq) or util.Eq
	if (Eq(l[1], m[1]) and Eq(l[2], m[2])) or
			(Eq(l[1], m[2]) and Eq(l[1], m[2])) then
		return true
	end
	local EqNumber = (veryApprox and util.VeryApproxEqNumber) or util.ApproxEqNumber
	-- Now begins the pain
	
	local gradL = util.LineGradient(l)
	local gradM = util.LineGradient(m)
	if (not gradL) or (not gradM) then
		if not (gradL or gradM) then
			return EqNumber(l[1][1], m[1][1])
		end
		return FallbackCheck(l, m, EqNumber)
	end
	if not EqNumber(gradL, gradM) then
		return FallbackCheck(l, m, EqNumber)
	end
	local intL = l[1][2] - gradL * l[1][1]
	local intM = m[1][2] - gradM * m[1][1]
	return EqNumber(intL, intM) or FallbackCheck(l, m, EqNumber)
end

function util.DistSqVectors(u, v)
	return util.DistSq(u[1], u[2], v[1], v[2])
end

function util.DistVectors(u, v)
	return util.Dist(u[1], u[2], v[1], v[2])
end

function util.DistSq(x1, y1, x2, y2)
	if y2 then
		return (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)
	end
	return util.DistSqVectors(x1, y1)
end

function util.LineLengthSq(l)
	return util.DistSqVectors(l[1], l[2])
end

function util.DistSqWithWrap(x1, y1, x2, y2, wrapX, wrapY)
	local smallestDistSq = false
	local si, sj = 0, 0
	for i = -1, 1 do
		for j = -1, 1 do
			local distSq = util.DistSq(x1, y1, x2 + i*wrapX, y2 + j*wrapY)
			if (not smallestDistSq) or distSq < smallestDistSq then
				smallestDistSq = distSq
				si, sj = i, j
			end
		end
	end
	return smallestDistSq, si, sj
end

function util.DistWithWrap(x1, y1, x2, y2, wrapX, wrapY)
	return math.sqrt(util.DistSqWithWrap(x1, y1, x2, y2, wrapX, wrapY))
end

function util.Dist(x1, y1, x2, y2)
	return sqrt(util.DistSq(x1,y1,x2,y2))
end

function util.Dist3D(x1,y1,z1,x2,y2,z2)
	return sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) + (z1 - z2)*(z1 - z2))
end

function util.Add(v1, v2)
	return {v1[1] + v2[1], v1[2] + v2[2]}
end

function util.Subtract(v1, v2)
	return {v1[1] - v2[1], v1[2] - v2[2]}
end

function util.SubtractWithWrap(v1, v2, wrapX, wrapY)
	-- Subtract is supposed to make the shortest from v2 to v1, so
	-- that other functions can find directions and unit vectors
	-- towards a target. This is the use case for this type of wrap.
	local xDiff = v1[1] - v2[1]
	local yDiff = v1[2] - v2[2]
	wrapX = wrapX or self.wrapWidth
	wrapY = wrapY or self.wrapHeight
	while xDiff > 0.5*wrapX do
		xDiff = xDiff - wrapX
	end
	while xDiff < -0.5*wrapX do
		xDiff = xDiff + wrapX
	end
	while yDiff > 0.5*wrapY do
		yDiff = yDiff - wrapY
	end
	while yDiff < -0.5*wrapY do
		yDiff = yDiff + wrapY
	end
	return {xDiff, yDiff}
end

function util.Mult(b, v)
	return {b*v[1], b*v[2]}
end

function util.AbsValSq(x, y, z)
	if z then
		return x*x + y*y + z*z
	elseif y then
		return x*x + y*y
	elseif x[3] then
		return x[1]*x[1] + x[2]*x[2] + x[3]*x[3]
	else
		return x[1]*x[1] + x[2]*x[2]
	end
end

function util.AbsVal(x, y, z)
	local value = util.AbsValSq(x, y, z)
	return value and sqrt(value)
end

function util.Unit(v)
	local mag = util.AbsVal(v)
	if mag > 0 then
		return {v[1]/mag, v[2]/mag}, mag
	else
		return v, mag
	end
end

function util.UnitTowards(from, to)
	local v, mag = util.Unit(util.Subtract(to, from))
	return v, mag
end

function util.UnitTowardsWithWrap(from, to, wrapX, wrapY)
	local smallestDistSq = false
	local si, sj = 0, 0
	for i = -1, 1 do
		for j = -1, 1 do
			local distSq = util.DistSq(from[1], from[2], to[1] + i*wrapX, to[2] + j*wrapY)
			if (not smallestDistSq) or distSq < smallestDistSq then
				smallestDistSq = distSq
				si, sj = i, j
			end
		end
	end
	local v, mag = util.Unit(util.Subtract({to[1] + si*wrapX, to[2] + sj*wrapY}, from))
	return v, mag
end

function util.SetLength(b, v)
	local mag = util.AbsVal(v)
	if mag > 0 then
		return {b*v[1]/mag, b*v[2]/mag}
	else
		return v
	end
end

function util.Angle(x, z)
	if not z then
		x, z = x[1], x[2]
	end
	if x == 0 and z == 0 then
		return 0
	end
	local mult = 1/util.AbsVal(x, z)
	x, z = x*mult, z*mult
	if z > 0 then
		return math.acos(x)
	elseif z < 0 then
		return 2*math.pi - math.acos(x)
	elseif x < 0 then
		return math.pi
	end
	-- x < 0
	return 0
end

function util.AngleFromPointToPoint(p1, p2)
	return util.Angle(util.Subtract(p2, p1))
end

function util.AngleFromPointToPointWithWrap(p1, p2, wrapX, wrapY)
	return util.Angle(util.SubtractWithWrap(p2, p1, wrapX, wrapY))
end

function util.Dot(v1, v2)
	if v1[3] then
		return v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3]
	else
		return v1[1]*v2[1] + v1[2]*v2[2]
	end
end

function util.Cross(v1, v2)
	return {v1[2]*v2[3] - v1[3]*v2[2], v1[3]*v2[1] - v1[1]*v2[3], v1[1]*v2[2] - v1[2]*v2[1]}
end

function util.Cross2D(v1, v2)
	return v1[1]*v2[2] - v1[2]*v2[1]
end

-- Projection of v1 onto v2
function util.Project(v1, v2)
	local uV2 = util.Unit(v2)
	return util.Mult(util.Dot(v1, uV2), uV2)
end

-- The normal of v1 onto v2. Returns such that v1 = normal + projection
function util.Normal(v1, v2)
	local projection = util.Project(v1, v2)
	return util.Subtract(v1, projection), projection
end

function util.GetAngleBetweenUnitVectors(u, v)
	return math.acos(util.Dot(u, v))
end

-- Get the average position between two vectors
function util.Average(u, v, uFactor)
	uFactor = uFactor or 0.5
	return util.Add(util.Mult(uFactor, util.Subtract(v, u)), u)
end

function util.AverageMulti(pointList)
	if #pointList == 0 then
		return false
	end
	local x = 0
	local y = 0
	for i = 1, #pointList do
		x = x + pointList[i][1]
		y = y + pointList[i][2]
	end
	return {
		x/#pointList,
		y/#pointList,
	}
end

function util.AverageScalar(u, v, uFactor)
	uFactor = uFactor or 0.5
	return u*(1 - uFactor) + v * uFactor
end

function util.AngleSubtractShortest(angleA, angleB)
	local dist = angleA - angleB
	if dist > 0 then
		if dist < pi then
			return dist
		end
		return dist - 2*pi
	else
		if dist > -pi then
			return dist
		end
		return dist + 2*pi
	end
end

function util.AngleAverageShortest(angleA, angleB)
	local diff = util.AngleSubtractShortest(angleA, angleB)
	return angleA - diff/2
end

function util.SignPreserveMax(val, mag)
	if val > mag then
		return mag
	end
	if val < -mag then
		return -mag
	end
	return val
end

function util.ExtendLine(line, length)
	local m = util.Average(line[1], line[2])
	local unit = util.UnitTowards(line[1], line[2])
	return {
		util.Add(m, util.Mult(-0.5 * length, unit)),
		util.Add(m, util.Mult(0.5 * length, unit)),
	}
end

function util.ArePointsConvex(points)
	if #points < 3 then
		return true
	end
	local n = #points
	local sign = false
	for i = 1, n do
		local a = points[i]
		local b = points[(i % n) + 1]
		local c = points[((i + 1) % n) + 1]
		local newSign = util.Cross2D(util.Subtract(a, b), util.Subtract(b, c))
		sign = sign or newSign
		if (sign > 0) ~= (newSign > 0) then
			return false
		end
	end
	return true
end

--------------------------------------------------
--------------------------------------------------
-- Transforms

function util.CartToPolar(v)
	return util.AbsVal(v), util.Angle(v)
end

function util.PolarToCart(mag, dir)
	return {mag*cos(dir), mag*sin(dir)}
end

function util.RotateVector(v, angle)
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)
	return {v[1]*cosAngle - v[2]*sinAngle, v[1]*sinAngle + v[2]*cosAngle}
end

function util.RotateVectorOrthagonal(v, angle)
	local cosAngle = math.floor(math.cos(angle) + 0.5)
	local sinAngle = math.floor(math.sin(angle) + 0.5)
	return {v[1]*cosAngle - v[2]*sinAngle, v[1]*sinAngle + v[2]*cosAngle}
end

function util.ReflectVector(v, angle)
	return {v[1]*math.cos(2*angle) + v[2]*math.sin(2*angle), v[1]*math.sin(2*angle) - v[2]*math.cos(2*angle)}
end

function util.DirectionToCardinal(direction, start, segments)
	start = start or 0
	segments = segments or 4
	return math.floor((direction + start + math.pi/segments) / (2*math.pi/segments)) % segments + 1
end

function util.CardinalToDirection(cardinal, start, segments)
	start = start or 0
	segments = segments or 4
	return cardinal * 2 * math.pi/segments + start 
end

function util.CardinalToVector(cardinal, length)
	length = length or 1
	if cardinal == 0 then
		return {length, 0}
	elseif cardinal == 1 then
		return {0, length}
	elseif cardinal == 2 then
		return {-length, 0}
	elseif cardinal == 3 then
		return {0, -length}
	end
end

function util.AngleToCardinal(angle, cardinal, start, segments)
	start = start or 0
	segments = segments or 4
	local cardinalAngle = (cardinal - 1)*math.pi*2/segments + start
	return cardinalAngle - angle
end

function util.InverseBasis(basis)
	local a, b, c, d = basis[1], basis[2], basis[3], basis[4]
	local det = a*d - b*c
	return {d/det, -b/det, -c/det, a/det}
end

function util.ChangeBasis(v, a, b, c, d)
	return {v[1]*a + v[2]*b, v[1]*c + v[2]*d}
end

--------------------------------------------------
--------------------------------------------------
-- Lines

function util.GetLineUnit(l)
	return util.Unit(util.Subtract(l[2], l[1]))
end

function util.RotateLineAroundOrigin(l, angle)
	return {
		util.RotateVector(l[1], angle),
		util.RotateVector(l[2], angle),
	}
end

function util.RotateCircleAroundOrigin(c, angle)
	local newPoint = util.RotateVector(c, angle)
	return {newPoint[1], newPoint[2], c[3]}
end

function util.GetAngleBetweenLines(l, m)
	local lu = util.GetLineUnit(l)
	local mu = util.GetLineUnit(m)
	local angle = util.GetAngleBetweenUnitVectors(lu, mu)
	if angle > math.pi/2 then
		angle = math.pi - angle
	end
	return angle
end

function util.GetBoundedLineIntersection(line1, line2)
	local x1, y1, x2, y2 = line1[1][1], line1[1][2], line1[2][1], line1[2][2]
	local x3, y3, x4, y4 = line2[1][1], line2[1][2], line2[2][1], line2[2][2]
	
	local denominator = ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4))
	if denominator == 0 then
		return false
	end
	local first = ((x1 - x3)*(y3 - y4) - (y1 - y3)*(x3 - x4))/denominator
	local second = -1*((x1 - x2)*(y1 - y3) - (y1 - y2)*(x1 - x3))/denominator
	
	if first < 0 or first > 1 or (second < 0 or second > 1) then
		return false
	end
	
	local px = x1 + first*(x2 - x1)
	local py = y1 + first*(y2 - y1)
	
	return {px, py}
end

function util.IsPositiveIntersect(lineInt, lineMid, lineDir)
	return util.Dot(util.Subtract(lineInt, lineMid), lineDir) > 0
end

function util.DistanceToBoundedLineSq(point, line)
	local startToPos = util.Subtract(point, line[1])
	local startToEnd = util.Subtract(line[2], line[1])
	local normal, projection = util.Normal(startToPos, startToEnd)
	local projFactor = util.Dot(projection, startToEnd)
	local normalFactor = util.Dot(normalFactor, startToEnd)
	if projFactor < 0 then
		return util.Dist(line[1], point)
	end
	if projFactor > 1 then
		return util.Dist(line[2], point)
	end
	return util.AbsValSq(util.Subtract(startToPos, normal)), normalFactor
end

function util.DistanceToBoundedLine2(point, line)
	local startToPos = util.Subtract(point, line[1])
	local startToEnd = util.Subtract(line[2], line[1])
	local normal, projection = util.Normal(startToPos, startToEnd)
	local projFactor = util.Dot(projection, startToEnd)
	if projFactor < 0 then
		return math.min(util.Dist(line[1], point), util.Dist(line[2], point))
	end
	if math.sqrt(projFactor) > util.AbsVal(startToEnd) then
		return math.min(util.Dist(line[1], point), util.Dist(line[2], point))
	end
	return util.AbsVal(normal)
end

function util.DistanceToBoundedLine(point, line)
	local distSq, normalFactor = util.DistanceToBoundedLineSq(point, line)
	return sqrt(distSq), normalFactor
end

function util.DistanceToLineSq(point, line)
	local startToPos = util.Subtract(point, line[1])
	local startToEnd = util.Subtract(line[2], line[1])
	local normal, projection = util.Normal(startToPos, startToEnd)
	return util.AbsValSq(normal)
end

function util.GetCircleLineIntersectionPoints(circle, line)
	local startToPos = util.Subtract(circle, line[1])
	local startToEnd = util.Subtract(line[2], line[1])
	local normal, projection = util.Normal(startToPos, startToEnd)
	local distSq = util.AbsValSq(normal)
	local radiusSq = circle[3] * circle[3]
	if distSq > radiusSq + 0.0000001 then
		return false
	end
	-- We now do pythagoras on half the isosceles triangle formed by
	-- the centre of the circle and its intersections with the line.
	-- We also ignore the issue of degeneracy.
	local innerProjLength = (distSq < radiusSq and sqrt(radiusSq - distSq)) or 0
	local innerProj = util.SetLength(innerProjLength, projection)
	local closestPoint = util.Add(line[1], projection)
	return {
		util.Add(closestPoint, innerProj),
		util.Subtract(closestPoint, innerProj),
	}
end

function util.GetCircleIntersectionPoints(c, d)
	local midToMid = util.Subtract(d, c)
	local distSq = util.AbsValSq(midToMid)
	--print("distSq", distSq - (c[3] + d[3])*(c[3] + d[3]))
	if distSq > (c[3] + d[3])*(c[3] + d[3]) + 0.01 or distSq < 0.0001 then
		return
	end
	
	local rSubFactor = (c[3]*c[3] - d[3]*d[3]) / distSq
	local rAddFactor = (c[3]*c[3] + d[3]*d[3]) / distSq
	local determinantSq = 2 * rAddFactor - rSubFactor*rSubFactor - 1
	--print("determinantSq", determinantSq)
	if determinantSq < 0 then
		if determinantSq > -0.0001 then
			determinantSq = 0
		else
			return
		end
	end
	local perpFactor = 0.5 * sqrt(determinantSq)
	
	local mid = {
		0.5*(c[1] + d[1]) + 0.5 * rSubFactor * (d[1] - c[1]),
		0.5*(c[2] + d[2]) + 0.5 * rSubFactor * (d[2] - c[2]),
	}
	local perp = {
		(d[2] - c[2]) * perpFactor,
		(c[1] - d[1]) * perpFactor,
	}
	return {
		util.Add(mid, perp),
		util.Subtract(mid, perp),
	}
end

--------------------------------------------------
--------------------------------------------------
-- Rectangles

function util.IntersectingRectangles(x1, y1, w1, h1, x2, y2, w2, h2)
	return ((x1 + w1 >= x2 and x1 <= x2) or (x2 + w2 >= x1 and x2 <= x1)) and ((y1 + h1 >= y2 and y1 <= y2) or (y2 + h2 >= y1 and y2 <= y1))
end

function util.PosInRectangle(pos, x1, y1, w1, h1)
	return (x1 + w1 >= pos[1] and x1 <= pos[1]) and (y1 + h1 >= pos[2] and y1 <= pos[2])
end

--------------------------------------------------
--------------------------------------------------
-- Circles

function util.PosInCircle(pos1, pos2, radius)
	local distSq = util.DistSq(pos1, pos2)
	if distSq <= radius*radius then
		return true, distSq
	end
end

function util.IntersectingCircles(pos1, radius1, pos2, radius2)
	local distSq = util.DistSqVectors(pos1, pos2)
	if distSq <= (radius1 + radius2)*(radius1 + radius2) then
		return true, distSq
	end
end

--------------------------------------------------
--------------------------------------------------
-- Group Utilities

function util.Permute(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

--------------------------------------------------
--------------------------------------------------
-- Probability

function util.WeightsToDistribution(weights)
	local sum = 0
	for i = 1, #weights do
		sum = sum + weights[i]
	end
	local normWeights = {}
	for i = 1, #weights do
		 normWeights[i] =  weights[i]/sum
	end
	return normWeights
end

function util.GenerateBoundedRandomWeight(bounds, rngIn)
	local rngFunc = rngIn or math.random
	local weights = {}
	for i = 1, #bounds do
		weights[i] = bounds[i][1] + rngFunc()*(bounds[i][2] - bounds[i][1])
	end
	return weights
end

function util.GenerateDistributionFromBoundedRandomWeights(bounds, rngIn)
	local weights = util.GenerateBoundedRandomWeight(bounds, rngIn)
	return util.WeightsToDistribution(weights)
end

function util.SampleList(list)
	if (not list) or (#list == 0) then
		return false, false
	end
	local index = math.floor(math.random()*#list) + 1
	return list[index], index
end

function util.SampleMap(map)
	local size = 0
	for _, _ in pairs(map) do
		size = size + 1
	end
	for k, v in pairs(map) do
		size = size - 1
		if size == 0 then
			return v, k
		end
	end
	return false
end

function util.SampleDistribution(distribution, rngIn)
	local rngFunc = rngIn or math.random
	local value = rngFunc()
	for i = 1, #distribution do
		if value < distribution[i] then
			return i
		end
		value = value - distribution[i]
	end
	return #distribution
end

function util.RandomPointInRectangle(pos, width, height, angle)
	local rectPoint = {(math.random() - 0.5) * width, (math.random() - 0.5) * height}
	if angle then
		rectPoint = util.RotateVector(rectPoint, angle)
	end
	return util.Add(pos, rectPoint)
end

function util.RandomPointInCircle(radius, startAngle, endAngle)
	startAngle = startAngle or 0
	endAngle = endAngle or 2*pi
	
	local r = math.random()
	local angle = startAngle + math.random()*(endAngle - startAngle)
	return util.PolarToCart(radius*math.sqrt(r), angle)
end

function util.RandomPointInAnnulus(innerRadius, outerRadius, startAngle, endAngle)
	startAngle = startAngle or 0
	endAngle = endAngle or 2*pi
	
	local minRadiusProp = math.sqrt(innerRadius/outerRadius)
	local r = minRadiusProp + math.random()*(1 - minRadiusProp)
	local angle = startAngle + math.random()*(endAngle - startAngle)
	return util.PolarToCart(outerRadius*math.sqrt(r), angle)
end

function util.RandomPointInEllipse(width, height, startAngle, endAngle)
	startAngle = startAngle or 0
	endAngle = endAngle or 2*pi
	
	local r = math.random()
	local angle = startAngle + math.random()*(endAngle - startAngle)
	local pos = util.PolarToCart(math.sqrt(r), angle)
	pos[1] = pos[1]*width
	pos[2] = pos[2]*height
	return pos
end

function util.GetRandomCardinalDirection()
	if math.random() < 0.5 then
		if math.random() < 0.5 then
			return {1, 0}
		else
			return {-1, 0}
		end
	else
		if math.random() < 0.5 then
			return {0, 1}
		else
			return {0, -1}
		end
	end
end

function util.GetRandomKingDirection()
	if math.random() < 0.5 then
		return util.GetRandomCardinalDirection()
	else
		if math.random() < 0.5 then
			if math.random() < 0.5 then
				return {1, 1}
			else
				return {1, -1}
			end
		else
			if math.random() < 0.5 then
				return {-1, 1}
			else
				return {-1, -1}
			end
		end
	end
end

function util.GetRandomAngle()
	return math.random()*2*pi
end

function util.GetRandomPermutation(size)
	local myList = {}
	for i = 1, size do
		myList[i] = i
	end
	util.Permute(myList)
	return myList
end

--------------------------------------------------
--------------------------------------------------
-- Nice Functions

function util.SmoothZeroToOne(value, factor)
	factor = factor or 1
	local minVal = 1 / (1 + math.exp( - factor * (-0.5)))
	local maxVal = 1 / (1 + math.exp( - factor * (0.5)))
	return (1 / (1 + math.exp( - factor * (value - 0.5))) - minVal) / (maxVal - minVal)
end

function util.SmoothStep(startRange, endRange, value, factor)
	if value < startRange then
		return 0
	end
	if value > endRange then
		return 1
	end
	value = (value - startRange)/(endRange - startRange)
	return util.SmoothZeroToOne(value, factor)
end

function util.Round(x, near)
	near = near or 1
	return math.floor((x + near*0.5)/near)*near
end

function util.RoundDown(x, near)
	near = near or 1
	return math.floor(x/near)*near
end

--------------------------------------------------
--------------------------------------------------
-- Time

function util.SecondsToString(seconds, dashForEmpty)
	if (seconds or 0) == 0 and dashForEmpty then
		return "-"
	end
	if seconds <= 0 then
		return "0:00"
	end
	local hours = math.floor(seconds/3600)
	local minutes = math.floor(seconds/60)%60
	local seconds = math.floor(seconds)%60
	
	if hours > 0 then
		return string.format("%d:%02.f:%02.f", hours, minutes, seconds)
	end
	return string.format("%d:%02.f", minutes, seconds)
end

function util.UpdateProportion(dt, value, speed)
	if value then
		value = value + speed*dt
		if value > 1 then
			value = false
		end
	end
	return value
end

function util.UpdateTimer(timer, dt)
	if not timer then
		return false
	end
	timer = timer - dt
	if timer < 0 then
		return false
	end
	return timer
end

--------------------------------------------------
--------------------------------------------------
-- Table Utilities

function util.TableKeysToList(keyTable, indexToKey)
	local list = {}
	for i = 1, #indexToKey do
		list[i] = keyTable[indexToKey[i]]
	end
	return list
end

local TableToStringHelper
local function AddTableLine(nameRaw, value, newIndent, indentAdd, delimiter, lineFunc, orderPreference, inlineConf, depth)
	local name = nameRaw and tostring(nameRaw)
	if name and type(nameRaw) == "number" then
		name = "[" .. name .. "]"
	end
	local name = name and (name .. " = ") or ""
	
	local ty = type(value)
	if ty == "userdata" then
		lineFunc("warning, userdata")
	end
	if ty == "table" then
		if depth and depth <= 0 then
			lineFunc(newIndent .. name .. "{...}" .. delimiter)
		else
			if inlineConf and nameRaw and inlineConf[nameRaw] then
				lineFunc(newIndent .. name .. "{")
				local retStr = ""
				local function AddLine(str)
					retStr = retStr .. str
				end
				TableToStringHelper(value, true, "", "", " ", AddLine, orderPreference, inlineConf, depth and (depth - 1))
				lineFunc(string.sub(retStr, 0, -3))
				lineFunc("},\n")
			else
				lineFunc(newIndent .. name .. "{" .. delimiter)
				TableToStringHelper(value, true, newIndent, indentAdd, delimiter, lineFunc, orderPreference, inlineConf, depth and (depth - 1))
				lineFunc(newIndent .. "}," .. delimiter)
			end
		end
	elseif ty == "function" then
		lineFunc(newIndent .. name .. " = function" .. delimiter)
	elseif ty == "boolean" then
		lineFunc(newIndent .. name .. (value and "true," or "false,") .. delimiter)
	elseif ty == "string" then
		lineFunc(newIndent .. name .. [["]] .. string.gsub(string.gsub(value, "\n", "\\n"), "\t", "\\t") .. [[",]] .. delimiter)
	elseif ty == "number" then
		lineFunc(newIndent .. name .. value .. ",".. delimiter)
	else
		lineFunc(newIndent .. name , value .. delimiter)
	end
end

function TableToStringHelper(data, tableChecked, newIndent, indentAdd, delimiter, lineFunc, orderPreference, inlineConf, depth)
	newIndent = (newIndent or "") .. indentAdd
	local alreadyAdded = {}
	for i = 1, #data do
		if not data[i] then
			break
		end
		AddTableLine(false, data[i], newIndent, indentAdd, delimiter, lineFunc, orderPreference, inlineConf, depth)
		alreadyAdded[i] = true
	end
	
	if orderPreference then
		for i = 1, #orderPreference do
			local nameRaw = orderPreference[i]
			if data[nameRaw] then
				AddTableLine(nameRaw, data[nameRaw], newIndent, indentAdd, delimiter, lineFunc, orderPreference, inlineConf, depth)
				alreadyAdded[nameRaw] = true
			end
		end
	end
	
	local remainingKeys = {}
	for nameRaw, value in pairs(data) do
		if not (alreadyAdded and alreadyAdded[nameRaw]) then
			remainingKeys[#remainingKeys + 1] = nameRaw
		end
	end
	
	table.sort(remainingKeys)
	for i = 1, #remainingKeys do
		local nameRaw = remainingKeys[i]
		AddTableLine(nameRaw, data[nameRaw], newIndent, indentAdd, delimiter, lineFunc, orderPreference, inlineConf, depth)
	end
end

function util.TableToString(data, orderPreference, inlineConf)
	local str = ""
	local function Append(newLine)
		str = str .. newLine
	end
	Append("{\n")
	TableToStringHelper(data, false, false, "\t", "\n", Append, orderPreference, inlineConf)
	Append("}\n")
	return str
end

function util.PrintTable(data, depth)
	indent = indent or ""
	if (not tableChecked) and type(data) ~= "table" then
		print(data)
		return
	end
	TableToStringHelper(data, true, false, "\t", "", print, false, false, depth)
end

function util.CopyTable(tableToCopy, deep, appendTo)
	local copy = appendTo or {}
	for key, value in pairs(tableToCopy) do
		if (deep and type(value) == "table") then
			copy[key] = util.CopyTable(value, true, appendTo and copy[key])
		else
			if not copy[key] then
				copy[key] = value
			end
		end
	end
	return copy
end

function util.ListToMask(listTable)
	local mapTable = {}
	for i = 1, #listTable do
		mapTable[listTable[i]] = true
	end
	return mapTable
end

function util.AddKeyNameToMaps(mapOfMaps, keyName)
	for k, v in pairs(mapOfMaps) do
		v[keyName] = k
	end
	return mapOfMaps
end

function util.ListContains(list, element, EqualityCheck)
	for i = 1, #list do
		if EqualityCheck(element, list[i]) then
			return true
		end
	end
	return false
end

function util.ListRemoveMutable(list, id)
	for i = 1, #list do
		if list[i].id == id then
			list[i] = list[#list]
			list[#list] = nil
			return true
		end
	end
	return false
end

--------------------------------------------------
--------------------------------------------------
-- Array Utilities

function util.ScaleArray(arrayToScale, scalar)
	local copy = {}
	for i = 1, #arrayToScale do
		copy[i] = arrayToScale[i] * scalar
	end
	return copy
end

--------------------------------------------------
--------------------------------------------------

function util.GetDefDirList(dir, ext)
	local files = love.filesystem.getDirectoryItems(dir)
	local defList = {}
	for i = 1, #files do
		if (not ext) or ext == string.sub(files[i], -3, -1) then
			local name = string.sub(files[i], 0, -5)
			defList[#defList + 1] = name
		end
	end
	return defList
end

function util.LoadDefDirectory(dir, nameByKey)
	local files = love.filesystem.getDirectoryItems(dir)
	local defTable = {}
	local nameList = {}
	for i = 1, #files do
		local name = string.sub(files[i], 0, -5)
		nameList[#nameList + 1] = name
		defTable[name] = love.filesystem.load(dir .. "/" .. name .. ".lua")()
		defTable[name].name = name
	end
	
	-- Loop for multiple inheritence
	local done = false
	while not done do
		done = true
		for i = 1, #nameList do
			local name = nameList[i]
			if defTable[name].inheritFrom then
				defTable[name] = util.CopyTable(defTable[defTable[name].inheritFrom], true, defTable[name])
				defTable[name].inheritFrom = nil
				done = false
			end
		end
	end
	if nameByKey then
		defTable = util.AddKeyNameToMaps(defTable, nameByKey)
	end
	return defTable, nameList
end

function util.LoadDefNames(path)
	local defs = love.filesystem.load(path .. ".lua")()
	local defNames = {}
	for i = 1, #defs do
		defs[i].index = i
		defNames[defs[i].name] = defs[i]
	end
	return defs, defNames
end

--------------------------------------------------
--------------------------------------------------

return util
