
return {
	baseImage = "house",
	destinationType = "house",
	spawnRoads = {
		straight = true,
		corner = true,
	},
	spawnCar = {
		period = 1.25,
		carType = "basic_car",
		entry = 2,
	},
	updateFunc = function (self, dt)
		self.spawnTimer = (self.spawnTimer or self.def.spawnCar.period) - dt
		if self.spawnTimer <= 0 then
			if not roadUtil.IsOccupied(self, occupyVector) then
				CarHandler.AddCar(self.def.spawnCar.carType, self.pos, (self.def.spawnCar.entry + self.rotation)%4)
			end
			self.spawnTimer = self.def.spawnCar.period + math.random()
		end
	end,
}