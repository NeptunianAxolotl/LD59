
return {
	baseImage = "highway",
	destinationType = "highway",
	noExport = true,
	spawnRoads = {
		straight_large = true,
	},
	spawnCar = {
		baseRate = 1.25,
		randomProp = 0.2,
		carType = "basic_car",
		spawnFullSpeed = true,
		targets = util.NormaliseWeightedList({
			{
				target = "highway",
				probability = 2,
			},
			{
				target = "house",
				probability = 1,
			},
		})
	},
	updateFunc = function (self, dt)
	end,
}