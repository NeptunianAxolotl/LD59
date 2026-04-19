
return {
	baseImage = "straight_small",
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
			occupyVector = {
				{0.6, -Global.DRIVE_OFFSET},
				{0, -Global.DRIVE_OFFSET},
			},
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
			occupyVector = {
				{-0.6, Global.DRIVE_OFFSET},
				{0, Global.DRIVE_OFFSET},
			},
		},
	},
}