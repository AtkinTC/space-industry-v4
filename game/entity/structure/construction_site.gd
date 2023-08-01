extends Structure
class_name ConstructionSite

@export var structure_id : String

func setup_from_entity_def() -> void:
	super.setup_from_entity_def()

func setup_from_init_parameters() -> void:
	super.setup_from_init_parameters()
	structure_id = init_parameters.get(Strings.KEY_STRUCTURE_ID, structure_id)

func _ready() -> void:
	super._ready()
	add_to_group(Strings.GROUP_CONSTRUCTION)
	
	##DEBUG##
	assert(structure_id != null && !structure_id.is_empty())
	assert(!EntityDefs.get_construction_cost(structure_id).is_empty())
	assert(has_inventory())
	assert(get_inventory().get_capacity() >= Items.get_volume_sum(EntityDefs.get_construction_cost(structure_id)))
	
	SignalBus.register_construction_site.emit(get_instance_id())

#Override
func setup_inventory() -> void:
	var construction_materials_volume = Items.get_volume_sum(get_construction_cost())
	inventory = Inventory.new(construction_materials_volume)

func _physics_process(_delta: float) -> void:
	if(is_ready_to_complete()):
		complete_construction()

func get_construction_cost() -> Dictionary:
	return EntityDefs.get_construction_cost(structure_id)

func get_remaining_construction_cost() -> Dictionary:
	var remaining := get_construction_cost().duplicate()
	var contents := get_inventory().get_contents()
	
	for item_id in remaining.keys():
		remaining[item_id] = remaining[item_id] - contents.get(item_id, 0)
		if(remaining[item_id] <= 0):
			remaining.erase(item_id)
	
	return remaining

func is_ready_to_complete():
	if(has_inventory() && get_inventory().contains_all(get_construction_cost())):
		return true
	return false

func complete_construction():
	get_inventory().remove_items(get_construction_cost())
	var remaining_contents := get_inventory().get_contents()
	
	var spawn_params := {
		Strings.KEY_POSITION : global_position,
		Strings.KEY_ROTATION : global_rotation,
		Strings.KEY_INVENTORY_CONTENTS : remaining_contents
	}
	
	var spawn_scene := EntityDefs.get_scene(structure_id)
	
	SignalBus.spawn_structure.emit(spawn_scene, spawn_params)
	queue_free()
	