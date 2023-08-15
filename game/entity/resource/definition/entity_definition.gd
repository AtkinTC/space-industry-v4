extends Resource
class_name EntityDefinition

@export var entity_type : String = ""
@export var scene : PackedScene

@export var influence_radius : float = -1
@export var selection_area_definition : SelectionAreaDefinition

@export_group("Display")
@export var display_name : String = ""
@export var display_image : Texture = null

@export_group("Construction")
@export var construction_cost : Dictionary = {}
@export var construction_time : float = 0

@export_group("Components")
@export var inventory_component : InventoryComponent = null
@export var health_component : HealthComponent = null
@export var logic_component : LogicComponent = null
@export var movement_component : MovementComponent = null
