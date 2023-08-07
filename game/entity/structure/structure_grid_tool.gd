@tool
extends Node2D
class_name StructureGridTool

@export var grid_size := Vector2i(1,1) : set = set_grid_size

var top_left : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	recalculate()

func set_grid_size(size : Vector2i) -> void:
	if(size.x <= 0 || size.y <= 0):
		return
	grid_size = size
	recalculate()

func recalculate() -> void:
	top_left = -grid_size * Constants.TILE_SIZE_I / 2.0
	queue_redraw()

func _draw() -> void:
	draw_circle(top_left, 3, Color.RED)
	draw_circle(top_left + Constants.TILE_SIZE / 2.0, 3, Color.BLUE)
	
	
	for x in grid_size.x:
		for y in grid_size.y:
			draw_rect(Rect2(Vector2(x,y) * Constants.TILE_SIZE + top_left, Constants.TILE_SIZE), Color.RED, false)
