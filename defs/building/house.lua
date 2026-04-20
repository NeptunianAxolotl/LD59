
return {
	baseImage = "house_white",
	destinationType = "house",
	canBeSick = true,
	canBeDrunk = true,
	exitRoadTypes = {
		straight = true,
	},
	spawnCar = {
		baseRate = 9,
		randomProp = 0.6,
		carType = "basic_car",
		targets = util.NormaliseWeightedList({
			{
				target = "highway",
				probability = 1.6,
			},
			{
				target = "house",
				probability = 1,
			},
		})
	},
}