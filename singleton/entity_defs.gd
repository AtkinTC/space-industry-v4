extends Node
#Singleton EntityDefs

const STRUCTURE_ID_TEST_STATION := "test_station"

const CONSTRUCTION_COSTS := {
	STRUCTURE_ID_TEST_STATION : {
		Items.ID_IRON_ORE : 12
	}
}

const ship_def_dir := "res://resources/entity_definitions/ship_definitions"
const structure_def_dir := "res://resources/entity_definitions/structure_definitions"

var entity_defs : Dictionary = {}

func _ready() -> void:
	var ship_def_filenames := DirAccess.get_files_at(ship_def_dir)
	print("Loading ShipDefinitions from dir : " + ship_def_dir)
	if(ship_def_filenames == null || ship_def_filenames.is_empty()):
		print_rich("[color=red]No Ship Definitions found![/color]")
	for filename in ship_def_filenames:
		print("\t..." + filename)
		var file_path := ship_def_dir + "/" + filename
		var resource : Resource = load(file_path)
		if(resource == null || !(resource is ShipDefinition)):
			print_rich("[color=red]Invalid Ship Definition at : %s![/color]" % file_path)
			continue
		var ship_def := resource as ShipDefinition
		var id := ship_def.entity_id
		if(entity_defs.has(id)):
			print_rich("[color=red]Duplicate ship entity_id : %s![/color]" % id)
			continue
		entity_defs[id] = ship_def
	
	var structure_def_filenames := DirAccess.get_files_at(structure_def_dir)
	print("Loading StructureDefinitions from dir : " + structure_def_dir)
	if(structure_def_filenames == null || structure_def_filenames.is_empty()):
		print_rich("[color=red]No Structure Definitions found![/color]")
	for filename in structure_def_filenames:
		print("\t..." + filename)
		var file_path := structure_def_dir + "/" + filename
		var resource : Resource = load(file_path)
		if(resource == null || !(resource is StructureDefinition)):
			print_rich("[color=red]Invalid Structure Definition at : %s![/color]" % file_path)
			continue
		var structure_def := resource as StructureDefinition
		var id := structure_def.entity_id
		if(entity_defs.has(id)):
			print_rich("[color=red]Duplicate Structure entity_id : %s![/color]" % id)
			continue
		entity_defs[id] = structure_def

func get_entity_definition(entity_id : String) -> EntityDefinition:
	return entity_defs.get(entity_id) as EntityDefinition

func get_ship_definition(entity_id : String) -> ShipDefinition:
	var ship_def : ShipDefinition = entity_defs.get(entity_id) 
	return ship_def

func get_structure_definition(entity_id : String) -> StructureDefinition:
	var structure_def : StructureDefinition = entity_defs.get(entity_id) 
	return structure_def

func get_scene(entity_id : String) -> PackedScene:
	var entity_def := get_entity_definition(entity_id)
	if(entity_def == null):
		return null
	return entity_def.scene

func get_construction_cost(entity_id : String) -> Dictionary:
	return CONSTRUCTION_COSTS.get(entity_id, {})