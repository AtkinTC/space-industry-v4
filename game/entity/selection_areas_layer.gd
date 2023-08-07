extends Node2D
class_name SelectionAreasLayer
# UI Node intended handle display and interactions with all selectable entities
# manages an EntitySelectionArea node for each selectable entity

var input_enabled := true

var selection_area_scene : PackedScene = preload("res://game/entity/entity_selection_area.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.register_selection_areas_layer(self)
	SignalBus.entity_ready.connect(add_selection_area)

func add_selection_area(entity : Entity) -> void:
	var area : EntitySelectionArea = selection_area_scene.instantiate()
	area.parent_entity = entity
	area.gui_input.connect(_on_selection_area_gui_input)
	add_child(area)

func _on_selection_area_gui_input(area : EntitySelectionArea, event : InputEvent):
	if(event is InputEventMouseButton):
		if(event.pressed == true):
			print(area)
			print(event)

func set_input_enabled(enabled : bool) -> void:
	input_enabled = enabled
	for child in get_children():
		if(child.has_method("set_input_enabled")):
			child.set_input_enabled(input_enabled)
