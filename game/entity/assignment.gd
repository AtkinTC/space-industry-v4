extends Node
class_name Assignment

enum GOAL_STATE {STANDBY, MINE, BUILD, RETURN}

var goal_state : GOAL_STATE = GOAL_STATE.STANDBY

func _init(_goal_state : GOAL_STATE = GOAL_STATE.STANDBY) -> void:
	goal_state = _goal_state

class ReturnToEntityAssignment extends Assignment:
	var target_entity : Entity = null
	var target_entity_id : int = -1
	
	func _init(_target_entity : Entity) -> void:
		super._init(GOAL_STATE.RETURN)
		target_entity = _target_entity
		target_entity_id = target_entity.get_instance_id()

class MiningAssignment extends Assignment:
	var resource_node : ResourceNode = null
	var resource_node_id : int = -1
	
	func _init(_resource_node : ResourceNode) -> void:
		super._init(GOAL_STATE.MINE)
		resource_node = _resource_node
		resource_node_id = resource_node.get_instance_id()

class BuildConstructionSiteAssignment extends Assignment:
	var construction_site: ConstructionSite = null
	var construction_site_id : int = -1
	var pickup_site : Entity = null
	var pickup_site_id : int = -1
	
	var assigned_items : Dictionary = {}
	var picked_up := false
	
	func _init(_construction_site : ConstructionSite, _pickup_site : Entity, _assigned_items : Dictionary) -> void:
		super._init(GOAL_STATE.BUILD)
		construction_site = _construction_site
		construction_site_id = construction_site.get_instance_id()
		pickup_site = _pickup_site
		pickup_site_id = pickup_site.get_instance_id()
		assigned_items = _assigned_items
