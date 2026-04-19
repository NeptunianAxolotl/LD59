
local BuildingDefs = util.LoadDefDirectory("defs/building")

local function CalculateWorldPos(self)
	return {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
end

local function FindRoadSpawn(self, pos)
	pos = pos or self.pos
	for i = 0, 3 do
		local road = TerrainHandler.GetRoadAtPos(pos, i)
		if road and self.def.spawnRoads[road.def.name] then
			return road
		end
	end
end

local function SpawnRegularCar(self)
	if not self.roadSpawn then
		return
	end
	--if not roadUtil.IsOccupied(self, occupyVector) then
	--	CarHandler.AddCar(self.def.spawnCar.carType, self.pos, (self.def.spawnCar.entry + self.rotation)%4)
	--end
	local roadPos = self.roadSpawn.GetPos()
	local targetBuilding = BuildingHandler.GetRandomMatchingBuilding("highway", self.buildingID)
	local targetRoadPos = targetBuilding.roadSpawn.GetPos()
	local direction = carUtil.GetBestMatchingDirectionTowards(roadPos, targetRoadPos, self.roadSpawn.worldEntryFilter)
	CarHandler.AddCar(self.def.spawnCar.carType, roadPos, targetRoadPos, (direction - 2)%4, direction)
end

local function NewBuilding(self)
	self.def = BuildingDefs[self.buildingType]
	
	self.toDestroy = false
	self.worldPos = CalculateWorldPos(self)
	self.roadSpawn = FindRoadSpawn(self)
	
	function self.GetPos()
		return self.pos
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
	
	function self.MatchAndExcludeID(buildingType, excludeID)
		return (self.buildingID ~= excludeID) and (self.buildingType == buildingType)
	end
	
	function self.Export(objList)
		local exportData = {pos = self.pos, buildingType = self.buildingType}
		objList[#objList + 1] = exportData
	end
	
	function self.UpdateWorldPos()
		self.worldPos = {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
	end
	
	function self.Update(dt)
		if self.toDestroy then
			return true
		end
		if self.def.updateFunc then
			self.def.updateFunc(self, dt)
		end
		self.spawnTimer = (self.spawnTimer or self.def.spawnCar.baseRate) - dt
		if self.spawnTimer <= 0 then
			SpawnRegularCar(self)
			self.spawnTimer = self.def.spawnCar.baseRate * (1 + 0.2 * math.random())
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
				Resources.DrawImage(self.def.baseImage, self.worldPos[1], self.worldPos[2], self.worldRot, false, LevelHandler.TileScale())
				if self.def.extraDrawFunc then
					self.def.extraDrawFunc(self, self.worldPos, self.worldRot)
				end
				if Global.DRAW_DEBUG then
					if self.roadSpawn then
						local roadPos = self.roadSpawn.GetWorldPos()
						love.graphics.setLineWidth((self.spawnTimer or 0)*10)
						love.graphics.setColor(0, 0.8, 0, 0.8)
						love.graphics.line(self.worldPos[1], self.worldPos[2], roadPos[1], roadPos[2])
					end
				end
			end})
		end
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return NewBuilding