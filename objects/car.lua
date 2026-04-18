
local CarDefs = util.LoadDefDirectory("defs/cars")

local function PickTurnOption(self, road, entry)
	local turnOptions = road.GetTurnOptions(self.def.choiceRatio, entry)
	local turnSelected = turnOptions and util.NormaliseAndSampleWeightedList(turnOptions)
	turnSelected = turnSelected and turnSelected.path.turn
	return turnSelected
end

local function EnterRoad(self, road, entry, dest)
	if not road then
		return false
	end
	if not self.wantTurn then
		self.wantTurn = PickTurnOption(self, road, entry)
	end
	local newPath, newDestination = road.GetPathAndNextRoad(self.wantTurn, entry, dest)
	if not newPath then
		return false
	end
	self.currentRoad = road
	self.roadWorldPos = road.GetWorldPos()
	self.roadWorldRot = road.GetWorldRotation()
	self.currentPath = newPath
	self.destination = newDestination
	
	self.prevDriveOffset = self.driveOffset
	self.driveOffset = Global.DRIVE_OFFSET
	local nextRoad = TerrainHandler.GetRoadAtPos(self.currentRoad.GetPos(), self.destination)
	if nextRoad then
		self.wantTurn = PickTurnOption(self, nextRoad, (newDestination - 2)%4)
		if self.wantTurn == "right" and nextRoad.IsIntersection() then
			self.driveOffset = Global.DRIVE_OFFSET * 0.05
		end
	end
	return true
end


local function GetPathDraw(self, path, worldPos, worldRot, travel)
	local worldPos = util.Add(worldPos, util.Mult(LevelHandler.TileSize(), util.RotateVector(path.posFunc(travel, self.prevDriveOffset, self.driveOffset), worldRot)))
	return worldPos, worldRot + path.dirFunc(travel)
end

local function NewCar(self, new_gridPos, entry, dest)
	self.def = CarDefs[self.carType]
	
	self.travel = 0
	self.speed = 1.2
	self.toDestroy = false
	self.driveOffset = Global.DRIVE_OFFSET
	self.prevDriveOffset = Global.DRIVE_OFFSET
	EnterRoad(self, TerrainHandler.GetRoadAtPos(new_gridPos), entry, dest)
	
	function self.SetCarrying(newCarry)
		self.cargo = newCarry
	end
	
	local function UpdateMovement(dt)
		local oldTravel = self.travel
		local allBlocked, someBlocked = false, false
		local stopOffset = 0
		local deccelMult = 1
		local mult = 1
		
		local travelFullSpeed = true
		local wantStop = false
		if travelFullSpeed then
			self.speed = math.min(self.def.maxSpeed, self.speed + dt*self.def.accel*mult)
		else
			if (self.speed > -0.05 and wantStop) or (self.speed > 0.5 and not wantStop) then
				if (self.travel > 0.4 + stopOffset or self.speed > 0.15) or self.travel > 0.55 + stopOffset then
					self.speed = self.speed - dt*self.def.deccel*mult*deccelMult
				end
			end
			
			if self.speed < 0.05 then
				if self.travel < 0.52 + stopOffset then
					self.speed = 0.15
				elseif self.travel < 0.6 + stopOffset then
					self.speed = 0
				end
			end
			if (self.speed < 0.5 and not wantStop) then
				self.speed = math.min(self.def.maxSpeed, self.speed + dt*self.def.accel*mult)
			end
		end
		local travelChange = dt*self.speed*mult
		self.travel = self.travel + travelChange
		if not travelFullSpeed then
			if self.travel >= 0.92 + stopOffset then
				self.speed = -0.2
				if self.travel >= 0.99 + stopOffset then
					self.travel = 0.99 + stopOffset
				end
			end
		end
		if self.travel >= self.currentPath.length then
			local nextRoad = TerrainHandler.GetRoadAtPos(self.currentRoad.GetPos(), self.destination)
			self.travel = self.travel - self.currentPath.length
			if not EnterRoad(self, nextRoad, (self.destination + 2)%4) then
				self.toDestroy = true
			end
		end
	end
	
	function self.Update(dt)
		if self.toDestroy then
			return true
		end
		UpdateMovement(dt)
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=0; f=function()
			if not self.toDestroy then
				local drawPos, drawRotation = GetPathDraw(self, self.currentPath, self.roadWorldPos, self.roadWorldRot, self.travel)
				Resources.DrawImage(self.def.image, drawPos[1], drawPos[2], drawRotation, false, LevelHandler.TileScale())
			end
		end})
		
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return NewCar
