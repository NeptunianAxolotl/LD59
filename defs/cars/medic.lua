local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "ambulance",
	animate = {
		"police_blue",
		"police_red",
	},
	maxSpeed = 1.25,
	ignoreRoadSpeed = true,
	accel = 1.7,
	deccel = 5,
	slowDeccel = 2,
	crashEndurance = 2.8,
	crashDamage = 1,
	choiceRatio = {
		straight = 0.35,
		left = 0.25,
		right = 0.2,
	},
	cureSickness = true,
	friendlyCollision = true,
	ignoreSignal = true,
	stopTimer = 0.2,
	wrongTurnChance = 0,
	returnAfterVisit = "doctor",
	onArrive = function (self, building)
		if building and building.def.name == "house" then
			self.sickness = math.min(1, (building.sickness or 0)) *0.4
			GameHandler.AddStat("doctorVisitHouse_sinceAccident")
			GameHandler.AddStat("doctorVisitHouse")
		end
		if building and building.def.name == "doctor" then
			GameHandler.AddStat("returnedToDoctor_sinceAccident")
			GameHandler.AddStat("returnedToDoctor")
		end
	end,
	
	behind = -1,
}

return util.MergeTable(def, shared)
