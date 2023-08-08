extends Node
# Singleton SignalBus

signal connect_transport_network_component(instance_id : int)
signal disconnect_transport_network_component(instance_id : int)

signal spawn_unit(entity_type : String, properties : Dictionary)
signal spawn_unit_callback(entity_type : String, properties : Dictionary, callback : Callable)
signal units_updated(quantity : int)
signal register_unit(instance_id : int)

signal spawn_structure(entity_type : String, properties : Dictionary)
signal spawn_structure_callback(entity_type : String, properties : Dictionary, callback : Callable)
signal structures_updated(quantity : int)
signal register_construction_site(instance_id : int)

signal entity_ready(entity : Entity)

signal register_influence_node(node : InfluenceNode)
signal register_structure_connector_component(node : StructureConnectorComponent)
