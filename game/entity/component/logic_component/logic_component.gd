extends Resource
class_name LogicComponent

var entity : Entity

func initialize() -> void:
	pass

func process(_delta : float):
	pass

func set_entity(_entity : Entity):
	entity = _entity
	
func get_entity() -> Entity:
	return entity
