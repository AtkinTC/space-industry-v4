extends Control
class_name StructureBuildMenu

func _ready() -> void:
	for def in EntityDefs.get_entity_definitions():
		if(def.player_buildable):
			var button := StructureBuildButton.new()
			button.structure_def = def
			add_child(button)
