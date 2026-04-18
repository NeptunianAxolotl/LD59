local Font = require("include/font")
local MapDefs = util.LoadDefDirectory("defs/maps")

local self = {}
local api = {}

local function SetupLevel()
	-- TODO self.map = {}
end

function api.Draw(drawQueue)
	drawQueue:push({y=0; f=function()		love.graphics.rectangle("line", 0, 0, 1, 1)				leftPos = self.left*Global.TILE_SIZE		topPos = self.top*Global.TILE_SIZE		rightPos = self.right*Global.TILE_SIZE		bottomPos = self.bottom*Global.TILE_SIZE				for i = self.left, self.right do			love.graphics.line(i*Global.TILE_SIZE, topPos, i*Global.TILE_SIZE, bottomPos)		end		for i = self.top, self.bottom do			love.graphics.line(leftPos, i*Global.TILE_SIZE, rightPos, i*Global.TILE_SIZE)		end
	end})
end
function api.GetViewRestriction()	local pointsToView = {{self.left*Global.TILE_SIZE, self.top*Global.TILE_SIZE}, {self.right*Global.TILE_SIZE, self.bottom*Global.TILE_SIZE}}	return pointsToViewend
function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,		left = -4,		right = 4,		top = -4,		bottom = 4,
	}
	SetupLevel(levelIndex, mapDataOverride)
end

return api
