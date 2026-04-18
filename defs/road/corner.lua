
return {
	baseImage = "corner_small",
	paths = {
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
		{ -- Outer corner, bottom to right
			posFunc = function (t, enterOffset, destOffset)
				return roadUtil.OuterCornerPos(t, enterOffset, destOffset)
			end,
			dirFunc = function (t)
				return roadUtil.OuterCornerDir(t)
			end,
			entry = 1,
			destination = 0,
			length = roadUtil.GetFullOuterLength(),
			turn = "right",
		},
	},
}