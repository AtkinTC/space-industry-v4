extends Node
# Singleton NetworksManager
# manages the network connections between StructureConnectorComponent connector nodes

class Connection:
	var id_1 : int
	var id_2 : int
	var node_1 : StructureConnectorComponent
	var node_2 : StructureConnectorComponent
	
	func _init(_node_1 : StructureConnectorComponent, _node_2 : StructureConnectorComponent):
		id_1 = _node_1.get_instance_id()
		id_2 = _node_2.get_instance_id()
		node_1 = _node_1 if (id_1 <= id_2) else _node_2
		node_2 = _node_2 if (id_1 <= id_2) else _node_1
		id_1 = node_1.get_instance_id()
		id_2 = node_2.get_instance_id()
	
	func equals(connection : Connection):
		return (id_1 == connection.id_1 && id_2 == connection.id_2)

class Network:
	var nodes := {}
	var connections : Array[Connection] = []
	
	func has_connection(node_1 : StructureConnectorComponent, node_2 : StructureConnectorComponent) -> bool:
		var connection := Connection.new(node_1, node_2)
		return has_connection_internal(connection)
	
	func has_connection_internal(connection : Connection) -> bool:
		for c in connections:
			if(c.equals(connection)):
				return true
		return false
	
	func connect_nodes(node_1 : StructureConnectorComponent, node_2 : StructureConnectorComponent) -> void:
		var connection := Connection.new(node_1, node_2)
		add_connection(connection)
	
	func add_connection(connection : Connection):
		if(has_connection_internal(connection)):
			return
		connections.append(connection)
	
	func get_connections() -> Array[Connection]:
		return connections
	
	func get_node_connections(node_id : int) -> Array[Connection]:
		var node_connections : Array[Connection] = []
		for connection in connections:
			if(connection.id_1 == node_id || connection.id_2 == node_id):
				node_connections.append(connection)
		return node_connections
	
	func erase_node_connections(node_id : int):
		var updated_connections : Array[Connection] = []
		for connection in connections:
			if(connection.id_1 != node_id && connection.id_2 != node_id):
				updated_connections.append(connection)
		connections = updated_connections
	
	func get_nodes() -> Array[StructureConnectorComponent]:
		var a : Array[StructureConnectorComponent] = []
		a.assign(nodes.values())
		return a
	
	func get_node_ids() -> Array[int]:
		var a : Array[int] = []
		a.assign(nodes.keys())
		return a
	
	func add_node(node : StructureConnectorComponent) -> void:
		nodes[node.get_instance_id()] = node
	
	func remove_node(node_id : int) -> void:
		nodes.erase(node_id)
		erase_node_connections(node_id)

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
	recalculate_structure_connections()
	var a : Array[int] = []
	a.assign(networks.keys())
	return a

func get_node_network_id(node_id : int) -> int:
	recalculate_structure_connections()
	return node_network_ids.get(node_id, -1)

func get_network_node_ids(network_id : int) -> Array[int]:
	recalculate_structure_connections()
	if(networks.has(network_id)):
		return networks[network_id].get_node_ids()
	return [] as Array[int]

func get_network_connections(network_id : int) -> Array[Connection]:
	recalculate_structure_connections()
	if(networks.has(network_id)):
		return networks[network_id].get_connections()
	return [] as Array[Connection]

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
	var new_connections : Array[Connection] = []
	
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
			new_connections.append(Connection.new(added_node, neighbor_node))
			
			var neighbor_network_id : int = node_network_ids[neighbor_node.get_instance_id()]
			if(!connected_network_ids.has(neighbor_network_id)):
				connected_network_ids.append(neighbor_network_id)
	
	if(connected_network_ids.is_empty()):
		var new_network_id := get_next_free_network_id()
		node_network_ids[added_node_id] = new_network_id
		var new_network = Network.new()
		new_network.add_node(added_node)
		networks[new_network_id] = new_network
	else:
		var primary_network_id : int = 9999
		for network_id in connected_network_ids:
			if(network_id < primary_network_id):
				primary_network_id = network_id
		
		node_network_ids[added_node_id] = primary_network_id
		var primary_network : Network = networks[primary_network_id]
		primary_network.add_node(added_node)
		
		for old_network_id in connected_network_ids:
			if(old_network_id == primary_network_id):
				continue
			
			var old_networks : Network = networks[old_network_id]
			
			for node in old_networks.get_nodes():
				primary_network.add_node(node)
				node_network_ids[node.get_instance_id()] = primary_network_id
			
			for connection in old_networks.get_connections():
				primary_network.add_connection(connection)
			
			networks.erase(old_network_id)
		
		for connection in new_connections:
			primary_network.add_connection(connection)
