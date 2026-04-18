
local outLength = roadUtil.GetCurveLength(Global.DRIVE_OFFSET)
local innerLength = roadUtil.GetCurveLength(0.5 - Global.DRIVE_OFFSET)


return {
	baseImage = "corner_small",
	paths = {
		{ -- Inner corner, right to bottom
			posFunc = function (t)
				t = t/innerLength
				return roadUtil.GetCurvePos({0.5, Global.DRIVE_OFFSET}, {Global.DRIVE_OFFSET, 0.5}, 0.5 - Global.DRIVE_OFFSET, t, 1)
			end,
			dirFunc = function (t)
				t = t/innerLength
				return roadUtil.GetCurveDir(t, 1)
			end,
			entry = 0,
			destination = 1,
			length = innerLength,
		},
		{ -- Outer corner, bottom to right
			posFunc = function (t)
				if t < 0.5 then
					return {-Global.DRIVE_OFFSET, 0.5 - t}
				elseif t < 0.5 + outLength then
					t = (t - 0.5)/outLength
					return roadUtil.GetCurvePos({-Global.DRIVE_OFFSET, 0}, {0, -Global.DRIVE_OFFSET}, Global.DRIVE_OFFSET, t, -1)
				else
					return {t - (0.5 + outLength), -Global.DRIVE_OFFSET}
				end
			end,
			dirFunc = function (t)
				if t < 0.5 then
					return -math.pi/2
				elseif t < 0.5 + outLength then
					t = (t - 0.5)/outLength
					return roadUtil.GetCurveDir(t, -1)
				else
					return 0
				end
			end,
			entry = 1,
			destination = 0,
			length = 1 + outLength,
		},
	},
}