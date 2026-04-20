
return {
	baseImage = "firehouse",
	destinationType = "firehouse",
	exitRoadTypes = {
		straight_large = true,
	},
	spawnWhenBlocked = true,
	spawnMatchFunc = function (other)
		return other.onFire
	end,
	spawnCar = {
		baseRate = 2.6 * Global.SPECIAL_SPAWN_MULT,
		randomProp = 0.1,
		carType = "firetruck",
		targets = util.NormaliseWeightedList({
			{
				target = "house",
				probability = 1,
			},
			{
				target = "station",
				probability = 1,
			},
			{
				target = "pub",
				probability = 1,
			},
			{
				target = "doctor",
				probability = 1,
			},
			{
				target = "big_house",
				probability = 1,
			},
			{
				target = "kebab",
				probability = 1,
			},
		})
	},
}