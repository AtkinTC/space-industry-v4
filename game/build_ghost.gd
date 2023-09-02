extends Sprite2D
class_name BuildGhost

var entity_def : EntityDefinition = null
var grid_position : Vector2i

func _init(def : EntityDefinition) -> void:
	entity_def = def

func _ready() -> void:
	assert(entity_def != null)
	assert(entity_def.display_image != null)
	
	texture = entity_def.display_image

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var used_cells := EntityManager.get_used_entity_cells()
	
	for cell in entity_def.get_grid_cells():
		var draw_color = Color.GREEN
		if((cell + grid_position) in used_cells):
			draw_color = Color.RED
		var rect := Rect2((cell as Vector2 + entity_def.get_grid_alignment_offset()) * Constants.TILE_SIZE, Constants.TILE_SIZE - Vector2.ONE)
		draw_rect(rect, draw_color, false)
	
	for point in entity_def.get_connector_points():
		point.draw_at(self, entity_def.get_center_cell_offset() * Constants.TILE_SIZE)
