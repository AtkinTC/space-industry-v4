extends MovementComponent
class_name BasicEntityMovementComponent

func set_controlled_entity(_entity : Entity):
	super.set_entity(_entity)

func process(_delta : float):
	var desired_velocity := Vector2.ZERO
	var desired_rotation := entity.global_rotation
	
	if(entity.move_state == Entity.MOVE_STATE.APPROACH && entity.move_target != null):
		var distance := entity.global_position.distance_to(entity.move_target.global_position)
		if(is_zero_approx(distance) || distance <= entity.approach_distance):
			desired_velocity = Vector2.ZERO
		else:
			desired_velocity = entity.global_position.direction_to(entity.move_target.global_position) * entity.entity_def.base_move_speed
		desired_rotation = entity.global_position.angle_to_point(entity.move_target.global_position)
	else:
		desired_velocity = Vector2.ZERO
		if(entity.move_target != null):
			desired_rotation = entity.global_position.angle_to_point(entity.move_target.global_position)
		
	
	entity.velocity = desired_velocity
	
	entity.global_position += entity.velocity * _delta
	entity.global_rotation = desired_rotation
