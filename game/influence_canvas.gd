extends CanvasGroup
class_name InfluenceCanvas

const CIRCLE_POINTS : int = 32

# These colors are used by the shader 'canvas_group_area' to draw the outlines
# These are not the actual display colors
const INNER_POLYGON_COLOR := Color(1,0,0,1)
const OUTLINE_POLYGON_COLOR := Color(1,0,0,0.5)

@export var influence_outline_color := Color(Color.GREEN, 0.5)
@export var influence_fill_color := Color(Color.GREEN, 0.1)

@export var outline_width : float = 3.0

func _ready():
	InfluenceManger.register_canvas(self)
	
	if(material != null && material is ShaderMaterial):
		material.set_shader_parameter("outline_color",influence_outline_color)
		material.set_shader_parameter("inner_color",influence_fill_color)

# this is all very quick and dirty, works for now but needs to be improved
# need to keep track fo the polygons so they can be removed/adjusted when needed
func add_influence_node(node : InfluenceNode) -> void:
	var polygon2 := Polygon2D.new()
	set_circle(polygon2, node.radius+outline_width)
	polygon2.color = OUTLINE_POLYGON_COLOR
	polygon2.global_position = node.global_position
	add_child(polygon2)
	
	var polygon := Polygon2D.new()
	set_circle(polygon, node.radius)
	polygon.color = INNER_POLYGON_COLOR
	polygon.global_position = node.global_position
	add_child(polygon)

func set_circle(circle : Polygon2D, radius : float) -> void:
	var polygon : PackedVector2Array = []
	var angle_increment := (2 * PI) / CIRCLE_POINTS
	for i in range(CIRCLE_POINTS):
		var angle = i * angle_increment
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		polygon.append(Vector2(x, y))
	
	circle.polygon = polygon
