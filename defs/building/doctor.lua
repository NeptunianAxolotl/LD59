
return {
	baseImage = "doctor",
	destinationType = "doctor",
	spawnRoads = {
		straight = true,
		straight_large = true,
	},
	spawnMatchFunc = function (other)
		return other.sickness
	end,
	spawnCar = {
		baseRate = 8,
		randomProp = 0.3,
		carType = "medic",
		targets = util.NormaliseWeightedList({
			{
				target = "house",
				probability = 1,
			},
		})
	},
	updateFunc = function (self, dt)
	end,
}