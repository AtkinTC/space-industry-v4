extends Node2D
class_name EntitiesParentNode

func _ready() -> void:
	EntityManager.register_entities_parent_node(self)
