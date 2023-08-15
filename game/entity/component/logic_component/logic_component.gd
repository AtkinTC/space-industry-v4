extends Resource
class_name LogicComponent

var parent : Entity

func initialize() -> void:
	pass

func set_controlled_parent(_parent : Entity):
	parent = _parent

func process(_delta : float):
	pass

func get_parent() -> Unit:
	return parent
