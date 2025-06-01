extends Node

signal tech_researched(tech_id)
signal tech_list_updated() # Could be used to refresh a UI list

enum TechStatus { LOCKED, AVAILABLE, RESEARCHED }

# Using String IDs for simplicity, could be enums for larger trees
var technologies = {
    "FIRE_CONTROL": {
        "name": "Fire Control",
        "cost": 10, # Research points
        "prerequisites": [],
        "status": TechStatus.AVAILABLE, # Initially available
        "description": "Allows cooking, warmth, and basic pottery later."
    },
    "BASIC_TOOL_MAKING": {
        "name": "Basic Tool Making",
        "cost": 15,
        "prerequisites": [],
        "status": TechStatus.AVAILABLE, # Initially available
        "description": "Unlocks Stone Axe and Stone Spear."
    },
    "SHELTER_BUILDING": {
        "name": "Shelter Building",
        "cost": 20,
        "prerequisites": ["BASIC_TOOL_MAKING"], # Example prerequisite
        "status": TechStatus.LOCKED,
        "description": "Unlocks basic Hut for population."
    },
    "HUNTING_TECHNIQUES": {
        "name": "Hunting Techniques",
        "cost": 25,
        "prerequisites": ["BASIC_TOOL_MAKING"],
        "status": TechStatus.LOCKED,
        "description": "Improves food gathering from hunting."
    }
}

func _ready():
    print("TechnologyManager loaded.")
    update_tech_availability() # Initial check for available techs

func get_all_technologies() -> Dictionary:
    return technologies

func get_technology_status(tech_id: String) -> TechStatus:
    if technologies.has(tech_id):
        return technologies[tech_id].status
    return TechStatus.LOCKED # Default to locked if unknown

func get_available_technologies() -> Array[String]:
    var available_techs = []
    for tech_id in technologies.keys():
        if technologies[tech_id].status == TechStatus.AVAILABLE:
            available_techs.append(tech_id)
    return available_techs

func update_tech_availability():
    var changed = false
    for tech_id in technologies.keys():
        if technologies[tech_id].status == TechStatus.LOCKED:
            var all_prereqs_met = true
            for prereq_id in technologies[tech_id].prerequisites:
                if !technologies.has(prereq_id) or technologies[prereq_id].status != TechStatus.RESEARCHED:
                    all_prereqs_met = false
                    break
            if all_prereqs_met:
                technologies[tech_id].status = TechStatus.AVAILABLE
                print("Technology '", technologies[tech_id].name, "' is now available.")
                changed = true
    if changed:
        emit_signal("tech_list_updated")


func can_research_tech(tech_id: String) -> bool:
    if !technologies.has(tech_id):
        printerr("Unknown tech_id: ", tech_id)
        return false

    var tech_data = technologies[tech_id]
    if tech_data.status != TechStatus.AVAILABLE:
        print("Tech '", tech_data.name, "' is not available to research. Status: ", TechStatus.keys()[tech_data.status])
        return false

    if ResourceManager:
        if ResourceManager.get_resource_count(ResourceManager.ResourceType.KNOWLEDGE) >= tech_data.cost:
            return true
        else:
            print("Not enough Knowledge to research '", tech_data.name, "'. Need: ", tech_data.cost, ", Have: ", ResourceManager.get_resource_count(ResourceManager.ResourceType.KNOWLEDGE))
            return false
    else:
        printerr("ResourceManager not found!")
        return false

func research_tech(tech_id: String) -> bool:
    if can_research_tech(tech_id):
        var tech_data = technologies[tech_id]
        if ResourceManager.spend_resource(ResourceManager.ResourceType.KNOWLEDGE, tech_data.cost):
            tech_data.status = TechStatus.RESEARCHED
            print("Technology '", tech_data.name, "' researched!")
            emit_signal("tech_researched", tech_id)
            update_tech_availability() # Check if this unlocks new techs
            return true
        else:
            # This case should ideally be caught by can_research_tech, but as a safeguard:
            print("Failed to spend Knowledge for '", tech_data.name, "' despite passing can_research_tech check.")
            return false
    return false

EOF
