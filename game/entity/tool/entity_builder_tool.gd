extends Tool
class_name EntityBuilderTool

signal build_completed(entity_type : String)
signal build_cancelled(entity_type : String)
signal orders_completed()

@export var build_speed : float = 1
var in_progress : bool = false
var remaining_build_time : float = 0

@export var build_orders := {}
var entity_type : String = ""

var spawn_points : Array[Transform2D] = []
var spawn_index : int = 0

func get_tool_type():
	return Constants.TOOL_TYPE_ENTITYBUILDER

func _ready() -> void:
	super._ready()
	
	for child in get_children():
		if(child is Marker2D):
			spawn_points.append(child.transform)
			child.queue_free()

func _physics_process(_delta: float) -> void:
	if(in_progress):
		process_build(_delta)
	else:
		if(!build_orders.is_empty()):
			start_build()

func process_build(_delta):
	if(entity_type.is_empty()):
		remaining_build_time = 0
		in_progress = false
		build_cancelled.emit("")
		return
	remaining_build_time -= _delta * build_speed
	if(remaining_build_time <= 0):
		complete_build()

func start_build() -> void:
	entity_type = ""
	for key in build_orders.duplicate().keys():
		if(build_orders[key] == 0):
			build_orders.erase(key)
			continue
		entity_type = key
	
	var entity_def := EntityDefs.get_entity_definition(entity_type)
	if(entity_def == null):
		print_debug("Attempting to build invalid entity type : " + entity_type)
		return
	remaining_build_time = entity_def.construction_time
	in_progress = true

func complete_build() -> void:
	var spawn_transform := next_spawn_transform()
	
	var spawn_params := {
		Constants.KEY_TRANSFORM : spawn_transform
	}
		
	SignalBus.spawn_entity.emit(entity_type, spawn_params)
	remaining_build_time = 0
	in_progress = false
	
	if(build_orders[entity_type] > 0):
		build_orders[entity_type] -= 1
	if(build_orders[entity_type] == 0):
		build_orders.erase(entity_type)
		
	build_completed.emit(entity_type)
	if(build_orders.is_empty()):
		orders_completed.emit()

func next_spawn_transform() -> Transform2D:
	if(spawn_points.is_empty()):
		return global_transform
	
	var spawn_transform := spawn_points[spawn_index]
	spawn_transform = Transform2D(spawn_transform.get_rotation() + global_rotation, spawn_transform.get_origin() + global_position)
	spawn_index = (spawn_index + 1) % spawn_points.size()
	return spawn_transform
