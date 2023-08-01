extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 5:
		SignalBus.spawn_ship.emit("mining_drone_001", {})
	for i in 2:
		SignalBus.spawn_ship.emit("construction_drone_001", {})


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
