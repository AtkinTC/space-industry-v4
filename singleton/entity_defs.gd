extends Node
# Singleton EntityDefs

const unit_def_dir := "res://resources/entity_definitions/unit_definitions"
const structure_def_dir := "res://resources/entity_definitions/structure_definitions"

var entity_defs : Dictionary = {}

func _init() -> void:
	var unit_def_filenames := DirAccess.get_files_at(unit_def_dir)
	print("Loading UnitDefinitions from dir : " + unit_def_dir)
	if(unit_def_filenames == null || unit_def_filenames.is_empty()):
		print_rich("[color=red]No Unit Definitions found![/color]")
	for filename in unit_def_filenames:
		print("\t..." + filename)
		var file_path := unit_def_dir + "/" + filename
		var resource : Resource = load(file_path)
		if(resource == null || !(resource is UnitDefinition)):
			print_rich("[color=red]Invalid Unit Definition at : %s![/color]" % file_path)
			continue
		var unit_def := resource as UnitDefinition
		var id := unit_def.entity_type
		if(entity_defs.has(id)):
			print_rich("[color=red]Duplicate unit entity_type : %s![/color]" % id)
			continue
		entity_defs[id] = unit_def
	
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
		var id := structure_def.entity_type
		if(entity_defs.has(id)):
			print_rich("[color=red]Duplicate Structure entity_type : %s![/color]" % id)
			continue
		entity_defs[id] = structure_def

func get_entity_definitions() -> Array[EntityDefinition]:
	var a : Array[EntityDefinition] = []
	a.assign(entity_defs.values)
	return a

func get_unit_definitions() -> Array[UnitDefinition]:
	var a : Array[UnitDefinition] = []
	a.assign(entity_defs.values().filter(func lambda(e : EntityDefinition) : return e is UnitDefinition))
	return a

func get_structure_definitions() -> Array[StructureDefinition]:
	var a : Array[StructureDefinition] = []
	a.assign(entity_defs.values().filter(func lambda(e : EntityDefinition) : return e is StructureDefinition))
	return a

func get_entity_definition(entity_type : String) -> EntityDefinition:
	return entity_defs.get(entity_type) as EntityDefinition

func get_unit_definition(entity_type : String) -> UnitDefinition:
	var unit_def : UnitDefinition = entity_defs.get(entity_type) 
	return unit_def

func get_structure_definition(entity_type : String) -> StructureDefinition:
	var structure_def : StructureDefinition = entity_defs.get(entity_type) 
	return structure_def

func get_scene(entity_type : String) -> PackedScene:
	var entity_def := get_entity_definition(entity_type)
	if(entity_def == null):
		return null
	return entity_def.scene
