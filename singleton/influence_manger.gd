extends Node
# Singleton InfluenceManager

var nodes : Dictionary = {}

var canvas : InfluenceCanvas = null

var influence_cells : Array[Vector2i] = []
var influence_cells_needs_recalculate := true

func _init() -> void:
	SignalBus.register_influence_node.connect(register_node)

func register_canvas(_canvas : InfluenceCanvas) -> void:
	canvas = _canvas
	for instance_id in nodes.keys():
		canvas.add_influence_node(nodes[instance_id])

func register_node(node : InfluenceNode) -> void:
	if(node == null):
		return
	
	var instance_id : int = node.get_instance_id()
	
	if(nodes.has(instance_id)):
		return
	
	nodes[instance_id] = node
	node.tree_exiting.connect(unregister_node.bind(instance_id))
	influence_cells_needs_recalculate = true
	
	if(canvas != null):
		canvas.add_influence_node(nodes[instance_id])

func unregister_node(instance_id : int) -> void:
	if(!nodes.has(instance_id)):
		return
	
	nodes.erase(instance_id)
	influence_cells_needs_recalculate = true

func is_point_in_influence(point : Vector2) -> bool:
	for node_id in nodes.keys():
		var node : InfluenceNode = nodes[node_id]
		if(point.distance_squared_to(node.global_position) <= pow(node.radius, 2)):
			return true
	
	return false

#TODO : probably a more efficient way to calculate this
#TODO : 2D Array might be a better way to store this result
func recalculate_influence_cells():
	var min_grid := Vector2i()
	var max_grid := Vector2i()
	
	for i in nodes.size():
		var node : InfluenceNode = nodes.values()[i]
		var influence_v := Vector2(node.radius, node.radius)
		if(i == 0):
			min_grid = GameState.world_to_grid(node.global_position - influence_v)
			max_grid = GameState.world_to_grid(node.global_position + influence_v)
		else:
			var min_g := GameState.world_to_grid(node.global_position - influence_v)
			var max_g := GameState.world_to_grid(node.global_position + influence_v)
			
			min_grid.x = min(min_grid.x, min_g.x)
			min_grid.y = min(min_grid.y, min_g.y)
			max_grid.x = max(max_grid.x, max_g.x)
			max_grid.y = max(max_grid.y, max_g.y)
	
	influence_cells = []
	for x in range(min_grid.x, max_grid.x + 1 ):
		for y in range(min_grid.y, max_grid.y + 1):
			var cell := Vector2i(x, y)
			var world_pos := GameState.grid_to_world(cell)
			if(is_point_in_influence(world_pos)):
				influence_cells.append(cell)

func get_cells_in_influence() -> Array[Vector2i]:
	if(influence_cells_needs_recalculate):
		recalculate_influence_cells()
	return influence_cells
