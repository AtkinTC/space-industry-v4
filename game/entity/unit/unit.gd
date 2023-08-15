extends Entity
class_name Unit

enum MOVE_STATE {STANDBY, APPROACH}
var move_state := MOVE_STATE.STANDBY
var move_target : Node2D = null

var approach_distance : float = 0

var velocity := Vector2.ZERO

@export var logic_component : LogicComponent = null
@export var movement_component : MovementComponent = null

#Override
func _ready():
	super._ready()
	add_to_group(Constants.GROUP_PLAYER_ENTITY)
	add_to_group(Constants.GROUP_UNIT)

func _physics_process(_delta : float) -> void:
	super._physics_process(_delta)
	logic_component.process(_delta)
	movement_component.process(_delta)

#############
### SETUP ###
#############

func setup() -> void:
	super.setup()
	
	setup_logic_component()
	setup_movement_component()

func setup_from_entity_def() -> void:
	if(entity_def == null && !default_entity_type.is_empty()):
		entity_def = EntityDefs.get_unit_definition(default_entity_type)
	if(entity_def == null):
		entity_def = UnitDefinition.new()
	super.setup_from_entity_def()

func setup_from_init_parameters() -> void:
	super.setup_from_init_parameters()

func setup_logic_component() -> void:
	if(entity_def.logic_component != null):
		logic_component = entity_def.logic_component.duplicate()
	else:
		if(logic_component == null):
			print_debug(" No LogicComponent resource for entity : %s" % entity_def.entity_type)
			logic_component = LogicComponent.new()
		else:
			if(!logic_component.resource_local_to_scene):
				print_debug("LogicComponent resource is not local_to_scene for entity : %s" % entity_def.entity_type)
	
	logic_component.set_controlled_parent(self)
	logic_component.initialize()

func setup_movement_component() -> void:
	if(entity_def.movement_component != null):
		movement_component = entity_def.movement_component.duplicate()
	else:
		if(movement_component == null):
			print_debug(" No MovementComponent resource for entity : %s" % entity_def.entity_type)
			movement_component = MovementComponent.new()
		else:
			if(!movement_component.resource_local_to_scene):
				print_debug("MovementComponent resource is not local_to_scene for entity : %s" % entity_def.entity_type)
	
	movement_component.set_controlled_parent(self)
	movement_component.initialize()
