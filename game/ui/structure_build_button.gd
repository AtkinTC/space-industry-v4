@tool
extends Button
class_name StructureBuildButton

@export var structure_def : StructureDefinition : set = set_structure_def

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	clip_text = true
	
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	expand_icon = true
	
	custom_minimum_size = Vector2(64, 64)
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	focus_mode = Control.FOCUS_NONE
	
	pressed.connect(_on_pressed)
	
	setup()

func set_structure_def(def : StructureDefinition) -> void:
	structure_def = def
	setup()

func setup() -> void:
	if(structure_def == null):
		text = ""
		icon = null
		return
	text = structure_def.display_name
	icon = structure_def.display_image

func _on_pressed() -> void:
	GameState.trigger_build_state.emit(structure_def)
