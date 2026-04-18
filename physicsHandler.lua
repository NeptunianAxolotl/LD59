local EffectsHandler = require("effectsHandler")

local self = {}
local api = {}

--------------------------------------------------
-- API
--------------------------------------------------

function api.GetPhysicsWorld()
	return self.physicsWorld
end

function api.AddStaticObject()
	return self.physicsWorld
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local function beginContact(a, b, coll)
	--world.beginContact(a, b, coll)
end

local function endContact(a, b, coll)
end

local function preSolve(a, b, coll)
end

local function postSolve(a, b, coll,  normalimpulse, tangentimpulse)
	--world.postSolve(a, b, coll,  normalimpulse, tangentimpulse)
end

--------------------------------------------------
-- Initialize
--------------------------------------------------

local function InitPhysics()
	love.physics.setMeter(Global.PHYSICS_SCALE)
	self.physicsWorld = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
	self.physicsWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
	self.physicsWorld:setGravity(0, 0)
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	self.physicsWorld:update(dt)
end

function api.Draw(drawQueue)
	if not self.world.GetCosmos().DrawPhysicsEnabled() then
		return
	end
	drawQueue:push({y=120; f=function()
		love.graphics.setLineWidth(2)
		love.graphics.setColor(1, 1, 1, 0.45)
		for _, body in pairs(self.physicsWorld:getBodies()) do
			for _, fixture in pairs(body:getFixtures()) do
				local shape = fixture:getShape()
				if shape:typeOf("CircleShape") then
					local cx, cy = body:getWorldPoints(shape:getPoint())
					love.graphics.circle("fill", cx, cy, shape:getRadius())
				elseif shape:typeOf("PolygonShape") then
					love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
				else
					love.graphics.line(body:getWorldPoints(shape:getPoints()))
				end
			end
		end
	end})
end

function api.Destroy(dt)
	if self.physicsWorld then
		self.physicsWorld:destroy()
		self.physicsWorld = nil
	end
end

function api.Initialize(parentWorld)
	self = {
		world = parentWorld,
	}
	InitPhysics()
end

return api