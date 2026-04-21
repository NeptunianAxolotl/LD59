
local CarDefs = util.LoadDefDirectory("defs/cars")

local function PickTurnOption(self, road, targetPos, entry)
	targetPos = targetPos and (math.random() >= self.def.wrongTurnChance) and targetPos
	if targetPos then
		local bestDirection = carUtil.GetBestMatchingDirectionTowards(road.GetPos(), targetPos, road.worldDestinationFilter, entry)
		local newPath, newDestination = road.GetPathAndNextRoad(false, entry, bestDirection)
		if newPath then
			return newPath.turn, newPath
		end
		--print("bestDirection", bestDirection, "rot", road.rotation, "entry", entry)
		--error("Custom Message") 
	end
	local turnOptions = road.GetTurnOptions(self.def.choiceRatio, entry)
	local pathSelected = turnOptions and util.NormaliseAndSampleWeightedList(turnOptions)
	local turnSelected = pathSelected and pathSelected.path.turn
	return turnSelected, (pathSelected and pathSelected.path)
end

local function CheckArriveWrongSide(self, building, entry)
	if not (building and building.roadDirectionFromSelf) then
		return false
	end
	local direction = (entry + 2)%4
	local wrongSideEntry = (direction%4 ~= (building.roadDirectionFromSelf - 1)%4)
	return wrongSideEntry
end

local function EnterRoad(self, road, entry)
	if not road then
		return false
	end
	if not self.wantTurn then
		self.wantTurn = PickTurnOption(self, road, self.targetPos, entry)
	end
	local newPath, newDestination = road.GetPathAndNextRoad(self.wantTurn, entry)
	if not newPath then
		return false
	end
	-- Enough movement to move
	if self.currentRoad and self.blockedInFrontTime and self.blockedInFrontTime > Global.SWEAR_AT_LIGHT_TIME then
		self.currentRoad.blockedInFrontTime = math.max(self.blockedInFrontTime*Global.BLOCK_TIMER_TO_ROAD, self.currentRoad.blockedInFrontTime or 0)
	end
	self.blockedInFrontTime = false
	self.blockedInFront = false
	self.onRoadTimer = 0
	
	self.currentRoad = road
	self.currentRoadPos = road.GetPos()
	self.roadWorldPos = road.GetWorldPos()
	self.roadWorldRot = road.GetWorldRotation()
	self.currentPath = newPath
	self.destination = newDestination
	
	self.blockedInFrontTime = road.blockedInFrontTime
	self.blockedInFront = false
	
	
	self.prevDriveOffset = self.driveOffset
	self.driveOffset = Global.DRIVE_OFFSET
	if util.Eq(self.currentRoadPos, self.targetPos) then
		self.arriveAtTarget = true
		local building = BuildingHandler.GetBuildingAtPos(self.targetBuildingPos)
		self.arriveTravelReq = Global.ARRIVE_TRAVEL
		if building and not building.def.arriveWithoutTurn then
			self.driveOffset = Global.SPAWN_OFFSET
			if CheckArriveWrongSide(self, building, entry) then
				self.destination = (self.destination + 2)%4
				self.currentPath = roadUtil.GetWrongSideArrivePath(self, entry, dest, self.roadWorldRot)
				self.arriveTravelReq = self.currentPath.length - 0.32
				self.arriveWrongSide = true
			end
		end
	end
	
	self.nextRoad = TerrainHandler.GetRoadAtPos(self.currentRoadPos, self.destination)
	if self.nextRoad then
		self.nextRoadEntry = (self.destination - self.nextRoad.rotation - 2)%4
		self.wantTurn, self.nextPath = PickTurnOption(self, self.nextRoad, self.targetPos, (newDestination - 2)%4)
		if self.wantTurn == "right" and self.nextRoad.IsIntersection() then
			self.driveOffset = Global.DRIVE_OFFSET * (self.currentPath.centreLimit or 0.05)
		elseif self.wantTurn == "straight" and self.nextRoad.IsIntersection() then
			self.driveOffset = Global.DRIVE_OFFSET * 1.1
		end
	else
		self.nextPath = false
		self.nextRoadEntry = false
	end
	if self.currentPath and self.nextPath and not self.def.ignoreRoadSpeed then
		self.maxSpeedMult = math.min(self.currentPath.speedMult or 1, self.nextPath.speedMult or 1)
	else
		self.maxSpeedMult = 1
	end
	return true
