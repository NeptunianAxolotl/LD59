
return {
	baseImage = "doctor",
	destinationType = "doctor",
	exitRoadTypes = {
		straight = true,
		straight_large = true,
	},
	spawnOtherIfBlocked = true,
	drawTargetPos = true,
	spawnMatchFunc = function (other)
		return other.sickness and not other.medicOnTheWayTimer
	end,
	onDispatchCar = function(self, targetBuilding)
		targetBuilding.medicOnTheWayTimer = Global.MEDIC_EXPECTED_TIMER
	end,
	spawnCar = {
		baseRate = 8 * Global.SPECIAL_SPAWN_MULT,
		randomProp = 0.3,
		carType = "medic",
		targets = util.NormaliseWeightedList({
			{
				target = "house",
				probability = 1,
			},
		})
	},
}