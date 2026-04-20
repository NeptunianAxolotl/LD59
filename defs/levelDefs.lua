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
			drunk = 0,
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
			house = 0.3,
			pub = 2.8,
			houseBecomeSick = 0,
			forceRedLight = 0.5,
		},
		carLimit = {
			drunk = 1,
		},
		redrawChance = {
			house = 0.6,
		},
		heading = "Drink Driving",
		text = "The pub is emptying and all the drink drivers need to get home safely. Try to have two arrive safely.\n\nDrunk drivers cannot see traffic lights or other cars.",
		showStats = {
			"accidents",
			"drunkArrivals_sinceDrunkAccident",
		},
		flashStat = {
			drunkArrivals_sinceDrunkAccident = true,
		},
		advanceRequirement = {
			drunkArrivals_sinceDrunkAccident = 2,
		},
	},
	{
		-- Hospital is introduced.
		map = "level_2",
		spawnMult = {
			highway = 0.8,
			house = 0.9,
			pub = 0.8,
			sickness = 0.7,
			houseBecomeSick = 1,
			forceRedLight = 0.75,
		},
		carLimit = {
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
			doctorVisitHouse = true,
			returnedToDoctor = true,
		},
		advanceRequirement = {
			doctorVisitHouse = 5,
			returnedToDoctor = 5,
		},
	},
	{
		-- Second round of drunks
		map = "level_3",
		spawnMult = {
			highway = 0.8,
			pub = 3.5,
			house = 0.7,
			houseBecomeSick = 0.8,
			forceRedLight = 0.85,
		},
		carLimit = {
			drunk = 1,
		},
		redrawChance = {
			house = 0.4,
		},
		heading = "More Drunks",
		text = "A growing population means more drunk drivers. Try to get at least more two home without a crash.",
		showStats = {
			"accidents",
			"sickDeaths",
			"returnedToDoctor",
			"doctorVisitHouse",
		},
		showStats = {
			"accidents",
			"sickDeaths",
			"drunkArrivals_sinceDrunkAccident",
		},
		flashStat = {
			drunkArrivals_sinceDrunkAccident = true,
		},
		resetStats = {
			"drunkArrivals_sinceDrunkAccident"
		},
		advanceRequirement = {
			drunkArrivals_sinceDrunkAccident = 2,
		},
	},
	{
		-- Police introduced
		map = "level_4",
		spawnMult = {
			highway = 0.8,
			pub = 2,
			house = 0.7,
			houseBecomeSick = 0.7,
		},
		carLimit = {
			drunk = 4,
			police = 1,
		},
		redrawChance = {
			house = 0.2,
		},
		heading = "Police",
		text = "A growing population means more drunk drivers. Try to get at least two home in a row.",
		showStats = {
			"accidents",
			"sickDeaths",
			"returnedToDoctor",
			"doctorVisitHouse",
		},
		showStats = {
			"accidents",
			"sickDeaths",
			"drunkArrivals_sinceDrunkAccident",
		},
		flashStat = {
			drunkArrivals_sinceDrunkAccident = true,
		},
		resetStats = {
			"drunkArrivals_sinceDrunkAccident"
		},
		advanceRequirement = {
			drunkArrivals_sinceDrunkAccident = 2,
		},
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