end

local function UpdateWobble(self, dt)
	if not self.def.wobble then
		return
	end
	local wobble = self.def.wobble
	self.wobbleAccel = (self.wobbleAccel or 0)
	self.wobblePos = (self.wobblePos or 0)
	self.wobbleAccel = self.wobbleAccel - (self.wobbleAccel*0.7 + math.random() - 0.5)*dt*wobble*4
	self.wobblePos = self.wobblePos + (self.wobbleAccel*5 - self.wobblePos)*dt
end

local function ApplyWobble(self)
	if not (self.def.wobble and self.wobblePos) then
		return 0, 0
	end
	return math.max(-0.1, math.min(0.1, self.wobblePos)) * 0.6, -self.wobbleAccel*2.8
end

local function WobbleSpeedMult(self)
	if not (self.def.wobble and self.wobblePos) then
		return 1
	end
	return 1 / (1 + math.min(0.1, math.abs(self.wobblePos))*10)
end

local function GetPositionOnRoad(self, path, worldPos, worldRot, travel)
	if not path then
		self.toDestroy = true
		return
	end
	local wobblePos, wobbleRot = ApplyWobble(self)
	local pathPos = path.posFunc(travel, self.prevDriveOffset + wobblePos, self.driveOffset + wobblePos)
	local worldPos = util.Add(worldPos, util.Mult(LevelHandler.TileSize(), util.RotateVector(pathPos, worldRot)))
	return worldPos, worldRot + path.dirFunc(travel) + wobbleRot
end

local rayWasHit = false
local function RayHit()
	rayWasHit = true
	return 0
end

