local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "car_grey",
	imageSelection = {
		house_blue = "car_blue",
		house_white = "car_white",
		house_green = "car_green",
		house_yellow = "car_yellow",
		house_red = "car_red",
	},
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
