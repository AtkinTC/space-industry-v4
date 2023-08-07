extends Node
# Singleton AssignmentConductor

var units : Dictionary = {}
var unit_assignments : Dictionary = {}
var needs_assignment_queue : Array[int] = []
var needs_assignment_waiting_queue : Array[int] = []

var resource_node_assignments : Dictionary = {}

var construction_sites : Dictionary = {}
var construction_sites_queue : Array[int] = []
var construction_site_assignments : Dictionary = {}

const MAX_MINERS_PER_RESOURCE_NODE : int = 2
const MAX_BUILDERS_PER_CONSTRUCTION_SITE : int = 1

const ASSIGNMENT_WAIT_TIME : float = 1
var wait_timer : SceneTreeTimer = null

func _ready() -> void:
	SignalBus.register_unit.connect(register_unit)
	SignalBus.register_construction_site.connect(register_construction_site)

func _physics_process(_delta: float) -> void:
	if(wait_timer == null || wait_timer.time_left <= 0):
		wait_timer = get_tree().create_timer(ASSIGNMENT_WAIT_TIME)
		needs_assignment_queue.append_array(needs_assignment_waiting_queue)
		needs_assignment_waiting_queue.clear()
	assign_tasks()

###########
#  Units  #
###########

func register_unit(instance_id) -> void:
	if(units.has(instance_id)):
		print_debug("unit %d is already registered" % instance_id)
		return
	var unit : Unit = instance_from_id(instance_id)
	if(unit == null && !is_instance_valid(unit)):
		return
	
	units[instance_id] = unit
	unit.tree_exiting.connect(_on_unit_freed.bind(instance_id))
	unit.requesting_assignment.connect(_on_unit_requesting_assignment.bind(instance_id))

func unregister_unit(instance_id : int) -> void:
	if(!units.has(instance_id)):
		return
		
	clear_unit_assignment(instance_id)
	needs_assignment_queue.erase(instance_id)
	units.erase(instance_id)

func _on_unit_freed(instance_id : int) -> void:
	unregister_unit(instance_id)

func _on_unit_requesting_assignment(instance_id : int) -> void:
	if(!units.has(instance_id)):
		print_debug("unregistered unit %d is requesting assignment" % instance_id)
		return
	if(needs_assignment_queue.has(instance_id)):
		print_debug("unit %d already in assignment queue" % instance_id)
		return
	clear_unit_assignment(instance_id)
	needs_assignment_queue.append(instance_id)

func assign_tasks() -> void:
	if(needs_assignment_queue.is_empty()):
		return
	
	# iterate over duplicate of queue
	for instance_id in needs_assignment_queue.duplicate():
		assign_task(instance_id)

func assign_task(instance_id) -> void:
	var unit : Unit = units[instance_id]
		
	var task_groups : Array[String] = unit.get_task_groups()
	
	if(task_groups.has(Constants.TASK_GROUP_BUILDER)):
		#var contents := unit.get_inventory().get_contents()
		if(unit.can_build() && unit.get_inventory().is_empty()):
			#var free_capacity := unit.get_inventory().get_available_capacity()
			var stations : Array[Structure] = get_depot_stations()
			for site_id in construction_sites_queue:
				var site_assignments : Array = construction_site_assignments.get(site_id, [])
				
				if(site_assignments.size() >= MAX_BUILDERS_PER_CONSTRUCTION_SITE):
					#SKIP - max number of jobs already assigned to this site
					continue
				
				var site : ConstructionSite = construction_sites[site_id]
				
				if(!InfluenceManger.is_point_in_influence(site.global_position)):
					#SKIP - site is not in the influence area
					continue
				
				#TODO - should only look for 'unassigned' materials
				var needed_materials : Dictionary = site.get_remaining_construction_cost()
#				for s in stations:
#					var i := s.get_inventory().get_contents()
#					var r := s.get_inventory().contains_any(needed_materials)
#					pass
				
				if(needed_materials.is_empty()):
					#SKIP - site already has needed materials
					continue
				
				var filtered_stations : Array[Structure] = stations.filter(func lambda(s : Structure) : return !s.get_inventory().contains_any(needed_materials).is_empty())
				if(filtered_stations.is_empty()):
					#SKIP - no stations with applicable build materials
					continue
				
				var pickup_station : Structure = get_closest_targets(unit.global_position, filtered_stations, 1)[0]
				
				var pickup_items : Dictionary = pickup_station.get_inventory().contains_any(needed_materials)
				
				set_unit_assignment(unit, Unit.ConstructionAssignment.new(Unit.GOAL_STATE.BUILD, site, pickup_station, pickup_items))
				return
	
	if(task_groups.has(Constants.TASK_GROUP_MINER)):
		if(unit.can_mine()):
			var filtered_targets : Array[ResourceNode] = find_mining_targets().filter(func lambda(n : ResourceNode) : return (resource_node_assignments.get(n.get_instance_id(), []).size() < MAX_MINERS_PER_RESOURCE_NODE))
			var targets := get_closest_targets(unit.global_position, filtered_targets)
			if(targets != null && targets.size() > 0 && targets[0] is ResourceNode):
				set_unit_assignment(unit, Unit.Assignment.new(Unit.GOAL_STATE.MINE, targets[0]))
				return
			else:
				print_debug("No Resource Nodes to mine")
		else:
			var targets := get_closest_targets(unit.global_position, get_dropoff_stations())
			if(targets != null && targets.size() > 0 && targets[0] is Structure):
				set_unit_assignment(unit, Unit.Assignment.new(Unit.GOAL_STATE.RETURN, targets[0]))
				return
			else:
				print_debug("No stations to return to")
	
	var depots := get_closest_targets(unit.global_position, get_depot_stations())
	if(depots != null && depots.size() > 0 && depots[0] is Structure):
		set_unit_assignment(unit, Unit.Assignment.new(Unit.GOAL_STATE.RETURN, depots[0]))
		return
	
	print_debug("No valid to task to assign to unit %d" % instance_id)
	# move to the waiting queue
	needs_assignment_waiting_queue.append(instance_id)
	needs_assignment_queue.erase(instance_id)
	

