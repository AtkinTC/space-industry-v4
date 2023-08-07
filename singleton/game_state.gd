extends Node
# Singleton GameState

signal trigger_build_state(structure_def : StructureDefinition)

var mining_drone_type : String = "mining_drone_001"

var selection_areas_layer : SelectionAreasLayer = null
var build_control_layer : BuildControlLayer = null

enum UI_STATE {NONE, BUILD}
var ui_state = UI_STATE.NONE

func _ready() -> void:
	trigger_build_state.connect(start_build_state)

func register_selection_areas_layer(layer : SelectionAreasLayer) -> void:
	selection_areas_layer = layer

func register_build_control_layer(layer : BuildControlLayer) -> void:
	build_control_layer = layer
	build_control_layer.build_state_complete.connect(_on_build_state_complete)

func set_ui_state(state : UI_STATE):
	if(ui_state == state):
		return
	
	ui_state = state
	match(state):
		UI_STATE.NONE:
			if(selection_areas_layer != null):
				selection_areas_layer.set_input_enabled(true)
		UI_STATE.BUILD:
			if(selection_areas_layer != null):
				selection_areas_layer.set_input_enabled(false)

func start_build_state(structure_def : StructureDefinition) -> void:
	if(build_control_layer != null):
		set_ui_state(UI_STATE.BUILD)
		build_control_layer.start_build_state(structure_def)

func _on_build_state_complete():
	if(ui_state == UI_STATE.BUILD):
		set_ui_state(UI_STATE.NONE)

func world_to_grid(world_pos : Vector2) -> Vector2i:
	var grid_pos : Vector2i = floor(world_pos / Constants.TILE_SIZE)
	return grid_pos

func grid_to_world(grid_pos : Vector2i) -> Vector2:
	var world_pos : Vector2 = (grid_pos as Vector2 + Vector2(0.5, 0.5)) * Constants.TILE_SIZE
	return world_pos
