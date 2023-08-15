extends Node2D
class_name EntityDebugDisplay

var parent_entity : Entity
var offset : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_entity = self.get_parent()
	offset = self.position
	process_transform()
	top_level = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_transform()

func process_transform():
	self.global_position = parent_entity.global_position + offset
	self.global_rotation = 0
	queue_redraw()

const LEFT : int = -12
const LINE_LENGTH : int = 24
const LINE_WIDTH : int = 2
const LINE_SPACING : int = 6

func draw_bar(color_1 : Color, color_2 : Color, percentage : float, line : int):
	draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH, line * LINE_SPACING), color_2, LINE_WIDTH+2)
	draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH, line * LINE_SPACING), Color.BLACK, LINE_WIDTH)
	draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH * percentage, line * LINE_SPACING), color_1, LINE_WIDTH)

func _draw():
	var line : int = 0
	
	if(parent_entity.has_health()):
		var health_component := parent_entity.get_health_component()
		
		if(health_component.max_hull > 0):
			var hull_percentage : float = max(0, health_component.current_hull / health_component.max_hull)
			draw_bar(Color.GREEN, Color.DARK_GREEN, hull_percentage, line)
			line+=1
		
		if(health_component.max_shield > 0):
			var shield_percentage : float = max(0, health_component.current_shield / health_component.max_shield)
			draw_bar(Color.DEEP_SKY_BLUE, Color.BLUE, shield_percentage, line)
			line+=1
		
	if(parent_entity.has_inventory()):
		var inventory_component := parent_entity.get_inventory_component()
		
		if(inventory_component.capacity > 0):
			var percentage : float = inventory_component.get_contents_size() as float / inventory_component.get_capacity()
			draw_bar(Color.YELLOW, Color.GOLD, percentage, line)
			line+=1
