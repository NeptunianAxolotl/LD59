local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "medic",
	maxSpeed = 1.15,
	ignoreRoadSpeedChange = true,
	accel = 1.7,
	deccel = 5,
	slowDeccel = 2,
	crashEndurance = 3,
	crashDamage = 1,
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
	returnAfterVisit = "doctor",
}

return util.MergeTable(def, shared)
