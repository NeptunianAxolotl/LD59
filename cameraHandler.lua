
local self = {}
local api = {}

function api.GetCameraTransform()
	return self.cameraTransform
end

function api.Update(dt, pad)
	local viewPoints = Camera.PointsToViewPoints(TerrainHandler.GetViewRestriction(), Global.VIEW_PADDING)
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, viewPoints)
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
	self.cameraScale = cameraScale
	Camera.UpdateTransform(self.cameraTransform, self.cameraPos[1], self.cameraPos[2], self.cameraScale)
end

local function UpdateCamera(dt, vector)
	local cameraX, cameraY, cameraScale = Camera.PushCamera(dt, vector, 0.55)
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
	--if ((cameraX - self.cameraPos[1])*10 < 150 or (cameraX - self.cameraPos[1])*10 > 180) and (cameraX - self.cameraPos[1])*10 > 40 then
	--	print(math.floor((cameraX - self.cameraPos[1])*10))
	--end
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
end

function api.Initialize(world, padding)
	self = {
		world = world,
	}
	
	self.cameraTransform = love.math.newTransform()
	self.cameraPos = {0, 0}
	Camera.Initialize({
		windowPadding = padding,
		squashRatio = 1,
	})
	
	local viewPoints = Camera.PointsToViewPoints(TerrainHandler.GetViewRestriction(), Global.VIEW_PADDING)
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, viewPoints)
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
	self.cameraScale = cameraScale
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
end

return api
