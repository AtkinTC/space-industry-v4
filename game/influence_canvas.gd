extends CanvasGroup
class_name InfluenceCanvas

@export var influence_outline_color := Color(Color.GREEN, 0.5)
@export var influence_fill_color := Color(Color.GREEN, 0.1)

func _ready():
	InfluenceManger.register_canvas(self)
	
	if(material != null && material is ShaderMaterial):
		material.set_shader_parameter("outline_color",influence_outline_color)
		material.set_shader_parameter("inner_color",influence_fill_color)

func add_influence_node(node : InfluenceNode) -> void:
	var circle := InfluenceCircle.new()
	circle.influence_source = node
	add_child(circle)