local function CheckImpendingCollision(self)
	local world = PhysicsHandler.GetPhysicsWorld()
	local unit = util.PolarToCart(1, self.rotation)
	local baseUnit = util.PolarToCart(1, self.rotation)
	local rayStart = self.def.length/2 + self.def.rayStart
	self.secondRay = false
	self.ray = {}
	self.ray[1] = util.Add(self.pos, util.Mult(rayStart, unit))
	local baseRay = self.ray[1]
	local rayLength = self.def.rayLength
	local travelRemaining = 1 - self.travel / self.currentPath.length
	self.suddenStop = false
	--if self.currentPath.trafficFromRight and travelRemaining > 0.9 and false then
		--self.ray[1] = util.Add(self.ray[1], util.Mult(24, util.RotateVector(unit, 1.3)))
		--unit = util.RotateVector(unit, -1.3)
		--rayLength = self.def.rayTurnLength
		--self.suddenStop = 4
	
	local sideRayRotate = 0
	local secondRayLength = 25
	local thirdRayLength = 20
	
	if self.currentPath.turn == "left" then
		unit = util.RotateVector(unit, -1.2 * travelRemaining)
		rayLength = self.def.rayTurnLength
		sideRayRotate = -0.5 * travelRemaining
	elseif self.currentPath.turn == "right" then
		sideRayRotate = 0.5 * travelRemaining
		if self.currentPath.acrossTraffic then
			if travelRemaining > 0.65 and not self.sneakingThrough then
				self.ray[1] = util.Add(self.ray[1], util.Mult(26*math.min(travelRemaining, 0.9)/0.9, util.RotateVector(unit, 0.8)))
				rayLength = self.def.crossTrafficRay
				unit = util.RotateVector(unit, math.min(travelRemaining, 0.9)*2.45 - 2.1)
				thirdRayLength = false
			else
				self.ray[1] = util.Add(self.ray[1], util.Mult(6, util.RotateVector(unit, -0.6)))
				rayLength = rayLength
			end
		elseif self.wantTurn == "left" then
			rayLength = self.def.rayLength * 0.8
			self.secondRay = {}
			self.secondRay[1] = self.ray[1]
			self.secondRay[2] = util.Add(self.ray[1], util.Mult(rayLength, util.RotateVector(unit, 0.4 * travelRemaining)))
			self.ray[1] = util.Add(self.ray[1], util.Mult(8, util.RotateVector(unit, -0.8)))
			unit = util.RotateVector(unit, 0.1 - (1 - travelRemaining) * 0.5)
		else
			rayLength = self.def.rayTurnLength
			unit = util.RotateVector(unit, 0.6 * travelRemaining)
		end
	else
		if self.wantStop then
			rayLength = rayLength * 0.7
		elseif self.stoppedTimer then
			rayLength = rayLength * 0.35
		end
		if (self.prevDriveOffset or 0) > (self.driveOffset or 0) and self.driveOffset < Global.DRIVE_OFFSET then -- Going to centre.
			unit = util.RotateVector(unit, 0.23)
		end
	end
	
	local secondRayRotate = sideRayRotate * 0.5
	if self.currentPath.turn == "straight" and self.wantTurn ~= "right" then
		secondRayLength = 32
	elseif self.currentPath.turn == "left" then
		secondRayLength = 30
		thirdRayLength = 14
		secondRayRotate = -0.85
	end
	if self.currentPath and self.nextPath and not self.currentPath.trafficFromLeft and not self.nextPath.trafficFromLeft and self.currentPath.turn == "straight" then
		secondRayRotate = sideRayRotate * 0.5 - 0.5
		secondRayLength = 45
	end
	if (self.maxSpeedMult or 1) > 1 then
		rayLength = rayLength * (self.maxSpeedMult or 1)
	end
	
	self.secondRay = {}
	self.secondRay[1] = util.Add(self.pos, util.Mult(9, util.RotateVector(baseUnit, -0.8)))
	self.secondRay[2] = util.Add(self.secondRay[1], util.Mult(secondRayLength, util.RotateVector(baseUnit, secondRayRotate)))
	
	if thirdRayLength then
		self.thirdRay = {}
		self.thirdRay[1] = util.Add(baseRay, util.Mult(8, util.RotateVector(baseUnit, 1.55)))
		self.thirdRay[2] = util.Add(self.thirdRay[1], util.Mult(thirdRayLength, util.RotateVector(baseUnit, sideRayRotate)))
	else
		self.thirdRay = false
	end
	
	self.ray[2] = util.Add(self.ray[1], util.Mult(rayLength, unit))
	rayWasHit = false
	world:rayCast(self.ray[1][1], self.ray[1][2], self.ray[2][1], self.ray[2][2], RayHit)
	if self.secondRay then
		world:rayCast(self.secondRay[1][1], self.secondRay[1][2], self.secondRay[2][1], self.secondRay[2][2], RayHit)
	end
	if thirdRayLength then
		world:rayCast(self.thirdRay[1][1], self.thirdRay[1][2], self.thirdRay[2][1], self.thirdRay[2][2], RayHit)
	end
	return rayWasHit
end

local function CheckCurrentRoadStop(self)
	if not self.currentRoad or self.currentRoad.toDestroy or not self.currentRoad.signal then
		return false, false
	end
	local travelRemaining = 1 - self.travel / self.currentPath.length
	if self.currentPath.turn == "left" then
		travelRemaining = travelRemaining*1.1
	end
	local signalBlocked = self.currentRoad.SignalActive(self.currentPath.entry)
	local sneaking = signalBlocked or self.currentRoad.SignalActive((self.currentPath.entry - 2)%4)
	if travelRemaining > 0.95 and signalBlocked then
		return true, sneaking
	end
	return false, sneaking
