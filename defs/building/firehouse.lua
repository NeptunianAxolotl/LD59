
return {
	baseImage = "firehouse",
	destinationType = "firehouse",
	exitRoadTypes = {
		straight_long = true,
	},
	spawnOtherIfBlocked = true,
	spawnMatchFunc = function (other)
		return other.onFire
	end,
	spawnCar = {
		baseRate = 8 * Global.SPECIAL_SPAWN_MULT,
		randomProp = 0.3,
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
		})
	},
}