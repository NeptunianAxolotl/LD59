
return {
	baseImage = "pub",
	destinationType = "pub",
	exitRoadTypes = {
		straight = true,
		straight_large = true,
	},
	spawnWhenBlocked = true,
	drawTargetPos = true,
	spawnMatchFunc = function (other)
		return (other.isDrunk and not other.drunkArriving) or other.def.alwaysDrunk
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
				probability = 1,
			},
			{
				target = "kebab",
				probability = 0.7,
			},
			{
				target = "big_house",
				probability = 0.05,
			},
		})
	},
}