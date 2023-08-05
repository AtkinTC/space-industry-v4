extends EntityDefinition
class_name StructureDefinition

@export var player_buildable : bool = false
@export var dock_range : float = 50

@export var construction_def : StructureDefinition = null

const GRID_TOOL_NODE_NAME := "StructureGridTool"
const GRID_TOOL_GRID_SIZE_PROP_NAME := "grid_size"
var grid_size_found := false
var grid_size :=  Vector2i(0, 0) : get = get_grid_size
var grid_cells : Array[Vector2i] = []

func get_grid_size() -> Vector2i:
	if(grid_size != Vector2i(0, 0)):
		return grid_size
	
	var scene_state := scene.get_state()
	for i in scene_state.get_node_count():
		if(scene_state.get_node_name(i) == GRID_TOOL_NODE_NAME):
			for j in scene_state.get_node_property_count(i):
				if(scene_state.get_node_property_name(i, j) == GRID_TOOL_GRID_SIZE_PROP_NAME):
					grid_size = scene_state.get_node_property_value(i, j)
					grid_size_found = true
					break
			break
	
	if(!grid_size_found):
		grid_size = Vector2i(1, 1)
		print_debug("No grid_size property in scene %s, using default unit grid size." % entity_type)
	
	return grid_size

func get_bounding_rect() -> Rect2:
	var size := get_grid_size()
	return Rect2(Constants.TILE_SIZE_I * -size/2.0, Constants.TILE_SIZE_I * size)

func get_grid_offset() -> Vector2:
	var offset := Vector2()
	var size := get_grid_size()
	offset.x = -1+(size.x % 2)/2.0
	offset.y = -1+(size.y % 2)/2.0
	
	return offset

func get_grid_cells() -> Array[Vector2i]:
	if(grid_cells.is_empty()):
		grid_cells = []
		var size := get_grid_size()
		var offset_x : int = -(size.x - 1)/2
		var offset_y : int = -(size.y - 1)/2
		
		for x in range(offset_x, offset_x + size.x):
			for y in range(offset_y, offset_y + size.y):
				grid_cells.append(Vector2i(x,y))
	
	return grid_cells
