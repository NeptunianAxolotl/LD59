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
			house = 0.8,
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
			lightClicks = 3,
		},
	},
	{
		-- Progress by having three drunks arrive in a row.
		map = "level_1",
		spawnMult = {
			highway = 3.2,
			house = 0.2,
			pub = 1.3,
		},
		redrawChance = {
			house = 0.8,
		},
		sickRate = 0,
		heading = "Drink Driving",
		text = "You control the signals.\n - Click a light to toggle it.\n - Click the middle of an intersection to lock it.\nToggle lights a few times to continue.",
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
