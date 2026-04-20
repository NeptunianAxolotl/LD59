
local self = {}
local api = {}

local RoadDefs = util.LoadDefDirectory("defs/road")
local BuildingDefs = util.LoadDefDirectory("defs/building")
local DoodadDefs = util.LoadDefDirectory("defs/doodads")

function api.Width()
	return self.width
end

function api.Height()
	return self.height
end

function api.TileSize()
	return self.tileSize
end

function api.TileScale()
	return self.tileSize / Global.GRID_SIZE
end

function api.GetLevelHumanName()
	return self.humanName
end

function api.IsFinalMap()
	return self.finalLevel
end

function api.GetMapData()
	return self.map
end

function api.WorldToGrid(pos)
	local x, y = math.floor(pos[1]/self.tileSize), math.floor(pos[2] / self.tileSize)
	return {x, y}
end

function api.WorldToGridSpaceNoSnap(pos)
	local x, y = (pos[1] - 0.5*self.tileSize)/self.tileSize, (pos[2] - 0.5*self.tileSize)/self.tileSize
	return {x, y}
end

function api.GridToWorld(pos)
	local x, y = (pos[1] + 0.5)*self.tileSize, (pos[2] + 0.5)*self.tileSize
	return {x, y}
end

local function SetupLevel()
	TerrainHandler.SetDimensions(self.map.dimensions)
	DoodadHandler.SetupLevel()
	for i = 1, #self.map.road do
		local road = self.map.road[i]
		if TerrainHandler.IsInBounds(road.pos) then
			TerrainHandler.AddRoad(road.pos, road.roadType, road.rot)
		end
		DoodadHandler.RemoveDoodads(road.pos)
	end
	for i = 1, #self.map.building do
		local building = self.map.building[i]
		BuildingHandler.AddBuilding(building.pos, building.buildingType)
		DoodadHandler.RemoveDoodads(building.pos)
	end
	for i = 1, #self.map.doodads do
		local doodad = self.map.doodads[i]
		DoodadHandler.AddDoodad(doodad.pos, doodad.doodadType)
	end
	TerrainHandler.SetDimensions(self.map.dimensions)
	BuildingHandler.UpdateRoadChanges()
end

function api.UpdateMap(name)
	self.map = require("defs/maps/" .. name)
	SetupLevel()
end

function api.LoadLevel(name)
	print("load level")
	local contents = love.filesystem.read("levels/" .. name)
	if not contents then
		EffectsHandler.SpawnEffect("error_popup", {480, 15}, {text = "Level file not found.", velocity = {0, 4}})
		return
	end
	local levelFunc = loadstring("return "..contents)
	if not levelFunc then
		EffectsHandler.SpawnEffect("error_popup", {480, 15}, {text = "Error loading level.", velocity = {0, 4}})
		return
	end
	local success, levelData = pcall(levelFunc)
	if not success then
		EffectsHandler.SpawnEffect("error_popup", {480, 15}, {text = "Level format error.", velocity = {0, 4}})
		return
	end
	
	self.world.GetCosmos().LoadLevelByTable(levelData)
	return true
end

function api.SaveLevel(name)
	love.filesystem.createDirectory("levels")
	self.humanName = name
	
	local save = {
		humanName = self.humanName,
		dimensions = TerrainHandler.GetDimensions(),
		road = TerrainHandler.ExportObjects(),
		building = BuildingHandler.ExportObjects(),
		doodads = DoodadHandler.ExportObjects(),
	}
	
	local saveTable = util.TableToString(save)
	local success, message = love.filesystem.write("levels/" .. name .. ".lua", saveTable)
	if success then
		EffectsHandler.SpawnEffect("error_popup", {0, 0}, {text = "Level saved to " .. name .. ".", velocity = {0, 4}})
	else
		EffectsHandler.SpawnEffect("error_popup", {0, 0}, {text = "Save error: " .. (message or "NO MESSAGE"), velocity = {0, 4}})
	end
	return success
end

function api.InEditMode()
	return self.editMode
end

function api.IsMenuOpen()
	return self.loadingLevelGetName or self.saveLevelGetName
end

function api.MousePressed(mx, my, button)
	if self.loadingLevelGetName or self.saveLevelGetName then
		return true
	end
	if not self.editMode then
		return
	end
	local clickPos = api.WorldToGrid({mx, my})
	if self.editor.tile == "delete" then
		TerrainHandler.RemoveRoad(clickPos)
		DoodadHandler.RemoveDoodads(clickPos)
		BuildingHandler.RemoveBuilding(clickPos)
		BuildingHandler.UpdateRoadChanges()
	elseif RoadDefs[self.editor.tile] then
		TerrainHandler.AddRoad(clickPos, self.editor.tile, self.editor.rotation)
		BuildingHandler.UpdateRoadChanges()
	elseif BuildingDefs[self.editor.tile] then
		BuildingHandler.AddBuilding(clickPos, self.editor.tile)
	elseif DoodadDefs[self.editor.tile] then
		DoodadHandler.AddDoodad(api.WorldToGridSpaceNoSnap({mx, my}), self.editor.tile)
	end
end

