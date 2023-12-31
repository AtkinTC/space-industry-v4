extends Node2D
class_name BuildControlLayer
# Handles logic for player placement of new entity construction sites and displays 'build ghost' visuals

signal build_state_complete()

var build_state := false
var build_entity_def : EntityDefinition = null
var build_ghost : BuildGhost = null

var ghost_cell := Vector2i()
var previous_ghost_cell := Vector2i()
var ghost_position := Vector2()

var valid_build_position := false

var dragging : bool = false

var trigger_build : bool = false
var build_cell := Vector2i()

func _ready() -> void:
	GameState.register_build_control_layer(self)
	previous_ghost_cell = ghost_cell

func _process(_delta: float) -> void:
	if(build_state):
		recalculate_position()
		if(!trigger_build):
			if(dragging && previous_ghost_cell != ghost_cell):
				trigger_build = true
				build_cell = ghost_cell
			previous_ghost_cell = ghost_cell
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if(trigger_build):
		trigger_build = false
		confirm_build()
	
func recalculate_position(force : bool = false):
	var mouse_pos := get_global_mouse_position()
	var new_cell : Vector2i = build_entity_def.world_to_grid(mouse_pos)
	if(force || new_cell != ghost_cell):
		ghost_cell = build_entity_def.world_to_grid(mouse_pos)
		ghost_position = build_entity_def.grid_to_world(ghost_cell)
		build_ghost.global_position = ghost_position
		build_ghost.grid_position = ghost_cell
		
		var used_cells := EntityManager.get_used_entity_cells()
		for cell in build_entity_def.get_grid_cells():
			if((cell + ghost_cell) in used_cells):
				valid_build_position = false
				return
		valid_build_position = true

func clear() -> void:
	build_entity_def = null
	build_state = false
	if(build_ghost != null):
		build_ghost.queue_free()
		build_ghost = null
	dragging = false

func start_build_state(def : EntityDefinition):
	if(def == null):
		end_build_state()
		return
	if(build_state):
		clear()
	build_entity_def = def
	build_state = true
	
	build_ghost = BuildGhost.new(build_entity_def)
	add_child(build_ghost)
	recalculate_position(true)

func end_build_state():
	clear()
	build_state_complete.emit()

func confirm_build():
	if(!build_state):
		return
	if(!valid_build_position):
		return
	var build_params := {
		Constants.KEY_CONSTRUCTION_TARGET_ENTITY_TYPE : build_entity_def.entity_type,
		Constants.KEY_GRID_POSITION : ghost_cell
	}
	SignalBus.spawn_entity.emit(build_entity_def.construction_site_def.entity_type, build_params)
	#end_build_state()

func _unhandled_input(event: InputEvent) -> void:
	if(!build_state):
		return
	if(event.is_action_pressed("select-alt")):
		end_build_state()
	if(event.is_action_pressed("select")):
		if(!trigger_build):
			trigger_build = true
			build_cell = ghost_cell
		dragging = true
	if(event.is_action_released("select")):
		dragging = false

func _draw() -> void:
	if(build_state):
		var used_strucuture_cells := EntityManager.get_used_entity_cells()
		for cell in used_strucuture_cells:
			draw_rect(Rect2(cell * Constants.TILE_SIZE_I, Constants.TILE_SIZE_I), Color(Color.RED, 0.25), true)
		
		for cell in InfluenceManger.get_cells_in_influence():
			if(cell not in used_strucuture_cells):
				draw_rect(Rect2(cell * Constants.TILE_SIZE_I, Constants.TILE_SIZE_I), Color(Color.GREEN, 0.15), true)
