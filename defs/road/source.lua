
local occupyVector = {
	{0.6, -Global.DRIVE_OFFSET},
	{0, -Global.DRIVE_OFFSET},
}

return {
	baseImage = "source_small",
	spawnCar = {
		period = 1.25,
		carType = "basic_car",
		entry = 2,
	},
	updateFunc = function (self, dt)
	end,
	paths = {
		{ -- left to right
			posFunc = function (t, enterOffset, destOffset)
				local offset = util.AverageScalar(enterOffset, destOffset, t*2)
				return {t, -offset}
			end,
			dirFunc = function (t)
				return 0
			end,
			entry = 2,
			destination = 0,
			length = 0.5,
			speedMult = Global.BIG_ROAD_SPEED,
		},
		{ -- right to left
			posFunc = function (t, enterOffset, destOffset)
				local offset = util.AverageScalar(enterOffset, destOffset, t*2)
				return {0.5 - t, offset}
			end,
			dirFunc = function (t)
				return math.pi
			end,
			entry = 0,
			destination = 2,
			length = 0.5,
			speedMult = Global.BIG_ROAD_SPEED,
		},
	},
}