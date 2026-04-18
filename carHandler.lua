
local NewCar = require("objects/car")

local self = {}
local api = {}

function api.AddCar(carType, gridPos, entry, dest)
	carData = {
		carType = carType,
	}
	local car = NewCar(carData, gridPos, entry, dest)
	IterableMap.Add(self.carList, car)
end

function api.NotifyGameLoss()
	-- Blow up all the cars
end

function api.Update(dt)
	IterableMap.ApplySelfRandomOrder(self.carList, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.carList, "Draw", drawQueue)
end

function api.Initialize(world)
	self = {
		carList = IterableMap.New(),
		world = world,
	}
end

return api
