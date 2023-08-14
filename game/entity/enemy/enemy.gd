extends Entity
class_name Enemy

enum MOVE_STATE {STANDBY, APPROACH}
var move_state := MOVE_STATE.STANDBY
var move_target : Node2D = null

var approach_distance : float = 0

var velocity := Vector2.ZERO

@export var decision_logic : DecisionLogic = null
@export var movement_logic : MovementLogic = null

func _ready() -> void:
	super._ready()
	add_to_group(Constants.GROUP_ENEMY_ENTITY)
	if(decision_logic == null):
		decision_logic = DecisionLogic.new()
	decision_logic.set_controlled_parent(self)
	if(movement_logic == null):
		movement_logic = MovementLogic.new()
	movement_logic.set_controlled_parent(self)

func setup_from_entity_def() -> void:
	if(entity_def == null && !default_entity_type.is_empty()):
		entity_def = EntityDefs.get_enemy_definition(default_entity_type)
	if(entity_def == null):
		entity_def = EnemyDefinition.new()
	super.setup_from_entity_def()

func _physics_process(_delta : float) -> void:
	super._physics_process(_delta)
	decision_logic.process(_delta)
	movement_logic.process(_delta)
