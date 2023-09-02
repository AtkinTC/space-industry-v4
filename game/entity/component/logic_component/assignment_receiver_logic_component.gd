extends LogicComponent
class_name AssignmentReceiverLogicComponent

signal requesting_assignment()

enum TASK_FLAG {BUILDER=1, TRANSPORTER=2, MINER=4}
@export_flags("builder:1", "transporter:2", "miner:4") var task_flags := 0
func has_task_flag(flag : TASK_FLAG) -> bool:
	return task_flags & flag

var assignment : Assignment = null

func initialize() -> void:
	super.initialize()
	SignalBus.register_assignment_receiver.emit(get_instance_id())
	clear_assignment()

func set_controlled_parent(_parent : Entity):
	assert(_parent is Unit)
	super.set_controlled_parent(_parent)

func set_assignemnt(_assignment : Assignment) -> void:
	parent.move_state = Unit.MOVE_STATE.STANDBY
	parent.move_target = null
	assignment = _assignment

func clear_assignment():
	parent.move_state = Unit.MOVE_STATE.STANDBY
	parent.move_target = null
	assignment = Assignment.new()
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
	if(!parent.has_inventory() || parent.get_inventory_component().is_full()):
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
		Assignment.GOAL_STATE.STANDBY:
			parent.move_state = Unit.MOVE_STATE.STANDBY
		
		Assignment.GOAL_STATE.BUILD:
			var construction_assignment := (assignment as Assignment.BuildConstructionSiteAssignment)
			
			var construction_site := construction_assignment.construction_site
			var construction_site_valid : bool = (construction_site != null && is_instance_valid(construction_site))
			if(!construction_site_valid):
				clear_assignment()
				return
				
			if(!construction_assignment.picked_up):
				# pickup building materials
				var pickup_site := construction_assignment.pickup_site
				var pickup_site_valid : bool = (pickup_site != null && is_instance_valid(pickup_site))
				if(!pickup_site_valid):
					#TODO : check for partial item pickup
					clear_assignment()
					return
				
				if(parent.global_position.distance_squared_to(pickup_site.global_position) > pow(pickup_site.get_dock_range(), 2)):
					parent.move_state = Unit.MOVE_STATE.APPROACH
					parent.move_target = pickup_site
					parent.approach_distance = pickup_site.get_dock_range() * 0.9
				else:
					var remaining_construction_cost := construction_site.get_remaining_construction_cost()
					var valid_insert_items := parent.get_inventory_component().precalculate_insert_result(remaining_construction_cost)
					InventoryComponent.transfer_items(pickup_site.get_inventory_component(), parent.get_inventory_component(), valid_insert_items)
					construction_assignment.assigned_items = valid_insert_items
					construction_assignment.picked_up = true
					
					if(valid_insert_items.is_empty() || parent.get_inventory_component().is_empty()):
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
					InventoryComponent.transfer_items(parent.get_inventory_component(), construction_site.get_inventory_component(), construction_site.get_remaining_construction_cost())
					clear_assignment()
					return
		
		Assignment.GOAL_STATE.MINE:
			var mining_assignment := (assignment as Assignment.MiningAssignment)
			
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
		
		Assignment.GOAL_STATE.RETURN:
			var return_assignment := (assignment as Assignment.ReturnToEntityAssignment)
			var entity := return_assignment.entity
			var entity_valid : bool = (entity != null && is_instance_valid(entity))
			
			if(!entity_valid):
				clear_assignment()
				return
			else:
				parent.approach_distance = entity.get_dock_range() * 0.9
				if(parent.global_position.distance_squared_to(entity.global_position) > pow(parent.approach_distance, 2)):
					parent.move_state = Unit.MOVE_STATE.APPROACH
					parent.move_target = entity
				else:
					if(!parent.get_inventory_component().is_empty() && entity.has_inventory()):
						InventoryComponent.transfer_all(parent.get_inventory_component(), entity.get_inventory_component())
					clear_assignment()
					return
