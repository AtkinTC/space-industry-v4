extends Node2D
class_name StructureManager

var nodes : Dictionary = {}

func _ready() -> void:
	SignalBus.spawn_structure.connect(spawn_node)
	SignalBus.spawn_ship_callback.connect(spawn_node_with_callback)

func spawn_node(entity_id : String, properties : Dictionary) -> Structure:
	var structure_def := EntityDefs.get_structure_definition(entity_id)
	if(structure_def == null):
		print_debug("No StructureDefinition found for id : %s" % entity_id)
		return
	
	var new_node : Structure = structure_def.scene.instantiate()
	new_node.setup(structure_def, properties)
#	if(properties != null):
#		if(properties.has("position")):
#			new_node.position = properties["position"]
#		if(properties.has("rotation")):
#			new_node.rotation = properties["rotation"]
#	if(new_node.has_method("set_init_properties")):
#		new_node.set_init_properties(properties)
	
	add_child(new_node)
	
	nodes[new_node.get_instance_id()] = new_node
	new_node.tree_exiting.connect(_on_node_freed.bind(new_node.get_instance_id()))
	SignalBus.ships_updated.emit(nodes.size())
	return new_node

func spawn_node_with_callback(entity_id : String, properties : Dictionary, callback : Callable) -> Structure:
		var new_node := spawn_node(entity_id, properties)
		if(callback != null):
			callback.call(new_node)
		return new_node

func _on_node_freed(instance_id : int) -> void:
	if(!nodes.has(instance_id)):
		return
		
	nodes.erase(instance_id)
	SignalBus.ships_updated.emit(nodes.size())
