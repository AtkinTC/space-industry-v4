@tool
extends Node2D
class_name StructureConnectorComponent

@export var regenerate : bool = false : set = trigger_regenerate

@export var network_source : bool = false
@export var connector_points : Array[ConnectorPoint] = []

var parent_structure : Structure
var structure_grid_tool : StructureGridTool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node := get_parent()
	assert(node is Structure)
	if(node is Structure):
		parent_structure = node
		for child in parent_structure.get_children():
			if(child is StructureGridTool):
				structure_grid_tool = child
				break
	
	if not Engine.is_editor_hint():
		SignalBus.register_structure_connector_component.emit(self)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func get_connector_points() -> Array[ConnectorPoint]:
	return connector_points

func get_center_cell() -> Vector2i:
	if(parent_structure == null):
		return Vector2i()
	return parent_structure.grid_position

func trigger_regenerate(_r : bool):
	regenerate = false
	connector_points = []
	if(structure_grid_tool == null):
		return
	for cell in structure_grid_tool.cells:
		var point := ConnectorPoint.new()
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			if (cell + dir) in structure_grid_tool.cells:
				continue
			point.directions.append(dir)
		if(point.directions.is_empty()):
			continue
		point.cell = cell
		connector_points.append(point)

func get_network_id() -> int:
	return NetworksManager.get_node_network_id(get_instance_id())

func is_on_network() -> bool:
	return get_network_id() != -1

func _draw() -> void:
	if not Engine.is_editor_hint():
		return 
	
	var center_offset := Vector2.ZERO
	if(structure_grid_tool != null):
		center_offset = structure_grid_tool.center_cell_offset
	
	for point in connector_points:
		if(point == null):
			continue
		if(point.has_method("draw_at")):
			point.draw_at(self, center_offset)
