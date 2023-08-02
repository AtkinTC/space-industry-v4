extends Node2D
class_name ShipsParentNode

func _ready() -> void:
	EntityManager.register_ships_parent_node(self)
