
return {
	baseImage = "source_small",
	spawnCar = {
		period = 1.25,
		carType = "basic_car",
		entry = 2,
	},
	updateFunc = function (self, dt)
		self.spawnTimer = (self.spawnTimer or self.def.spawnCar.period) - dt
		if self.spawnTimer <= 0 then
			CarHandler.AddCar(self.def.spawnCar.carType, self.pos, (self.def.spawnCar.entry + self.rotation)%4)
			self.spawnTimer = self.def.spawnCar.period + math.random()
		end
	end,
	paths = {
		{ -- left to right
			posFunc = function (t, enterOffset, destOffset)
				local offset = util.AverageScalar(enterOffset, destOffset, t*2)
				return {t, -offset}
			end,
			dirFunc = function (t)
				return 0
			end,
			entry = 2,
			destination = 0,
			length = 0.5,
		},
		{ -- right to left
			posFunc = function (t, enterOffset, destOffset)
				local offset = util.AverageScalar(enterOffset, destOffset, t*2)
				return {0.5 - t, offset}
			end,
			dirFunc = function (t)
				return math.pi
			end,
			entry = 0,
			destination = 2,
			length = 0.5,
		},
	},
}