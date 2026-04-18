
return {
	baseImage = "source_small",
	spawnCar = {
		period = 2,
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
			posFunc = function (t)
				return {t, -Global.DRIVE_OFFSET}
			end,
			dirFunc = function (t)
				return 0
			end,
			entry = 2,
			destination = 0,
			length = 0.5,
		},
		{ -- right to left
			posFunc = function (t)
				return {0.5 - t, Global.DRIVE_OFFSET}
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