end

local function CheckNextRoadStop(self)
	if not self.nextRoad or self.nextRoad.toDestroy or not self.nextRoad.signal or not self.nextRoadEntry then
		return false
	end
	local travelRemaining = 1 - self.travel / self.currentPath.length
	if self.currentPath.turn == "left" then
		travelRemaining = travelRemaining * 0.6
	end
	local myLightsBlocked = self.nextRoad.SignalActive(self.nextRoadEntry)
	if travelRemaining < 0.18 * (self.maxSpeedMult or 1) and myLightsBlocked then
		return true, myLightsBlocked
	end
	return false, myLightsBlocked
end

local function CheckStopSignal(self)
	local currentBlocked, sneakingThrough = CheckCurrentRoadStop(self)
	if self.def.ignoreSignal then
		return false, sneakingThrough
	end
	local nextBlocked, blockedInFront = CheckNextRoadStop(self)
	if currentBlocked then
		self.currentRoad.WaitingCar(self.currentPath.entry)
	elseif currentBlocked then
		self.nextRoad.WaitingCar(self.nextRoadEntry)
	end
	return currentBlocked or nextBlocked, sneakingThrough, blockedInFront
end

local function FindReturnAfterVisit(self)
	local targetBuilding = BuildingHandler.GetRandomMatchingBuilding(self.def.returnAfterVisit)
	if not (targetBuilding and targetBuilding.roadSpawn) then
		return false
	end
	self.targetPos = targetBuilding.roadSpawn.GetPos()
	self.targetBuildingPos = targetBuilding.pos
	self.returning = true
	self.driveOffset = Global.DRIVE_OFFSET
	self.prevDriveOffset = Global.RETURN_SPAWN_OFFSET * 0.75
	
	if self.arriveWrongSide then
		if self.currentRoad then
			self.currentPath = self.currentRoad.GetPathAndNextRoad(false, (self.destination + 2)%4)
		end
		self.wantTurn = false
		self.travel = Global.SPAWN_TRAVEL
		self.prevDriveOffset = Global.RETURN_SPAWN_OFFSET * 0.75
	end
	return true
end

local function LookOutForCollision(self)
	if self.def.ignoreCollision or self.ignoreCollisionTimer then
		return false
	end
	if self.collision and self.currentPath and self.currentPath.ignoreCollisionUntil and self.travel < self.currentPath.ignoreCollisionUntil then
		return false
	end
	if self.collision and self.currentPath and self.currentPath.ignoreCollisionAfter and self.travel > self.currentPath.ignoreCollisionAfter then
		return false
	end
	return true
end

local function DoDestroy(self)
	if self.body then
		self.body:destroy()
		self.body = nil
	end
	if not self.alreadyDestroyed then
		if self.def.onDestroy then
			self.def.onDestroy(self)
		end
		self.alreadyDestroyed = true
	end
end

