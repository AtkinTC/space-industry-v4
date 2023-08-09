@tool
extends Marker2D
class_name Marker2DCustom

const PRIMARY_LENGTH : float = 16
const COLOR_PRIMARY := Color(Color.BLUE, 1)

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
		
	var points : PackedVector2Array = [
		Vector2.ZERO, Vector2(PRIMARY_LENGTH, 0)
		]
	var colors : PackedColorArray = [
		COLOR_PRIMARY
		]
	
	draw_multiline_colors(points, colors, 0.5)
