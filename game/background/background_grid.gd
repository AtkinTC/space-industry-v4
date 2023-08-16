@tool
extends Sprite2D
class_name BackgroundGrid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("position", global_position - get_rect().size/2 + Vector2.ONE)
	material.set_shader_parameter("gridWidth_1", Constants.TILE_SIZE_I * 4)
	material.set_shader_parameter("gridWidth_2", Constants.TILE_SIZE_I * 8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	material.set_shader_parameter("position", global_position - get_rect().size/2 + Vector2.ONE)
