extends Node2D
class_name EnemiesParentNode

func _ready() -> void:
	EntityManager.register_enemies_parent_node(self)
