local Font = require("include/font")
local MapDefs = util.LoadDefDirectory("defs/maps")
roadUtil = require("utilities/roadUtilities")local RoadDefs = util.LoadDefDirectory("defs/road")local NewRoad = require("objects/road")
local self = {}
local api = {}
function api.GetDimensions()	return self.dimensionsendfunction api.SetDimensions(dimensions)	self.dimensions = util.CopyTable(dimensions)endfunction api.IsInBounds(gPos)	return self.dimensions.left <= gPos[1] and self.dimensions.right > gPos[1] and self.dimensions.top <= gPos[2] and self.dimensions.bottom > gPos[2]endfunction api.RemoveRoad(pos)	local x, y = pos[1], pos[2]	if self.roadPos[x] and self.roadPos[x][y] then		local oldRoad = IterableMap.Get(self.roadList, self.roadPos[x][y])		IterableMap.Remove(self.roadList, self.roadPos[x][y])	endendfunction api.AddRoad(pos, roadType, rotation, setData)	local x, y = pos[1], pos[2]	self.roadPos[x] = self.roadPos[x] or {}	api.RemoveRoad(pos)	local def = RoadDefs[roadType]	local roadData = (setData and util.CopyTable(setData)) or {}	roadData.pos = pos	roadData.roadType = roadType	roadData.rotation = rotation	self.roadPos[x][y] = IterableMap.Add(self.roadList, NewRoad(roadData, api))end
function api.ExportObjects()	local objList = {}	IterableMap.ApplySelf(self.roadList, "Export", objList)	return objListendfunction api.GetViewRestriction()	local dim = api.GetDimensions()	local size = LevelHandler.TileSize()	local pointsToView = {{dim.left*size, dim.top*size}, {dim.right*size, dim.bottom*size}}	return pointsToViewendfunction api.Draw(drawQueue)	IterableMap.ApplySelf(self.roadList, "Draw", drawQueue)	drawQueue:push({y=0; f=function()		local dim = api.GetDimensions()		local size = LevelHandler.TileSize()		love.graphics.setLineWidth(1)		love.graphics.setColor(1, 1, 1, 1)		love.graphics.rectangle("line", 0, 0, 1, 1)				leftPos = dim.left*size		topPos = dim.top*size		rightPos = dim.right*size		bottomPos = dim.bottom*size				for i = dim.left, dim.right do			love.graphics.line(i*size, topPos, i*size, bottomPos)		end		for i = dim.top, dim.bottom do			love.graphics.line(leftPos, i*size, rightPos, i*size)		end	end})end
function api.Initialize(world, mapDataOverride)
	self = {
		world = world,		roadList = IterableMap.New(),		roadPos = {},
	}
end

return api
