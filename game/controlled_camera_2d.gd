class_name ControlledCamera2D
extends Camera2D

@export var left_action : String = "ui_left"
@export var right_action : String = "ui_right"
@export var up_action :String = "ui_up"
@export var down_action : String= "ui_down"
@export var zoom_in_action :String = "zoom_in"
@export var zoom_out_action : String= "zoom_out"

@export var max_speed := 500.0
@export_range(0.0, 1.0) var acceleration := 0.1
@export_range(0.0, 1.0) var deceleration := 0.1

var move_direction := Vector2.ZERO
var move_speed = Vector2.ZERO

@export_range(0.0, 10.0) var min_zoom : float = 0.25
@export_range(0.0, 10.0) var max_zoom : float = 3.0
@export_range(0.0, 10.0) var zoom_level : float = 1.0

@export_range(0.0, 10.0) var max_zoom_speed := 0.025
@export_range(0.0, 1.0) var zoom_acceleration := 0.25
@export_range(0.0, 1.0) var zoom_deceleration := 0.1

var zoom_direction := 0.0
var zoom_speed := 0.0

func _physics_process(_delta):
	var adj_max_speed = max_speed / zoom_level
	
	##Camera Movement
	var speed_offset = adj_max_speed * acceleration * move_direction
	
	move_speed.x = clamp(move_speed.x + speed_offset.x, -adj_max_speed, adj_max_speed)
	move_speed.y = clamp(move_speed.y + speed_offset.y, -adj_max_speed, adj_max_speed)
	
	if move_direction.x == 0:
		move_speed.x *= (1.0 - deceleration)
	if move_direction.y == 0:
		move_speed.y *= (1.0 - deceleration)
	
	global_translate(move_speed * _delta)
	
	##Camera Zoom
	var zoom_offset = max_zoom_speed * zoom_acceleration * zoom_direction
	zoom_speed = clamp(zoom_speed + zoom_offset, -max_zoom_speed, max_zoom_speed)
	
	if(is_equal_approx(zoom_direction, 0)):
		if(abs(zoom_speed) < 0.001):
			zoom_speed = 0.0
		else:
			zoom_speed *= (1.0 - zoom_deceleration)
	
	zoom_level = clamp(zoom_level + zoom_speed, min_zoom, max_zoom)
	set_zoom(Vector2(zoom_level, zoom_level))

func _input(_event):
	move_direction.x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
	move_direction.y = Input.get_action_strength(down_action) - Input.get_action_strength(up_action)
	zoom_direction = Input.get_action_strength(zoom_in_action) - Input.get_action_strength(zoom_out_action)

func get_zoom_level() -> float:
	return zoom_level
