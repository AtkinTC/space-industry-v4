extends Resource
class_name DecisionLogic

var parent : Unit

func initialize() -> void:
	if(!resource_local_to_scene):
		print_debug("DecisionLogic resource is not local_to_scene")

func set_controlled_parent(_parent : Unit):
	parent = _parent

func process(_delta : float):
	pass

func get_parent() -> Unit:
	return parent
