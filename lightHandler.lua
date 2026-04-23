
local LightDefs = util.LoadDefDirectory("defs/lights")
local NewLight = require("objects/light")

local self = {}
local api = {}

function api.AddLight(pos, lightType)
	local def = LightDefs[lightType]
	local lightData = {}
	lightData.pos = pos
	lightData.lightType = lightType
	IterableMap.Add(self.lightList, NewLight(lightData, api))
end

function api.RemoveLights(pos)
	IterableMap.ApplySelf(self.lightList, "RemoveAtPos", pos)
end

function api.SetupLevel()
	local map = LevelHandler.GetMapData()
	
	if map.lights then
		for i = 1, #map.lights do
			local light = map.lights[i]
			api.AddLight(light.pos, light.lightType)
		end
	end
end

function api.ExportObjects()
	local objList = {}
	IterableMap.ApplySelf(self.lightList, "Export", objList)
	return objList
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.lightList, "Draw", drawQueue)
end

function api.Initialize(world)
	self = {
		lightList = IterableMap.New(),
		world = world,
	}
end

return api
