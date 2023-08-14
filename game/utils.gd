class_name Utils

static func get_closest_targets(source_pos : Vector2, targets : Array, amount : int = 1) -> Array[Node2D]:
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
