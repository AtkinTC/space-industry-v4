extends Node2D
class_name EntitySelectionArea

signal area_clicked(area : EntitySelectionArea)

const PADDING := Vector2(4, 4)

var selection_extents : Rect2

@onready var nine_patch : NinePatchRect = %NinePatchRect

@export var default_color := Color.GREEN_YELLOW
@export var highlighted_color := Color.SKY_BLUE
@export var selected_color := Color.BLUE

@export var debug_draw : bool = false

var selected : bool = false
var highlighted : bool = false

var parent_entity : Entity = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(parent_entity == null):
		queue_free()
		return
	
	assert(nine_patch != null)
	
	if(nine_patch != null):
		nine_patch.gui_input.connect(_on_nine_patch_rect_gui_input)
		nine_patch.mouse_entered.connect(_on_none_patch_rect_mouse_entered)
		nine_patch.mouse_exited.connect(_on_none_patch_rect_mouse_exited)
		nine_patch.modulate = default_color
	
	calculate_extents()
	reposition_texture()

func _physics_process(_delta : float) -> void:
	if(parent_entity == null || !is_instance_valid(parent_entity)):
		queue_free()
		return
	
	#nine_patch.visible = parent_entity.is_visible_in_tree()
	#if(visible && nine_patch.visible):
	
	if(selected):
		nine_patch.modulate = selected_color
	elif(highlighted):
		nine_patch.modulate = highlighted_color
	else:
		nine_patch.modulate = default_color
	
	global_transform = parent_entity.global_transform
	global_rotation = 0
	calculate_extents()
	reposition_texture()
	queue_redraw()

func calculate_extents() -> void:
	var p_min := Vector2()
	var p_max := Vector2()
	for col_shape in parent_entity.get_collision_shapes():
		if (col_shape.shape is RectangleShape2D):
			var rectangle := col_shape.shape as RectangleShape2D
			var p1 := col_shape.position + Vector2(rectangle.size.x, rectangle.size.y).rotated(col_shape.global_rotation)/2.0
			var p2 := col_shape.position + Vector2(rectangle.size.x, -rectangle.size.y).rotated(col_shape.global_rotation)/2.0
			var p3 := col_shape.position + Vector2(-rectangle.size.x, -rectangle.size.y).rotated(col_shape.global_rotation)/2.0
			var p4 := col_shape.position + Vector2(-rectangle.size.x, rectangle.size.y).rotated(col_shape.global_rotation)/2.0
			p_min.x = min(p_min.x, p1.x, p2.x, p3.x, p4.x)
			p_min.y = min(p_min.y, p1.y, p2.y, p3.y, p4.y)
			p_max.x = max(p_max.x, p1.x, p2.x, p3.x, p4.x)
			p_max.y = max(p_max.y, p1.y, p2.y, p3.y, p4.y)
			
		if(col_shape.shape is CapsuleShape2D):
			var capsule := col_shape.shape as CapsuleShape2D
			var p1 := col_shape.position + Vector2(capsule.radius, capsule.height/2.0).rotated(col_shape.global_rotation)
			var p2 := col_shape.position + Vector2(capsule.radius, -capsule.height/2.0).rotated(col_shape.global_rotation)
			var p3 := col_shape.position + Vector2(-capsule.radius, -capsule.height/2.0).rotated(col_shape.global_rotation)
			var p4 := col_shape.position + Vector2(-capsule.radius, capsule.height/2.0).rotated(col_shape.global_rotation)
			p_min.x = min(p_min.x, p1.x, p2.x, p3.x, p4.x)
			p_min.y = min(p_min.y, p1.y, p2.y, p3.y, p4.y)
			p_max.x = max(p_max.x, p1.x, p2.x, p3.x, p4.x)
			p_max.y = max(p_max.y, p1.y, p2.y, p3.y, p4.y)
		
		if(col_shape.shape is CircleShape2D):
			var circle := col_shape.shape as CircleShape2D
			var p1 := col_shape.position + Vector2(circle.radius, circle.radius)
			var p2 := col_shape.position + Vector2(circle.radius, -circle.radius)
			var p3 := col_shape.position + Vector2(-circle.radius, -circle.radius)
			var p4 := col_shape.position + Vector2(-circle.radius, circle.radius)
			p_min.x = min(p_min.x, p1.x, p2.x, p3.x, p4.x)
			p_min.y = min(p_min.y, p1.y, p2.y, p3.y, p4.y)
			p_max.x = max(p_max.x, p1.x, p2.x, p3.x, p4.x)
			p_max.y = max(p_max.y, p1.y, p2.y, p3.y, p4.y)
	
	for col_polygon in parent_entity.get_collision_polygons():
		for p in col_polygon.polygon:
			var p1 := col_polygon.position + p.rotated(col_polygon.global_rotation)
			p_min.x = min(p_min.x, p1.x,)
			p_min.y = min(p_min.y, p1.y)
			p_max.x = max(p_max.x, p1.x)
			p_max.y = max(p_max.y, p1.y)
	
	p_min -= PADDING
	p_max += PADDING
	selection_extents = Rect2(p_min, p_max-p_min)

func reposition_texture() -> void:
	if(nine_patch == null):
		return
	nine_patch.position = selection_extents.position
	nine_patch.size = selection_extents.size

func _draw() -> void:
	if(!debug_draw):
		return
	
	draw_rect(Rect2(selection_extents.position, selection_extents.size), default_color, false)


func _on_nine_patch_rect_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.pressed == true):
			print(event)
			area_clicked.emit(self)

func _on_none_patch_rect_mouse_entered() -> void:
	highlighted = true

func _on_none_patch_rect_mouse_exited() -> void:
	highlighted = false
