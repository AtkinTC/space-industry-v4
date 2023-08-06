extends Node
# Singleton EntityManager

var ships_parent_node : Node2D
var ships : Dictionary = {}

var structures_parent_node : Node2D
var structures : Dictionary = {}
var structures_by_cell = {}
var structure_cells = {}

func _ready() -> void:
	SignalBus.spawn_ship.connect(spawn_ship)
	SignalBus.spawn_ship_callback.connect(spawn_ship_with_callback)
	
	SignalBus.spawn_structure.connect(spawn_structure)
	SignalBus.spawn_structure_callback.connect(spawn_structure_with_callback)

func register_ships_parent_node(node : Node2D) -> void:
	ships_parent_node = node

func register_structures_parent_node(node : Node2D) -> void:
	structures_parent_node = node

func get_entities_by_type(entity_type : String) -> Array[Entity]:
	var filtered : Array[Entity] = []
	for key in ships.keys():
		var ship : Ship = ships[key]
		if(ship.entity_def.entity_type == entity_type):
			filtered.append(ship)
	for key in structures.keys():
		var structure : Structure = structures[key]
		if(structure.entity_def.entity_type == entity_type):
			filtered.append(structure)
	return filtered

#########
# SHIPS #
#########

func spawn_ship(entity_type : String, properties : Dictionary) -> Ship:
	var ship_def := EntityDefs.get_ship_definition(entity_type)
	if(ship_def == null):
		print_debug("No StructureDefinition found for type : %s" % entity_type)
		return
	
	var new_node : Ship = ship_def.scene.instantiate()
	new_node.init(ship_def, properties)
	
	ships_parent_node.add_child(new_node)
	
	ships[new_node.get_instance_id()] = new_node
	new_node.tree_exiting.connect(_on_ship_freed.bind(new_node.get_instance_id()))
	SignalBus.ships_updated.emit(ships.size())
	return new_node

func spawn_ship_with_callback(entity_type : String, properties : Dictionary, callback : Callable) -> Ship:
		var new_node := spawn_ship(entity_type, properties)
		if(callback != null):
			callback.call(new_node)
		return new_node

func _on_ship_freed(instance_id : int) -> void:
	if(!ships.has(instance_id)):
		return
		
	ships.erase(instance_id)
	SignalBus.ships_updated.emit(ships.size())

##############
# STRUCTURES #
##############

func spawn_structure(entity_type : String, properties : Dictionary) -> Structure:
	var structure_def := EntityDefs.get_structure_definition(entity_type)
	if(structure_def == null):
		print_debug("No StructureDefinition found for type : %s" % entity_type)
		return
	
	assert(!structure_def.grid_locked || properties.has(Constants.KEY_GRID_POSITION))
	
	var new_node : Structure = structure_def.scene.instantiate()
	new_node.init(structure_def, properties)
	
	if(structure_def.grid_locked):
		var cells : Array[Vector2i] = []
		var grid_position : Vector2i = properties.get(Constants.KEY_GRID_POSITION)
		for cell in structure_def.get_grid_cells():
			cells.append(cell + grid_position)
		assert(!cells.is_empty())
		add_structure_cells(new_node.get_instance_id(), cells)
	
	structures_parent_node.add_child(new_node)
	
	structures[new_node.get_instance_id()] = new_node
	new_node.tree_exiting.connect(_on_structure_freed.bind(new_node.get_instance_id()))
	SignalBus.structures_updated.emit(structures.size())
	return new_node

func spawn_structure_with_callback(entity_type : String, properties : Dictionary, callback : Callable) -> Structure:
		var new_node := spawn_structure(entity_type, properties)
		if(callback != null):
			callback.call(new_node)
		return new_node

func add_structure_cells(instance_id : int, cells : Array[Vector2i]) -> void:
	for cell in cells:
		structures_by_cell[cell] = instance_id
	structure_cells[instance_id] = cells

func remove_structure_cells(instance_id : int) -> void:
	if(structure_cells.has(instance_id)):
		for cell in structure_cells[instance_id]:
			structures_by_cell.erase(cell as Vector2i)
		structure_cells.erase(instance_id)

func get_structure_id_at_cell(cell : Vector2i) -> int:
	return structures_by_cell.get(cell, -1)

func get_used_structure_cells() -> Array[Vector2i]:
	var cells : Array[Vector2i] = []
	cells.assign(structures_by_cell.keys())
	return cells

func _on_structure_freed(instance_id : int) -> void:
	if(!structures.has(instance_id)):
		return
		
	structures.erase(instance_id)
	remove_structure_cells(instance_id)
	
	SignalBus.structures_updated.emit(structures.size())
