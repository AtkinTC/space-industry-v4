extends Node
# Singleton EntityDefs

const unit_def_dir := "res://resources/entity_definitions/unit_definitions"
const structure_def_dir := "res://resources/entity_definitions/structure_definitions"

var entity_defs := {}

func _init() -> void:
	load_def_type(unit_def_dir, entity_defs)
	load_def_type(structure_def_dir, entity_defs)

func load_def_type(source_directory : String, target_dictionary : Dictionary) -> void:
	print("Loading Definitions from dir : " + source_directory)
	var def_filenames := DirAccess.get_files_at(source_directory)
	if(def_filenames == null || def_filenames.is_empty()):
		print_rich("[color=red]No Definitions found![/color]")
	for filename in def_filenames:
		print("\t..." + filename)
		var file_path := source_directory + "/" + filename
		var resource : Resource = load(file_path)
		if(resource == null):
			print_rich("[color=red]Invalid Definition at : %s![/color]" % file_path)
			continue
		var entity_def := resource as EntityDefinition
		var id := entity_def.entity_type
		if(target_dictionary.has(id)):
			print_rich("[color=red]Duplicate Definiton entity_type : %s![/color]" % id)
			continue
		target_dictionary[id] = resource

func get_entity_definitions() -> Array[EntityDefinition]:
	var a : Array[EntityDefinition] = []
	a.assign(entity_defs.values())
	return a

func get_entity_definition(entity_type : String) -> EntityDefinition:
	var entity_def : EntityDefinition = entity_defs.get(entity_type) 
	return entity_def
