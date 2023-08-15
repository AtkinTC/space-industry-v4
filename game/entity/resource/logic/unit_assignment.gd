extends Node
class_name UnitAssignment

enum GOAL_STATE {STANDBY, MINE, BUILD, RETURN}

var goal_state : GOAL_STATE = GOAL_STATE.STANDBY

func _init(_goal_state : GOAL_STATE = GOAL_STATE.STANDBY) -> void:
	goal_state = _goal_state

class ReturnUnitAssignment extends UnitAssignment:
	var structure : Structure = null
	var structure_id : int = -1
	
	func _init(_structure : Structure) -> void:
		super._init(GOAL_STATE.RETURN)
		structure = _structure
		structure_id = structure.get_instance_id()

class MiningUnitAssignment extends UnitAssignment:
	var resource_node : ResourceNode = null
	var resource_node_id : int = -1
	
	func _init(_resource_node : ResourceNode) -> void:
		super._init(GOAL_STATE.MINE)
		resource_node = _resource_node
		resource_node_id = resource_node.get_instance_id()

class ConstructionUnitAssignment extends UnitAssignment:
	var construction_site: ConstructionSite = null
	var construction_site_id : int = -1
	var pickup_structure : Structure = null
	var pickup_structure_id : int = -1
	
	var assigned_items : Dictionary = {}
	var picked_up := false
	
	func _init(_construction_site : ConstructionSite, _pickup_structure : Structure, _assigned_items : Dictionary) -> void:
		super._init(GOAL_STATE.BUILD)
		construction_site = _construction_site
		construction_site_id = construction_site.get_instance_id()
		pickup_structure = _pickup_structure
		pickup_structure_id = pickup_structure.get_instance_id()
		assigned_items = _assigned_items
