extends LogicComponent
class_name BasicEnemyLogicComponent

func process(_delta : float):
	if(entity.move_target == null || !is_instance_valid(entity.move_target)):
		entity.move_target = null
		var nodes = []
		#var nodes := parent.get_tree().get_nodes_in_group(Constants.GROUP_PLAYER_ATTACKABLE_STRUCTURE)
		var targets := Utils.get_closest_targets(entity.global_position, nodes, 1)
		if(targets.size() > 0):
			entity.move_target = targets[0]
	
	if(entity.move_target != null):
		entity.move_state = Entity.MOVE_STATE.APPROACH
	else:
		entity.move_state = Entity.MOVE_STATE.STANDBY
