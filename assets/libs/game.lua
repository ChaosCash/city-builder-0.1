game = {}


local background_go_id = "background"

local tile_types = {
	["plains"] = {
		["type"] = "plains",
		["rarity"] = 100,
		["sprites"] = {
			"plains tile"
		},
		["stats"] = {
			["build_space"] = {
				["standard"] = {
					["max"] = 1600,
					["min"] = 800
				},
				["player_spawn"] = {
					["max"] = 2000,
					["min"] = 1000
				}
			},
			["build_speed"] = {
				["standard"] = {
					["max"] = 130,
					["min"] = 90
				},
				["player_spawn"] = {
					["max"] = 150,
					["min"] = 120
				}
				
			}
		},

		["deposits"] = {
			["wood"] = {
				["standard"] = {
					["chance"] = 70,
					["rolls"] = 3,
					["min"] = 1
				},
				["player_spawn"] = {
					["chance"] = 70,
					["rolls"] = 5,
					["min"] = 2
				}
			}
		}
	},

	
	["forest"] = {
		["type"] = "forest",
		["rarity"] = 100,
		["sprites"] = {
			"forest tile"
		},
		["stats"] = {
			["build_space"] = {
				["standard"] = {
					["max"] = 1100,
					["min"] = 700
				},
				["player_spawn"] = {
					["max"] = 1600,
					["min"] = 900
				}
			},
			["build_speed"] = {
				["standard"] = {
					["max"] = 120,
					["min"] = 80
				},
				["player_spawn"] = {
					["max"] = 140,
					["min"] = 90
				}

			}
		},

		["deposits"] = {
			["wood"] = {
				["standard"] = {
					["chance"] = 70,
					["rolls"] = 7,
					["min"] = 2
				},
				["player_spawn"] = {
					["chance"] = 70,
					["rolls"] = 10,
					["min"] = 3
				}
			}
		}
	},
	

	["mountains"] = {
		["type"] = "mountains",
		["rarity"] = 70,
		["sprites"] = {
			"mountains tile"
		},
		["stats"] = {
			["build_space"] = {
				["standard"] = {
					["max"] = 900,
					["min"] = 500
				},
				["player_spawn"] = {
					["max"] = 1400,
					["min"] = 800
				}
			},
			["build_speed"] = {
				["standard"] = {
					["max"] = 100,
					["min"] = 70
				},
				["player_spawn"] = {
					["max"] = 120,
					["min"] = 80
				}

			}
		},

		["deposits"] = {
			["wood"] = {
				["standard"] = {
					["chance"] = 70,
					["rolls"] = 3,
					["min"] = 1
				},
				["player_spawn"] = {
					["chance"] = 70,
					["rolls"] = 5,
					["min"] = 2
				}
			}
		}
	}
}



function game.create_game_instance(game_name, privacy, session_type, player_count, map_width, map_height)
	create_map(map_width, map_height, player_count)
	
	
end



function create_map(width, height, player_count)
	local tile_pick_ranges = {}
	local highest_pick_number = 0
	for tile_name, tile_type in pairs(tile_types) do
		tile_pick_ranges[tile_name] = highest_pick_number + tile_type["rarity"]
		highest_pick_number = highest_pick_number + tile_type["rarity"]
	end

	local available_tiles = {}
	game.map = {} 
	for x = 1, width do
		game.map[x] = {}
		for y = 1, height do
			table.insert(available_tiles, {["x"] = x, ["y"] = y})
			local cur_pick_number = math.random(0, highest_pick_number)
			for tile_name, pick_range in pairs(tile_pick_ranges) do
				if cur_pick_number < pick_range then
					game.map[x][y] = generate_random_tile(tile_name, "standard")
					break
				end
			end
		end
	end


	for cur_player = 1, player_count do
		local cur_tile_number = math.random(1, #available_tiles)
		local cur_pick_number = math.random(0, highest_pick_number)
		for tile_name, pick_range in pairs(tile_pick_ranges) do
			if cur_pick_number < pick_range then
				game.map[available_tiles[cur_tile_number]["x"]][available_tiles[cur_tile_number]["y"]] = generate_random_tile(tile_name, "player_spawn")
			end
		end
	end

	game.map_width = #game.map
	game.map_height = #game.map[1]
end



function generate_random_tile(tile_name, stat_type)
	stat_type = stat_type or "standard"
	local cur_tile_type = tile_types[tile_name]
	local cur_tile = {["stats"] = {}, ["deposits"] = {},["type"] = tile_name}
	
	for stat_name, stat in pairs(cur_tile_type["stats"]) do
		cur_tile["stats"][stat_name] = math.random(stat[stat_type]["min"], stat[stat_type]["max"])
	end
	
	for deposit_type, deposit in pairs(cur_tile_type["deposits"]) do
		for i = 1, deposit[stat_type]["rolls"] do
			if math.random(1, 100) <= deposit[stat_type]["chance"] then
				cur_tile["deposits"][deposit_type] = (cur_tile["deposits"][deposit_type] or 0) + 1
			end
		end
	end

	
	cur_tile["sprite"] = cur_tile_type["sprites"][math.random(1, #tile_types[tile_name]["sprites"])]

	return cur_tile
end



function game.print_map()
	local map = game.map
	for x, slice in pairs(map) do
		for y, tile in pairs(slice) do
			local game_object = factory.create("#test factory", vmath.vector3(x * 100,y * 100,0))
			sprite.play_flipbook(game_object, tile["sprite"])
		end
	end
	--print(game.map_width * 100 / 2, game.map_height * 100 / 2,)
	go.set_position(vmath.vector3(game.map_width * 100 / 2, game.map_height * 100 / 2, -1), background_go_id)
end