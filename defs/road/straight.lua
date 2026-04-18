
return {
	baseImage = "straight_small",
	paths = {
		{ -- right to left
			posFunc = function (t)
				return {0.5 - t, Global.DRIVE_OFFSET}
			end,
			dirFunc = function (t)
				return math.pi
			end,
			entry = 0,
			destination = 2,
			length = 1,
		},
		{ -- left to right
			posFunc = function (t)
				return {t - 0.5, -Global.DRIVE_OFFSET}
			end,
			dirFunc = function (t)
				return 0
			end,
			entry = 0,
			destination = 2,
			length = 1,
		},
	},
}