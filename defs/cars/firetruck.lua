local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "fireengine",
	animate = {
		"police_blue",
		"police_red",
	},
	maxSpeed = 1.25,
	ignoreRoadSpeed = true,
	accel = 1.7,
	deccel = 5,
	slowDeccel = 2,
	crashEndurance = 4.8,
	crashDamage = 2.2,
	choiceRatio = {
		straight = 0.35,
		left = 0.25,
		right = 0.2,
	},
	cureFire = true,
	friendlyCollision = true,
	ignoreSignal = true,
	ignoreCollision = true,
	stopTimer = 0.2,
	wrongTurnChance = 0,
	onArrive = function (self, building)
		if building then
		
		end
	end,
	behind = -2,
}

return util.MergeTable(def, shared)
