local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "medic",
	maxSpeed = 1.2,
	accel = 2.2,
	deccel = 4.2,
	slowDeccel = 2,
	choiceRatio = {
		straight = 0.35,
		left = 0.25,
		right = 0.2,
	},
	length = 20,
	width = 12,
	cureSickness = true,
	friendlyCollision = true,
	ignoreSignal = true,
	stopTimer = 0.2,
	wrongTurnChance = 0,
}

return util.MergeTable(def, shared)
