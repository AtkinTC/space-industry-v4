extends Resource
class_name MovementComponent

var parent : Unit

func initialize() -> void:
	pass

func set_controlled_parent(_parent : Unit):
	parent = _parent

func process(_delta : float):
	pass
