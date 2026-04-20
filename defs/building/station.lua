
return {
	baseImage = "police",
	destinationType = "station",
	exitRoadTypes = {
		straight = true,
		straight_large = true,
	},
	canCatchFire = true,
	spawnCar = {
		baseRate = 12 * Global.SPECIAL_SPAWN_MULT,
		randomProp = 0.3,
		carType = "police",
		targets = util.NormaliseWeightedList({
			{
				target = "highway",
				probability = 1,
			},
		})
	},
}