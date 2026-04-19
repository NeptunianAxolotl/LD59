
return {
	baseImage = "house",
	destinationType = "house",
	canBeSick = true,
	spawnRoads = {
		straight = true,
	},
	spawnCar = {
		baseRate = 12,
		randomProp = 0.6,
		carType = "basic_car",
		targets = util.NormaliseWeightedList({
			{
				target = "highway",
				probability = 2,
			},
			{
				target = "house",
				probability = 1,
			},
		})
	},
	updateFunc = function (self, dt)
	end,
}