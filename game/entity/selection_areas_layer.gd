extends Node2D

var selection_area_scene : PackedScene = preload("res://game/entity/entity_selection_area.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.entity_ready.connect(add_selection_area)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_selection_area(entity : Entity) -> void:
	var area : EntitySelectionArea = selection_area_scene.instantiate()
	area.parent_entity = entity
	add_child(area)
