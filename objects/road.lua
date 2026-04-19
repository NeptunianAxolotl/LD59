
local RoadDefs = util.LoadDefDirectory("defs/road")

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
	
	self.worldPos = {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
	self.worldRot = self.rotation*math.pi/2
	
	function self.GetTurnOptions(choiceRatio, entry)
		local trackSpaceEntry = (entry - self.rotation)%4
		local choices = {}
		for i = 1, #self.def.paths do
			local path = self.def.paths[i]
			if (trackSpaceEntry == path.entry) then
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
		local trackSpaceEntry = (entry - self.rotation)%4
		local choices = {}
		for i = 1, #self.def.paths do
			local path = self.def.paths[i]
			if (trackSpaceEntry == path.entry) and ((not wantTurn) or wantTurn == path.turn) then
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
	
	function self.IsInUse(entry, ignoreOff)
		if Global.BOSON_MODE then
			return false
		end
		if self.toDestroy then
			return true
		end
		if self.def.entryUseIndexMap then
			if entry then
				entry = (entry - self.rotation)%4
				if self.inUse[self.def.entryUseIndexMap[entry]] then
					return true
				end
				if self.permanentlyBlocked and self.permanentlyBlocked[self.def.entryUseIndexMap[entry]] then
					return true
				end
			else
				if self.inUse[1] or self.inUse[2] then
					return true
				end
				if self.permanentlyBlocked and self.permanentlyBlocked[1] and self.permanentlyBlocked[2] then
					return true
				end
			end
		elseif self.inUse or self.permanentlyBlocked then
			return true
		end
		if self.def.offState and not ignoreOff then
			return (self.state == self.def.offState)
		end
		return false
	end
	
	function self.SetPermanentBlock(entry)
		TerrainHandler.SetUneditable(self.pos[1], self.pos[2])
		if self.def.entryUseIndexMap then
			entry = (entry - self.rotation)%4
			self.permanentlyBlocked = self.permanentlyBlocked or {}
			self.permanentlyBlocked[self.def.entryUseIndexMap[entry]] = true
		else
			self.permanentlyBlocked = true
		end
	end
	
	function self.IsPermanentlyBlocked(entry)
		if self.def.entryUseIndexMap then
			entry = (entry - self.rotation)%4
			if self.permanentlyBlocked then
				return self.permanentlyBlocked[self.def.entryUseIndexMap[entry]]
			end
		else
			return self.permanentlyBlocked
		end
		return false
	end
	
	function self.Export(objList)
		local exportData = {pos = self.pos, rot = self.rotation, roadType = self.roadType}
		if self.def.editorWantGoods then
			exportData.setData = {progression = self.progression}
		end
		objList[#objList + 1] = exportData
	end
	
	function self.UpdateWorldPos()
		self.worldPos = {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
	end
	
	function self.MousePressed()
		if self.signalTime then
			self.stopSignal = 1 - self.stopSignal
			self.signalTime = self.def.signalTimeMax[self.stopSignal]*2
			self.orangeSignalTime = self.def.orangeTimeMax
		end
	end
	
	function self.Update(dt)
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
		return self.toDestroy
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
