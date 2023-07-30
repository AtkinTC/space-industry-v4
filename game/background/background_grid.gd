@tool
extends Sprite2D
class_name BackgroundGrid

@export var grid_cell_size : Vector2i = Vector2i(32,32)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("position", position - get_rect().size/2)
	material.set_shader_parameter("gridWidth_1", grid_cell_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	material.set_shader_parameter("position", position - get_rect().size/2)
