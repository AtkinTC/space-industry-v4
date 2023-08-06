extends Sprite2D
class_name BuildGhost

var structure_def : StructureDefinition = null
var grid_position : Vector2i

func _init(def : StructureDefinition) -> void:
	structure_def = def

func _ready() -> void:
	assert(structure_def != null)
	assert(structure_def.image != null)
	
	texture = structure_def.image

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
#	var bounding_rect := structure_def.get_bounding_rect()
#	draw_rect(bounding_rect, Color.RED, false)
	
	var used_cells := EntityManager.get_used_structure_cells()
	
	for cell in structure_def.get_grid_cells():
		var draw_color = Color.GREEN
		if((cell + grid_position) in used_cells):
			draw_color = Color.RED
		var rect := Rect2((cell as Vector2 + structure_def.get_grid_alignment_offset()) * Constants.TILE_SIZE, Constants.TILE_SIZE - Vector2.ONE)
		draw_rect(rect, draw_color, false)
	
