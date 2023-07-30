extends Node2D
class_name ResourceNode

@export var resource_id : String
@export var base_resource_quantity : int
var remaining_resource_quantity : int

func set_init(init_parameters : Dictionary) -> void:
	global_position = init_parameters.get(Strings.KEY_POSITION, global_position)
	global_rotation = init_parameters.get(Strings.KEY_ROTATION, global_rotation)

func _ready():
	add_to_group(Strings.GROUP_RESOURCE_NODE)
	
	remaining_resource_quantity = base_resource_quantity

func _physics_process(_delta):
	if(remaining_resource_quantity <= 0):
		queue_free()

func is_minable() -> bool:
	return (Items.get_item_ids().has(resource_id) && remaining_resource_quantity > 0)

func get_mining_result(mining_volume : int) -> Dictionary:
	var item_def := Items.get_item_definition(resource_id)
	
	if(item_def == null):
		return {}
	
	var mined_quantity : int = mining_volume #floori(mining_volume / item_def.volume)
	mined_quantity = min(mined_quantity, remaining_resource_quantity)
	return {resource_id : mined_quantity}

func mine(mining_volume : int) -> Dictionary:
	var result := get_mining_result(mining_volume)
	remaining_resource_quantity -= result[resource_id]
	return result
