
local NewBuilding = require("objects/building")

local self = {}
local api = {}

function api.RemoveBuilding(pos)
	local x, y = pos[1], pos[2]
	if self.buildingPos[x] and self.buildingPos[x][y] then
		local oldBuilding = IterableMap.Get(self.buildingList, self.buildingPos[x][y])
		if oldBuilding then
			oldBuilding.toDestroy = true
		end
		IterableMap.Remove(self.buildingList, self.buildingPos[x][y])
		self.buildingPos[x][y] = nil
	end
end

function api.GetBuildingAtPos(gridPos)
	local x, y = gridPos[1], gridPos[2]
	if not (self.buildingPos[x] and self.buildingPos[x][y]) then
		return false
	end
	return IterableMap.Get(self.buildingList, self.buildingPos[x][y])
end

function api.VisitBuilding(pos, car)
	local building = api.GetBuildingAtPos(pos)
	if building then
		return building.Visited(car)
	end
end

function api.UpdateRoadChanges()
	IterableMap.ApplySelf(self.buildingList, "FindRoad")
end

function api.AddBuilding(pos, buildingType)
	local x, y = pos[1], pos[2]
	self.buildingPos[x] = self.buildingPos[x] or {}
	api.RemoveBuilding(pos)
	local buildingID = IterableMap.GetNewUniqueKey(self.buildingList)
	local buildingData = {
		buildingType = buildingType,
		pos = pos,
		buildingID = buildingID,
	}
	local building = NewBuilding(buildingData)
	self.buildingPos[x][y] = IterableMap.Add(self.buildingList, buildingID, building)
end

function api.ReplaceHighwayEnds(ends)
	IterableMap.ApplySelf(self.buildingList, "MatchAndExcludeID", "highway") -- Removes
	api.AddBuilding({ends[1] - 1, 0}, "highway")
	api.AddBuilding({ends[2] + 1, 0}, "highway")
end

function api.GetRandomMatchingBuilding(buildingType, excludeID, matchFunc)
	return IterableMap.GetRandomSatisfies(self.buildingList, "MatchAndExcludeID", buildingType, excludeID, matchFunc)
end

function api.ExportObjects()
	local objList = {}
	IterableMap.ApplySelf(self.buildingList, "Export", objList)
	return objList
end

function api.Update(dt)
	IterableMap.ApplySelfRandomOrder(self.buildingList, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.buildingList, "Draw", drawQueue)
end

function api.Initialize(world)
	self = {
		buildingList = IterableMap.New(),
		buildingPos = {},
		world = world,
	}
end

return api
