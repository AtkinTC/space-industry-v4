@tool
extends Resource
class_name ConnectorPoint

@export var cell : Vector2i
@export var directions : Array[Vector2i] = []

func draw_at(node : Node2D, offset : Vector2 = Vector2.ZERO) -> void:
	var pos : Vector2 = offset + (cell as Vector2) * Constants.TILE_SIZE
	node.draw_circle(pos, 2.0, Color.WEB_GREEN)
	
	for direction in directions:
		var dir := (direction as Vector2).normalized()
		node.draw_line(pos + dir * 2, pos + dir * 14, Color.BLUE, 1.0)
