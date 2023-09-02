@tool
extends Node2D
class_name GridNeighborConnectorComponent

@export var regenerate : bool = false : set = trigger_regenerate
@export var connector_points : Array[ConnectorPoint] = [] : set = set_connector_points

var entity : Entity
var grid_tool : EntityGridTool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var node := get_parent()
	assert(node is Entity)
	if(node is Entity):
		entity = node
		for child in entity.get_children():
			if(child is EntityGridTool):
				grid_tool = child
				break
	
	if not Engine.is_editor_hint():
		SignalBus.register_grid_neighbor_connector_component.emit(self)

func set_connector_points(_connector_points) -> void:
	connector_points = _connector_points
	queue_redraw()

func get_connector_points() -> Array[ConnectorPoint]:
	return connector_points

func get_center_cell() -> Vector2i:
	if(entity == null):
		return Vector2i()
	return entity.grid_position

func trigger_regenerate(_r : bool):
	regenerate = false
	connector_points = []
	if(grid_tool == null):
		return
	for cell in grid_tool.cells:
		var point := ConnectorPoint.new()
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			if (cell + dir) in grid_tool.cells:
				continue
			point.directions.append(dir)
		if(point.directions.is_empty()):
			continue
		point.cell = cell
		connector_points.append(point)
	queue_redraw()

func get_network_id() -> int:
	return NetworksManager.get_node_network_id(get_instance_id())

func get_entity() -> Entity:
	return entity

func _draw() -> void:
	if not Engine.is_editor_hint():
		return 
	
	var center_offset := Vector2.ZERO
	if(grid_tool != null):
		center_offset = grid_tool.center_cell_offset
	
	for point in connector_points:
		if(point == null):
			continue
		if(point.has_method("draw_at")):
			point.draw_at(self, center_offset)