local function UpdateMovement(self, dt)
	if self.isCrashed or (self.crashProgress and self.crashProgress > self.def.crashEndurance * Global.CRASH_THRESHOLD_MULT) then
		self.Crash()
		return
	end
	
	UpdateWobble(self, dt)
	local oldTravel = self.travel
	local spawn = 1 - (self.spawnTimer or 0) / Global.SPAWN_FADE_TIME
	local allBlocked, someBlocked = false, false
	local stopOffset = 0
	local deccelMult = (self.maxSpeedMult or 1)
	local maxSpeed = (self.maxSpeedMult or 1) * (self.def.maxSpeed + self.speedRand) * spawn * WobbleSpeedMult(self)
	local mult = spawn
	
	self.signalBlocked, self.sneakingThrough, self.blockedInFront = CheckStopSignal(self)
	
	self.collision = LookOutForCollision(self) and CheckImpendingCollision(self)
	self.wantStop = self.collision or self.signalBlocked
	if self.arriveTimer or (self.arriveAtTarget and self.travel > self.arriveTravelReq) then
		self.wantStop = true
		if not self.arriveWrongSide then
			self.travel = Global.ARRIVE_TRAVEL
		end
		self.arriveTimer = self.arriveTimer or Global.ARRIVE_FADE_TIME
	end
	local rapidDecel = self.collision and self.suddenStop
	if rapidDecel then
		deccelMult = deccelMult * self.suddenStop
	end
	local travelFullSpeed = not self.wantStop
	if travelFullSpeed then
		if self.speed > maxSpeed*1.01 then
			self.speed = math.max(maxSpeed, self.speed - dt*self.def.slowDeccel*mult*deccelMult)
		else
			self.speed = math.min(maxSpeed, self.speed + dt*self.def.accel*mult)
		end
	else
		if (self.speed > 0 and self.wantStop) then
			self.speed = self.speed - dt*self.def.deccel*mult*deccelMult
		end
		
		if self.speed < 0.05 then
			self.speed = 0
		end
		if (self.speed < 0.5 and not self.wantStop) then
			self.speed = math.min(maxSpeed, self.speed + dt*self.def.accel*mult)
		end
	end
	if self.stoppedTimer or self.speed == 0 then
		self.stoppedTimer = ((self.speed == 0 or not self.stoppedTimer) and self.def.stopTimer or self.stoppedTimer) - dt
		if self.stoppedTimer <= 0 then
			self.stoppedTimer = false
		end
	end
	local travelChange = dt*self.speed*mult
	self.travel = self.travel + travelChange
	if self.travel >= self.currentPath.length and not self.arriveTimer then
		local nextRoad = TerrainHandler.GetRoadAtPos(self.currentRoadPos, self.destination)
		self.travel = self.travel - self.currentPath.length
		if not EnterRoad(self, nextRoad, (self.destination + 2)%4) then
			self.toDestroy = true
		end
	end
	self.pos, self.rotation = GetPositionOnRoad(self, self.currentPath, self.roadWorldPos, self.roadWorldRot, self.travel)
	self.body:setPosition(self.pos[1], self.pos[2])
	self.body:setAngle(self.rotation)
	local speed = self.ignoreCollisionTimer and Global.ANGRY_SPEED or Global.BODY_SPEED
	local vel = util.PolarToCart(self.speed*speed, self.rotation)
	self.body:setLinearVelocity(vel[1], vel[2])
end

local function UpdateCrash(self, dt)
	if not self.isCrashed then
		return
	end
	local x, y = self.body:getPosition()
	self.pos = {x, y}
	self.rotation = self.body:getAngle()
	self.crashTimer = self.crashTimer or Global.CRASH_FADEOUT
	self.crashTimer = util.UpdateTimer(self.crashTimer, dt)
	if math.random() < (0.021 * (0.5 + 0.5 * (self.crashTimer or 0)/Global.CRASH_FADEOUT))*dt*300 then
		EffectsHandler.SpawnEffect(self.crashEffect or "fireball_explode", self.pos, {scale = 0.05 + math.random()*0.1})
	end
	if not self.crashTimer then
		self.toDestroy = true
	end
end

