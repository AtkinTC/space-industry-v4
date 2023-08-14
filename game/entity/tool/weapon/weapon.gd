extends Tool
class_name Weapon

func get_tool_type():
	return Constants.TOOL_TYPE_WEAPON

@export var optimal_range : float = 0
@export var optimal_range_min : float = -1
@export var optimal_range_max : float = -1

@export var auto_trigger : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	optimal_range = max(0, optimal_range)
	if(optimal_range_min < 0):
		optimal_range_min = optimal_range
	if(optimal_range_max < optimal_range):
		optimal_range_max = optimal_range

func is_ready() -> bool:
	return false

func trigger() -> void:
	pass

func set_auto_trigger(_auto_trigger : bool) -> void:
	auto_trigger = _auto_trigger

func _physics_process(delta: float) -> void:
	if(auto_trigger):
		trigger()
