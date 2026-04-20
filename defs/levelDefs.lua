local levelDefs = {
	{
		-- Tutorial - click a road.
		map = "level_1",
		spawnMult = {
			highway = 2.8,
			house = 0.3,
			pub = 0,
			houseBecomeSick = 0,
			houseBecomeFire = 0,
			forceRedLight = 0.4,
		},
		redrawChance = {
			house = 0.4,
		},
		carLimit = {
			drunk = 0,
		},
		heading = "Traffic Control Publican",
		text = "Control the traffic signals to ensure your patrons make it home in one piece.\n - Toggle lights with Left Mouse Button.\n - Lock intersections with Left Mouse Button.\n\nToggle a few lights to continue.",
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
			houseBecomeFire = 0,
			forceRedLight = 0.4,
		},
		carLimit = {
			drunk = 1,
		},
		redrawChance = {
			house = 0.2,
		},
		heading = "Closing Time",
		text = "The pub is emptying out - time to get the patrons home safely. They ignore lights and other cars. Have two in a row reach home without crashing.",
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
			highway = 0.9,
			house = 0.9,
			doctor = 1.5,
			pub = 0.8,
			sickness = 0.7,
			houseBecomeSick = 2,
			houseBecomeFire = 0,
			forceRedLight = 0.6,
		},
		carLimit = {
			drunk = 2,
		},
		heading = "Mysterious Illness",
		text = "The chef does not always serve the freshest food. Clear the way for ambulances to make it through. Ambulances ignore lights.",
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
			doctorVisitHouse = 10,
			returnedToDoctor = 10,
		},
	},
	{
		-- Second round of drunks
		map = "level_3",
		spawnMult = {
			highway = 0.8,
			pub = 3.5,
			house = 0.7,
			houseBecomeSick = 0.7,
			houseBecomeFire = 0,
			forceRedLight = 0.7,
		},
		carLimit = {
			drunk = 2,
		},
		redrawChance = {
			house = 0.2,
		},
		heading = "Big Party",
		text = "The town is growing at an alarming rate. More people need to be guided home safely.",
		showStats = {
			"accidents",
			"sickDeaths",
			"drunkArrivals_new",
		},
		flashStat = {
			drunkArrivals_new = true,
		},
		resetStats = {
			"drunkArrivals_new"
		},
		advanceRequirement = {
			drunkArrivals_new = 5,
		},
	},
	{
		-- Police introduced
		map = "level_4",
		spawnMult = {
			highway = 0.8,
			pub = 2,
			house = 0.7,
			station = 2.5,
			houseBecomeSick = 0.7,
			houseBecomeFire = 0,
			forceRedLight = 0.8,
		},
		carLimit = {
			drunk = 3,
			police = 1,
		},
		heading = "Police Presence",
		text = "Some people think that our growing town needs policing. See to it that our valued customers make it home without being arrested - three in a row. Crashing is fine.",
		showStats = {
			"accidents",
			"sickDeaths",
			"arrests",
			"drunkArrivals_sinceCaught",
		},
		flashStat = {
			drunkArrivals_sinceCaught = true,
		},
		resetStats = {
			"drunkArrivals_sinceCaught"
		},
		advanceRequirement = {
			drunkArrivals_sinceCaught = 3,
		},
	},
	{
		map = "level_5",
		spawnMult = {
			highway = 0.8,
			pub = 1,
			house = 0.8,
			station = 1,
			houseBecomeSick = 0.6,
			houseBecomeFire = 1.35,
			forceRedLight = 0.9,
		},
		carLimit = {
			drunk = 6,
			police = 2,
			firetruck = 3,
		},
		heading = "Incendiary",
		text = "The newly established fire department will help immensely with all the fires that are about to occur. Don't worry too much about the trucks, they are well armoured.",
		showStats = {
			"accidents",
			"sickDeaths",
			"fireDeaths",
			"firePutOut",
		},
		flashStat = {
			firePutOut = true,
		},
		advanceRequirement = {
			firePutOut = 3,
		},
	},
	{
		map = "level_6",
		spawnMult = {
			highway = 0.8,
			pub = 1.8,
			house = 0.8,
			station = 1,
			houseBecomeSick = 0.6,
			houseBecomeFire = 0.18,
		},
		carLimit = {
			drunk = 10,
			police = 1,
			firetruck = 3,
		},
		heading = "Just a Snack",
		text = "A kebab shop has opened on the edge of town. Perfect for a bite on the way home. Send some patrons its way.",
		showStats = {
			"accidents",
			"sickDeaths",
			"fireDeaths",
			"kebabEaten",
		},
		flashStat = {
			kebabEaten = true,
		},
		advanceRequirement = {
			kebabEaten = 3,
		},
	},
	{
		map = "level_7",
		spawnMult = {
			highway = 1.2,
			pub = 0.9,
			house = 1.1,
			station = 1,
			houseBecomeSick = 0.6,
			houseBecomeFire = 0.35,
		},
		carLimit = {
			drunk = 6,
			police = 3,
			firetruck = 3,
		},
		redrawChance = {
			kebab = 0.7,
			house = 0.85,
			highway = 0.9,
		},
		heading = "The Advent of Cinema",
		text = "A town with a cinema has everything. People from near and far wants to see the latest movie. Clear them path through the chaos.",
		showStats = {
			"accidents",
			"sickDeaths",
			"fireDeaths",
			"cinemaVisits",
		},
		flashStat = {
			cinemaVisits = true,
		},
		advanceRequirement = {
			cinemaVisits = 20,
		},
	},
	{
		map = "level_8",
		spawnMult = {
			houseBecomeSick = 1.8,
			houseBecomeFire = 0.5,
		},
		carLimit = {
			drunk = 12,
			police = 3,
			firetruck = 3,
		},
		redrawChance = {
			kebab = 0.7,
		},
		heading = "The End",
		makeRecord = true,
		text = "Your time as traffic signal operator has come to an end. Thanks for playing!",
		showStats = {
			"totalTime",
			"totalDeaths",
			"fireDeaths",
			"sickDeaths",
			"returnedToDoctor",
			"kebabEaten",
			"arrests",
			"accidents",
		},
	},

}

return levelDefs
