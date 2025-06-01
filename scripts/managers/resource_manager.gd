extends Node

# Signals to notify when a resource changes
signal food_changed(new_amount)
signal wood_changed(new_amount)
signal stone_changed(new_amount)
signal knowledge_changed(new_amount)
signal generic_resource_changed(resource_type, new_amount) # For more flexibility

enum ResourceType { FOOD, WOOD, STONE, KNOWLEDGE }

var resources: Dictionary = {
    ResourceType.FOOD: 100,
    ResourceType.WOOD: 50,
    ResourceType.STONE: 20,
    ResourceType.KNOWLEDGE: 0
}

func _ready():
    print("ResourceManager loaded.")
    # Emit initial signals if needed, or let UI poll
    # emit_signal("food_changed", resources[ResourceType.FOOD]) # Example

func add_resource(type: ResourceType, amount: int):
    if resources.has(type):
        resources[type] += amount
        print("Added ", amount, " of ", ResourceType.keys()[type], ". New total: ", resources[type])
        emit_resource_signal(type)
        emit_signal("generic_resource_changed", ResourceType.keys()[type], resources[type])
    else:
        print("Error: Tried to add unknown resource type: ", type)

func spend_resource(type: ResourceType, amount: int) -> bool:
    if resources.has(type):
        if resources[type] >= amount:
            resources[type] -= amount
            print("Spent ", amount, " of ", ResourceType.keys()[type], ". Remaining: ", resources[type])
            emit_resource_signal(type)
            emit_signal("generic_resource_changed", ResourceType.keys()[type], resources[type])
            return true
        else:
            print("Error: Not enough ", ResourceType.keys()[type], " to spend. Need: ", amount, ", Have: ", resources[type])
            return false
    else:
        print("Error: Tried to spend unknown resource type: ", type)
        return false

func get_resource_count(type: ResourceType) -> int:
    if resources.has(type):
        return resources[type]
    else:
        print("Error: Tried to get count of unknown resource type: ", type)
        return 0

func emit_resource_signal(type: ResourceType):
    match type:
        ResourceType.FOOD:
            emit_signal("food_changed", resources[type])
        ResourceType.WOOD:
            emit_signal("wood_changed", resources[type])
        ResourceType.STONE:
            emit_signal("stone_changed", resources[type])
        ResourceType.KNOWLEDGE:
            emit_signal("knowledge_changed", resources[type])

# Helper to convert string to ResourceType, useful if taking string input
static func string_to_resource_type(s: String) -> ResourceType:
    match s.to_lower():
        "food": return ResourceType.FOOD
        "wood": return ResourceType.WOOD
        "stone": return ResourceType.STONE
        "knowledge": return ResourceType.KNOWLEDGE
    printerr("Unknown resource string: ", s)
    return -1 # Invalid type
