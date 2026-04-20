local levelDefs = {
	{
		-- Tutorial - click a road.
		map = "level_1",
		spawnMult = {
			highway = 2.8,
			house = 0.3,
			pub = 0,
			houseBecomeSick = 0,
		},
		redrawChance = {
			house = 0.65,
		},
		carLimit = {
			basic_car = 80,
		},
		heading = "Traffic Terror",
		text = "You control the signals.\n - Click a light to toggle it.\n - Click the middle of an intersection to lock it.\n - Drivers ignore lights that are red for too long.\nToggle a few lights to continue.",
		showStats = {
			"lightClicks",
		},
		advanceRequirement = {
			lightClicks = 3,
		},
		flashStat = {
			lightClicks = true,
		},
	},
	{
		-- Progress by having three drunks arrive in a row.
		map = "level_1",
		spawnMult = {
			highway = 3.2,
			house = 0.2,
			pub = 2,
			houseBecomeSick = 0,
		},
		carLimit = {
			basic_car = 80,
			drunk = 2,
		},
		redrawChance = {
			house = 0.6,
		},
		heading = "Drink Driving",
		text = "The pub is emptying and all the drink drivers need to get home safely. Try to have three arrive home without a crash.\n\nDrunk drivers cannot see traffic lights or other cars.",
		showStats = {
			"accidents",
			"drunkArrivals_sinceAccident",
		},
		flashStat = {
			drunkArrivals_sinceAccident = true,
		},
		advanceRequirement = {
			drunkArrivals_sinceAccident = 3,
		},
	},
	{
		-- Hospital is introduced.
		map = "level_2",
		spawnMult = {
			sickness = 0.7,
			houseBecomeSick = 1,
		},
		carLimit = {
			basic_car = 80,
			drunk = 2,
		},
		redrawChance = {
			house = 0.6,
		},
		heading = "Illness",
		text = "Something was a bit wrong with the pub parma. Clear the way for ambulances to reach houses with sickness.",
		showStats = {
			"accidents",
			"sickDeaths",
			"returnedToDoctor",
			"doctorVisitHouse",
		},
		flashStat = {
			drunkArrivals_sinceAccident = true,
		},
		advanceRequirement = {
			doctorVisitHouse = 10,
			returnedToDoctor = 10,
		},
	},
	{
		map = "level_3",
	},
	{
		map = "level_4",
	},
	{
		map = "level_5",
	},
	{
		map = "level_6",
	},
	{
		map = "level_7",
	},
	{
		map = "level_8",
	},

}

return levelDefs
