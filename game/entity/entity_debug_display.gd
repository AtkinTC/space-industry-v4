extends Node2D
class_name EntityDebugDisplay

var parent_entity : Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	parent_entity = self.get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.global_rotation = 0
	queue_redraw()

const LEFT : int = -15
const LINE_LENGTH : int = 30
const LINE_WIDTH : int = 2
const LINE_SPACING : int = 6

func _draw():
	var line : int = 0
	
	if(parent_entity.has_inventory()):
		var inventory : Inventory = parent_entity.get_inventory()
		line+=1
		draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH, line * LINE_SPACING), Color.BLACK, LINE_WIDTH+2)
		var percentage : float = inventory.get_contents_size() as float / inventory.get_capacity()
		var percentage_capped : float = min(1.0, percentage)
		if(percentage > percentage_capped):
			draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH * percentage, line * LINE_SPACING), Color.RED, LINE_WIDTH)
		draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH * percentage_capped, line * LINE_SPACING), Color.BLUE, LINE_WIDTH)
		
		
#	var power_supply : PowerSupplyComponent = parent_entity.components.get(Constants.COMPONENT_CLASS.POWER_SUPPLY)
#	if(power_supply != null):
#		line+=1
#		draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH, line * LINE_SPACING), Color.BLACK, LINE_WIDTH)
#		var percentage : float = power_supply.get_supply() / power_supply.get_capacity()
#		draw_line(Vector2(LEFT, line * LINE_SPACING), Vector2(LEFT + LINE_LENGTH * percentage, line * LINE_SPACING), Color.YELLOW, LINE_WIDTH)
