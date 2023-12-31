extends Node
# Singleton AssignmentConductor

var receivers := {}
var receiver_assignments := {}

var needs_assignment_queue : Array[int] = []
var needs_assignment_waiting_queue : Array[int] = []

var resource_node_assignments : Dictionary = {}

var construction_sites : Dictionary = {}
var construction_sites_queue : Array[int] = []
var construction_site_assignments : Dictionary = {}

const MAX_MINERS_PER_RESOURCE_NODE : int = 2
const MAX_BUILDERS_PER_CONSTRUCTION_SITE : int = 2

const ASSIGNMENT_WAIT_TIME : float = 0.5
var wait_timer : SceneTreeTimer = null

func _init() -> void:
	SignalBus.register_assignment_receiver.connect(register_receiver)
	SignalBus.register_construction_site.connect(register_construction_site)

func _physics_process(_delta: float) -> void:
	if(wait_timer == null || wait_timer.time_left <= 0):
		wait_timer = get_tree().create_timer(ASSIGNMENT_WAIT_TIME)
		needs_assignment_queue.append_array(needs_assignment_waiting_queue)
		needs_assignment_waiting_queue.clear()
	assign_tasks()

func register_receiver(instance_id : int) -> void:
	if(receivers.has(instance_id)):
		print_debug("receiver %d is already registered" % instance_id)
		return
	var receiver : AssignmentReceiverLogicComponent = instance_from_id(instance_id)
	if(receiver == null):
		return
	
	receivers[instance_id] = receiver
	receiver.get_entity().tree_exiting.connect(_on_receiver_freed.bind(instance_id))
	receiver.requesting_assignment.connect(_on_receiver_requesting_assignment.bind(instance_id))

func unregister_receiver(instance_id : int) -> void:
	if(!receivers.has(instance_id)):
		return
	
	var receiver : AssignmentReceiverLogicComponent = receivers[instance_id]
	if(is_instance_valid(receiver)):
		if(receiver.requesting_assignment.is_connected(_on_receiver_requesting_assignment)):
			receiver.requesting_assignment.disconnect(_on_receiver_requesting_assignment)
	
	clear_receiver_assignment(instance_id)
	needs_assignment_queue.erase(instance_id)
	needs_assignment_waiting_queue.erase(instance_id)
	receivers.erase(instance_id)
	
	if(is_instance_id_valid(instance_id)):
		pass

func _on_receiver_freed(instance_id : int) -> void:
	unregister_receiver(instance_id)

func _on_receiver_requesting_assignment(instance_id : int) -> void:
	if(!receivers.has(instance_id)):
		print_debug("unregistered receiver %d is requesting assignment" % instance_id)
		return
	if(needs_assignment_queue.has(instance_id) || needs_assignment_waiting_queue.has(instance_id)):
		print_debug("receiver %d already in assignment queue" % instance_id)
		return
	clear_receiver_assignment(instance_id)
	needs_assignment_waiting_queue.append(instance_id)

func assign_tasks() -> void:
	if(needs_assignment_queue.is_empty()):
		return
	
	# iterate over duplicate of queue
	for instance_id in needs_assignment_queue.duplicate():
		assign_task(instance_id)

