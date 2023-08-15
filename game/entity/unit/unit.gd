extends Entity
class_name Unit

enum MOVE_STATE {STANDBY, APPROACH}
var move_state := MOVE_STATE.STANDBY
var move_target : Node2D = null

var approach_distance : float = 0

var velocity := Vector2.ZERO

#Override
func _ready():
	super._ready()
	add_to_group(Constants.GROUP_PLAYER_ENTITY)
	add_to_group(Constants.GROUP_UNIT)

func _physics_process(_delta : float) -> void:
	super._physics_process(_delta)

#############
### SETUP ###
#############

func setup() -> void:
	super.setup()

func setup_from_entity_def() -> void:
	if(entity_def == null && !default_entity_type.is_empty()):
		entity_def = EntityDefs.get_unit_definition(default_entity_type)
	if(entity_def == null):
		entity_def = UnitDefinition.new()
	super.setup_from_entity_def()

func setup_from_init_parameters() -> void:
	super.setup_from_init_parameters()
