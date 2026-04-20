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
	maxSpeed = 0.9,
	accel = 1.5,
	deccel = 3.5,
	slowDeccel = 2,
	crashEndurance = 2,
	crashDamage = 3,
	choiceRatio = {
		straight = 0.35,
		left = 0.25,
		right = 0.2,
	},
	drawTargetPos = true,
	isDrunk = true,
	ignoreSignal = true,
	ignoreCollision = true,
	stopTimer = 0.4,
	wobble = 1,
	wrongTurnChance = 0,
	onDestroy = function (self)
		local building = self.targetBuildingPos and BuildingHandler.GetBuildingAtPos(self.targetBuildingPos)
		if building then
			building.isDrunk = false
			building.drunkArriving = false
		end
	end,
	onArrive = function (self, building)
		if building and building.def.name == "house" then
			GameHandler.AddStat("drunkArrivals_sinceAccident")
			GameHandler.AddStat("drunkArrivals_sinceDrunkAccident")
			GameHandler.AddStat("drunkArrivals")
		elseif building and building.def.name == "kebab" then
			GameHandler.AddStat("kebabEaten")
		end
	end,
	behind = 1,
}

return util.MergeTable(def, shared)
