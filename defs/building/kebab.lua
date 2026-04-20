
return {
	baseImage = "kebab",
	destinationType = "kebab",
	exitRoadTypes = {
		straight = true,
	},
	spawnCar = {
		baseRate = 8 * Global.SPECIAL_SPAWN_MULT,
		randomProp = 0.2,
		carType = "basic_car",
		targets = util.NormaliseWeightedList({
			{
				target = "house",
				probability = 1,
			},
		})
	},
}
