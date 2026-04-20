
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
	Camera.UpdateTransform(self.cameraTransform, self.cameraPos[1], self.cameraPos[2], self.cameraScale, false, false, self.world.GetCosmos().GetLocalisation())
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
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale, false, false, self.world.GetCosmos().GetLocalisation())
end

return api
