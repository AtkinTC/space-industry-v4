extends Node
#Singleton SignalBus

signal connect_transport_network_component(instance_id : int)
signal disconnect_transport_network_component(instance_id : int)

signal spawn_ship(entity_id : String, properties : Dictionary)
signal spawn_ship_callback(entity_id : String, properties : Dictionary, callback : Callable)
signal ships_updated(quantity : int)
signal register_ship(instance_id : int)

signal spawn_structure(entity_id : String, properties : Dictionary)
signal spawn_structure_callback(entity_id : String, properties : Dictionary, callback : Callable)
signal structures_updated(quantity : int)
signal register_construction_site(instance_id : int)

signal entity_ready(entity : Entity)

signal register_influence_node(node : InfluenceNode)
