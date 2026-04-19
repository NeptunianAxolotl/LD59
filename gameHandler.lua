
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local Resources = require("resourceHandler")
MusicHandler = require("musicHandler")

local self = {}
local api = {}
local world

--------------------------------------------------
-- Updating
--------------------------------------------------

--------------------------------------------------
-- API
--------------------------------------------------

function api.ToggleMenu()
	self.menuOpen = not self.menuOpen
	world.SetMenuState(self.menuOpen)
end

function api.MousePressed(x, y)
	local windowX, windowY = love.window.getMode()
	local drawPos = world.ScreenToInterface({windowX, 0})
end


local function CanInfect(building)
	return building.def.canBeSick and not building.sickness
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
		self.sicknessTimer = 10
	end
end

function api.DrawInterface()
	local windowX, windowY = love.window.getMode()
end

function api.Initialize(parentWorld)
	self = {}
	self.sicknessTimer = 2
	world = parentWorld
end

return api
