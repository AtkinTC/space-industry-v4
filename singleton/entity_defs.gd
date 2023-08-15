extends Node
# Singleton EntityDefs

const unit_def_dir := "res://resources/entity_definitions/unit_definitions"
const structure_def_dir := "res://resources/entity_definitions/structure_definitions"

var unit_defs := {}
var structure_defs := {}

func _init() -> void:
	load_def_type(unit_def_dir, unit_defs)
	for key in unit_defs.keys():
		if(!(unit_defs[key] is UnitDefinition)):
			print_rich("[color=red]Invalid Unit Definition for type : %s![/color]" % key)
	
	load_def_type(structure_def_dir, structure_defs)
	for key in structure_defs.keys():
		if(!(structure_defs[key] is StructureDefinition)):
			print_rich("[color=red]Invalid Structure Definition for type : %s![/color]" % key)

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

func get_unit_definitions() -> Array[UnitDefinition]:
	var a : Array[UnitDefinition] = []
	a.assign(unit_defs.values())
	return a

func get_unit_definition(entity_type : String) -> UnitDefinition:
	var unit_def : UnitDefinition = unit_defs.get(entity_type) 
	return unit_def

func get_structure_definitions() -> Array[StructureDefinition]:
	var a : Array[StructureDefinition] = []
	a.assign(structure_defs.values())
	return a

func get_structure_definition(entity_type : String) -> StructureDefinition:
	var structure_def : StructureDefinition = structure_defs.get(entity_type) 
	return structure_def

