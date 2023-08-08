@tool
extends Node2D
class_name StructureGridTool

@export var grid_size := Vector2i(1,1) : set = set_grid_size
@export var cells : Array[Vector2i] = []

var top_left : Vector2
var center_cell_offset : Vector2

func _ready() -> void:
	recalculate()

func set_grid_size(size : Vector2i) -> void:
	if(size.x <= 0 || size.y <= 0):
		return
	grid_size = size
	recalculate()

func recalculate() -> void:
	top_left = -grid_size * Constants.TILE_SIZE_I / 2.0
	center_cell_offset = -(Vector2.ONE - ((grid_size % 2) as Vector2))/2.0 * Constants.TILE_SIZE
	
	cells = []
	@warning_ignore("integer_division")
	var offset_x : int = -(grid_size.x - 1)/2
	@warning_ignore("integer_division")
	var offset_y : int = -(grid_size.y - 1)/2
	
	for x in range(offset_x, offset_x + grid_size.x):
		for y in range(offset_y, offset_y + grid_size.y):
			cells.append(Vector2i(x,y))
	
	queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return 
	
	draw_circle(top_left, 3, Color.RED)
	draw_circle(center_cell_offset, 3, Color.BLUE)
	
	var offset = center_cell_offset - Constants.TILE_SIZE/2.0
	for cell in cells:
		draw_rect(Rect2(cell as Vector2 * Constants.TILE_SIZE + offset, Constants.TILE_SIZE), Color.RED, false)
