extends LogicComponent
class_name BasicEnemyUnitLogicComponent

func set_controlled_parent(_parent : Entity):
	assert(_parent is Unit)
	super.set_controlled_parent(_parent)

func process(_delta : float):
	if(parent.move_target == null || !is_instance_valid(parent.move_target)):
		parent.move_target = null
		var nodes := parent.get_tree().get_nodes_in_group(Constants.GROUP_PLAYER_ATTACKABLE_STRUCTURE)
		var targets := Utils.get_closest_targets(parent.global_position, nodes, 1)
		if(targets.size() > 0):
			parent.move_target = targets[0]
	
	if(parent.move_target != null):
		parent.move_state = Unit.MOVE_STATE.APPROACH
	else:
		parent.move_state = Unit.MOVE_STATE.STANDBY
