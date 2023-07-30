extends Node
#Singleton EntityDefs

const SHIP_ID_MINING_DRONE := "mining_drone"

const STRUCTURE_ID_TEST_STATION := "test_station"

const SCENE_PATHS := {
	SHIP_ID_MINING_DRONE : "res://scenes/ship/mining_drone.tscn",
	STRUCTURE_ID_TEST_STATION : "res://game/entity/structure/structure.tscn"
}

const CONSTRUCTION_COSTS := {
	STRUCTURE_ID_TEST_STATION : {
		Items.ID_IRON_ORE : 12
	}
}

var SCENES := {}

var definitions : Dictionary = {}

func get_scene(entity_id : String) -> PackedScene:
	if(SCENES.has(entity_id)):
		return SCENES[entity_id]
	
	if(!SCENE_PATHS.has(entity_id)):
		return null
		
	var scene := load(SCENE_PATHS[entity_id])
	SCENES[entity_id] = scene
	return scene

func get_construction_cost(entity_id : String) -> Dictionary:
	return CONSTRUCTION_COSTS.get(entity_id, {})
