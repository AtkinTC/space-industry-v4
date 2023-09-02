@tool
extends Button
class_name ConstructionSelectionButton

@export var entity_def : EntityDefinition : set = set_entity_def

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

func set_entity_def(def : EntityDefinition) -> void:
	entity_def = def
	setup()

func setup() -> void:
	if(entity_def == null):
		text = ""
		icon = null
		return
	text = entity_def.display_name
	icon = entity_def.display_image

func _on_pressed() -> void:
	GameState.trigger_build_state.emit(entity_def)
