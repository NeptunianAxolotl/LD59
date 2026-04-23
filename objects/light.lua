
local LightDefs = util.LoadDefDirectory("defs/lights")

local function NewLight(self, terrain)
	self.def = LightDefs[self.lightType]
	self.worldPos = {(self.pos[1] + 0.5)* LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
	
	function self.Export(objList)
		objList[#objList + 1] = {pos = self.pos, lightType = self.lightType}
	end
	
	function self.RemoveAtPos(pos)
		return (math.floor(self.pos[1] + 0.5) == pos[1]) and (math.floor(self.pos[2] + 0.5) == pos[2])
	end
	
	function self.UpdateWorldPos()
		self.worldPos = {(self.pos[1] + 0.5) * LevelHandler.TileSize(), (self.pos[2] + 0.5) * LevelHandler.TileSize()}
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=40 + self.pos[2]*0.01 - 0.001*self.pos[1] + (self.def.drawY or 0); f=function()
			Resources.DrawImage(self.def.image, self.worldPos[1], self.worldPos[2], 0, false, LevelHandler.TileScale())
		end})
		if self.def.topImage then
			drawQueue:push({y=200 + self.pos[2]*0.01 - 0.001; f=function()
				Resources.DrawImage(self.def.topImage, self.worldPos[1], self.worldPos[2], 0, false, LevelHandler.TileScale())
				if self.def.extraDrawFunc then
					self.def.extraDrawFunc(self, self.worldPos, self.worldRot)
				end
			end})
		end
	end
	
	return self
end

return NewLight
