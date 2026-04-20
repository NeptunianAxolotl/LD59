local shared = util.CopyTable(require('defs/cars/shared'))

local def = {
	image = "ambulance",
	maxSpeed = 1.25,
	ignoreRoadSpeed = true,
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
	cureSickness = true,
	friendlyCollision = true,
	ignoreSignal = true,
	stopTimer = 0.2,
	wrongTurnChance = 0,
	returnAfterVisit = "doctor",
	onArrive = function (self, building)
		if building and building.def.name == "house" then
			self.sickness = (building.sickness or 0) / 3
			GameHandler.AddStat("doctorVisitHouse_sinceAccident")
			GameHandler.AddStat("doctorVisitHouse")
		end
		if building and building.def.name == "doctor" then
			GameHandler.AddStat("returnedToDoctor_sinceAccident")
			GameHandler.AddStat("returnedToDoctor")
		end
	end,
}

return util.MergeTable(def, shared)
