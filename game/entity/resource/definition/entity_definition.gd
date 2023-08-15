extends Resource
class_name EntityDefinition

@export var display_name : String = ""
@export var entity_type : String = ""
@export var scene : PackedScene
@export var base_inventory_capacity : int = -1
@export var construction_cost : Dictionary = {}
@export var construction_time : float = 0
@export var influence_radius : float = -1

@export var health : Health = null

@export var image : Texture = null

@export var selection_area_definition : SelectionAreaDefinition
