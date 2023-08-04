extends EntityDefinition
class_name StructureDefinition

@export var player_buildable : bool = false
@export var dock_range : float = 50

@export var construction_scene : PackedScene = null

const GRID_TOOL_NODE_NAME := "StructureGridTool"
const GRID_TOOL_GRID_SIZE_PROP_NAME := "grid_size"
var grid_size_checked := false
var grid_size_found := false
var grid_size :=  Vector2i(1, 1) : get = get_grid_size

func get_grid_size() -> Vector2i:
	if(grid_size_checked == true):
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
		print_debug("No grid_size property in scene, using default unit grid size.")
	
	grid_size_checked = true
	return grid_size
