extends Sprite2D
class_name BuildGhost

var structure_def : StructureDefinition = null

func _init(def : StructureDefinition) -> void:
	structure_def = def

func _ready() -> void:
	assert(structure_def != null)
	assert(structure_def.image != null)
	
	texture = structure_def.image

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(structure_def.get_bounding_rect(), Color.RED, false)
