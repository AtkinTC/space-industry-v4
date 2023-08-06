extends Entity
class_name Structure

@export var is_depot : bool = false

var grid_position := Vector2i()

#Override
func _ready():
	super._ready()
	add_to_group(Constants.GROUP_STRUCTURE)

#Override
func setup_from_entity_def() -> void:
	if(entity_def == null):
		entity_def = StructureDefinition.new()
	super.setup_from_entity_def()

#Override
func setup_from_init_parameters() -> void:
	if(init_parameters.has(Constants.KEY_GRID_POSITION)):
		grid_position = init_parameters.get(Constants.KEY_GRID_POSITION)
		var pos = entity_def.grid_to_world(grid_position)
		global_position = entity_def.grid_to_world(grid_position)
		init_parameters.erase(Constants.KEY_POSITION)
	super.setup_from_init_parameters()

func get_dock_range() -> float:
	return (entity_def as StructureDefinition).dock_range
