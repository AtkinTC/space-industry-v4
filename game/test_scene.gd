extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.spawn_structure.emit("station_core_001", {Constants.KEY_GRID_POSITION : Vector2i(0,0)})
	
	#for i in 5:
	#	SignalBus.spawn_unit.emit("mining_drone_001", {})
	#for i in 2:
	#	SignalBus.spawn_unit.emit("construction_drone_001", {})


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
