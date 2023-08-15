extends Node2D
class_name ConnectionLinesLayer

var connection_line_scene : PackedScene = preload("res://game/entity/connection_line.tscn")

var networks_updated : Array[int] = []

var connection_lines := {}
var line_ids_by_network := {}

func _ready() -> void:
	NetworksManager.network_updated.connect(_on_network_updated)

func _on_network_updated(_network_ids : Array[int]):
	for id in _network_ids:
		if(!networks_updated.has(id)):
			networks_updated.append(id)

func _process(_delta: float) -> void:
	if(!networks_updated.is_empty()):
		
		for network_id in networks_updated:
			for connection_line_id in line_ids_by_network.get(network_id, []):
				connection_lines[connection_line_id].queue_free()
				connection_lines.erase(connection_line_id)
			line_ids_by_network.erase(network_id)
		
		for network_id in networks_updated:
			line_ids_by_network[network_id] = []
			for connection in NetworksManager.get_network_unique_connections(network_id):
				var connection_line : Line2D = connection_line_scene.instantiate()
				connection_line.points = [connection[0].get_structure().global_position, connection[1].get_structure().global_position]
				connection_lines[connection_line.get_instance_id()] = connection_line
				line_ids_by_network[network_id].append(connection_line.get_instance_id())
				add_child(connection_line)
		
		networks_updated = []
