extends Tool
class_name MinerTool

func get_tool_type():
	return Constants.TOOL_TYPE_MINER

@export var max_range : float = 40
@export var cycle_duration : float = 5
@export var mining_power : float = 1.0

var cycle_time : float = 0

var target : ResourceNode = null
var next_target : ResourceNode = null

enum STATE {STANDBY, CYCLING}
var state := STATE.STANDBY

func _ready() -> void:
	pass

func get_inventory() -> Inventory:
	return parent_entity.get_inventory()

func _physics_process(_delta: float) -> void:
	if(state == STATE.STANDBY && next_target != null):
		target = next_target
		next_target = null
	
	var target_valid : bool = false
	if(target != null && is_instance_valid(target)):
		var distance_squared_to_target = global_position.distance_squared_to(target.global_position)
		if(distance_squared_to_target <= pow(max_range, 2)):
			target_valid = true
	else:
		target = null
			
	if(state == STATE.STANDBY):
		if(target_valid):
			start_cycle()
	elif(state == STATE.CYCLING):
		if(target_valid):
			if(cycle_time >= cycle_duration):
				complete_cycle()
			else:
				process_cycle(_delta)
		else:
			complete_cycle()
	queue_redraw()

func start_cycle():
	if(get_inventory().is_full()):
		return
	state = STATE.CYCLING
	cycle_time = 0.0

func process_cycle(_delta : float):
	cycle_time += _delta

func complete_cycle():
	cycle_time = 0.0
	state = STATE.STANDBY
	
	if(target == null):
		return
	
	var completion : float = cycle_time / cycle_duration
	completion = max(min(completion, 0.0), 1.0)

	var mine_result := target.mine(floori(mining_power))
	get_inventory().insert_items(mine_result, true)
	
func set_target(_target : ResourceNode) -> void:
	next_target = _target

func _draw():
	if(state == STATE.CYCLING && target != null && is_instance_valid(target)):
		var local_target_position : Vector2 = (target.global_position - global_position).rotated(-global_rotation)
		var beam_color = Color.BLUE
		beam_color.a = cycle_time / cycle_duration
		draw_line(Vector2.ZERO, local_target_position, beam_color, 2)
		
