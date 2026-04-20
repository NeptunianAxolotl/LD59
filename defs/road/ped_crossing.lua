
local outLength = roadUtil.GetCurveLength(Global.DRIVE_OFFSET + 0.25)
local innerLength = roadUtil.GetCurveLength(0.5 - Global.DRIVE_OFFSET)

return {
	baseImage = "ped_crossing",
	hasSignal = true,
	orangeTimeMax = 0,
	signalCount = 3,
	skipSignal = 1,
	stateImage = "road_stop_single",
	signalTimeMax = {
		[0] = 4,
		[1] = 20,
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
		}
	},
}