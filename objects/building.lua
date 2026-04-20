
local BuildingDefs = util.LoadDefDirectory("defs/building")

local function CalculateWorldPos(self)
	return {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
end

local function FindRoadSpawn(self, pos)
	if not self.def.exitRoadTypes then
		return
	end
	pos = pos or self.pos
	for i = 2, 0, -2 do
		local road = TerrainHandler.GetRoadAtPos(pos, i)
		if road and self.def.exitRoadTypes[road.def.name] then
			return road, i
		end
	end
	for i = 3, 1, -2 do
		local road = TerrainHandler.GetRoadAtPos(pos, i)
		if road and self.def.exitRoadTypes[road.def.name] then
			return road, i
		end
	end
end

local function GetSpawnTime(self)
	if not self.def.spawnCar then
		return
	end
	return self.def.spawnCar.baseRate * (1 - self.def.spawnCar.randomProp * math.random())
end

local function SpawnRegularCar(self)
	if not self.roadSpawn then
		return false
	end
	local roadPos = self.roadSpawn.GetPos()
	if not GameHandler.CarSpawnAllowed(self.def.spawnCar.carType) then
		return false
	end
	local targetType = GameHandler.GetTargetType(self.def.spawnCar.targets)
	if not targetType then
		return false
	end
	local targetBuilding = BuildingHandler.GetRandomMatchingBuilding(targetType.target, self.buildingID, self.def.spawnMatchFunc)
	if not (targetBuilding and targetBuilding.roadSpawn) then
		return false
	end
	local targetRoadPos = targetBuilding.roadSpawn.GetPos()
	local direction = carUtil.GetBestMatchingDirectionTowards(roadPos, targetRoadPos, self.roadSpawn.worldEntryFilter)
	local wrongSideSpawn = (direction%4 ~= (self.roadDirectionFromSelf - 1)%4)
	
	local checkSpawn = (not self.def.spawnWhenBlocked)
	local blockedSpawn = checkSpawn and roadUtil.IsOccupied(self.roadSpawn, roadUtil.GetClearZone((direction - self.roadSpawn.rotation)%4))
	if blockedSpawn then
		if self.def.spawnOtherIfBlocked and wrongSideSpawn then
			direction = (direction - 2)%4
			wrongSideSpawn = false
			if roadUtil.IsOccupied(self.roadSpawn, roadUtil.GetClearZone((direction - self.roadSpawn.rotation)%4)) then
				return false
			end
		else
			return false
		end
	end
	-- Check this side of the road too.
	if wrongSideSpawn and checkSpawn and roadUtil.IsOccupied(self.roadSpawn, roadUtil.GetClearZone((direction - 2 - self.roadSpawn.rotation)%4)) then
		return false
	end
	
	CarHandler.AddCar(self.def.spawnCar.carType, roadPos, targetRoadPos, targetBuilding.GetPos(), wrongSideSpawn, (direction - 2)%4, direction, self.def.spawnCar.spawnFullSpeed)
	if self.def.onDispatchCar then
		self.def.onDispatchCar(self, targetBuilding)
	end
	return true
end

local function NewBuilding(self)
	self.def = BuildingDefs[self.buildingType]
	
	self.toDestroy = false
	self.worldPos = CalculateWorldPos(self)
	self.roadSpawn, self.roadDirectionFromSelf = FindRoadSpawn(self)
	
	function self.GetPos()
		return self.pos
	end
	
	function self.FindRoad()
		self.roadSpawn, self.roadDirectionFromSelf = FindRoadSpawn(self)
	end
	
	function self.GetWorldRotation()
		return self.worldRot
	end
	
	function self.GetWorldPos()
		return self.worldPos
	end
	
	function self.UpdateWorldPos()
		self.worldPos = CalculateWorldPos()
	end
	
	function self.MatchAndExcludeID(buildingType, excludeID, matchFunc)
		return (self.buildingID ~= excludeID) and ((not buildingType) or self.buildingType == buildingType) and not self.toDestroy and ((not matchFunc) or matchFunc(self))
	end
	
	function self.Export(objList)
		if self.def.noExport then
			return
		end
		local exportData = {pos = self.pos, buildingType = self.buildingType}
		objList[#objList + 1] = exportData
	end
	
	function self.UpdateWorldPos()
		self.worldPos = {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
	end
	
	function self.Visited(car)
		if car.def.cureSickness and self.sickness then
			self.sickness = false
			self.medicOnTheWayTimer = false
			return true -- Medic needs to return
		end
	end
	
	function self.Update(dt)
		if self.toDestroy then
			return true
		end
		if self.def.updateFunc then
			self.def.updateFunc(self, dt)
		end
		if self.sickness then
			self.sickness = self.sickness + dt*GameHandler.GetLevelRate("sickness")
			if self.sickness > 1 then
				
			end
		end
		self.medicOnTheWayTimer = util.UpdateTimer(self.medicOnTheWayTimer, dt)
		if self.def.spawnCar then
			self.spawnTimer = (self.spawnTimer or GetSpawnTime(self)) - dt * GameHandler.GetLevelRate(self.buildingType)
			if self.spawnTimer <= 0 then
				if SpawnRegularCar(self) then
					self.spawnTimer = GetSpawnTime(self)
				else
					self.spawnTimer = math.random()*0.5
				end
			end
		end
	end
	
	function self.Draw(drawQueue)
		if self.def.baseImage then
			if self.def.onlyDrawInEditMode then
				if not LevelHandler.InEditMode() then
					return
				end
			end
			drawQueue:push({y=-90 + self.pos[2]*0.01; f=function()
				local image = self.def.baseImage
				local color = {1, 1, 1}
				if self.sickness then
					color[1] = 1 - 0.9* math.max(0, self.sickness*0.1)
					color[3] = color[1]
				end
				Resources.DrawImage(image, self.worldPos[1], self.worldPos[2], self.worldRot, false, LevelHandler.TileScale(), color)
				if self.def.extraDrawFunc then
					self.def.extraDrawFunc(self, self.worldPos, self.worldRot)
				end
				if DrawDebug() then
					if self.roadSpawn then
						local roadPos = self.roadSpawn.GetWorldPos()
						love.graphics.setLineWidth((self.spawnTimer or 0)*10)
						love.graphics.setColor(0, 0.8, 0, 0.8)
						love.graphics.line(self.worldPos[1], self.worldPos[2], roadPos[1], roadPos[2])
					end
					if self.isDrunk then
						Font.SetSize(4)
						love.graphics.setColor(0, 0, 0, 1)
						love.graphics.printf("DR", self.worldPos[1], self.worldPos[2], 50, "center")
					end
					if self.sickness then
						Font.SetSize(4)
						love.graphics.setColor(0, 0, 0, 1)
						love.graphics.printf(string.format("%.2f", self.sickness), self.worldPos[1], self.worldPos[2] - 20, 50, "center")
					end
					--if self.roadSpawn then
					--	local direction = 2
					--	if roadUtil.IsOccupied(self.roadSpawn, roadUtil.GetClearZone((direction - self.roadSpawn.rotation)%4)) then
					--		love.graphics.setLineWidth(3)
					--		love.graphics.setColor(1, 0, 1, 0.8)
					--		love.graphics.circle("fill", self.worldPos[1], self.worldPos[2], 10)
					--	end
					--end
				end
			end})
		end
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return NewBuilding