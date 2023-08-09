extends Node
# Singleton NetworksManager
# manages the network connections between StructureConnectorComponent nodes

class Connection:
	var id : String = ""
	var c1 : StructureConnectorComponent
	var c2 : StructureConnectorComponent
	
	func _init(a : StructureConnectorComponent, b : StructureConnectorComponent):
		self.c1 = a if (a.get_instance_id() <= b.get_instance_id()) else b
		self.c2 = b if (a.get_instance_id() <= b.get_instance_id()) else a
		self.id = Connection.create_id(c1, c2)
	
	static func create_id(a : StructureConnectorComponent, b : StructureConnectorComponent) -> String:
		return str(min(a.get_instance_id(), b.get_instance_id()), "-", max(a.get_instance_id(), b.get_instance_id()))
		
	static func from_id(_id : String) -> Connection:
		var id_parts := _id.split("-")
		if(id_parts.size() != 2 || id_parts[0].is_empty() || id_parts[1].is_empty()):
			return null
		var a : StructureConnectorComponent = NetworksManager.nodes[id_parts[0].to_int()]
		var b : StructureConnectorComponent = NetworksManager.nodes[id_parts[1].to_int()]
		return Connection.new(a, b)

var nodes := {} # all StructureConnectorComponent organized by instance_id
var networks := {} # array of StructureConnectorComponent instance_ids in the network, one for each network
var network_connections := {} # array containing all the unique Connections in the network, one for each network
var node_network_ids := {} # each StructureConnectorComponent's network id, organized by node instance_id
var nodes_by_cell := {} # center grid cell of each StructureConnectorComponent, organized by node instance_id

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
	
	nodes[instance_id] = node
	node.tree_exiting.connect(unregister_node.bind(instance_id))
	connection_needs_recalculate = true
	
	#if(canvas != null):
	#	canvas.add_influence_node(nodes[instance_id])

func unregister_node(instance_id : int) -> void:
	if(!nodes.has(instance_id)):
		return
	
	nodes.erase(instance_id)
	connection_needs_recalculate = true

func get_network_ids() -> Array[int]:
	recalculate_structure_connections()
	var a : Array[int] = []
	a.assign(networks.keys())
	return a

func get_node_network_id(instance_id : int) -> int:
	recalculate_structure_connections()
	return node_network_ids.get(instance_id, -1)

func get_network_node_ids(network_id : int) -> Array[int]:
	recalculate_structure_connections()
	return networks.get(network_id, [])

func get_network_connections(network_id : int) -> Array[Connection]:
	recalculate_structure_connections()
	return network_connections.get(network_id, [])

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
	
	var unchecked_node_ids : Array[int] = []
	unchecked_node_ids.assign(nodes.keys())
	var checked_node_ids : Array[int] = []
	
	networks = {}
	network_connections = {}
	node_network_ids = {}
	var network_index : int = 0
	while(!unchecked_node_ids.is_empty()):
		var first_node_id : int = unchecked_node_ids.pop_back()
		var node_id_queue : Array[int] = [first_node_id]
		var network_node_ids : Array[int] = [first_node_id]
		var connections : Array[Connection] = []
		var connection_ids : Array[String] = []
		while(!node_id_queue.is_empty()):
			var node_id : int = node_id_queue.pop_front()
			if(node_id in checked_node_ids):
				continue
			checked_node_ids.append(node_id)
			var node : StructureConnectorComponent = nodes[node_id]
			node_network_ids[node_id] = network_index
			var center_cell := node.get_center_cell()
			for point in node.connector_points:
				var point_cell : Vector2i = point.cell + center_cell
				for dir in point.directions:
					var neighbor : StructureConnectorComponent = nodes_by_cell.get(point_cell + dir)
					if(neighbor == null):
						continue
					var neighbor_id := neighbor.get_instance_id()
					
					# record unique connection ids
					var connection_id := Connection.create_id(node, neighbor)
					if(!connection_ids.has(connection_id)):
						connection_ids.append(Connection.create_id(node, neighbor))
						
					if(node_id_queue.has(neighbor_id) || checked_node_ids.has(neighbor_id)):
						continue
					network_node_ids.append(neighbor_id)
					node_id_queue.append(neighbor_id)
					#connections.append(Connection.new(node, neighbor))
			
		for connection_id in connection_ids:
			connections.append(Connection.from_id(connection_id))
		networks[network_index] = network_node_ids
		network_connections[network_index] = connections
		network_index += 1
