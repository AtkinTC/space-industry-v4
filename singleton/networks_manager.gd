extends Node
# Singleton NetworksManager
# manages the network connections between StructureConnectorComponent connector nodes

signal network_updated(network_id : int)

class Graph:
	var connections := {}

	func has_connection(id_1 : int, id_2 : int) -> bool:
		return connections.get(id_1, []).has(id_2)

	func add_node(node_id : int) -> void:
		if(connections.has(node_id)):
			return
		connections[node_id] = [] as Array[int]

	func erase_node(node_id : int) -> void:
		connections.erase(node_id)
		for connected_node_ids in connections.values():
			(connected_node_ids as Array[int]).erase(node_id)

	func add_connection(id_1 : int, id_2 : int) -> void:
		var connections_1 : Array[int] = connections.get(id_1, [] as Array[int])
		if(!connections_1.has(id_2)):
			connections_1.append(id_2)
		connections[id_1] = connections_1
		var connections_2 : Array[int] = connections.get(id_2, [] as Array[int])
		if(!connections_2.has(id_1)):
			connections_2.append(id_1)
		connections[id_2] = connections_2
	
	func erase_connection(id_1 : int, id_2 : int) -> void:
		connections.get(id_1, []).erase(id_2)
		connections.get(id_2, []).erase(id_1)
	
	func get_node_ids() -> Array[int]:
		var a : Array[int] = []
		a.assign(connections.keys())
		return a
	
	func get_connections() -> Dictionary:
		return connections
	
	func get_connected_node_ids(node_id : int) -> Array[int]:
		var a : Array[int] = []
		a.assign(connections.get(node_id, []))
		return a
	
	func append(graph : Graph):
		for key_id in graph.get_connections().keys():
			var node_connection_ids : Array[int] = connections.get(key_id, [] as Array[int])
			for node_id in graph.get_connections()[key_id]:
				if(!node_connection_ids.has(node_id)):
					node_connection_ids.append(node_id)
			connections[key_id] = node_connection_ids

var connector_nodes := {} # all StructureConnectorComponent organized by instance_id
var node_network_ids := {} # each StructureConnectorComponent's network id, organized by node instance_id
var nodes_by_cell := {} # StructureConnectorComponent nodes organized by their cell positions
var cells_by_node_id := {} # structure point cells organized by node instance_id

var networks := {} 

var added_connector_ids : Array[int] = []
var removed_connector_ids : Array[int] = []

var canvas : NetworkDisplayLayer = null

func _init() -> void:
	SignalBus.register_structure_connector_component.connect(register_node)

func _physics_process(_delta: float) -> void:
	recalculate_structure_connections()

func register_canvas(_canvas : Node2D) -> void:
	canvas = _canvas
	#for instance_id in connector_nodes.keys():
	#	canvas.add_influence_node(connector_nodes[instance_id])

func register_node(node : StructureConnectorComponent) -> void:
	if(node == null):
		return
	
	var instance_id : int = node.get_instance_id()
	
	if(connector_nodes.has(instance_id)):
		return
	
	connector_nodes[instance_id] = node
	node.tree_exiting.connect(unregister_node.bind(instance_id))
	
	if(!added_connector_ids.has(instance_id)):
		added_connector_ids.append(instance_id)
	
	#if(canvas != null):
	#	canvas.add_influence_node(connector_nodes[instance_id])

func unregister_node(instance_id : int) -> void:
	if(!connector_nodes.has(instance_id)):
		return
	
	connector_nodes.erase(instance_id)
	
	if(!removed_connector_ids.has(instance_id)):
		removed_connector_ids.append(instance_id)

func get_network_ids() -> Array[int]:
	var a : Array[int] = []
	a.assign(networks.keys())
	return a

func get_connector_node(node_id : int) -> StructureConnectorComponent:
	return connector_nodes.get(node_id)

func get_network(node_id) -> Graph:
	return networks.get(node_id)

func get_node_network_id(node_id : int) -> int:
	return node_network_ids.get(node_id, -1)

