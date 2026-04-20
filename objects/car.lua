
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
	self.currentRoad = road
	self.currentRoadPos = road.GetPos()
	self.roadWorldPos = road.GetWorldPos()
	self.roadWorldRot = road.GetWorldRotation()
	self.currentPath = newPath
	self.destination = newDestination
	
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
				self.arriveTravelReq = self.currentPath.length - 0.35
				self.arriveWrongSide = true
			end
		end
	end
	
	self.nextRoad = TerrainHandler.GetRoadAtPos(self.currentRoadPos, self.destination)
	if self.nextRoad then
		self.nextRoadEntry = (self.nextRoad.rotation + self.destination)%4
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
	return self.wobblePos * 0.6, -self.wobbleAccel*2.8
end

local function WobbleSpeedMult(self)
	if not (self.def.wobble and self.wobblePos) then
		return 1
	end
	return 1 / (1 + math.abs(self.wobblePos)*10)
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
		else
			unit = util.RotateVector(unit, 0.12)
		end
	end
	local thirdRayLength = 28
	if self.currentPath.turn == "straight" and self.wantTurn ~= "right" then
		thirdRayLength = 52
	end
	if (self.maxSpeedMult or 1) > 1 then
		rayLength = rayLength * (self.maxSpeedMult or 1)
	end
	
	self.secondRay = {}
	self.secondRay[1] = util.Add(self.pos, util.Mult(12, util.RotateVector(baseUnit, -0.8)))
	self.secondRay[2] = util.Add(self.secondRay[1], util.Mult(thirdRayLength, util.RotateVector(baseUnit, sideRayRotate * 0.5)))
	
	self.thirdRay = {}
	self.thirdRay[1] = util.Add(baseRay, util.Mult(6, util.RotateVector(baseUnit, 1.55)))
	self.thirdRay[2] = util.Add(self.thirdRay[1], util.Mult(22, util.RotateVector(baseUnit, sideRayRotate)))
	
	self.ray[2] = util.Add(self.ray[1], util.Mult(rayLength, unit))
	rayWasHit = false
	world:rayCast(self.ray[1][1], self.ray[1][2], self.ray[2][1], self.ray[2][2], RayHit)
	if self.secondRay then
		world:rayCast(self.secondRay[1][1], self.secondRay[1][2], self.secondRay[2][1], self.secondRay[2][2], RayHit)
	end
	world:rayCast(self.thirdRay[1][1], self.thirdRay[1][2], self.thirdRay[2][1], self.thirdRay[2][2], RayHit)
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
	if travelRemaining > 0.95 and signalBlocked then
		return true, signalBlocked
	end
	return false, signalBlocked
end

local function CheckNextRoadStop(self)
	if not self.nextRoad or self.nextRoad.toDestroy or not self.nextRoad.signal or not self.nextRoadEntry then
		return false
	end
	local travelRemaining = 1 - self.travel / self.currentPath.length
	if self.currentPath.turn == "left" then
		travelRemaining = travelRemaining * 0.4
	end
	local myLightsBlocked = self.nextRoad.SignalActive(self.nextRoadEntry)
	if travelRemaining < 0.2 * (self.maxSpeedMult or 1) and myLightsBlocked then
		return true
	end
	return false
end

local function CheckStopSignal(self)
	local currentBlocked, sneakingThrough = CheckCurrentRoadStop(self)
	if self.def.ignoreSignal then
		return false, sneakingThrough
	end
	local nextBlocked = CheckNextRoadStop(self)
	if currentBlocked then
		self.currentRoad.WaitingCar(self.currentPath.entry)
	elseif currentBlocked then
		self.nextRoad.WaitingCar(self.nextRoadEntry)
	end
	return currentBlocked or nextBlocked, sneakingThrough
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
		self.travel = Global.SPAWN_TRAVEL + 0.05
	end
	return true
end

local function LookOutForCollision(self)
	if self.def.ignoreCollision then
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

