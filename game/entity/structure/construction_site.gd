extends Structure
class_name ConstructionSite

@export var structure_type : String

#Override
func _ready() -> void:
	super._ready()
	add_to_group(Constants.GROUP_CONSTRUCTION)
	
	##DEBUG##
	assert(structure_type != null && !structure_type.is_empty())
	assert(get_construction_structure_definition() != null)
	assert(!get_construction_cost().is_empty())
	assert(has_inventory())
	assert(get_inventory_component().get_capacity() >= Items.get_volume_sum(get_construction_cost()))
	
	SignalBus.register_construction_site.emit(get_instance_id())

#Override
func setup_from_entity_def() -> void:
	super.setup_from_entity_def()

#Override
func setup_from_init_parameters() -> void:
	super.setup_from_init_parameters()
	structure_type = init_parameters.get(Constants.KEY_STRUCTURE_TYPE, structure_type)

#Override
func setup_inventory() -> void:
	var construction_materials_volume = Items.get_volume_sum(get_construction_cost())
	inventory_component = InventoryComponent.new(construction_materials_volume)

#Override
func _physics_process(_delta: float) -> void:
	if(is_ready_to_complete()):
		complete_construction()

func get_construction_structure_definition() -> StructureDefinition:
	return EntityDefs.get_structure_definition(structure_type)

func get_construction_cost() -> Dictionary:
	return get_construction_structure_definition().construction_cost

func get_remaining_construction_cost() -> Dictionary:
	var remaining := get_construction_cost().duplicate()
	var contents := get_inventory_component().get_contents()
	
	for item_id in remaining.keys():
		remaining[item_id] = remaining[item_id] - contents.get(item_id, 0)
		if(remaining[item_id] <= 0):
			remaining.erase(item_id)
	
	return remaining

func is_ready_to_complete():
	if(has_inventory() && get_inventory_component().contains_all(get_construction_cost())):
		return true
	return false

func complete_construction():
	get_inventory_component().remove_items(get_construction_cost())
	var remaining_contents := get_inventory_component().get_contents()
	
	var spawn_params := {
		Constants.KEY_GRID_POSITION : grid_position,
		Constants.KEY_POSITION : global_position,
		Constants.KEY_ROTATION : global_rotation,
		Constants.KEY_INVENTORY_CONTENTS : remaining_contents
	}
	
	SignalBus.spawn_structure.emit(structure_type, spawn_params)
	queue_free()
	
