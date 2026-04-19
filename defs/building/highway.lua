
return {
	baseImage = "highway",
	destinationType = "highway",
	noExport = true,
	attachRoachTypes = {
		straight_large = true,
	},
	spawnCar = {
		baseRate = 2.7,
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
}