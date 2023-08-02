extends Node2D
class_name InfluenceNode

@export var radius : float = 250

func _init(_radius : float) -> void:
	radius = _radius

func _ready() -> void:
	SignalBus.register_influence_node.emit(self)

#func _process(_delta: float) -> void:
#	queue_redraw()
#
#func _draw() -> void:
#	if(radius >= 0):
#		draw_arc(Vector2.ZERO, radius, 0, PI*2, 16, Color.RED)

func get_influence_radius() -> float:
	return radius