func set_unit_assignment(unit : Unit, assignment : Unit.Assignment) -> void:
	var instance_id := unit.get_instance_id()
	unit_assignments[instance_id] = assignment
	needs_assignment_queue.erase(instance_id)
	unit.set_assignemnt(assignment)
	
	if(assignment is Unit.ConstructionAssignment):
		var site_id := assignment.target.get_instance_id()
		construction_site_assignments[site_id] = construction_site_assignments.get(site_id, []) + [instance_id]
	
	if(assignment.goal == Unit.GOAL_STATE.MINE):
		var resource_node_id := assignment.target.get_instance_id()
		resource_node_assignments[resource_node_id] = resource_node_assignments.get(resource_node_id, []) + [instance_id]

func clear_unit_assignment(instance_id : int) -> void:
	if(unit_assignments.has(instance_id)):
		var assignment : Unit.Assignment = unit_assignments[instance_id]
		# clear out additional consruction assignment details
		if(assignment is Unit.ConstructionAssignment):
			var construction_id : int = assignment.target_instance_id
			var assigned_ids : Array = construction_site_assignments.get(construction_id, [])
			assigned_ids.erase(instance_id)
			if(assigned_ids.is_empty()):
				construction_site_assignments.erase(construction_id)
			else:
				construction_site_assignments[construction_id] = assigned_ids
		
		# clear out assitional mining assignment details
		if(assignment.goal == Unit.GOAL_STATE.MINE):
			var resource_node_id : int = assignment.target_instance_id
			var assigned_ids : Array = resource_node_assignments.get(resource_node_id, [])
			assigned_ids.erase(instance_id)
			if(assigned_ids.is_empty()):
				resource_node_assignments.erase(resource_node_id)
			else:
				resource_node_assignments[resource_node_id] = assigned_ids
			
	unit_assignments.erase(instance_id)

##################
#  Construction  #
##################

func register_construction_site(instance_id) -> void:
	if(construction_sites.has(instance_id)):
		print_debug("construction site %d is already registered" % instance_id)
		return
	var construction_site : ConstructionSite = instance_from_id(instance_id)
	if(construction_site == null && !is_instance_valid(construction_site)):
		return
	
	construction_sites[instance_id] = construction_site
	construction_sites_queue.append(instance_id)
	construction_site.tree_exiting.connect(_on_construction_site_freed.bind(instance_id))

func unregister_construction_site(instance_id : int) -> void:
	if(!construction_sites.has(instance_id)):
		return
		
	construction_site_assignments.erase(instance_id)
	construction_sites_queue.erase(instance_id)
	construction_sites.erase(instance_id)

func _on_construction_site_freed(instance_id : int) -> void:
	unregister_construction_site(instance_id)

#############
#  Targets  #
#############

func find_mining_targets() -> Array[ResourceNode]:
	var resource_nodes := get_tree().get_nodes_in_group(Constants.GROUP_RESOURCE_NODE)
	var potential_mining_targets : Array[ResourceNode] = []
	for node in resource_nodes:
		if(!(node as ResourceNode).is_minable()):
			continue
		potential_mining_targets.append(node)
	return potential_mining_targets

func get_stations() -> Array[Structure]:
	var nodes := get_tree().get_nodes_in_group(Constants.GROUP_STRUCTURE)
	var stations : Array[Structure] = []
	for node in nodes:
		if(node is Structure):
			stations.append(node)
	return stations

func get_stations_filtered(filter : Callable) -> Array[Structure]:
	var nodes := get_tree().get_nodes_in_group(Constants.GROUP_STRUCTURE)
	var stations : Array[Structure] = []
	for node in nodes:
		if(node is Structure && filter.call(node)):
			stations.append(node)
	return stations

func get_depot_stations() -> Array[Structure]:
	var nodes := get_tree().get_nodes_in_group(Constants.GROUP_STRUCTURE)
	var stations : Array[Structure] = []
	for node in nodes:
		if(node is Structure && node.is_depot):
			stations.append(node)
	return stations

func get_dropoff_stations() -> Array[Structure]:
	var nodes := get_tree().get_nodes_in_group(Constants.GROUP_STRUCTURE)
	var stations : Array[Structure] = []
	for node in nodes:
		if(node is Structure && node.is_depot && node.has_inventory() && !node.get_inventory().is_full()):
			stations.append(node)
	return stations

func get_closest_targets(source_pos : Vector2, targets : Array, amount : int = 1) -> Array[Node2D]:
	if(amount < 1):
		amount = targets.size()
	var closest_targets : Array[Node2D] = []
	var closest_distances_sqr : Array[float] = []
	for node in targets:
		if(!(node is Node2D)):
			continue
		var distance_sqr = source_pos.distance_squared_to(node.global_position)
		if(closest_targets.size() == 0):
			closest_targets.append(node)
			closest_distances_sqr.append(distance_sqr)
		else:
			for i in min(amount, closest_targets.size()+1):
				if(i >= closest_targets.size()):
					closest_targets.append(node)
					closest_distances_sqr.append(distance_sqr)
					break
				elif(distance_sqr < closest_distances_sqr[i]):
					closest_targets.insert(i, node)
					closest_distances_sqr.insert(i, distance_sqr)
					break
	if(closest_targets.size() > amount):
		closest_targets.resize(amount)
		
	return closest_targets
