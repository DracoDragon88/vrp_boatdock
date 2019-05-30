local boatshop = {
	opened = false,
	title = "Boat dealer",
	currentmenu = "main",
	lastmenu = nil,
	currentpos = nil,
	selectedbutton = 0,
	marker = { r = 0, g = 155, b = 255, a = 200, type = 1 },
	menu = {
		x = 0.9,
		y = 0.08,
		width = 0.2,
		height = 0.04,
		buttons = 10,
		from = 1,
		to = 10,
		scale = 0.4,
		font = 0,
		["main"] = {
			title = "CATEGORIES",
			name = "main",
			buttons = {
				{name = "Pneumatic", description = ""},
				{name = "Sails", description = ""},
				{name = "Jetski", description = ""},
				--{name = "Submersible", description = ""},
				{name = "Trawler", description = ""},
				{name = "Vedette", description = ""}
			}
		},
		["Pneumatic"] = {
			title = "Pneumatic",
			name = "Pneumatic",
			buttons = {
				{name = "Dinghy 2Seat", costs = 20000, description = {}, model = "dinghy2"},
				{name = "Dinghy 4Seat", costs = 25000, description = {}, model = "dinghy"},
				{name = "Dinghy", costs = 20000, description = {}, model = "dinghy3"},
				{name = "Dinghy Yacht", costs = 200000, description = {}, model = "dinghy4"}
			}
		},
		["Sails"] = {
			title = "Sails",
			name = "Sails",
			buttons = {
				{name = "Marquis", costs = 200000, description = {}, model = "marquis"}
			}
		},
		["Jetski"] = {
			title = "Jetski",
			name = "Jetski",
			buttons = {
				{name = "Seashark", costs = 5000, description = {}, model = "seashark"},
				-- {name = "Seashark Lifeguard", costs = 5000, description = {}, model = "seashark2"},
				{name = "Seashark Yacht", costs = 5000, description = {}, model = "seashark3"}
			}
		},
		["Submersible"] = {
			title = "Submersible",
			name = "Submersible",
			buttons = {
				{name = "Kraken", costs = 500000, description = {}, model = "kraken"},
				{name = "Submersible", costs = 665000, description = {}, model = "submersible"}
				-- {name = "Submersible2", costs = 665000, description = {}, model = "submersible2"}
			}
		},
		["Trawler"] = {
			title = "Trawler",
			name = "Trawler",
			buttons = {
				{name = "Tug", costs = 160000, description = {}, model = "tug"}
			}
		},
		["Vedette"] = {
			title = "Vedette",
			name = "Vedette",
			buttons = {
				{name = "Speeder", costs = 8000, description = {}, model = "speeder"},
				{name = "Speeder2", costs = 8000, description = {}, model = "speeder2"},
				{name = "Toro", costs = 20000, description = {}, model = "toro"},
				{name = "Toro Yacht", costs = 210000, description = {}, model = "toro2"},
				-- {name = "Police", costs = 21000, description = {}, model = "predator"},
				{name = "Tropic", costs = 22000, description = {}, model = "tropic"},
				{name = "Tropic Yacht", costs = 220000, description = {}, model = "tropic2"},
				{name = "Jetmax", costs = 75000, description = {}, model = "jetmax"},
				{name = "Suntrap", costs = 249000, description = {}, model = "suntrap"},
				{name = "Squalo", costs = 715000, description = {}, model = "squalo"}
			}
		}
	}
}

return boatshop