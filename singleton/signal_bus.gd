extends Node
# Singleton SignalBus

signal connect_transport_network_component(instance_id : int)
signal disconnect_transport_network_component(instance_id : int)

signal spawn_unit(entity_type : String, properties : Dictionary)
signal units_updated(quantity : int)
signal register_unit(instance_id : int)

signal spawn_enemy(entity_type : String, properties : Dictionary)
signal enemies_updated(quantity : int)

signal spawn_structure(entity_type : String, properties : Dictionary)
signal structures_updated(quantity : int)
signal register_construction_site(instance_id : int)

signal entity_ready(entity : Entity)

signal register_influence_node(node : InfluenceNode)
signal register_grid_neighbor_connector_component(node : GridNeighborConnectorComponent)

signal register_assignment_receiver(instance_id : int)
