extends Node2D
class_name UnitsParentNode

func _ready() -> void:
	EntityManager.register_units_parent_node(self)
