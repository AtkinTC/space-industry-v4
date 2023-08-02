extends Entity
class_name Structure

@export var is_depot : bool = false

func setup_from_entity_def() -> void:
	if(entity_def == null):
		entity_def = StructureDefinition.new()
	super.setup_from_entity_def()

func setup_from_init_parameters() -> void:
	super.setup_from_init_parameters()

func _ready():
	super._ready()
	add_to_group(Constants.GROUP_STRUCTURE)

func get_dock_range() -> float:
	return (entity_def as StructureDefinition).dock_range
