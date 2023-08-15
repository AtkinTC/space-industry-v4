extends Resource
class_name MovementComponent

var parent : Entity

func initialize() -> void:
	pass

func set_controlled_parent(_parent : Entity):
	parent = _parent

func process(_delta : float):
	pass
