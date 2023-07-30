extends Polygon2D
class_name InfluenceCircle

const CIRCLE_POINTS : int = 32
const OUTLINE_WIDTH : float = 3.0

# These colors are used by the shader 'canvas_group_area' to calculate the outlines
# These are not the actual display colors
const INNER_POLYGON_COLOR := Color(1,0,0,1)
const OUTLINE_POLYGON_COLOR := Color(1,0,0,0.5)

var influence_source : InfluenceNode = null

var outline_circle : Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(influence_source == null || !is_instance_valid(influence_source)):
		queue_free()
		return
	
	color = INNER_POLYGON_COLOR
	polygon = generate_circle_points(influence_source.get_influence_radius())
	
	outline_circle = Polygon2D.new()
	outline_circle.color = OUTLINE_POLYGON_COLOR
	outline_circle.polygon = generate_circle_points(influence_source.get_influence_radius() + OUTLINE_WIDTH)
	add_child(outline_circle)

func _physics_process(_delta : float) -> void:
	if(influence_source == null || !is_instance_valid(influence_source)):
		queue_free()
		return
	
	global_position = influence_source.global_position

func generate_circle_points(radius : float) -> PackedVector2Array:
	var points : PackedVector2Array = []
	var angle_increment := (2 * PI) / CIRCLE_POINTS
	for i in range(CIRCLE_POINTS):
		var angle = i * angle_increment
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		points.append(Vector2(x, y))
	return points
	
