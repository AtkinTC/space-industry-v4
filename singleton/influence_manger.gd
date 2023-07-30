extends Node
# Singleton InfluenceManager

var nodes : Dictionary = {}

var canvas : InfluenceCanvas = null

func _ready() -> void:
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
	
	if(canvas != null):
		canvas.add_influence_node(nodes[instance_id])

func unregister_node(instance_id : int) -> void:
	if(!nodes.has(instance_id)):
		return
		
	nodes.erase(instance_id)

func is_point_in_influence(point : Vector2) -> bool:
	for node_id in nodes.keys():
		var node : InfluenceNode = nodes[node_id]
		if(point.distance_squared_to(node.global_position) <= pow(node.radius, 2)):
			return true
	
	return false