func assign_task(instance_id : int) -> void:
	var receiver : AssignmentReceiverLogicComponent = receivers[instance_id]
		
	var task_groups : Array[String] = receiver.get_task_groups()
	
	if(task_groups.has(Constants.TASK_GROUP_BUILDER)):
		if(receiver.can_build() && receiver.get_entity().get_inventory_component().is_empty()):
			var depots : Array[Entity] = get_depots()
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
#					var i := s.get_inventory_component().get_contents()
#					var r := s.get_inventory_component().contains_any(needed_materials)
#					pass
				
				if(needed_materials.is_empty()):
					#SKIP - site already has needed materials
					continue
				
				var filtered_stations : Array[Entity] = depots.filter(func lambda(s : Entity) : return !s.get_inventory_component().contains_any(needed_materials).is_empty())
				if(filtered_stations.is_empty()):
					#SKIP - no stations with applicable build materials
					continue
				
				var pickup_station : Entity = Utils.get_closest_targets(receiver.get_entity().global_position, filtered_stations, 1)[0]
				
				var pickup_items : Dictionary = pickup_station.get_inventory_component().contains_any(needed_materials)
				
				set_receiver_assignment(receiver, Assignment.BuildConstructionSiteAssignment.new(site, pickup_station, pickup_items))
				return
	
	if(task_groups.has(Constants.TASK_GROUP_MINER)):
		if(receiver.can_mine()):
			var filtered_targets : Array[ResourceNode] = find_mining_targets().filter(func lambda(n : ResourceNode) : return (resource_node_assignments.get(n.get_instance_id(), []).size() < MAX_MINERS_PER_RESOURCE_NODE))
			var targets := Utils.get_closest_targets(receiver.get_entity().global_position, filtered_targets)
			if(targets != null && targets.size() > 0 && targets[0] is ResourceNode):
				set_receiver_assignment(receiver, Assignment.MiningAssignment.new(targets[0]))
				return
			else:
				print_debug("No Resource Nodes to mine")
		else:
			var targets := Utils.get_closest_targets(receiver.get_entity().global_position, get_dropoff_depots())
			if(targets != null && targets.size() > 0 && targets[0] is Entity):
				set_receiver_assignment(receiver, Assignment.ReturnToEntityAssignment.new(targets[0]))
				return
			else:
				print_debug("No stations to return to")
	
	var depots := Utils.get_closest_targets(receiver.get_entity().global_position, get_depots())
	if(depots != null && depots.size() > 0 && depots[0] is Entity):
		set_receiver_assignment(receiver, Assignment.ReturnToEntityAssignment.new(depots[0]))
		return
	
	print_debug("No valid to task to assign to entity %d" % instance_id)
	# move to the waiting queue
	needs_assignment_waiting_queue.append(instance_id)
	needs_assignment_queue.erase(instance_id)
	

func set_receiver_assignment(receiver : AssignmentReceiverLogicComponent, assignment : Assignment) -> void:
	var instance_id := receiver.get_instance_id()
	receiver_assignments[instance_id] = assignment
	needs_assignment_queue.erase(instance_id)
	receiver.set_assignemnt(assignment)
	
	if(assignment is Assignment.BuildConstructionSiteAssignment):
		var site_id := (assignment as Assignment.BuildConstructionSiteAssignment).construction_site_id
		construction_site_assignments[site_id] = construction_site_assignments.get(site_id, []) + [instance_id]
	
	if(assignment is Assignment.MiningAssignment):
		var resource_node_id := (assignment as Assignment.MiningAssignment).resource_node_id
		resource_node_assignments[resource_node_id] = resource_node_assignments.get(resource_node_id, []) + [instance_id]

func clear_receiver_assignment(instance_id : int) -> void:
	if(receiver_assignments.has(instance_id)):
		var assignment : Assignment = receiver_assignments[instance_id]
		
		if(assignment is Assignment.BuildConstructionSiteAssignment):
			# clear out additional consruction assignment details
			var construction_site_id : int = (assignment as Assignment.BuildConstructionSiteAssignment).construction_site_id
			var assigned_ids : Array = construction_site_assignments.get(construction_site_id, [])
			assigned_ids.erase(instance_id)
			if(assigned_ids.is_empty()):
				construction_site_assignments.erase(construction_site_id)
			else:
				construction_site_assignments[construction_site_id] = assigned_ids
		
		# clear out assitional mining assignment details
		if(assignment is Assignment.MiningAssignment):
			var resource_node_id : int = (assignment as Assignment.MiningAssignment).resource_node_id
			var assigned_ids : Array = resource_node_assignments.get(resource_node_id, [])
			assigned_ids.erase(instance_id)
			if(assigned_ids.is_empty()):
				resource_node_assignments.erase(resource_node_id)
			else:
				resource_node_assignments[resource_node_id] = assigned_ids
			
	receiver_assignments.erase(instance_id)

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

func get_depots() -> Array[Entity]:
	var nodes := get_tree().get_nodes_in_group(Constants.GROUP_DEPOT)
	var depots : Array[Entity] = []
	for node in nodes:
		if(node is Entity && node.is_depot):
			depots.append(node)
	return depots

func get_dropoff_depots() -> Array[Entity]:
	var depots : Array[Entity] = []
	for depot in get_depots():
		if(depot.has_inventory() && !depot.get_inventory_component().is_full()):
			depots.append(depot)
	return depots
