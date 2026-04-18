
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
				t = t/innerLength
				return roadUtil.GetCurvePos({0.5, Global.DRIVE_OFFSET}, {Global.DRIVE_OFFSET, 0.5}, t, 1)
			end,
			dirFunc = function (t)
				t = t/innerLength
				return roadUtil.GetCurveDir(t, 1)
			end,
			entry = 0,
			destination = 1,
			length = innerLength,
			turn = "left",
		},
		{ -- Inner corner, bottom to left
			posFunc = function (t)
				t = t/innerLength
				return roadUtil.GetCurvePos({-Global.DRIVE_OFFSET, 0.5}, {-0.5, Global.DRIVE_OFFSET}, t, -1)
			end,
			dirFunc = function (t)
				t = t/innerLength
				return roadUtil.GetCurveDir(t, 1, 3)
			end,
			entry = 1,
			destination = 2,
			length = innerLength,
			turn = "left",
		},
		{ -- Outer corner, bottom to right
			posFunc = function (t)
				if t < 0.25 then
					return {-Global.DRIVE_OFFSET, 0.5 - t}
				elseif t < 0.25 + outLength then
					t = (t - 0.25)/outLength
					return roadUtil.GetCurvePos({-Global.DRIVE_OFFSET, 0.25}, {0.25, -Global.DRIVE_OFFSET}, t, -1)
				else
					return {t - outLength, -Global.DRIVE_OFFSET}
				end
			end,
			dirFunc = function (t)
				if t < 0.25 then
					return -math.pi/2
				elseif t < 0.25 + outLength then
					t = (t - 0.25)/outLength
					return roadUtil.GetCurveDir(t, -1, 1)
				else
					return 0
				end
			end,
			entry = 1,
			destination = 0,
			length = 0.5 + outLength,
			turn = "right",
		},
		{ -- Outer corner, left to bottom
			posFunc = function (t)
				if t < 0.25 then
					return {-0.5 + t, -Global.DRIVE_OFFSET}
				elseif t < 0.25 + outLength then
					t = (t - 0.25)/outLength
					return roadUtil.GetCurvePos({-0.25, -Global.DRIVE_OFFSET}, {Global.DRIVE_OFFSET, 0.25}, t, 1)
				else
					return {Global.DRIVE_OFFSET, -outLength + t}
				end
			end,
			dirFunc = function (t)
				if t < 0.25 then
					return 0
				elseif t < 0.25 + outLength then
					t = (t - 0.25)/outLength
					return roadUtil.GetCurveDir(t, -1, 2)
				else
					return math.pi/2
				end
			end,
			entry = 2,
			destination = 1,
			length = 0.5 + outLength,
			turn = "right",
		},
	},
}