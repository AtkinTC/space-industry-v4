extends Node
# Singleton EntityManager

var entities_parent_node : Node2D
var entities := {}
var entities_by_cell := {}
var entity_cells := {}

func _init() -> void:
	SignalBus.spawn_entity.connect(spawn_entity)
	
func register_entities_parent_node(node : Node2D) -> void:
	entities_parent_node = node

func spawn_entity(entity_type : String, properties : Dictionary) -> Entity:
	var entity_def := EntityDefs.get_entity_definition(entity_type)
	if(entity_def == null):
		print_debug("No EntityDefinition found for type : %s" % entity_type)
		return
	
	assert(!entity_def.grid_locked || properties.has(Constants.KEY_GRID_POSITION))
	
	var new_node : Entity = entity_def.scene.instantiate()
	new_node.init(entity_def, properties)
	
	if(entity_def.grid_locked):
		var cells : Array[Vector2i] = []
		var grid_position : Vector2i = properties.get(Constants.KEY_GRID_POSITION)
		for cell in entity_def.get_grid_cells():
			cells.append(cell + grid_position)
		assert(!cells.is_empty())
		add_entity_cells(new_node.get_instance_id(), cells)
	
	entities_parent_node.add_child(new_node)
	
	entities[new_node.get_instance_id()] = new_node
	new_node.tree_exiting.connect(_on_entity_freed.bind(new_node.get_instance_id()))
	SignalBus.entities_updated.emit(entities.size())
	return new_node

func add_entity_cells(instance_id : int, cells : Array[Vector2i]) -> void:
	for cell in cells:
		entities_by_cell[cell] = instance_id
	entity_cells[instance_id] = cells

func remove_entity_cells(instance_id : int) -> void:
	if(entity_cells.has(instance_id)):
		for cell in entity_cells[instance_id]:
			if(entities_by_cell.get(cell as Vector2i, -1) == instance_id):
				entities_by_cell.erase(cell as Vector2i)
		entity_cells.erase(instance_id)

func get_entity_id_at_cell(cell : Vector2i) -> int:
	return entities_by_cell.get(cell, -1)

func get_used_entity_cells() -> Array[Vector2i]:
	var cells : Array[Vector2i] = []
	cells.assign(entities_by_cell.keys())
	return cells

func _on_entity_freed(instance_id : int) -> void:
	if(!entities.has(instance_id)):
		return
		
	entities.erase(instance_id)
	remove_entity_cells(instance_id)
	
	SignalBus.entities_updated.emit(entities.size())
