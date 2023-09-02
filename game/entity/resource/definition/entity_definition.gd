extends Resource
class_name EntityDefinition

enum DISPLAY_LAYER {UNIT=0, STRUCTURE=-1}

@export var entity_type : String = ""
@export var scene : PackedScene

@export var dock_range : float = 0
@export var influence_radius : float = -1
@export var selection_area_definition : SelectionAreaDefinition

@export var grid_locked : bool = false

@export_group("Display")
@export var display_name : String = ""
@export var display_image : Texture = null
@export var default_display_layer : DISPLAY_LAYER = 0

@export_group("Construction")
@export var construction_cost : Dictionary = {}
@export var construction_time : float = 0
@export var construction_site_def : EntityDefinition = null
@export var player_buildable : bool = false

@export_group("Components")
@export var inventory_component : InventoryComponent = null
@export var health_component : HealthComponent = null
@export var logic_component : LogicComponent = null
@export var movement_component : MovementComponent = null

@export_group("Movement")
@export var base_move_speed : float = 0




const GRID_TOOL_NODE_NAME := "EntityGridTool"
const GRID_SIZE_PROP_NAME := "grid_size"
const GRID_NEIGHBOR_CONNECTOR_COMPONENT_NODE_NAME := "GridNeighborConnectorComponent"
const CONNECTOR_POINTS_PROP_NAME := "connector_points"

var grid_size_found := false
var grid_size :=  Vector2i(0, 0) : get = get_grid_size
var grid_cells : Array[Vector2i] = []

var connector_points_found := false
var connector_points : Array[ConnectorPoint] = []

func get_connector_points() -> Array[ConnectorPoint]:
	if(connector_points_found):
		return connector_points
	
	var scene_state := scene.get_state()
	for i in scene_state.get_node_count():
		if(scene_state.get_node_name(i) == GRID_NEIGHBOR_CONNECTOR_COMPONENT_NODE_NAME):
			for j in scene_state.get_node_property_count(i):
				if(scene_state.get_node_property_name(i, j) == CONNECTOR_POINTS_PROP_NAME):
					connector_points = scene_state.get_node_property_value(i, j)
					connector_points_found = true
					break
			break
	if(!connector_points_found):
		connector_points = []
		print_debug("No connector_cells property in scene %s." % entity_type)
		connector_points_found = true
	
	return connector_points

func get_grid_size() -> Vector2i:
	if(grid_size_found):
		return grid_size
	
	var scene_state := scene.get_state()
	for i in scene_state.get_node_count():
		if(scene_state.get_node_name(i) == GRID_TOOL_NODE_NAME):
			for j in scene_state.get_node_property_count(i):
				if(scene_state.get_node_property_name(i, j) == GRID_SIZE_PROP_NAME):
					grid_size = scene_state.get_node_property_value(i, j)
					grid_size_found = true
					break
			break
	
	if(!grid_size_found):
		grid_size = Vector2i(1, 1)
		print_debug("Using default grid size for entity scene : %s." % entity_type)
		grid_size_found = true
	
	return grid_size

func get_bounding_rect() -> Rect2:
	var size := get_grid_size()
	return Rect2(Constants.TILE_SIZE_I * -size/2.0, Constants.TILE_SIZE_I * size)

func get_grid_alignment_offset() -> Vector2:
	var size := get_grid_size()
	var offset : Vector2 = -(Vector2.ONE - (size % 2)/2.0)
	return offset

func get_center_cell_offset() -> Vector2:
	var size := get_grid_size()
	return -(Vector2.ONE - ((size % 2) as Vector2))/2.0

func get_grid_cells() -> Array[Vector2i]:
	if(grid_cells.is_empty()):
		grid_cells = []
		var size := get_grid_size()
		@warning_ignore("integer_division")
		var offset_x : int = -(size.x - 1)/2
		@warning_ignore("integer_division")
		var offset_y : int = -(size.y - 1)/2
		
		for x in range(offset_x, offset_x + size.x):
			for y in range(offset_y, offset_y + size.y):
				grid_cells.append(Vector2i(x,y))
	
	return grid_cells

# entity specific translation from entity's world position to its center grid cell
func world_to_grid(world_pos : Vector2) -> Vector2i:
	var grid_pos : Vector2i = floor((world_pos + get_grid_alignment_offset()) / Constants.TILE_SIZE)
	return grid_pos

# entity specific translation from entity's center grid cell to its world position
func grid_to_world(grid_pos : Vector2i) -> Vector2:
	var world_pos : Vector2 = ((grid_pos as Vector2 - get_grid_alignment_offset()) * Constants.TILE_SIZE) as Vector2
	return world_pos
