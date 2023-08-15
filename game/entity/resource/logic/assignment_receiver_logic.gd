extends DecisionLogic
class_name AssignmentReceiverLogic

signal requesting_assignment()

enum TASK_FLAG {BUILDER=1, TRANSPORTER=2, MINER=4}
@export_flags("builder:1", "transporter:2", "miner:4") var task_flags := 0
func has_task_flag(flag : TASK_FLAG) -> bool:
	return task_flags & flag

var assignment : UnitAssignment = null

func initialize() -> void:
	super.initialize()
	SignalBus.register_assignment_receiver.emit(get_instance_id())
	clear_assignment()

func set_assignemnt(_assignment : UnitAssignment) -> void:
	parent.move_state = Unit.MOVE_STATE.STANDBY
	parent.move_target = null
	assignment = _assignment

func clear_assignment():
	parent.move_state = Unit.MOVE_STATE.STANDBY
	parent.move_target = null
	assignment = UnitAssignment.new()
	requesting_assignment.emit()

func get_task_groups() -> Array[String]:
	var task_groups : Array[String] = []
	
	if(has_task_flag(TASK_FLAG.BUILDER)):
		task_groups.append(Constants.TASK_GROUP_BUILDER)
	if(has_task_flag(TASK_FLAG.TRANSPORTER)):
		task_groups.append(Constants.TASK_GROUP_TRANSPORTER)
	if(has_task_flag(TASK_FLAG.MINER)):
		task_groups.append(Constants.TASK_GROUP_MINER)
	
	return task_groups

func can_mine() -> bool:
	if(!has_task_flag(TASK_FLAG.MINER)):
		return false
	if(!parent.has_inventory() || parent.get_inventory().is_full()):
		return false
	if(parent.get_tools(Constants.TOOL_TYPE_MINER).is_empty()):
		return false
	return true

func can_build() -> bool:
	if(!has_task_flag(TASK_FLAG.BUILDER)):
		return false
	if(!parent.has_inventory()):
		return false
	return true

func process(_delta : float) -> void:
	parent.approach_distance = 0.0
	match(assignment.goal_state):
		UnitAssignment.GOAL_STATE.STANDBY:
			parent.move_state = Unit.MOVE_STATE.STANDBY
		
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
				
				if(parent.global_position.distance_squared_to(pickup_structure.global_position) > pow(pickup_structure.get_dock_range(), 2)):
					parent.move_state = Unit.MOVE_STATE.APPROACH
					parent.move_target = pickup_structure
					parent.approach_distance = pickup_structure.get_dock_range() * 0.9
				else:
					var remaining_construction_cost := construction_site.get_remaining_construction_cost()
					var valid_insert_items := parent.get_inventory().precalculate_insert_result(remaining_construction_cost)
					Inventory.transfer_items(pickup_structure.get_inventory(), parent.get_inventory(), valid_insert_items)
					construction_assignment.assigned_items = valid_insert_items
					construction_assignment.picked_up = true
					
					if(valid_insert_items.is_empty() || parent.get_inventory().is_empty()):
						# could not pick up any building material
						clear_assignment()
						return
					else:
						parent.move_state = Unit.MOVE_STATE.STANDBY
			else:
				# bring materials to construction site
				
				if(parent.global_position.distance_squared_to(construction_site.global_position) > pow(construction_site.get_dock_range(), 2)):
					parent.move_state = Unit.MOVE_STATE.APPROACH
					parent.move_target = construction_site
					parent.approach_distance = construction_site.get_dock_range() * 0.9
				else:
					# transfer over any inventory still needed for construction
					Inventory.transfer_items(parent.get_inventory(), construction_site.get_inventory(), construction_site.get_remaining_construction_cost())
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
				for miner in parent.get_tools(Constants.TOOL_TYPE_MINER):
					mining_range = (miner as MinerTool).max_range if mining_range < 0 else min(mining_range, (miner as MinerTool).max_range)
					(miner as MinerTool).set_target(resource_node)
				
				parent.approach_distance = mining_range * 0.9
				
				if(parent.global_position.distance_squared_to(resource_node.global_position) > pow(parent.approach_distance, 2)):
					parent.move_state = Unit.MOVE_STATE.APPROACH
					parent.move_target = resource_node
				else:
					parent.move_state = Unit.MOVE_STATE.STANDBY
		
		UnitAssignment.GOAL_STATE.RETURN:
			var return_assignment := (assignment as UnitAssignment.ReturnUnitAssignment)
			
			var structure := return_assignment.structure
			var structure_valid : bool = (structure != null && is_instance_valid(structure))
			
			if(!structure_valid):
				clear_assignment()
				return
			else:
				parent.approach_distance = structure.get_dock_range() * 0.9
				if(parent.global_position.distance_squared_to(structure.global_position) > pow(parent.approach_distance, 2)):
					parent.move_state = Unit.MOVE_STATE.APPROACH
					parent.move_target = structure
				else:
					if(!parent.get_inventory().is_empty() && structure.has_inventory()):
						Inventory.transfer_all(parent.get_inventory(), structure.get_inventory())
					clear_assignment()
					return
