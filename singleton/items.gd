extends Node
#Singleton Items

const KEY_DISPLAY_NAME := "display_name"
#const KEY_VOLUME := "volume"

# KEYS
const ID_IRON_ORE := "iron_ore"
const ID_URANIUM_ORE := "uranium_ore"

const DEFINITIONS = {
	ID_IRON_ORE : {
		KEY_DISPLAY_NAME : "iron ore"
		#KEY_VOLUME : 0.1
	},
	ID_URANIUM_ORE : {
		KEY_DISPLAY_NAME : "uranium ore"
		#KEY_VOLUME : 0.2
	}
}

var definitions := {}

class ItemDefinition:
	var id : String
	var display_name : String
	#var volume : float

func get_item_ids() -> Array:
	return DEFINITIONS.keys()

func get_item_definition(item_id) -> ItemDefinition:
	if(definitions.has(item_id)):
		return definitions[item_id]
	
	if(!DEFINITIONS.has(item_id)):
		return null
	
	var dict : Dictionary =  DEFINITIONS[item_id]
	var def := ItemDefinition.new()
	
	def.id = item_id
	def.display_name = dict[KEY_DISPLAY_NAME]
	#def.volume = dict[KEY_VOLUME]
	
	definitions[item_id] = def
	return def

func get_volume_sum(items : Dictionary) -> int:
	var volume : int = 0
	for item_id in items.keys():
		#var item_def := get_item_definition(item_id)
		#volume += item_def.volume * items[item_id]
		volume += items[item_id]
	return volume
		
func combine_items(items_a : Dictionary, items_b : Dictionary) -> Dictionary:
	var combined := items_a.duplicate()
	for key in items_b.keys():
		combined[key] = combined.get(key, 0) + items_b[key]
	return combined