func get_network_node_ids(network_id : int) -> Array[int]:
	if(networks.has(network_id)):
		return networks[network_id].get_node_ids()
	return [] as Array[int]

func get_network_unique_connections(network_id : int):
	if(!networks.has(network_id)):
		return []
		
	var unique_connections = []
	var network : Graph = networks[network_id]
	var checked_node_ids : Array[int] = []
	for key_node_id in network.get_node_ids():
		var node_1 : StructureConnectorComponent = connector_nodes[key_node_id]
		for connected_node_id in network.get_connected_node_ids(key_node_id):
			if(!checked_node_ids.has(connected_node_id)):
				var node_2 : StructureConnectorComponent = connector_nodes[connected_node_id]
				unique_connections.append([node_1, node_2])
		checked_node_ids.append(key_node_id)
	return unique_connections

func get_next_free_network_id() -> int:
	var id : int = 0
	while(networks.has(id)):
		id += 1
	return id

func recalculate_structure_connections() -> void:
	calculate_removed_connectors()
	calculate_added_connectors()

func record_node_cells(node_id : int) -> void:
	var node : StructureConnectorComponent = connector_nodes[node_id]
	var center_cell := node.get_center_cell()
	var point_cells : Array[Vector2i] = []
	for point in node.connector_points:
		nodes_by_cell[center_cell + point.cell] = node
		point_cells.append(center_cell + point.cell)
	cells_by_node_id[node_id] = point_cells

func erase_node_cells(node_id : int) -> void:
	var point_cells : Array[Vector2i] = cells_by_node_id[node_id]
	for cell in point_cells:
		nodes_by_cell.erase(cell)
	cells_by_node_id.erase(node_id)

func calculate_removed_connectors() -> void:
	while(!removed_connector_ids.is_empty()):
		calculate_removed_connector(removed_connector_ids.pop_front())

func calculate_removed_connector(removed_node_id : int) -> void:
	pass
	
func calculate_added_connectors() -> void:
	while(!added_connector_ids.is_empty()):
		calculate_added_connector(added_connector_ids.pop_front())

func calculate_added_connector(added_node_id : int) -> void:
	record_node_cells(added_node_id)
	
	var added_node : StructureConnectorComponent = connector_nodes[added_node_id]
	
	var connected_network_ids : Array[int] = []
	
	var new_network := Graph.new()
	new_network.add_node(added_node_id)
	
	var center_cell := added_node.get_center_cell()
	for point in added_node.connector_points:
		var point_cell : Vector2i = point.cell + center_cell
		for dir in point.directions:
			var neighbor_node : StructureConnectorComponent = nodes_by_cell.get(point_cell + dir)
			if(neighbor_node == null):
				continue
			var neighbor_id := neighbor_node.get_instance_id()
			if(neighbor_id == added_node_id):
				# cannot connect with itself
				continue
			new_network.add_connection(added_node_id, neighbor_id)
			
			var neighbor_network_id : int = node_network_ids[neighbor_node.get_instance_id()]
			if(!connected_network_ids.has(neighbor_network_id)):
				connected_network_ids.append(neighbor_network_id)
	
	if(connected_network_ids.is_empty()):
		var new_network_id := get_next_free_network_id()
		node_network_ids[added_node_id] = new_network_id
		networks[new_network_id] = new_network
		
		network_updated.emit(new_network_id)
	else:
		var primary_network_id : int = 9999
		for network_id in connected_network_ids:
			if(network_id < primary_network_id):
				primary_network_id = network_id
		
		node_network_ids[added_node_id] = primary_network_id
		var primary_network : Graph = networks[primary_network_id]
		primary_network.append(new_network)
		
		for old_network_id in connected_network_ids:
			if(old_network_id == primary_network_id):
				continue
			
			var old_networks : Graph = networks[old_network_id]
			networks.erase(old_network_id)
			primary_network.append(old_networks)
			
			for node_id in old_networks.get_node_ids():
				node_network_ids[node_id] = primary_network_id
		
		for network_id in connected_network_ids:
			network_updated.emit(network_id)

