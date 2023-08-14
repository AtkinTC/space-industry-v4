extends Resource
class_name MovementLogic

var parent : Enemy

func set_controlled_parent(_enemy : Enemy):
	parent = _enemy

func process(_delta : float):
	pass
