extends Resource
class_name LogicComponent

var parent : Unit

func initialize() -> void:
	pass

func set_controlled_parent(_parent : Unit):
	parent = _parent

func process(_delta : float):
	pass

func get_parent() -> Unit:
	return parent
