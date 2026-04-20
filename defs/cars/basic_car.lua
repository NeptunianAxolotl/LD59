local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "car_blue",
	maxSpeed = 0.92,
	accel = 1.7,
	deccel = 3.2,
	slowDeccel = 2,
	crashEndurance = 1.6,
	crashDamage = 0.85,
	choiceRatio = {
		straight = 0.35,
		left = 0.25,
		right = 0.2,
	},
	friendlyCollision = true,
	stopTimer = 0.4,
	wrongTurnChance = 0.2,
}

return util.MergeTable(def, shared)
