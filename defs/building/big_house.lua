
return {
	baseImage = "big_house",
	destinationType = "big_house",
	exitRoadTypes = {
		straight = true,
	},
	spawnCar = {
		baseRate = 12,
		randomProp = 0.6,
		carType = "basic_car",
		targets = util.NormaliseWeightedList({
			{
				target = "highway",
				probability = 1,
			},
			{
				target = "house",
				probability = 1,
			},
		})
	},
}