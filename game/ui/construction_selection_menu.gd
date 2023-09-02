extends Control
class_name ConstructionSelectionMenu

func _ready() -> void:
	for def in EntityDefs.get_entity_definitions():
		if(def.player_buildable):
			var button := ConstructionSelectionButton.new()
			button.entity_def = def
			add_child(button)
