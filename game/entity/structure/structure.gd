extends Entity
class_name Structure

@export var dock_range : float = 50

@export var is_depot : bool = false

func set_init(init_parameters : Dictionary) -> void:
	super.set_init(init_parameters)

func _ready():
	super._ready()
	add_to_group(Strings.GROUP_STRUCTURE)

func get_dock_range() -> float:
	return dock_range
