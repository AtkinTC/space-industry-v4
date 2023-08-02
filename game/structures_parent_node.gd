extends Node2D
class_name StructuresParentNode

func _ready() -> void:
	EntityManager.register_structures_parent_node(self)