local function NewCar(self, new_gridPos, targetPos, targetBuildingPos, wrongSideSpawn, carID, entry, dest, fullSpeed)
	self.def = CarDefs[self.carType]
	
	self.spawnTimer = (not fullSpeed) and Global.SPAWN_FADE_TIME
	self.travel = fullSpeed and 0 or Global.SPAWN_TRAVEL
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
	
	self.body = love.physics.newBody(PhysicsHandler.GetPhysicsWorld(), self.pos[1], self.pos[2], "dynamic")
	local shape = love.physics.newRectangleShape(self.def.length, self.def.width)
	self.fixture = love.physics.newFixture(self.body, shape, 1)
	self.body:setLinearDamping(Global.BODY_DAMPENING)
	self.body:setAngularDamping(Global.BODY_DAMPENING*0.75)
	local physicsData = {carID = carID}
	self.fixture:setUserData(physicsData)
	
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
	
	function self.Crash()
		self.isCrashed = true
	end
	
	function self.AddCrashProgress(progress)
		if self.isCrashed then
			return
		end
		local newCrash = not self.crashProgress
		self.crashProgress = (self.crashProgress or 0) + progress
		if newCrash or math.random() < 0.03 then
			EffectsHandler.SpawnEffect("popup", self.pos, {text = string.format("%d", self.crashProgress * 10), velocity = {0, -2}})
		end
	end
	
	local function UpdateMovement(dt)
		if self.isCrashed or (self.crashProgress and self.crashProgress > self.def.crashEndurance * Global.CRASH_THRESHOLD_MULT) then
			self.isCrashed = true
			return
		end
		
		UpdateWobble(self, dt)
		local oldTravel = self.travel
		local spawn = 1 - (self.spawnTimer or 0) / Global.SPAWN_FADE_TIME
		local allBlocked, someBlocked = false, false
		local stopOffset = 0
		local deccelMult = (self.maxSpeedMult or 1)
		local maxSpeed = (self.maxSpeedMult or 1) * self.def.maxSpeed * spawn * WobbleSpeedMult(self)
		local mult = spawn
		
		self.signalBlocked, self.sneakingThrough = CheckStopSignal(self)
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
		local vel = util.PolarToCart(self.speed*Global.BODY_SPEED, self.rotation)
		self.body:setLinearVelocity(vel[1], vel[2])
	end
	
	local function UpdateCrash(dt)
		if not self.isCrashed then
			return
		end
		local x, y = self.body:getPosition()
		self.pos = {x, y}
		self.rotation = self.body:getAngle()
		self.crashTimer = self.crashTimer or Global.CRASH_FADEOUT
		self.crashTimer = util.UpdateTimer(self.crashTimer, dt)
		if not self.crashTimer then
			self.toDestroy = true
		end
	end
	
	function self.Update(dt)
		if self.toDestroy then
			DoDestroy(self)
			return true
		end
		self.spawnTimer = util.UpdateTimer(self.spawnTimer, dt)
		self.crashProgress = util.UpdateTimer(self.crashProgress, dt)
		self.arriveTimer, self.arrived = util.UpdateTimer(self.arriveTimer, dt)
		if self.arrived then
			self.arrived = false
			self.arriveAtTarget = false
			local visitMightReturn = self.targetBuildingPos and BuildingHandler.VisitBuilding(targetBuildingPos, self)
			if (not visitMightReturn) or self.returning or (not self.def.returnAfterVisit) or not FindReturnAfterVisit(self) then
				self.toDestroy = true
				DoDestroy(self)
				return true
			end
		end
		UpdateMovement(dt)
		UpdateCrash(dt)
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=0; f=function()
			if not self.toDestroy then
				local alpha = 1 - (self.spawnTimer or 0) / Global.SPAWN_FADE_TIME
				if self.arriveTimer and ((not self.def.returnAfterVisit) or self.returning) then
					alpha = (self.arriveTimer or 0) / Global.ARRIVE_FADE_TIME
				end
				if self.crashTimer and self.crashTimer < 1 then
					alpha = alpha * self.crashTimer
				end
				Resources.DrawImage(self.def.image, self.pos[1], self.pos[2], self.rotation, alpha, LevelHandler.TileScale())
				if DrawDebug() then
					if self.ray and not self.signalBlocked then
						if self.sneakingThrough then
							love.graphics.setLineWidth(3)
							love.graphics.setColor(0.8, 0.8, 0, 0.8)
						elseif self.collision then
							love.graphics.setLineWidth(4)
							love.graphics.setColor(0.8, 0, 0, 0.8)
						else
							love.graphics.setLineWidth(2)
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
