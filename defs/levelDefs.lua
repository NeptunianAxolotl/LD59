local levelDefs = {
	{
		-- Tutorial - click a road.
		map = "level_1",
		spawnMult = {
			highway = 2.8,
			house = 0.3,
			pub = 0,
		},
		redrawChance = {
			house = 0.65,
		},
		carLimit = {
			basic_car = 80,
		},
		sickRate = 0,
		heading = "Traffic Terror",
		text = "You control the signals.\n - Click a light to toggle it.\n - Click the middle of an intersection to lock it.\nToggle lights a few times to continue.",
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
			pub = 2.4,
		},
		carLimit = {
			basic_car = 80,
			drunk = 1,
		},
		redrawChance = {
			house = 0.6,
		},
		sickRate = 0,
		heading = "Drink Driving",
		text = "The pub is emptying and all the drink drivers need to get home safely. Try to have three arrive home without a crash.",
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
		map = "level_2",
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
