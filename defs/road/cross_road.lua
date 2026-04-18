
local outLength = roadUtil.GetCurveLength(Global.DRIVE_OFFSET + 0.25)
local innerLength = roadUtil.GetCurveLength(0.5 - Global.DRIVE_OFFSET)

return {
	baseImage = "cross_small",
	intersection = true,
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
		},
		{ -- bot to top
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.GetStraightPos(t, enterOffset, destOffset), math.pi/2)
			end,
			dirFunc = function (t)
				return -math.pi/2
			end,
			entry = 1,
			destination = 3,
			length = 1,
			turn = "straight",
		},
		{ -- top to bot
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.GetStraightPos(t, enterOffset, destOffset), -math.pi/2)
			end,
			dirFunc = function (t)
				return math.pi/2
			end,
			entry = 3,
			destination = 1,
			length = 1,
			turn = "straight",
		},
		{ -- Inner corner, right to bottom
			posFunc = function (t, enterOffset, destOffset)
				return roadUtil.InnerCornerPos(t, enterOffset, destOffset)
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
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.InnerCornerPos(t, enterOffset, destOffset), math.pi/2)
			end,
			dirFunc = function (t)
				return roadUtil.InnerCornerDir(t) + math.pi/2
			end,
			entry = 1,
			destination = 2,
			length = roadUtil.GetInnerLength(),
			turn = "left",
		},
		{ -- Inner corner, left to top
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.InnerCornerPos(t, enterOffset, destOffset), math.pi)
			end,
			dirFunc = function (t)
				return roadUtil.InnerCornerDir(t) + math.pi
			end,
			entry = 2,
			destination = 3,
			length = roadUtil.GetInnerLength(),
			turn = "left",
		},
		{ -- Inner corner, top to right
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.InnerCornerPos(t, enterOffset, destOffset), math.pi*3/2)
			end,
			dirFunc = function (t)
				return roadUtil.InnerCornerDir(t) + math.pi*3/2
			end,
			entry = 3,
			destination = 0,
			length = roadUtil.GetInnerLength(),
			turn = "left",
		},
		{ -- Outer corner, bottom to right
			posFunc = function (t, enterOffset, destOffset)
				return roadUtil.OuterLanedCornerPos(t, enterOffset, destOffset)
			end,
			dirFunc = function (t)
				return roadUtil.OuterLanedCornerDir(t)
			end,
			entry = 1,
			destination = 0,
			length = roadUtil.GetFullLanedOuterLength(),
			turn = "right",
		},
		{ -- Outer corner, left to bottom
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.OuterLanedCornerPos(t, enterOffset, destOffset), math.pi/2)
			end,
			dirFunc = function (t)
				return roadUtil.OuterLanedCornerDir(t) + math.pi/2
			end,
			
			entry = 2,
			destination = 1,
			length = roadUtil.GetFullLanedOuterLength(),
			turn = "right",
		},
		{ -- Outer corner, top to left
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.OuterLanedCornerPos(t, enterOffset, destOffset), math.pi)
			end,
			dirFunc = function (t)
				return roadUtil.OuterLanedCornerDir(t) + math.pi
			end,
			
			entry = 3,
			destination = 2,
			length = roadUtil.GetFullLanedOuterLength(),
			turn = "right",
		},
		{ -- Outer corner, right to top
			posFunc = function (t, enterOffset, destOffset)
				return util.RotateVector(roadUtil.OuterLanedCornerPos(t, enterOffset, destOffset), math.pi*3/2)
			end,
			dirFunc = function (t)
				return roadUtil.OuterLanedCornerDir(t) + math.pi*3/2
			end,
			
			entry = 0,
			destination = 3,
			length = roadUtil.GetFullLanedOuterLength(),
			turn = "right",
		},
	},
}