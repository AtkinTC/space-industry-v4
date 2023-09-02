extends Node2D
class_name NetworkDisplayLayer
# UI Node inteded for the display of structure network related visuals
# such as overall network shapes and individual connection between structures

var display_networks : bool = true

const network_colors : PackedColorArray = [Color.RED, Color.GREEN, Color.BLUE, Color.MEDIUM_PURPLE, Color.WHITE]

var networks_updated := true

func _ready() -> void:
	NetworksManager.register_canvas(self)
	NetworksManager.network_updated.connect(_on_network_updated)

func _process(_delta: float) -> void:
	if(networks_updated):
		queue_redraw()
		networks_updated = false

func _on_network_updated(_network_ids : Array[int]):
	networks_updated = true

func _draw() -> void:
	if(display_networks):
		var points : PackedVector2Array = []
		var colors : PackedColorArray = []
		var color_index : int = 0
		for network_id in NetworksManager.get_network_ids():
			var empty := true
			var color := network_colors[color_index]
			for connection in NetworksManager.get_network_unique_connections(network_id):
				points.append_array([connection[0].get_entity().global_position, connection[1].get_entity().global_position])
				colors.append(color)
				empty = false
			if(!empty):
				color_index = (color_index + 1) % network_colors.size()
		if(!points.is_empty()):
			draw_multiline_colors(points, colors, 1.0)
