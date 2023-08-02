extends Node2D
class_name ShipManager

var nodes : Dictionary = {}

func _ready() -> void:
	SignalBus.spawn_ship.connect(spawn_node)
	SignalBus.spawn_ship_callback.connect(spawn_node_with_callback)

func spawn_node(entity_type : String, properties : Dictionary) -> Ship:
	var ship_def := EntityDefs.get_ship_definition(entity_type)
	if(ship_def == null):
		print_debug("No ShipDefinition found for type : %s" % entity_type)
		return
	
	var new_node : Ship = ship_def.scene.instantiate()
	new_node.setup(ship_def, properties)
#	if(properties != null):
#		if(properties.has("position")):
#			new_node.position = properties["position"]
#		if(properties.has("rotation")):
#			new_node.rotation = properties["rotation"]
#	if(new_node.has_method("set_init_properties")):
#		new_node.set_init_properties(properties)
	
	add_child(new_node)
	
	var instance_id := new_node.get_instance_id()
	nodes[instance_id] = new_node
	new_node.tree_exiting.connect(_on_node_freed.bind(instance_id, entity_type))
	SignalBus.ships_updated.emit(nodes.size())
	return new_node

func spawn_node_with_callback(entity_type : String, properties : Dictionary, callback : Callable) -> Ship:
		var new_node := spawn_node(entity_type, properties)
		if(callback != null):
			callback.call(new_node)
		return new_node

func get_nodes_by_entity_type(entity_type : String) -> Array[Ship]:
	var filtered : Array[Ship] = []
	for instance_id in nodes.keys():
		var ship : Ship = nodes[instance_id]
		if(ship.entity_def.entity_type == entity_type):
			filtered.append(ship)
	return filtered

func get_entity_type_count(entity_type : String) -> int:
	return get_nodes_by_entity_type(entity_type).size()

func _on_node_freed(instance_id : int) -> void:
	if(!nodes.has(instance_id)):
		return
		
	nodes.erase(instance_id)
	SignalBus.ships_updated.emit(nodes.size())
