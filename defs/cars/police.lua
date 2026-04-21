local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "police_car",
	animate = {
		"police_blue",
		"police_red",
	},
	maxSpeed = 1,
	accel = 1.8,
	deccel = 3.8,
	slowDeccel = 2,
	crashEndurance = 3.2,
	crashDamage = 0.8,
	choiceRatio = {
		straight = 0.35,
		left = 0.25,
		right = 0.2,
	},
	policeRadius = Global.DRUNK_FIND_DISTANCE,
	ignoreSignal = true,
	friendlyCollision = true,
	isPolice = true,
	stopTimer = 0.4,
	wrongTurnChance = 0.9,
}

return util.MergeTable(def, shared)
