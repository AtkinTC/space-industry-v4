extends Area2D
class_name Entity

@export var default_entity_type : String
var entity_def : EntityDefinition
@export var default_init_parameters : Dictionary = {}
var init_parameters : Dictionary = {}

@export var inventory : Inventory = null
@export var health : Health = null

@onready var collision_shape : CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var collision_polygon : CollisionPolygon2D = get_node_or_null("CollisionPolygon2D")

@onready var tools_node : Node2D = get_node_or_null("Tools")
var tools : Dictionary = {}

func init(_entity_def : EntityDefinition = null, _init_parameters : Dictionary = {}) -> void:
	entity_def = _entity_def
	init_parameters = _init_parameters

func _ready():
	deferred_ready.call_deferred()
	setup()
	
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
	pass

#############
### SETUP ###
#############

func setup() -> void:
	if(entity_def == null && !default_entity_type.is_empty()):
		entity_def = EntityDefs.get_entity_definition(default_entity_type)
	setup_from_entity_def()
	
	if(init_parameters.is_empty() && !default_init_parameters.is_empty()):
		init_parameters = default_init_parameters
	setup_from_init_parameters()
	
	setup_inventory()
	setup_health()

func setup_from_entity_def() -> void:
	if(entity_def == null):
		entity_def = EntityDefinition.new()

func setup_from_init_parameters() -> void:
	global_position = init_parameters.get(Constants.KEY_POSITION, global_position)
	global_rotation = init_parameters.get(Constants.KEY_ROTATION, global_rotation)

#################
### INVENTORY ###
#################

func setup_inventory() -> void:
	if(inventory == null && entity_def.base_inventory_capacity > 0):
		inventory = Inventory.new(entity_def.base_inventory_capacity)

func has_inventory() -> bool:
	return inventory != null

func get_inventory() -> Inventory:
	return inventory

##############
### HEALTH ###
##############

func setup_health() -> void:
	if(health == null && entity_def.health != null):
		health = entity_def.health.duplicate()
	if(health != null):
		health.initialize()
		health.hull_depleted.connect(_on_hull_depleted)
		health.shield_depleted.connect(_on_shield_depleted)

func has_health() -> bool:
	return health != null

func get_health() -> Health:
	return health

func _on_hull_depleted() -> void:
	print("Hull depleted")

func _on_shield_depleted() -> void:
	print("Shield depleted")

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
