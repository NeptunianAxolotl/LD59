
local names = util.GetDefDirList("resources/images/cars")
local data = {}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/cars/" .. names[i] .. ".png",
		form = "image",
		xScale = Global.GRID_SIZE/550,
		yScale = Global.GRID_SIZE/550,
		frontDir = -math.pi/2,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return data
