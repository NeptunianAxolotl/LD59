
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local Resources = require("resourceHandler")
local BGMHandler = require("bgmHandler")
local LevelDefs = require("defs/levelDefs")

local self = {}
local api = {}

local statName = {
	lightClicks = "Toggle Lights",
	accidents = "Crashes",
	drunkArrivals_sinceAccident = "Drunks returned home since last crash",
	sickDeaths = "Succumbed to Illness",
	returnedToDoctor = "Patients in Hospital",
	doctorVisitHouse = "Patients picked up",
}

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.ResetStat(name)
	self.stats[name] = 0
	if self.levelData.flashStat and self.levelData.flashStat[name] then
		self.flashStat[name] = Global.FLASH_STAT_TIME / 2
	end
end

function api.AddStat(name, count)
	count = count or 1
	self.stats[name] = (self.stats[name] or 0) + count
	if count > 0 and self.levelData.flashStat and self.levelData.flashStat[name] then
		self.flashStat[name] = Global.FLASH_STAT_TIME
	end
end

function api.GetStat(name)
	return self.stats[name] or 0
end

function api.CarSpawnAllowed(name)
	if not (self.levelData.carLimit and self.levelData.carLimit[name]) then
		return true
	end
	local limit = self.levelData.carLimit[name]
	return limit > CarHandler.GetCarCount(name)
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.ToggleMenu()
	self.menuOpen = not self.menuOpen
	self.world.SetMenuState(self.menuOpen)
end

function api.MousePressed(x, y)
	local windowX, windowY = love.window.getMode()
	local drawPos = self.world.ScreenToInterface({windowX, 0})
end

function api.LightWasClicked()
	BGMHandler.addPoints(1)
	api.AddStat("lightClicks")
end

function api.RegisterCollision()
	BGMHandler.RegisterCollision()
end

function api.KeyPressed(key, scancode, isRepeat)
	if key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.AdvanceLevel()
	end
end

--------------------------------------------------
-- Game Stage
--------------------------------------------------

function api.GetLevelRate(bType)
	return self.levelData.spawnMult and self.levelData.spawnMult[bType] or 1
end

function api.GetTargetType(distribution)
	if #distribution == 1 then
		return distribution[1]
	end
	local result = util.SampleListWeighted(distribution)
	if not self.levelData.redrawChance then
		return result
	end
	while self.levelData.redrawChance[result] or 0 > math.random() do
		result = util.SampleListWeighted(distribution)
	end
	return result
end

function api.AdvanceLevel()
	if not LevelDefs[self.level + 1] then
		return
	end
	self.level = self.level + 1
	self.levelData = LevelDefs[self.level]
	if self.levelData.map then
		LevelHandler.UpdateMap(self.levelData.map)
	end
	self.nextLevelTimer = Global.LEVEL_DONE_EXPAND_TIMER
end


--------------------------------------------------
-- Filtering
--------------------------------------------------

local function CanInfect(building)
	return building.def.canBeSick and not building.sickness
end

local function CanBeDrunk(building)
	return building.def.canBeDrunk and not building.isDrunk
end

--------------------------------------------------
-- Updating
--------------------------------------------------

local function CheckLevelAdvance()
	local req = self.levelData.advanceRequirement
	if not req then
		return
	end
	for name, count in pairs(req) do
		if count > api.GetStat(name) then
			return
		end
	end
	api.AdvanceLevel()
end

function api.Update(dt)
	self.sicknessTimer = util.UpdateTimer(self.sicknessTimer, dt*0.1*api.GetLevelRate("houseBecomeSick"))
	if not self.sicknessTimer then
		local building = BuildingHandler.GetRandomMatchingBuilding(false, false, CanInfect)
		if building then
			building.sickness = 0
		end
		self.sicknessTimer = 1
	end
	self.drunkTimer = util.UpdateTimer(self.drunkTimer, dt)
	if not self.drunkTimer then
		local building = BuildingHandler.GetRandomMatchingBuilding(false, false, CanBeDrunk)
		if building then
			building.isDrunk = true
		end
		self.drunkTimer = Global.REDRUNK_TIMER
	end
	
	self.nextLevelTimer = util.UpdateTimer(self.nextLevelTimer, dt)
	
	for name, data in pairs(self.flashStat) do
		self.flashStat[name] = util.UpdateTimer(self.flashStat[name], dt)
		if not self.flashStat[name] then
			self.flashStat[name] = nil
		end
	end
	api.AddStat("timeTaken", dt)
	api.AddStat("timeTakenLevel_" .. self.level, dt)
	CheckLevelAdvance()
end

function api.DrawInterface()
	if LevelHandler.InEditMode() then
		return
	end
	local drawX = 40
	local width = 660
	local height = 470
	local offset = 20
	if self.world.GetCosmos().GetLocalisation() then
		drawX = Global.WINDOW_X - width - drawX
	end
	local expand = (self.nextLevelTimer or 0)
	expand = 1 + expand * (Global.LEVEL_DONE_EXPAND_TIMER - expand) * 0.07
	InterfaceUtil.DrawPanel(drawX - (expand - 1)*width/2, offset - (expand - 1)*height/2, width * expand, height * expand, 8)
	
	love.graphics.setColor(0, 0, 0, 1)
	Font.SetSize(1)
	
	offset = 40
	if self.nextLevelTimer and self.nextLevelTimer%0.3 < 0.15 then
		love.graphics.setColor(0.8, 0.8, 0.8, 1)
	else
		love.graphics.setColor(0, 0, 0, 1)
	end
	love.graphics.printf(self.levelData.heading or "NO HEADING", drawX + 40, offset, width - 50, "left")
	
	Font.SetSize(3)
	
	love.graphics.setColor(0, 0, 0, 1)
	offset = offset + 75
	love.graphics.printf(self.levelData.text or "NO DESC", drawX + 40, offset, width - 50, "left")
	
	offset = height - 5
	if self.levelData.showStats then
		local req = self.levelData.advanceRequirement
		for i = 1, #self.levelData.showStats do
			local name = self.levelData.showStats[i]
			offset = offset - 40
			if self.flashStat[name] and (self.flashStat[name])%0.3 < 0.15 then
				love.graphics.setColor(0.8, 0.8, 0.8, 1)
			else
				love.graphics.setColor(0, 0, 0, 1)
			end
			if req and req[name] then
				love.graphics.printf((statName[name] or name) .. ": " .. math.floor(api.GetStat(name)) .. " / " .. req[name], drawX + 40, offset, width - 50, "left")
			else
				love.graphics.printf((statName[name] or name) .. ": " .. math.floor(api.GetStat(name)), drawX + 40, offset, width - 50, "left")
			end
		end
	end
	
end

function api.Initialize(parentWorld)
	self = {}
	self.stats = {}
	self.level = 1
	self.levelData = LevelDefs[self.level]
	self.flashStat = {}
	
	self.sicknessTimer = 0.02
	self.drunkTimer = 2
	self.world = parentWorld
end

return api
