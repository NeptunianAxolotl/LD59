
local outLength = roadUtil.GetCurveLength(Global.DRIVE_OFFSET + 0.25)
local innerLength = roadUtil.GetCurveLength(0.5 - Global.DRIVE_OFFSET)

return {
	baseImage = "t_small",
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
			turn = "straight",
		},
		{ -- left to right
			posFunc = function (t)
				return {t - 0.5, -Global.DRIVE_OFFSET}
			end,
			dirFunc = function (t)
				return 0
			end,
			entry = 2,
			destination = 0,
			length = 1,
			turn = "straight",
		},
		{ -- Inner corner, right to bottom
			posFunc = function (t)
				return roadUtil.InnerCornerPos(t)
			end,
			dirFunc = function (t)
				return roadUtil.InnerCornerDir(t)
			end,
			entry = 0,
			destination = 1,
			length = roadUtil.GetInnerLength(),
			turn = "left",
		},
		{ -- Inner corner, bottom to left
			posFunc = function (t)
				return util.RotateVector(roadUtil.InnerCornerPos(t), math.pi/2)
			end,
			dirFunc = function (t)
				return roadUtil.InnerCornerDir(t) + math.pi/2
			end,
			entry = 1,
			destination = 2,
			length = roadUtil.GetInnerLength(),
			turn = "left",
		},
		{ -- Outer corner, bottom to right
			posFunc = function (t)
				return roadUtil.OuterLanedCornerPos(t)
			end,
			dirFunc = function (t)
				return roadUtil.OuterLanedCornerDir(t)
			end,
			entry = 1,
			destination = 0,
			length = roadUtil.GetFullOuterLength(),
			turn = "right",
		},
		{ -- Outer corner, left to bottom
			posFunc = function (t)
				return util.RotateVector(roadUtil.OuterLanedCornerPos(t), math.pi/2)
			end,
			dirFunc = function (t)
				return roadUtil.OuterLanedCornerDir(t) + math.pi/2
			end,
			
			entry = 2,
			destination = 1,
			length = roadUtil.GetFullOuterLength(),
			turn = "right",
		},
	},
}