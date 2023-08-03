class_name Constants

const KEY_POSITION := "position"
const KEY_ROTATION := "rotation"
const KEY_STRUCTURE_ID := "structure_id"
const KEY_INVENTORY_CONTENTS := "inventory_contents"

const GROUP_RESOURCE_NODE := "resource_node"
const GROUP_STRUCTURE := "structure"
const GROUP_CONSTRUCTION := "construction_site"

const GLOBAL_STORAGE_COMPONENT_GROUP := "global_storage_component"

const GROUP_SHIP := "ship"
const GROUP_MINER := "miner"

const ACCEPTING_CARGO_GROUP := "accepting_cargo"

enum COMPONENT_CLASS {NONE = 0, STORAGE, DOCK, DRONE_DEPOT, POWER_SUPPLY, RECHARGER, TRANSPORT_NETWORK}
const DOCK_COMPONENT_GROUP := "dock_component_group"
const DRONE_DEPOT_COMPONENT_GROUP := "drone_depot_component_group"
const RECHARGER_COMPONENT_GROUP := "recharger_component_group"

enum WEAPON_TYPE {NONE = 0, MINING, BEAM, PROJECTILE, MISSILE}

const TOOL_TYPE_NULL := "null"
const TOOL_TYPE_MINER := "miner"
const TOOL_TYPES := [TOOL_TYPE_NULL, TOOL_TYPE_MINER]

const TASK_GROUP_SHIP := "ship"
const TASK_GROUP_MINER := "miner"
const TASK_GROUP_BUILDER := "buider"
const TASK_GROUP_TRANSPORTER := "transporter"
const TASK_GROUP_FIGHTER := "fighter"
const TASK_GROUPS := [TASK_GROUP_SHIP, TASK_GROUP_MINER, TASK_GROUP_FIGHTER]

const TILE_SIZE := Vector2i(32, 32)
