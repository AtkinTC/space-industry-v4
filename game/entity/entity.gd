extends Area2D
class_name Entity

@export var entity_def : EntityDefinition = null
@export var init_parameters : Dictionary = {}

@export var inventory : Inventory = null

@onready var collision_shape : CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var collision_polygon : CollisionPolygon2D = get_node_or_null("CollisionPolygon2D")

@onready var tools_node : Node2D = get_node_or_null("Tools")
var tools : Dictionary = {}

func _init(_entity_def : EntityDefinition = null, _init_parameters : Dictionary = {}) -> void:
	setup(_entity_def, _init_parameters)

func setup(_entity_def : EntityDefinition = null, _init_parameters : Dictionary = {}) -> void:
	entity_def = _entity_def
	setup_from_entity_def()
	
	init_parameters = _init_parameters
	setup_from_init_parameters()

func setup_from_entity_def() -> void:
	if(entity_def == null):
		entity_def = EntityDefinition.new()

func setup_from_init_parameters() -> void:
	global_position = init_parameters.get(Strings.KEY_POSITION, global_position)
	global_rotation = init_parameters.get(Strings.KEY_ROTATION, global_rotation)

func _ready():
	deferred_ready.call_deferred()
	setup_inventory()
	
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

func setup_inventory() -> void:
	if(inventory == null && entity_def.base_inventory_capacity > 0):
		inventory = Inventory.new(entity_def.base_inventory_capacity)

func get_tools(tool_type : String) -> Array[Tool]:
	var result : Array = tools.get(tool_type, [])
	var typed_result : Array[Tool] = []
	for tool in result:
		typed_result.append(tool)
	return typed_result

func has_inventory() -> bool:
	return inventory != null

func get_inventory() -> Inventory:
	return inventory

func get_collision_shapes() -> Array[CollisionShape2D]:
	if(collision_shape == null):
		return []
	return [collision_shape]

func get_collision_polygons() -> Array[CollisionPolygon2D]:
	if(collision_polygon == null):
		return []
	return [collision_polygon]
