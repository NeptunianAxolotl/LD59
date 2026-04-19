
return {
	baseImage = "highway",
	destinationType = "highway",
	spawnRoads = {
		straight_large = true,
	},
	spawnCar = {
		baseRate = 1.25,
		carType = "basic_car",
		targets = {
			{
				target = "highway",
				probability = 2,
			},
			{
				target = "house",
				probability = 1,
			},
		}
	},
	updateFunc = function (self, dt)
	end,
}