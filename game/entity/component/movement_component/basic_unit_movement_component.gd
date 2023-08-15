extends MovementComponent
class_name BasicUnitMovementComponent

func set_controlled_parent(_parent : Entity):
	assert(_parent is Unit)
	super.set_controlled_parent(_parent)

func process(_delta : float):
	var desired_velocity := Vector2.ZERO
	var desired_rotation := parent.global_rotation
	
	if(parent.move_state == Unit.MOVE_STATE.APPROACH && parent.move_target != null):
		var distance := parent.global_position.distance_to(parent.move_target.global_position)
		if(is_zero_approx(distance) || distance <= parent.approach_distance):
			desired_velocity = Vector2.ZERO
		else:
			desired_velocity = parent.global_position.direction_to(parent.move_target.global_position) * parent.entity_def.base_move_speed
		desired_rotation = parent.global_position.angle_to_point(parent.move_target.global_position)
	else:
		desired_velocity = Vector2.ZERO
		if(parent.move_target != null):
			desired_rotation = parent.global_position.angle_to_point(parent.move_target.global_position)
		
	
	parent.velocity = desired_velocity
	
	parent.global_position += parent.velocity * _delta
	parent.global_rotation = desired_rotation
