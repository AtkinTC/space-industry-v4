extends Node
# Singleton GameState

signal trigger_build_state(structure_def : StructureDefinition)

var mining_drone_type : String = "mining_drone_001"

var build_control_layer : BuildControlLayer = null

func _ready() -> void:
	trigger_build_state.connect(start_build_state)

func register_build_control_layer(layer : BuildControlLayer) -> void:
	build_control_layer = layer

func start_build_state(structure_def : StructureDefinition) -> void:
	if(build_control_layer != null):
		build_control_layer.start_build_state(structure_def)
