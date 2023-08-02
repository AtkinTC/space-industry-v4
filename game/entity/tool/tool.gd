extends Node2D
class_name Tool

@export var debug : bool = false

var parent_entity : Node2D = null

func get_tool_type() -> String:
	return Constants.TOOL_TYPE_NULL

func _ready():
	pass

func set_parent_entity(entity : Node2D) -> void:
	parent_entity = entity

func _process(_delta):
	queue_redraw()

func _draw() -> void:
	if(debug):
		debug_draw()

func debug_draw() -> void:
	pass
