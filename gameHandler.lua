
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local Resources = require("resourceHandler")
BGMHandler = require("bgmHandler")
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

function api.KeyPressed(key, scancode, isRepeat)
	if key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.AdvanceLevel()
	end
end

--------------------------------------------------
-- Game Stage
--------------------------------------------------

function api.AdvanceLevel()
	if not LevelDefs[self.level + 1] then
		return
	end
	self.level = self.level + 1
	self.levelData = LevelDefs[self.level]
	LevelHandler.UpdateMap(self.levelData.map)
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
	self.sicknessTimer = util.UpdateTimer(self.sicknessTimer, dt)
	if not self.sicknessTimer then
		local building = BuildingHandler.GetRandomMatchingBuilding(false, false, CanInfect)
		if building then
			building.sickness = 0
		end
		self.sicknessTimer = 5
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
	local windowX, windowY = love.window.getMode()
end

function api.Initialize(parentWorld)
	self = {}
	self.level = 1
	self.levelData = LevelDefs[self.level]
	
	self.sicknessTimer = 2
	self.drunkTimer = 2
	self.world = parentWorld
end

return api
