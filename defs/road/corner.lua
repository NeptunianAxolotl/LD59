
local outLength = roadUtil.GetCurveLength(Global.DRIVE_OFFSET)
local innerLength = roadUtil.GetCurveLength(0.5 - Global.DRIVE_OFFSET)


return {
	baseImage = "corner_small",
	paths = {
		{ -- Inner corner, right to bottom
			posFunc = function (t)
				return roadUtil.GetCurvePos({Global.DRIVE_OFFSET, 0}, {Global.DRIVE_OFFSET, 0}, 0.5 - Global.DRIVE_OFFSET, t)
			end,
			dirFunc = function (t)
				return roadUtil.GetCurveDir({Global.DRIVE_OFFSET, 0}, {Global.DRIVE_OFFSET, 0}, 0.5 - Global.DRIVE_OFFSET, t)
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
					return roadUtil.GetCurvePos({-Global.DRIVE_OFFSET, 0}, {0, -Global.DRIVE_OFFSET}, Global.DRIVE_OFFSET, t)
				else
					return {t - (0.5 + outLength), -Global.DRIVE_OFFSET}
				end
			end,
			dirFunc = function (t)
				if t < 0.5 then
					return -math.pi/2
				elseif t < 0.5 + outLength then
					return roadUtil.GetCurvePos({-Global.DRIVE_OFFSET, 0}, {0, -Global.DRIVE_OFFSET}, Global.DRIVE_OFFSET, t)
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