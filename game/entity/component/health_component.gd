extends Resource
class_name HealthComponent

signal hull_depleted()
signal shield_depleted()

class DamageResult:
	var hull_damage : float = -1
	var shield_damage : float = -1
	var remaining_damage : float = -1

@export var destroyed : bool = false

@export var max_hull : float = -1
@export var current_hull : float = -1

@export var max_shield : float = -1
@export var current_shield : float = -1

func initialize() -> void:
	if(current_hull == -1):
		current_hull = max_hull
	if(current_shield == -1):
		current_shield = max_shield
	
	destroyed = (current_hull > 0)

func damage(damage_amount : float) -> DamageResult:
	var result := DamageResult.new()
	result.remaining_damage = damage_amount
	if(result.remaining_damage > 0 && current_shield > 0):
		result.shield_damage = damage_shield(result.remaining_damage)
		result.remaining_damage -= result.shield_damage
	
	if(result.remaining_damage > 0 && current_hull > 0):
		result.hull_damage = damage_hull(result.remaining_damage)
		result.remaining_damage -= result.hull_damage
	return result
	
func damage_hull(damage_amount : float) -> float:
	if(current_hull <= 0 || damage_amount <= 0):
		return 0
	
	var real_damage : float = min(current_hull, damage_amount)
	current_hull -= damage_amount
	if(current_hull <= 0):
		current_hull = 0
		destroyed = true
		hull_depleted.emit()
	return real_damage

func damage_shield(damage_amount : float) -> float:
	if(current_shield <= 0 || damage_amount <= 0):
		return 0
	
	var real_damage : float = min(current_shield, damage_amount)
	current_shield -= damage_amount
	if(current_shield <= 0):
		current_shield = 0
		shield_depleted.emit()
	return real_damage

func full_restore() -> void:
	current_hull = max_hull
	current_shield = max_shield

func restore_hull(restore_amount : float) -> void:
	if(current_hull >= max_hull || restore_amount <= 0):
		return
	current_hull = max(max_hull, current_hull + restore_amount)

func restore_shield(restore_amount : float) -> void:
	if(current_shield >= max_shield || restore_amount <= 0):
		return
	current_shield = max(max_shield, current_shield + restore_amount)
