
local RoadDefs = util.LoadDefDirectory("defs/road")

local function CalculateWorldPos(self)
	return {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
end

local function UpdateSignalFromAuto(self)
	for i = 0, self.def.signalCount - 1 do
		self.signal[i] = (self.autoSignalState - i)%2 == 0
	end
end

local function GetNearbySignalRoad(self)
	for i = 0, 3 do
		local road = TerrainHandler.GetRoadAtPos(self.pos, i)
		if road and road.signal then
			return road, i
		end
	end
end

local function ToggleAdjacentSignal(self)
	local other, direction = GetNearbySignalRoad(self)
	if not other then
		return false
	end
	other.ToggleSignal((direction - 2)%4)
	return true
end

local function SetupSignal(self)
	if not self.def.hasSignal then
		return 
	end
	self.automaticSignal = true
	self.autoSignalState = 0
	self.signalTime = self.def.signalTimeMax[self.autoSignalState]
	self.signal = {}
	UpdateSignalFromAuto(self)
end

local function GetHoveredMouseDrawing(self)
	if not self.signal then
		return
	end
	local lockAlpha = (not self.automaticSignal and 0.65)
	if TerrainHandler.IsGridHovered(self.pos) then
		lockAlpha = (lockAlpha or 0.1)*1.3
	end
	local hoveredSignal = false
	for i = 0, self.def.signalCount - 1 do
		if TerrainHandler.IsGridHovered(self.pos, (i + self.rotation)%4) then
			hoveredSignal = i
			break
		end
	end
	return lockAlpha, hoveredSignal
end

local function ClickNotify(self)
	if not self.clickNotifyCooldown then
		self.clickNotifyCooldown = Global.LIGHT_CLICK_NOTIFY_COOLDOWN
		GameHandler.LightWasClicked()
	end
end

local function NewRoad(self, terrain)
	self.def = RoadDefs[self.roadType]
	SetupSignal(self)
	
	self.worldPos = CalculateWorldPos(self)
	self.worldRot = self.rotation*math.pi/2
	self.worldEntryFilter = {}
	self.worldDestinationFilter = {}
	for i = 1, #self.def.paths do
		local path = self.def.paths[i]
		self.worldEntryFilter[(path.entry + self.rotation)%4] = true
		self.worldDestinationFilter[(path.destination + self.rotation)%4] = true
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
	
	function self.SignalActive(entry)
		if self.automaticSignal and self.orangeSignalTime then
			return true
		end
		return self.signal[entry]
	end
	
	function self.ToggleSignal(worldDir)
		if not self.signal then
			return
		end
		local myDir = (worldDir + self.rotation)%4
		self.signal[myDir] = not self.signal[myDir]
		self.signalTime = self.def.signalTimeMax[self.autoSignalState]
		ClickNotify(self)
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
	
	function self.WaitingCar(entry)
		-- TODO idk?
	end
	
	function self.UpdateWorldPos()
		self.worldPos = CalculateWorldPos()
	end
	
	function self.Export(objList)
		if self.def.noExport then
			return
		end
		local exportData = {pos = self.pos, rot = self.rotation, roadType = self.roadType}
		objList[#objList + 1] = exportData
	end
	
	function self.MousePressed()
		if self.signalTime then
			self.automaticSignal = not self.automaticSignal
			ClickNotify(self)
		else
			ToggleAdjacentSignal(self)
		end
	end
	
	function self.Update(dt)
		if self.toDestroy then
			return true
		end
		if self.def.updateFunc then
			self.def.updateFunc(self, dt)
		end
		self.clickNotifyCooldown = util.UpdateTimer(self.clickNotifyCooldown, dt)
		if self.automaticSignal then
			self.signalTime = self.signalTime - dt
			if self.signalTime <= 0 then
				self.autoSignalState = 1 - self.autoSignalState
				UpdateSignalFromAuto(self)
				self.signalTime = self.def.signalTimeMax[self.autoSignalState]
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
		local lockAlpha, hoveredSignal = GetHoveredMouseDrawing(self)
		if self.signal then
			drawQueue:push({y=100 + self.pos[2]*0.01; f=function()
				local timeProp = self.signalTime / self.def.signalTimeMax[self.autoSignalState] / Global.MANUAL_CLICK_BOOST
				local alpha = math.min(1, timeProp + 0.5)
				for i = 0, self.def.signalCount - 1 do
					local lightImage = self.signal[i] and "traffic_red" or "traffic_green"
					local color = self.signal[i] and Global.TRAFFIC_RED or Global.TRAFFIC_GREEN
					Resources.DrawImage(lightImage, self.worldPos[1], self.worldPos[2], self.worldRot + i*math.pi/2, false, LevelHandler.TileScale())
					Resources.DrawImage(self.def.stateImage, self.worldPos[1], self.worldPos[2], self.worldRot + i*math.pi/2, alpha, LevelHandler.TileScale(), color)
					if hoveredSignal == i then
						Resources.DrawImage(self.def.stateImage, self.worldPos[1], self.worldPos[2], self.worldRot + i*math.pi/2, 0.6, LevelHandler.TileScale())
					end
				end
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
				if lockAlpha then
					Resources.DrawImage("lock", self.worldPos[1], self.worldPos[2], false, lockAlpha, LevelHandler.TileScale())
				end
				if self.def.extraDrawFunc then
					self.def.extraDrawFunc(self, self.worldPos, self.worldRot)
				end
				
				if DrawDebug() then
					if self.ray then
						love.graphics.setLineWidth(2)
						love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
						for i = 1, #self.ray do
							love.graphics.line(self.ray[i][1][1], self.ray[i][1][2], self.ray[i][2][1], self.ray[i][2][2])
						end
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
