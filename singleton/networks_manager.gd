extends Node
# Singleton NetworksManager

var nodes := {}
var network_source_ids : Array[int] = []
var networks := {}
var node_network_ids := {}
var nodes_by_cell := {}

var canvas : NetworkDisplayLayer = null
var connection_needs_recalculate := true

func _init() -> void:
	SignalBus.register_structure_connector_component.connect(register_node)

func register_canvas(_canvas : Node2D) -> void:
	canvas = _canvas
	#for instance_id in nodes.keys():
	#	canvas.add_influence_node(nodes[instance_id])

func register_node(node : StructureConnectorComponent) -> void:
	if(node == null):
		return
	
	var instance_id : int = node.get_instance_id()
	
	if(nodes.has(instance_id)):
		return
	
	if(node.network_source):
		network_source_ids.append(instance_id)
	
	nodes[instance_id] = node
	node.tree_exiting.connect(unregister_node.bind(instance_id))
	connection_needs_recalculate = true
	
	#if(canvas != null):
	#	canvas.add_influence_node(nodes[instance_id])

func unregister_node(instance_id : int) -> void:
	if(!nodes.has(instance_id)):
		return
	
	nodes.erase(instance_id)
	network_source_ids.erase(instance_id)
	connection_needs_recalculate = true

func get_node_network_id(instance_id : int) -> int:
	recalculate_structure_connections()
	return node_network_ids.get(instance_id, -1)

func get_network_node_ids(network_id : int) -> Array[int]:
	recalculate_structure_connections()
	return networks.get(network_id, [])

func recalculate_structure_connections() -> void:
	if(!connection_needs_recalculate):
		return
	connection_needs_recalculate = false
	
	# recalculate all connector positions
	nodes_by_cell = {}
	for node_id in nodes.keys():
		var node : StructureConnectorComponent = nodes[node_id]
		var center_cell := node.get_center_cell()
		for point in node.connector_points:
			nodes_by_cell[center_cell + point.cell] = node
	
	var checked_node_ids : Array[int] = []
	
	node_network_ids = {}
	var network_index : int = 0
	for source_node_id in network_source_ids:
		var network_node_ids : Array[int] = [source_node_id]
		var node_id_queue : Array[int] = [source_node_id]
		while(!node_id_queue.is_empty()):
			var node_id : int = node_id_queue.pop_front()
			if(node_id in checked_node_ids):
				continue
			checked_node_ids.append(node_id)
			var node : StructureConnectorComponent = nodes[node_id]
			#node.network_id = network_index
			node_network_ids[node_id] = network_index
			var center_cell := node.get_center_cell()
			for point in node.connector_points:
				var point_cell : Vector2i = point.cell + center_cell
				for dir in point.directions:
					var neighbor : StructureConnectorComponent = nodes_by_cell.get(point_cell + dir)
					if(neighbor == null):
						continue
					var neighbor_id := neighbor.get_instance_id()
					if(node_id_queue.has(neighbor_id) || checked_node_ids.has(neighbor_id)):
						continue
					network_node_ids.append(neighbor_id)
					node_id_queue.append(neighbor_id)
		networks[network_index] = network_node_ids
		network_index += 1
