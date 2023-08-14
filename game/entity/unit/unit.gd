extends Entity
class_name Unit

enum TASK_FLAG {BUILDER=1, TRANSPORTER=2, MINER=4}
@export_flags("builder:1", "transporter:2", "miner:4") var task_flags := 0
func has_task_flag(flag : TASK_FLAG) -> bool:
	return task_flags & flag

signal requesting_assignment()

var assignment : UnitAssignment = null

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

func set_assignemnt(_assignment : UnitAssignment) -> void:
	move_state = MOVE_STATE.STANDBY
	move_target = null
	assignment = _assignment

func clear_assignment():
	move_state = MOVE_STATE.STANDBY
	move_target = null
	assignment = UnitAssignment.new()
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
	match(assignment.goal_state):
		UnitAssignment.GOAL_STATE.STANDBY:
			move_state = MOVE_STATE.STANDBY
		
		UnitAssignment.GOAL_STATE.BUILD:
			var construction_assignment := (assignment as UnitAssignment.ConstructionUnitAssignment)
			
			var construction_site := construction_assignment.construction_site
			var construction_site_valid : bool = (construction_site != null && is_instance_valid(construction_site))
			if(!construction_site_valid):
				clear_assignment()
				return
				
			if(!construction_assignment.picked_up):
				# pickup building materials
				var pickup_structure := construction_assignment.pickup_structure
				var pickup_structure_valid : bool = (pickup_structure != null && is_instance_valid(pickup_structure))
				if(!pickup_structure_valid):
					#TODO : check for partial item pickup
					clear_assignment()
					return
				
				if(global_position.distance_squared_to(pickup_structure.global_position) > pow(pickup_structure.get_dock_range(), 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = pickup_structure
					approach_distance = pickup_structure.get_dock_range() * 0.9
				else:
					var remaining_construction_cost := construction_site.get_remaining_construction_cost()
					var valid_insert_items := get_inventory().precalculate_insert_result(remaining_construction_cost)
					Inventory.transfer_items(pickup_structure.get_inventory(), get_inventory(), valid_insert_items)
					construction_assignment.assigned_items = valid_insert_items
					construction_assignment.picked_up = true
					
					if(valid_insert_items.is_empty() || get_inventory().is_empty()):
						# could not pick up any building material
						clear_assignment()
						return
					else:
						move_state = MOVE_STATE.STANDBY
			else:
				# bring materials to construction site
				
				if(global_position.distance_squared_to(construction_site.global_position) > pow(construction_site.get_dock_range(), 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = construction_site
					approach_distance = construction_site.get_dock_range() * 0.9
				else:
					# transfer over any inventory still needed for construction
					Inventory.transfer_items(get_inventory(), construction_site.get_inventory(), construction_site.get_remaining_construction_cost())
					clear_assignment()
					return
		
		UnitAssignment.GOAL_STATE.MINE:
			var mining_assignment := (assignment as UnitAssignment.MiningUnitAssignment)
			
			var resource_node := mining_assignment.resource_node
			var mining_valid : bool = (resource_node != null && is_instance_valid(resource_node)  && can_mine())
			
			if(!mining_valid):
				clear_assignment()
				return
			else:
				# get the minimum range of all miner tools
				var mining_range : float = -1
				for miner in get_tools(Constants.TOOL_TYPE_MINER):
					mining_range = (miner as MinerTool).max_range if mining_range < 0 else min(mining_range, (miner as MinerTool).max_range)
					
				approach_distance = mining_range * 0.9
			
				for miner in get_tools(Constants.TOOL_TYPE_MINER):
					(miner as MinerTool).set_target(resource_node)
				
				if(global_position.distance_squared_to(resource_node.global_position) > pow(approach_distance, 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = resource_node
				else:
					move_state = MOVE_STATE.STANDBY
		
		UnitAssignment.GOAL_STATE.RETURN:
			var return_assignment := (assignment as UnitAssignment.ReturnUnitAssignment)
			
			var structure := return_assignment.structure
			var structure_valid : bool = (structure != null && is_instance_valid(structure))
			
			if(!structure_valid):
				clear_assignment()
				return
			else:
				approach_distance = structure.get_dock_range() * 0.9
				if(global_position.distance_squared_to(structure.global_position) > pow(approach_distance, 2)):
					move_state = MOVE_STATE.APPROACH
					move_target = structure
				else:
					if(!get_inventory().is_empty() && structure.has_inventory()):
						Inventory.transfer_all(get_inventory(), structure.get_inventory())
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