local function UpdateBlocked(self, dt)
	self.onRoadTimer = (self.onRoadTimer or 0) + dt
	if self.onRoadTimer > Global.ON_SAME_ROAD_ANGRY_TIMER then
		self.blockedInFront = true
		if not self.blockedInFrontTime then
			self.blockedInFrontTime = Global.SWEAR_AT_LIGHT_TIME
		end
	end
	if self.blockedInFront then
		self.blockedInFrontTime = (self.blockedInFrontTime or 0) + dt*GameHandler.GetLevelRate("forceRedLight")
	elseif self.blockedInFrontTime then
		self.blockedInFrontTime = self.blockedInFrontTime - dt*GameHandler.GetLevelRate("forceRedLight")*0.6
		if self.blockedInFrontTime < 0 then
			self.blockedInFrontTime = false
		end
	end
	if not self.blockedInFrontTime then
		return
	end
	if self.blockedInFrontTime > Global.SWEAR_AT_LIGHT_TIME then
		local chance = dt*4*math.pow((self.blockedInFrontTime - Global.SWEAR_AT_LIGHT_TIME) / Global.RUN_RED_LIGHT_TIME, 1.3)
		if math.random() < chance then
			EffectsHandler.SpawnEffect("angry_popup", self.pos, {text = "$#%@", velocity = {0, -0.3 - 0.6*math.random()}})
		end
	end
	
	if self.blockedInFrontTime > Global.RUN_RED_LIGHT_TIME then
		local nextRoad = TerrainHandler.GetRoadAtPos(self.currentRoadPos, self.destination)
		if not self.ignoreCollisionTimer and self.blockedInFrontTime > Global.IGNORE_COLLISION_ANGRY_TIME then
			self.ignoreCollisionTimer = Global.IGNORE_COLLISION_WHILE_ANGRY_FOR
		end
		if nextRoad then
			nextRoad.ForceSignal(self.destination, Global.FORCE_SIGNAL_TIME)
		end
	end
end

local function SetColorFromHouse(self)
	if not self.def.imageSelection then
		return false
	end
	local building = self.targetBuildingPos and BuildingHandler.GetBuildingAtPos(self.targetBuildingPos)
	if building and building.image and self.def.imageSelection[building.image] then
		self.image = self.def.imageSelection[building.image]
		return true
	end
	return false
end

local function SetMyImage(self)
	self.image = self.def.image
	if self.def.randomImage then
		self.image = util.SampleList(self.def.randomImage)
	end
end

