
local names = util.GetDefDirList("resources/images/buildings")
local data = {}

local xOffset = {
	pub = 0.25,
}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/buildings/" .. names[i] .. ".png",
		form = "image",
		xScale = Global.GRID_SIZE/400,
		yScale = Global.GRID_SIZE/400,
		xOffset = xOffset[names[i]] or 0.5,
		yOffset = 0.5,
	}
end

return data
