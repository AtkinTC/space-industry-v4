extends Node2D
class_name NetworkDisplayLayer
# UI Node inteded for the display of structure network related visuals
# such as overall network shapes and individual connection between structures

var display_networks : bool = true

const network_colors : PackedColorArray = [Color.RED, Color.GREEN, Color.BLUE, Color.MEDIUM_PURPLE, Color.WHITE]

func _ready() -> void:
	NetworksManager.register_canvas(self)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if(display_networks):
		var points : PackedVector2Array = []
		var colors : PackedColorArray = []
		var color_index : int = 0
		for network_id in NetworksManager.get_network_ids():
			var color := network_colors[color_index]
			if(!NetworksManager.get_network_connections(network_id).is_empty()):
				color_index = (color_index + 1) % network_colors.size()
			for connection in NetworksManager.get_network_connections(network_id):
				points.append_array([connection.c1.get_structure().global_position, connection.c2.get_structure().global_position])
				colors.append(color)
		if(!points.is_empty()):
			draw_multiline_colors(points, colors, 1.0)
