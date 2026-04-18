

--local EffectDefs = util.LoadDefDirectory("effects")
local NewPlayerCar = require("objects/playerCar")

local self = {}
local api = {}

function api.Update(dt)
	if self.playerCar then
		self.playerCar.Update(dt)
	end
end

function api.Draw(drawQueue)
	if self.playerCar then
		self.playerCar.Draw(drawQueue)
	end
end

function api.Initialize(world)
	self = {
		playerCar = false,
		animationTimer = 0,
		world = world,
	}
	
	local initPlayerData = {
		pos = {500, 200}
	}
	self.playerCar = NewPlayerCar(initPlayerData, self.world.GetPhysicsWorld())
end

return api
