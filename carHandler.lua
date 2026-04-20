
carUtil = require("utilities/carUtilities")

local NewCar = require("objects/car")

local self = {}
local api = {}

function api.AddCar(carType, gridPos, targetPos, targetBuildingPos, wrongSideSpawn, entry, dest, fullSpeed)
	carData = {
		carType = carType,
	}
	carID = IterableMap.GetNewUniqueKey(self.carList)
	local car = NewCar(carData, gridPos, targetPos, targetBuildingPos, wrongSideSpawn, carID, entry, dest, fullSpeed)
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
	if not (carDef.friendlyCollision and otherDef.friendlyCollision and car.OnSamePath(other)) then
		local damage = carDef.crashDamage * otherDef.crashDamage * (1 + car.GetSpeed() + other.GetSpeed())
		car.AddCrashProgress(self.lastDt * (1 + Global.CRASH_PROGRESS_MULT * damage))
		other.AddCrashProgress(self.lastDt * (1 + Global.CRASH_PROGRESS_MULT * damage))
    self.world.RegisterCollision()
	end
	
	if carDef.friendlyCollision and otherDef.friendlyCollision and (not car.isCrashed) and (not other.isCrashed) then
		-- Some other situation -> slower car lets the faster car past.
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


function api.GetCarCount(carType)
	return IterableMap.SumWithFunction(self.carList, "CountIfMatch", carType)
end

function api.Update(dt)
	self.lastDt = dt
	IterableMap.ApplySelfRandomOrder(self.carList, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.carList, "Draw", drawQueue)
end

function api.Initialize(world)
	self = {
		carList = IterableMap.New(),
		world = world,
		lastDt = 0
	}
end

return api
