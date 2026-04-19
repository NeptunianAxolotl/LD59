local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "basic_car",
	maxSpeed = 1.15,
	accel = 2.2,
	deccel = 4.5,
	slowDeccel = 2,
	choiceRatio = {
		straight = 0.35,
		left = 0.25,
		right = 0.2,
	},
	length = 20,
	width = 12,
	friendlyCollision = true,
	stopTimer = 0.4,
	wrongTurnChance = 0,
}

return util.MergeTable(def, shared)