local function NewCar(self, new_gridPos, targetPos, targetBuildingPos, wrongSideSpawn, carID, entry, dest, fullSpeed)
	self.def = CarDefs[self.carType]
	
	self.speedRand = math.random()*self.def.speedRand
	self.spawnTimer = (not fullSpeed) and Global.SPAWN_FADE_TIME
	self.travel = fullSpeed and (math.random()*0.6) or Global.SPAWN_TRAVEL
	self.speed = fullSpeed and self.def.maxSpeed or 0
	self.toDestroy = false
	self.driveOffset = Global.DRIVE_OFFSET
	self.targetPos = targetPos
	self.targetBuildingPos = targetBuildingPos
	EnterRoad(self, TerrainHandler.GetRoadAtPos(new_gridPos), entry, dest)
	if not fullSpeed then
		self.prevDriveOffset = Global.SPAWN_OFFSET -- Side of the road
		if wrongSideSpawn then
			self.travel = 0
			self.currentPath = roadUtil.GetWrongSideSpawnPath(self, entry, dest, self.roadWorldRot)
		end
	end
	self.pos, self.rotation = GetPositionOnRoad(self, self.currentPath, self.roadWorldPos, self.roadWorldRot, self.travel)
	
	if not SetColorFromHouse(self) then
		SetMyImage(self)
	end
	
	if self.pos then
		self.body = love.physics.newBody(PhysicsHandler.GetPhysicsWorld(), self.pos[1], self.pos[2], "dynamic")
		local shape = love.physics.newRectangleShape(self.def.length, self.def.width)
		self.fixture = love.physics.newFixture(self.body, shape, 1)
		self.body:setLinearDamping(Global.BODY_DAMPENING)
		self.body:setAngularDamping(Global.BODY_DAMPENING*0.9)
		local physicsData = {carID = carID}
		self.fixture:setUserData(physicsData)
	end
	
	function self.IsDestroyed()
		return self.toDestroy
	end
	
	function self.GetDef()
		return self.def
	end
	
	function self.GetSpeed()
		return self.speed
	end
	
	function self.DoHardBrake()
		self.speed = 0
	end
	
	function self.OnSamePath(other)
		if other and not self.isCrashed and not other.isCrashed then
			if util.Eq(other.currentRoadPos, self.currentRoadPos) then
				local mP = self.currentPath
				local oP = other.currentPath
				if mP and oP and mP.entry == oP.entry and mP.destination == oP.destination then
					return true
				end
			end
		end
		return false
	end
	
	function self.Crash(fakeCrash)
		if not self.isCrashed and not fakeCrash then
			GameHandler.AddStat("accidents")
			GameHandler.ResetStat("doctorVisitHouse_sinceAccident")
			GameHandler.ResetStat("returnedToDoctor_sinceAccident")
			GameHandler.ResetStat("drunkArrivals_sinceAccident")
			if self.def.isDrunk then
				GameHandler.ResetStat("drunkArrivals_sinceDrunkAccident")
			end
			EffectsHandler.SpawnEffect("fireball_explode", self.pos, {scale = 0.2 + math.random()*0.1})
		end
		self.isCrashed = true
	end
	
	function self.GetArrested(policeCar)
		self.Crash(true)
		self.isArrested = true
		GameHandler.ResetStat("drunkArrivals_sinceCaught")
		GameHandler.AddStat("arrests")
		self.crashEffect = "police_explode"
	end
	
	function self.CountIfMatch(toMatch)
		return (self.carType == toMatch) and 1
	end
	
	function self.AddCrashProgress(progress)
		if self.isCrashed then
			return
		end
		local newCrash = not self.crashProgress
		self.crashProgress = (self.crashProgress or 0) + progress *(self.ignoreCollisionTimer and Global.ANGRY_CRASH_RESIST or 1)
		if newCrash or math.random() < 0.03 then
			EffectsHandler.SpawnEffect("fireball_explode", self.pos, {spawnRadius = 12, scale = 0.1 + math.random()*0.03})
		end
	end
	
	function self.Update(dt)
		if self.toDestroy then
			DoDestroy(self)
			return true
		end
		self.spawnTimer = util.UpdateTimer(self.spawnTimer, dt)
		self.crashProgress = util.UpdateTimer(self.crashProgress, dt)
		self.ignoreCollisionTimer = util.UpdateTimer(self.ignoreCollisionTimer, dt)
		self.arriveTimer, self.arrived = util.UpdateTimer(self.arriveTimer, dt)
		if self.arrived then
			self.arrived = false
			self.arriveAtTarget = false
			if self.def.onArrive then
				local building = self.targetBuildingPos and BuildingHandler.GetBuildingAtPos(self.targetBuildingPos)
				self.def.onArrive(self, building)
			end
			local visitMightReturn = self.targetBuildingPos and BuildingHandler.VisitBuilding(targetBuildingPos, self)
			if (not visitMightReturn) or self.returning or (not self.def.returnAfterVisit) or not FindReturnAfterVisit(self) then
				self.toDestroy = true
				DoDestroy(self)
				return true
			end
		end
		if self.def.isDrunk then
			if math.random() < 10*dt then
				EffectsHandler.SpawnEffect("drunk_popup", self.pos, {velocity = util.Add({0, -0.2 - 0.5*math.random()}, util.RandomPointInCircle(0.15))})
			end
		end
		if self.sickness then
			self.sickness = self.sickness + dt*Global.SICK_PROGRESS_RATE*GameHandler.GetLevelRate("sickness")
			if self.sickness > 1 then
				self.sickDeathTimer = self.sickDeathTimer or Global.SICK_DEATH_TIME
				self.sickDeathTimer = util.UpdateTimer(self.sickDeathTimer, dt)
				if not self.sickDeathTimer then
					EffectsHandler.SpawnEffect("sickness_popup", self.pos, {velocity = {0, -0.3 - 0.6*math.random()}})
					GameHandler.AddStat("sickDeaths")
				end
			end
		else
			self.sickDeathTimer = nil
		end
		if self.def.policeRadius then
			local drunkCar = CarHandler.GetNearbyDrunk(self.pos, self.def.policeRadius)
			if drunkCar then
				drunkCar.GetArrested()
				EffectsHandler.SpawnEffect("police_explode", self.pos, {scale = self.def.policeRadius/160})
			end
		end
		UpdateMovement(self, dt)
		UpdateCrash(self, dt)
		UpdateBlocked(self, dt)
		if self.def.isPolice then
			local chance = dt*GameHandler.GetLevelRate("policeHighlight")*2
			if math.random() < chance then
				EffectsHandler.SpawnEffect("police_popup", self.pos, {text = "!!", velocity = {0, -0.3 - 0.6*math.random()}})
			end
		end
		
		if self.def.animate then
			self.anim = (self.anim or 0) + dt
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[1]*0.001 + self.pos[2]*0.0001 - (self.def.behind or 0); f=function()
			if not self.toDestroy then
				local alpha = 1 - (self.spawnTimer or 0) / Global.SPAWN_FADE_TIME
				if self.arriveTimer and ((not self.def.returnAfterVisit) or self.returning) then
					alpha = (self.arriveTimer or 0) / Global.ARRIVE_FADE_TIME
				end
				if self.crashTimer and self.crashTimer < 1 then
					alpha = alpha * self.crashTimer
				end
				local color = {1, 1, 1}
				if self.sickness then
					color[1] = 1 - 0.9* math.max(0, self.sickness*0.1)
					color[3] = color[1]
				end
				Resources.DrawImage(self.image, self.pos[1], self.pos[2], self.rotation, alpha, LevelHandler.TileScale(), color)
				if self.def.animate and not self.isCrashed then
					local aIndex = (self.anim or 0)%0.3 > 0.15 and 1 or 2
					Resources.DrawImage(self.def.animate[aIndex], self.pos[1], self.pos[2], self.rotation, alpha, LevelHandler.TileScale())
				end
				if self.targetBuildingPos and self.def.drawTargetPos then
					local draw = LevelHandler.GridToWorld(self.targetBuildingPos)
					love.graphics.setLineWidth(1)
					love.graphics.setColor(0.8, 0.8, 0.8, 0.35)
					love.graphics.line(self.pos[1], self.pos[2], draw[1], draw[2])
				end
				if DrawDebug() then
					--if self.nextRoad and self.nextRoadEntry and self.nextRoad.SignalActive(self.nextRoadEntry) then
					--	love.graphics.setLineWidth(3)
					--	love.graphics.setColor(1, 0, 1, 0.8)
					--	love.graphics.circle("fill", self.pos[1], self.pos[2], 10)
					--end
					if self.ray and not self.signalBlocked then
						love.graphics.setLineWidth(1)
						if self.sneakingThrough then
							love.graphics.setColor(0.8, 0.8, 0, 0.8)
						elseif self.collision then
							love.graphics.setColor(0.8, 0, 0, 0.8)
						else
							love.graphics.setColor(0, 0.8, 0, 0.8)
						end
						love.graphics.line(self.ray[1][1], self.ray[1][2], self.ray[2][1], self.ray[2][2])
					end
					if self.secondRay and not self.signalBlocked then
						love.graphics.line(self.secondRay[1][1], self.secondRay[1][2], self.secondRay[2][1], self.secondRay[2][2])
					end
					if self.thirdRay and not self.signalBlocked then
						love.graphics.line(self.thirdRay[1][1], self.thirdRay[1][2], self.thirdRay[2][1], self.thirdRay[2][2])
					end
				end
				if DrawDebug() then
					if self.targetPos then
						local draw = LevelHandler.GridToWorld(self.targetPos)
						love.graphics.setLineWidth(1)
						love.graphics.setColor(0.8, 0.8, 0.8, 0.5)
						love.graphics.line(self.pos[1], self.pos[2], draw[1], draw[2])
					end
				end
			end
		end})
		
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return NewCar
