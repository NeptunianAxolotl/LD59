
carUtil = require("utilities/carUtilities")

local NewCar = require("objects/car")

local self = {}
local api = {}

function api.AddCar(carType, gridPos, targetPos, entry, dest, fullSpeed)
	carData = {
		carType = carType,
	}
	carID = IterableMap.GetNewUniqueKey(self.carList)
	local car = NewCar(carData, gridPos, targetPos, carID, entry, dest, fullSpeed)
	IterableMap.Add(self.carList, carID, car)
end

function api.HandleCollision(carID, otherID)
	local car = IterableMap.Get(self.carList, carID)
	local other = IterableMap.Get(self.carList, otherID)
	if not (car and not car.IsDestroyed() and other and not other.IsDestroyed()) then
		return
	end
	local carDef = car.GetDef()
	local otherDef = other.GetDef()
	if carDef.friendlyCollision and otherDef.friendlyCollision then
		if car.GetSpeed() < other.GetSpeed() then
			car.DoHardBrake()
		else
			other.DoHardBrake()
		end
	end
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
