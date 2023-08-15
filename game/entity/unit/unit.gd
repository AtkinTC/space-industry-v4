extends Entity
class_name Unit

enum MOVE_STATE {STANDBY, APPROACH}
var move_state := MOVE_STATE.STANDBY
var move_target : Node2D = null

var approach_distance : float = 0

var velocity := Vector2.ZERO

@export var decision_logic : DecisionLogic = null
@export var movement_logic : MovementLogic = null

#Override
func _ready():
	super._ready()
	add_to_group(Constants.GROUP_PLAYER_ENTITY)
	add_to_group(Constants.GROUP_UNIT)
	
	if(decision_logic == null):
		decision_logic = DecisionLogic.new()
	decision_logic.set_controlled_parent(self)
	if(movement_logic == null):
		movement_logic = MovementLogic.new()
	movement_logic.set_controlled_parent(self)
	
	decision_logic.initialize()
	movement_logic.initialize()

#Override
func setup_from_entity_def() -> void:
	if(entity_def == null && !default_entity_type.is_empty()):
		entity_def = EntityDefs.get_unit_definition(default_entity_type)
	if(entity_def == null):
		entity_def = UnitDefinition.new()
	super.setup_from_entity_def()

#Override
func setup_from_init_parameters() -> void:
	super.setup_from_init_parameters()

func _physics_process(_delta : float) -> void:
	super._physics_process(_delta)
	decision_logic.process(_delta)
	movement_logic.process(_delta)

func can_mine() -> bool:
	if(!has_inventory() || get_inventory().is_full()):
		return false
	if(get_tools(Constants.TOOL_TYPE_MINER).is_empty()):
		return false
	return true

func can_build() -> bool:
	if(!has_inventory()):
		return false
	return true