function api.KeyPressed(key, scancode, isRepeat)
	if self.loadingLevelGetName or self.saveLevelGetName then
		if key and string.len(key) == 1 then
			if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
				key = string.upper(key)
			end
			self.enteredText = (self.enteredText or "") .. key
		end
		if key == "meta" or key == "space" then
			self.enteredText = (self.enteredText or "") .. " "
		end
		if (key == "delete" or key == "backspace") and self.enteredText and string.len(self.enteredText) > 0 then
			self.enteredText = string.sub(self.enteredText, 0, string.len(self.enteredText) - 1)
		end
		if key == "escape" then
			self.loadingLevelGetName = false
			self.saveLevelGetName = false
		end
		if key == "return" and self.enteredText then
			if self.loadingLevelGetName then
				api.LoadLevel(self.enteredText)
				-- Loading causes immediate reinitialisation from world.
			elseif self.saveLevelGetName then
				if api.SaveLevel(self.enteredText) then
					self.saveLevelGetName = false
				end
			end
		end
		return true
	end
	
	if key == "l" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		self.loadingLevelGetName = true
	end
	if key == "k" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		self.saveLevelGetName = true
	end
	if key == "j" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		print("editMode", self.editMode)
		self.editMode = not self.editMode
	end
	
	if not self.editMode then
		return
	end
	
	local varyRate = ((love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and 5) or 1
	if key == "r" then
		self.editor.rotation = (self.editor.rotation + 1)%4
	elseif key == "e" then
		self.editor.rotation = (self.editor.rotation - 1)%4
	elseif key == "q" then
		self.editor.tile = "straight"
	elseif key == "d" then
		self.editor.tile = "straight_large"
	elseif key == "h" then
		self.editor.tile = "house"
	elseif key == "b" then
		self.editor.tile = "doctor"
	elseif key == "w" then
		self.editor.tile = "corner"
	elseif key == "a" then
		self.editor.tile = "t_road"
	elseif key == "v" then
		self.editor.tile = "ped_crossing"
	elseif key == "n" then
		self.editor.tile = "pub"
	elseif key == "y" then
		self.editor.tile = "big_house"
	elseif key == "u" then
		self.editor.tile = "firehouse"
	elseif key == "i" then
		self.editor.tile = "station"
	elseif key == "o" then
		self.editor.tile = "kebab"
	elseif key == "s" then
		self.editor.tile = "cross_road"
	elseif key == "z" then
		self.editor.tile = "delete"
	elseif key == "kp1" then
		self.editor.tile = "tree1"
	elseif key == "kp2" then
		self.editor.tile = "tree2"
	elseif key == "kp3" then
		self.editor.tile = "tree3"
	end
	print(key)
end

function api.GetSelectedTile()
	return self.editor and self.editor.tile, self.editor and self.editor.rotation
end

function api.DrawInterface()
	local gameOver, gameWon, gameLost = self.world.GetGameOver()
	local windowX, windowY = love.window.getMode()
	local overX = windowX*0.32
	local overWidth = windowX*0.36
	local overY = windowY*0.3
	local overHeight = windowY*0.4
	love.graphics.setColor(0, 0, 0, 1)
	Font.SetSize(2)
	
	local drawWindow = self.loadingLevelGetName or self.saveLevelGetName or self.townWantConf
	if drawWindow then
		love.graphics.setColor(Global.PANEL_COL[1], Global.PANEL_COL[2], Global.PANEL_COL[3], 0.97)
		love.graphics.setLineWidth(4)
		love.graphics.rectangle("fill", overX, overY, overWidth, overHeight, 8, 8, 16)
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.setLineWidth(10)
		love.graphics.rectangle("line", overX, overY, overWidth, overHeight, 8, 8, 16)
	end
	if self.loadingLevelGetName then
		Font.SetSize(0)
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.printf("Loading Level", overX, overY + overHeight * 0.04, overWidth, "center")
		
		Font.SetSize(3)
		love.graphics.printf("Type level name (Enter accept, ESC cancel)\n" .. (self.enteredText or ""), overX + overWidth*0.05, overY + overHeight * 0.32 , overWidth*0.9, "center")
		
		Font.SetSize(3)
		love.graphics.printf("Loading from " .. (love.filesystem.getSaveDirectory() or "DIR_ERROR") .. "/levels", overX + overWidth*0.05, overY + overHeight * 0.65, overWidth*0.9, "center")
	elseif self.saveLevelGetName then
		Font.SetSize(0)
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.printf("Saving Level", overX, overY + overHeight * 0.04, overWidth, "center")
		
		Font.SetSize(3)
		love.graphics.printf("Type level name (Enter accept, ESC cancel)\n" .. (self.enteredText or ""), overX + overWidth*0.05, overY + overHeight * 0.32 , overWidth*0.9, "center")
		
		Font.SetSize(3)
		love.graphics.printf("Saving to " .. (love.filesystem.getSaveDirectory() or "DIR_ERROR") .. "/levels", overX + overWidth*0.05, overY + overHeight * 0.65, overWidth*0.9, "center")
	end
	
	if self.editMode then
		Font.SetSize(2)
		offset = 20
		love.graphics.printf("Editing Level", 20, offset, 500, "left")
		offset = offset + 40
		love.graphics.printf("Piece: " .. self.editor.tile, 20, offset, 500, "left")
		offset = offset + 40
		love.graphics.printf("Rotation: " .. self.editor.rotation, 20, offset, 500, "left")
		offset = offset + 40
		
		offset = offset + 40
		love.graphics.printf([[
R - Rotate
E - Rotate backwards
Q - Straight Road
D - Straight Road Large
W - Curve
A - T-Int
V - Ped

H - House
B - Doctor
N - Pub
Y - Theatre
U - Firehouse
I - Station
O - Kebab

S - Cross
Z - Delete
]], 20, offset, 500, "left")
		offset = offset + 40
	end
	return drawWindow
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		tileSize = Global.GRID_SIZE,
		editor = {
			rotation = 0,
			tile = "straight",
		},
	}
	self.map = levelData
	SetupLevel()
end

return api
