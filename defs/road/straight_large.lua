
return {
	baseImage = "straight_large",
	noExport = true,
	paths = {
		{ -- right to left
			posFunc = function (t, enterOffset, destOffset)
				return roadUtil.GetStraightPos(t, enterOffset, destOffset)
			end,
			dirFunc = function (t)
				return math.pi
			end,
			entry = 0,
			destination = 2,
			length = 1,
			turn = "straight",
			speedMult = Global.BIG_ROAD_SPEED,
		},
		{ -- left to right
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.GetStraightPos(t, enterOffset, destOffset), math.pi)
			end,
			dirFunc = function (t)
				return 0
			end,
			entry = 2,
			destination = 0,
			length = 1,
			turn = "straight",
			speedMult = Global.BIG_ROAD_SPEED,
		},
	},
}