
local outLength = roadUtil.GetCurveLength(Global.DRIVE_OFFSET + 0.25)
local innerLength = roadUtil.GetCurveLength(0.5 - Global.DRIVE_OFFSET)

return {
	baseImage = "t_small",
	highwayImage = "t_large",
	intersection = true,
	hasSignal = true,
	orangeTimeMax = 0.5,
	signalCount = 3,
	stateImage = "road_stop_single",
	signalTimeMax = {
		[0] = 4,
		[1] = 7,
	},
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
			trafficFromLeft = true,
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
			trafficFromLeft = true,
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
			trafficFromRight = true,
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
			trafficFromLeft = true,
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
			acrossTraffic = true,
		},
	},
}