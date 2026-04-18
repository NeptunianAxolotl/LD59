
local self = {}
local api = {}

function api.GetCameraTransform()
	return self.cameraTransform
end

function api.Update(dt, pad)
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, 
		{
			{pos = {0, 0}, xOff = pad and pad[1] or 20, yOff = pad and pad[2] or 20},
			{pos = {self.levelData.width, self.levelData.height}, xOff = pad and pad[3] or 20, yOff = pad and pad[4] or 20},
		}
	)
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

function api.GetCameraTransform()
	return self.cameraTransform
end

function api.Initialize(world, levelData, padding)
	levelData = levelData or {width = 600, height = 500}
	self = {
		world = world,
		levelData = levelData,
	}
	
	self.cameraTransform = love.math.newTransform()
	self.cameraPos = {0, 0}
	Camera.Initialize({
		windowPadding = padding,
	})
	
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, 
		{
			{pos = {0, 0}, xOff = 20, yOff = 20},
			{pos = {self.levelData.width, self.levelData.height}, xOff = 20, yOff = 20},
		}
	)
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
	self.cameraScale = cameraScale
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
end

return api
