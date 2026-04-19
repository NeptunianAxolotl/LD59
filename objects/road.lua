
local RoadDefs = util.LoadDefDirectory("defs/road")

local function CalculateWorldPos(self)
	return {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
end

local function NewRoad(self, terrain)
	self.def = RoadDefs[self.roadType]
	
	if self.def.entryUseIndexMap then
		self.inUse = {}
	else
		self.inUse = false
	end
	self.toDestroy = false
	self.state = 1
	self.stopSignal = self.def.hasSignal and 1 or false
	self.signalTime = self.stopSignal and self.def.signalTimeMax[self.stopSignal]
	
	self.worldPos = CalculateWorldPos(self)
	self.worldRot = self.rotation*math.pi/2
	self.worldEntryFilter = {}
	for i = 1, #self.def.paths do
		local path = self.def.paths[i]
		self.worldEntryFilter[(path.entry + self.rotation)%4] = true
	end
	
	function self.GetTurnOptions(choiceRatio, entry)
		local roadSpaceEntry = (entry - self.rotation)%4
		local choices = {}
		for i = 1, #self.def.paths do
			local path = self.def.paths[i]
			if (roadSpaceEntry == path.entry) then
				local worldSpaceDest = (path.destination + self.rotation)%4
				choices[#choices + 1] = {
					probability = choiceRatio[path.turn],
					path = path,
					worldSpaceDest = worldSpaceDest,
				}
			end
		end
		return choices
	end
	
	function self.GetPathAndNextRoad(wantTurn, entry, dest)
		local roadSpaceEntry = (entry - self.rotation)%4
		local roadSpaceDest = dest and (dest - self.rotation)%4
		local choices = {}
		for i = 1, #self.def.paths do
			local path = self.def.paths[i]
			if (roadSpaceEntry == path.entry) and ((not wantTurn) or wantTurn == path.turn) and ((not roadSpaceDest) or roadSpaceDest == path.destination) then
				local worldSpaceDest = (path.destination + self.rotation)%4
				return path, worldSpaceDest
			end
		end
		if wantTurn then
			return self.GetPathAndNextRoad(false, entry, dest)
		end
		return false
	end
	
	function self.OrangeSignal()
		return self.orangeSignalTime
	end
	
	function self.ShouldTrainSlow(train)
		if self.def.trainSlowFunc then
			return self.def.trainSlowFunc(self, train)
		end
	end
	
	function self.SetUsedState(newState, entry)
		if self.def.entryUseIndexMap then
			entry = (entry - self.rotation)%4
			self.inUse[self.def.entryUseIndexMap[entry]] = newState
		else
			self.inUse = newState
		end
	end
	
	function self.IsIntersection()
		return self.def.intersection
	end
	
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
	
	function self.Export(objList)
		local exportData = {pos = self.pos, rot = self.rotation, roadType = self.roadType}
		objList[#objList + 1] = exportData
	end
	
	
	function self.MousePressed()
		if self.signalTime then
			self.stopSignal = 1 - self.stopSignal
			self.signalTime = self.def.signalTimeMax[self.stopSignal]*2
			self.orangeSignalTime = self.def.orangeTimeMax
		end
	end
	
	function self.Update(dt)
		if self.toDestroy then
			return true
		end
		if self.def.updateFunc then
			self.def.updateFunc(self, dt)
		end
		if self.signalTime then
			self.signalTime = self.signalTime - dt
			if self.signalTime <= 0 then
				self.stopSignal = 1 - self.stopSignal
				self.signalTime = self.def.signalTimeMax[self.stopSignal]
				self.orangeSignalTime = self.def.orangeTimeMax
			end
			if self.orangeSignalTime then
				self.orangeSignalTime = self.orangeSignalTime - dt
				if self.orangeSignalTime <= 0 then
					self.orangeSignalTime = false
				end
			end
		end
	end
	
	function self.Draw(drawQueue)
		if self.def.stateImage and self.stopSignal then
			drawQueue:push({y=0 + self.pos[2]*0.01; f=function()
				Resources.DrawImage(self.def.stateImage[self.stopSignal], self.worldPos[1], self.worldPos[2], self.worldRot + self.stopSignal*math.pi/2, false, LevelHandler.TileScale())
			end})
		end
		if self.def.baseImage then
			if self.def.onlyDrawInEditMode then
				if not LevelHandler.InEditMode() then
					return
				end
			end
			drawQueue:push({y=-100 + self.pos[2]*0.01; f=function()
				Resources.DrawImage(self.def.baseImage, self.worldPos[1], self.worldPos[2], self.worldRot, false, LevelHandler.TileScale())
				if self.def.extraDrawFunc then
					self.def.extraDrawFunc(self, self.worldPos, self.worldRot)
				end
				
				if Global.DRAW_DEBUG then
					if self.ray then
						love.graphics.setLineWidth(2)
						love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
						love.graphics.line(self.ray[1][1], self.ray[1][2], self.ray[2][1], self.ray[2][2])
					end
				end
			end})
		end
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return NewRoad
