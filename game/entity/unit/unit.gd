extends Entity
class_name Unit

enum TASK_FLAG {BUILDER=1, TRANSPORTER=2, MINER=4}
@export_flags("builder:1", "transporter:2", "miner:4") var task_flags := 0
func has_task_flag(flag : TASK_FLAG) -> bool:
	return task_flags & flag

class Assignment:
	var goal : GOAL_STATE = GOAL_STATE.STANDBY
	var target : Node2D = null
	var target_instance_id : int
	func _init(_goal : GOAL_STATE, _target : Node2D) -> void:
		goal = _goal
		target = _target
		target_instance_id = target.get_instance_id()

class ConstructionAssignment extends Assignment:
	var pickup_target : Structure = null
	var assigned_items : Dictionary = {}
	var picked_up := false
	func _init(_goal : GOAL_STATE, _target : Node2D, _pickup_target : Structure, _assigned_items : Dictionary) -> void:
		super._init(_goal, _target)
		pickup_target = _pickup_target
		assigned_items = _assigned_items

signal requesting_assignment()

var assignment : Assignment = null

enum MOVE_STATE {STANDBY, APPROACH}
var move_state := MOVE_STATE.STANDBY
var move_target : Node2D = null

var approach_distance : float = 0

var home_station : Structure

enum GOAL_STATE {STANDBY, MINE, BUILD, RETURN}
var goal_state := GOAL_STATE.STANDBY

var velocity := Vector2.ZERO

#Override
func _ready():
	super._ready()
	add_to_group(Constants.GROUP_PLAYER_ENTITY)
	add_to_group(Constants.GROUP_UNIT)
	
	SignalBus.register_unit.emit(get_instance_id())
	clear_assignment()

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

func get_task_groups() -> Array[String]:
	var task_groups : Array[String] = []
	
	if(has_task_flag(TASK_FLAG.BUILDER)):
		task_groups.append(Constants.TASK_GROUP_BUILDER)
	if(has_task_flag(TASK_FLAG.TRANSPORTER)):
		task_groups.append(Constants.TASK_GROUP_TRANSPORTER)
	if(has_task_flag(TASK_FLAG.MINER)):
		task_groups.append(Constants.TASK_GROUP_MINER)
	
	return task_groups

func set_assignemnt(_assignment : Assignment) -> void:
	goal_state = _assignment.goal
	move_state = MOVE_STATE.STANDBY
	move_target = null
	assignment = _assignment

func clear_assignment():
	goal_state = GOAL_STATE.STANDBY
	move_state = MOVE_STATE.STANDBY
	move_target = null
	assignment = null
	requesting_assignment.emit()

func _physics_process(_delta : float) -> void:
	super._physics_process(_delta)
	process_state(_delta)
	process_movement(_delta)

func can_mine() -> bool:
	if(!has_task_flag(TASK_FLAG.MINER)):
		return false
	if(!has_inventory() || get_inventory().is_full()):
		return false
	if(get_tools(Constants.TOOL_TYPE_MINER).is_empty()):
		return false
	return true

func can_build() -> bool:
	if(!has_task_flag(TASK_FLAG.BUILDER)):
		return false
	if(!has_inventory()):
		return false
	return true

func process_state(_delta : float):
	approach_distance = 0.0
	match(goal_state):
		GOAL_STATE.STANDBY:
			move_state = MOVE_STATE.STANDBY
		
		GOAL_STATE.BUILD:
			var build_assignment := (assignment as ConstructionAssignment)
			var pickup_target_valid : bool = (build_assignment.pickup_target != null && is_instance_valid(build_assignment.pickup_target))
			if(!pickup_target_valid):
				clear_assignment()
				return
				
			var site_target_valid : bool = (build_assignment.target != null && is_instance_valid(build_assignment.target))
			if(!site_target_valid):
				clear_assignment()
				return
				
			if(!build_assignment.picked_up):
				# pickup building materials
				var pickup_target : Structure = build_assignment.pickup_target
				if(global_position.distance_squared_to(pickup_target.global_position) > pow(pickup_target.get_dock_range(), 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = pickup_target
					approach_distance = pickup_target.get_dock_range() * 0.9
				else:
					var site_target : ConstructionSite = build_assignment.target
					var remaining_construction_cost := site_target.get_remaining_construction_cost()
					var valid_insert_items := get_inventory().precalculate_insert_result(remaining_construction_cost)
					Inventory.transfer_items(pickup_target.get_inventory(), get_inventory(), valid_insert_items)
					build_assignment.assigned_items = valid_insert_items
					build_assignment.picked_up = true
					
					if(valid_insert_items.is_empty() || get_inventory().is_empty()):
						# could not pick up any building material
						clear_assignment()
						return
					else:
						move_state = MOVE_STATE.STANDBY
			else:
				# bring materials to construction site
				var site_target : ConstructionSite = build_assignment.target
				var target_valid : bool = (site_target != null && is_instance_valid(site_target))
				if(!target_valid):
					clear_assignment()
					return
				
				if(global_position.distance_squared_to(site_target.global_position) > pow(site_target.get_dock_range(), 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = site_target
					approach_distance = site_target.get_dock_range() * 0.9
				else:
					# transfer over any inventory still needed for construction
					Inventory.transfer_items(get_inventory(), site_target.get_inventory(), site_target.get_remaining_construction_cost())
					clear_assignment()
					return
		
		GOAL_STATE.MINE:
			var mining_valid : bool = (assignment.target != null && is_instance_valid(assignment.target)  && can_mine())
			
			if(!mining_valid):
				clear_assignment()
				return
			else:
				var target : ResourceNode = assignment.target
				
				# get the minimum range of all miner tools
				var mining_range : float = -1
				for miner in get_tools(Constants.TOOL_TYPE_MINER):
					mining_range = (miner as MinerTool).max_range if mining_range < 0 else min(mining_range, (miner as MinerTool).max_range)
					
				approach_distance = mining_range * 0.9
			
				for miner in get_tools(Constants.TOOL_TYPE_MINER):
					(miner as MinerTool).set_target(target)
				
				if(global_position.distance_squared_to(target.global_position) > pow(approach_distance, 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = target
				else:
					move_state = MOVE_STATE.STANDBY
		
		GOAL_STATE.RETURN:
			var target : Structure = assignment.target
			var target_valid : bool = (target != null && is_instance_valid(target))
			
			if(!target_valid):
				clear_assignment()
				return
			else:
				approach_distance = target.get_dock_range() * 0.9
				if(global_position.distance_squared_to(target.global_position) > pow(approach_distance, 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = target
				else:
					if(!get_inventory().is_empty() && target.has_inventory()):
						Inventory.transfer_all(get_inventory(), (target as Structure).get_inventory())
					clear_assignment()
					return

func process_movement(_delta : float):
	var desired_velocity := Vector2.ZERO
	var desired_rotation := global_rotation
	
	if(move_state == MOVE_STATE.APPROACH && move_target != null):
		var distance := global_position.distance_to(move_target.global_position)
		if(is_zero_approx(distance) || distance <= approach_distance):
			desired_velocity = Vector2.ZERO
		else:
			desired_velocity = global_position.direction_to(move_target.global_position) * entity_def.base_move_speed
		desired_rotation = global_position.angle_to_point(move_target.global_position)
	else:
		desired_velocity = Vector2.ZERO
		if(move_target != null):
			desired_rotation = global_position.angle_to_point(move_target.global_position)
		
	
	velocity = desired_velocity
	
	global_position += velocity * _delta
	global_rotation = desired_rotation

