
return {
	baseImage = "pub",
	destinationType = "pub",
	exitRoadTypes = {
		straight = true,
		straight_large = true,
	},
	spawnWhenBlocked = true,
	spawnMatchFunc = function (other)
		return other.isDrunk and not other.drunkArriving
	end,
	onDispatchCar = function(self, targetBuilding)
		targetBuilding.drunkArriving = true
	end,
	spawnCar = {
		baseRate = 10 * Global.SPECIAL_SPAWN_MULT,
		randomProp = 0.2,
		carType = "drunk",
		targets = util.NormaliseWeightedList({
			{
				target = "house",
				probability = 1.8,
			},
		})
	},
}