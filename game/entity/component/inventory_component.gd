extends Resource
class_name InventoryComponent

@export var capacity : int = 0 : set = set_capacity
@export var contents : Dictionary = {}

func _init(_capacity : int = 0):
	capacity = _capacity
	contents = {}

func get_contents() -> Dictionary:
	return contents

func is_full() -> bool:
	return get_available_capacity() <= 0

func is_empty() -> bool:
	return get_available_capacity() >= capacity

func set_capacity(_capacity : int) -> void:
	capacity = _capacity

func get_capacity() -> int:
	return capacity

func get_contents_size() -> int:
	return Items.get_volume_sum(contents)

func get_available_capacity() -> int:
	return capacity - get_contents_size()

# precalculate the result of an insertion, without actually inserting anything
func precalculate_insert_result(items : Dictionary) -> Dictionary:
	var result := {}
	var remaining_capacity = get_available_capacity()
	for item_id in items.keys():
		if(remaining_capacity <= 0):
			break
		var insert_amount : int = min(remaining_capacity, items[item_id])
		if(insert_amount > 0):
			result[item_id] = insert_amount
			remaining_capacity -= insert_amount
	return result

func insert_items(items : Dictionary, force : bool = false) -> bool:
	if(!force):
		# check that there is capacity for the new items
		var volume := Items.get_volume_sum(items)
		if(volume > get_available_capacity()):
			return false
	for item_id in items.keys():
		contents[item_id] = contents.get(item_id, 0) + items[item_id]
	return true

# precalculate the result of a removal, without actually inserting anything
func precalculate_remove_result(items : Dictionary) -> Dictionary:
	var result := {}
	for item_id in items.keys():
		var remove_amount = min(items[item_id], contents.get(item_id, 0))
		if(remove_amount > 0):
			result[item_id] = remove_amount
	return result

func remove_items(items : Dictionary, force : bool = false) -> Dictionary:
	if(!force):
		# check that the items exist to be removed
		for item_id in items.keys():
			if(contents.get(item_id, 0) < items[item_id]):
				return {}
	
	var removed_items := {}
	for item_id in items.keys():
		var current_amount : int = contents.get(item_id, 0)
		var remove_amount : int = min(items[item_id], current_amount)
		var quantity : int = current_amount - remove_amount
		if(quantity > 0 ):
			contents[item_id] = quantity
		else:
			contents.erase(item_id)
		removed_items[item_id] = remove_amount
			
	return removed_items

func remove_all() -> void:
	contents.clear()

func contains_all(items : Dictionary) -> bool:
	for item_id in items.keys():
		if(contents.get(item_id, 0) < items[item_id]):
			return false
	return true

func contains_any(items : Dictionary) -> Dictionary:
	var result := {}
	for item_id in items.keys():
		if(contents.get(item_id, 0) > 0):
			result[item_id] = min(contents.get(item_id, 0), items[item_id])
	return result

static func transfer_items(from_inventory : InventoryComponent, to_inventory : InventoryComponent, items : Dictionary) -> void:
	var removed_items := from_inventory.remove_items(items, true)
	to_inventory.insert_items(removed_items, true)

static func transfer_all(from_inventory : InventoryComponent, to_inventory : InventoryComponent) -> void:
	to_inventory.insert_items(from_inventory.get_contents(), true)
	from_inventory.remove_all()

#static func transfer_as_much_as_possible(from_inventory : InventoryComponent, to_inventory : InventoryComponent) -> void:
#	var remaining_transfer_capacity : int = to_inventory.get_available_capacity()
#	for item_id in from_inventory.contents.keys():
#		var transfer_quantity : int = min(from_inventory.contents[item_id], remaining_transfer_capacity)
#		var insert_success : bool = to_inventory.insert_item(item_id, transfer_quantity)
#		if(insert_success):
#			from_inventory.remove_item(item_id, transfer_quantity)
#			remaining_transfer_capacity -= transfer_quantity
#		if(remaining_transfer_capacity <= 0):
#			break

