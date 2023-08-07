extends Node2D
class_name EntityDebugDisplay

var parent_entity : Entity
var offset : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_entity = self.get_parent()
	offset = self.position
	top_level = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
		var health := parent_entity.get_health()
		
		if(health.max_hull > 0):
			var hull_percentage : float = max(0, health.current_hull / health.max_hull)
			draw_bar(Color.GREEN, Color.DARK_GREEN, hull_percentage, line)
			line+=1
		
		if(health.max_shield > 0):
			var shield_percentage : float = max(0, health.current_shield / health.max_shield)
			draw_bar(Color.DEEP_SKY_BLUE, Color.BLUE, shield_percentage, line)
			line+=1
		
	if(parent_entity.has_inventory()):
		var inventory := parent_entity.get_inventory()
		
		if(inventory.capacity > 0):
			var percentage : float = inventory.get_contents_size() as float / inventory.get_capacity()
			draw_bar(Color.YELLOW, Color.GOLD, percentage, line)
			line+=1
		
		
#	var power_supply : PowerSupplyComponent = parent_entity.components.get(Constants.COMPONENT_CLASS.POWER_SUPPLY)
#	if(power_supply != null):
#		line+=1
#		draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH, line * LINE_SPACING), Color.BLACK, LINE_WIDTH)
#		var percentage : float = power_supply.get_supply() / power_supply.get_capacity()
#		draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH * percentage, line * LINE_SPACING), Color.YELLOW, LINE_WIDTH)
