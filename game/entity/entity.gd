extends Area2D
class_name Entity

@export var default_entity_type : String
var entity_def : EntityDefinition
@export var default_init_parameters : Dictionary = {}
var init_parameters : Dictionary = {}

@export var inventory_component : InventoryComponent = null
@export var health_component : HealthComponent = null
@export var logic_component : LogicComponent = null
@export var movement_component : MovementComponent = null
var network_component : GridNeighborConnectorComponent = null

@onready var collision_shape : CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var collision_polygon : CollisionPolygon2D = get_node_or_null("CollisionPolygon2D")

@onready var tools_node : Node2D = get_node_or_null("Tools")
var tools : Dictionary = {}

@export var is_depot : bool = false
@export var hq : bool = false
@export var attackable: bool = false

var grid_position := Vector2i()

enum MOVE_STATE {STANDBY, APPROACH}
var move_state := MOVE_STATE.STANDBY
var move_target : Node2D = null

var approach_distance : float = 0

var velocity := Vector2.ZERO

func init(_entity_def : EntityDefinition = null, _init_parameters : Dictionary = {}) -> void:
	entity_def = _entity_def
	init_parameters = _init_parameters

func _ready():
	deferred_ready.call_deferred()
	setup()
	
	add_to_group(Constants.GROUP_PLAYER_ENTITY)
	
	if(hq):
		add_to_group(Constants.GROUP_PLAYER_HQ)
	
	if(is_depot):
		add_to_group(Constants.GROUP_DEPOT)
	
	if(entity_def.influence_radius > 0):
		var influence_node := InfluenceNode.new(entity_def.influence_radius)
		add_child(influence_node)
	
	if (tools_node != null):
		for child in tools_node.get_children():
			if(child is Tool):
				var type := (child as Tool).get_tool_type()
				tools[type] = (tools.get(type, []) as Array) + [child]
				child.set_parent_entity(self)

func deferred_ready():
	SignalBus.entity_ready.emit(self)

func _physics_process(_delta: float) -> void:
	process_logic(_delta)
	process_movement(_delta)

#############
### SETUP ###
#############

func setup() -> void:
	setup_from_entity_def()
	
	if(init_parameters.is_empty() && !default_init_parameters.is_empty()):
		init_parameters = default_init_parameters
	setup_from_init_parameters()
	
	setup_inventory()
	setup_health()
	setup_network()
	setup_logic_component()
	setup_movement_component()

func setup_from_entity_def() -> void:
	if(entity_def == null && !default_entity_type.is_empty()):
		entity_def = EntityDefs.get_entity_definition(default_entity_type)
	if(entity_def == null):
		entity_def = EntityDefs.new()
	
	self.z_index = entity_def.default_display_layer

func setup_from_init_parameters() -> void:
	if(init_parameters.has(Constants.KEY_TRANSFORM)):
		global_transform = init_parameters.get(Constants.KEY_TRANSFORM)
		
	if(init_parameters.has(Constants.KEY_POSITION)):
		global_position = init_parameters.get(Constants.KEY_POSITION)
	
	if(init_parameters.has(Constants.KEY_ROTATION)):
		global_rotation = init_parameters.get(Constants.KEY_ROTATION)
	
	if(init_parameters.has(Constants.KEY_GRID_POSITION)):
		grid_position = init_parameters.get(Constants.KEY_GRID_POSITION)
		global_position = entity_def.grid_to_world(grid_position)
		init_parameters.erase(Constants.KEY_POSITION)

#################
### INVENTORY ###
#################

func setup_inventory() -> void:
	if(entity_def.inventory_component != null):
		inventory_component = entity_def.inventory_component.duplicate(true)
	if(inventory_component == null):
		inventory_component = InventoryComponent.new()

func has_inventory() -> bool:
	return inventory_component != null

func get_inventory_component() -> InventoryComponent:
	return inventory_component

##############
### HEALTH ###
##############

func setup_health() -> void:
	if(entity_def.health_component != null):
		health_component = entity_def.health_component.duplicate(true)
	if(health_component != null):
		health_component.initialize()
		health_component.hull_depleted.connect(_on_hull_depleted)
		health_component.shield_depleted.connect(_on_shield_depleted)

func has_health() -> bool:
	return health_component != null

func get_health_component() -> HealthComponent:
	return health_component

func _on_hull_depleted() -> void:
	print("Hull depleted")

func _on_shield_depleted() -> void:
	print("Shield depleted")

#############
### LOGIC ###
#############

func setup_logic_component() -> void:
	if(entity_def.logic_component != null):
		logic_component = entity_def.logic_component.duplicate()
	else:
		if(logic_component != null && !logic_component.resource_local_to_scene):
				print_debug("LogicComponent resource is not local_to_scene for entity : %s" % entity_def.entity_type)
	
	if(logic_component == null):
		return
	
	logic_component.set_entity(self)
	logic_component.initialize()

func process_logic(_delta : float) -> void:
	if(logic_component == null):
		return
	logic_component.process(_delta)

################
### MOVEMENT ###
################

func setup_movement_component() -> void:
	if(entity_def.movement_component != null):
		movement_component = entity_def.movement_component.duplicate()
	else:
		if(!movement_component == null && !movement_component.resource_local_to_scene):
				print_debug("MovementComponent resource is not local_to_scene for entity : %s" % entity_def.entity_type)
	
	if(movement_component == null):
		return
	
	movement_component.set_entity(self)
	movement_component.initialize()

func process_movement(_delta : float) -> void:
	if(movement_component == null):
		return
	movement_component.process(_delta)
	
###############
### NETWORK ###
###############

func setup_network() -> void:
	network_component = get_node_or_null("GridNeighborConnectorComponent")

func has_network_component() -> bool:
	return network_component != null

func get_network_component() -> GridNeighborConnectorComponent:
	return network_component

#############
### TOOLS ###
#############

func get_tools(tool_type : String) -> Array[Tool]:
	var result : Array = tools.get(tool_type, [])
	var typed_result : Array[Tool] = []
	for tool in result:
		typed_result.append(tool)
	return typed_result

func get_collision_shapes() -> Array[CollisionShape2D]:
	if(collision_shape == null):
		return []
	return [collision_shape]

func get_collision_polygons() -> Array[CollisionPolygon2D]:
	if(collision_polygon == null):
		return []
	return [collision_polygon]

##############
### STATUS ###
##############

func can_mine() -> bool:
	if(!has_inventory() || get_inventory_component().is_full()):
		return false
	if(get_tools(Constants.TOOL_TYPE_MINER).is_empty()):
		return false
	return true

func can_build() -> bool:
	if(!has_inventory()):
		return false
	return true

func get_dock_range() -> float:
	return entity_def.dock_range
