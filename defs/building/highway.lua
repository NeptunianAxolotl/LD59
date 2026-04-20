
return {
	baseImage = "highway",
	destinationType = "highway",
	noExport = true,
	arriveWithoutTurn = true,
	exitRoadTypes = {
		straight_large = true,
	},
	spawnCar = {
		baseRate = 3,
		randomProp = 0.8,
		carType = "basic_car",
		spawnFullSpeed = true,
		targets = util.NormaliseWeightedList({
			{
				target = "highway",
				probability = 1.6,
			},
			{
				target = "house",
				probability = 1,
			},
			{
				target = "big_house",
				probability = 0.08,
			},
		})
	},
}