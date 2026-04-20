
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local Resources = require("resourceHandler")
local BGMHandler = require("bgmHandler")
local LevelDefs = require("defs/levelDefs")


local self = {}
local api = {}

--------------------------------------------------
-- Updating
--------------------------------------------------

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

function api.GetSpawnMult(bType)
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

function api.Update(dt)
	self.sicknessTimer = util.UpdateTimer(self.sicknessTimer, dt*(self.levelData.sickRate or 1))
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
	
	self.levelTimer = (self.levelTimer or 5)
	--self.levelTimer = util.UpdateTimer(self.levelTimer, dt)
	if not self.levelTimer then
		api.AdvanceLevel()
	end
end

function api.DrawInterface()
	if LevelHandler.InEditMode() then
		return
	end
	local drawX = 20
	local width = 660
	if self.world.GetCosmos().GetLocalisation() then
		drawX = Global.WINDOW_X - width - drawX
	end
	InterfaceUtil.DrawPanel(drawX, 20, width, 500, 8)
	
	love.graphics.setColor(0, 0, 0, 1)
	Font.SetSize(2)
	offset = 20
end

function api.Initialize(parentWorld)
	self = {}
	self.level = 1
	self.levelData = util.CopyTable(LevelDefs[self.level])
	
	self.sicknessTimer = 1
	self.drunkTimer = 2
	self.world = parentWorld
end

return api
