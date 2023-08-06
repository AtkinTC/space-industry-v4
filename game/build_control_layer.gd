extends Node2D
class_name BuildControlLayer
# Handles logic for player placement of new structures and displays 'build ghost' visuals

signal build_state_complete()

var build_state := false
var build_structure_def : StructureDefinition = null
var build_ghost : BuildGhost = null

var build_cell := Vector2i()
var build_position := Vector2()

func _ready() -> void:
	GameState.register_build_control_layer(self)

func _process(_delta: float) -> void:
	if(build_state):
		var mouse_pos := get_global_mouse_position()
		build_cell = build_structure_def.world_to_grid(mouse_pos)
		build_position = build_structure_def.grid_to_world(build_cell)
		build_ghost.global_position = build_position

func clear() -> void:
	build_structure_def = null
	build_state = false
	if(build_ghost != null):
		build_ghost.queue_free()
		build_ghost = null

func start_build_state(def : StructureDefinition):
	if(def == null):
		end_build_state()
		return
	if(build_state):
		clear()
	build_structure_def = def
	build_state = true
	
	build_ghost = BuildGhost.new(build_structure_def)
	add_child(build_ghost)

func end_build_state():
	clear()
	build_state_complete.emit()

func confirm_build():
	if(!build_state):
		return
	var build_params := {
		Constants.KEY_STRUCTURE_TYPE : build_structure_def.entity_type,
		Constants.KEY_GRID_POSITION : build_cell
	}
	SignalBus.spawn_structure.emit(build_structure_def.construction_def.entity_type, build_params)
	end_build_state()

func _unhandled_input(event: InputEvent) -> void:
	if(!build_state):
		return
	if(event.is_action_pressed("select-alt")):
		end_build_state()
	if(event.is_action_pressed("select")):
		confirm_build()
