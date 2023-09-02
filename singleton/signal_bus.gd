extends Node
# Singleton SignalBus

signal connect_transport_network_component(instance_id : int)
signal disconnect_transport_network_component(instance_id : int)

signal spawn_entity(entity_type : String, properties : Dictionary)
signal entities_updated(quantity : int)

signal register_construction_site(instance_id : int)
signal register_influence_node(node : InfluenceNode)
signal register_grid_neighbor_connector_component(node : GridNeighborConnectorComponent)
signal register_assignment_receiver(instance_id : int)

signal entity_ready(entity : Entity)
