extends Control

@onready var food_label: Label = \$ResourceDisplay/FoodLabel
@onready var wood_label: Label = \$ResourceDisplay/WoodLabel
@onready var stone_label: Label = \$ResourceDisplay/StoneLabel
@onready var knowledge_label: Label = \$ResourceDisplay/KnowledgeLabel
@onready var era_label: Label = \$EraLabel
@onready var tech_tree_button: Button = \$TechTreeButton

func _ready():
    print("Main UI scene loaded!")

    if ResourceManager:
        update_resource_display("Food", ResourceManager.get_resource_count(ResourceManager.ResourceType.FOOD))
        update_resource_display("Wood", ResourceManager.get_resource_count(ResourceManager.ResourceType.WOOD))
        update_resource_display("Stone", ResourceManager.get_resource_count(ResourceManager.ResourceType.STONE))
        update_resource_display("Knowledge", ResourceManager.get_resource_count(ResourceManager.ResourceType.KNOWLEDGE))

        ResourceManager.food_changed.connect(_on_food_changed)
        ResourceManager.wood_changed.connect(_on_wood_changed)
        ResourceManager.stone_changed.connect(_on_stone_changed)
        ResourceManager.knowledge_changed.connect(_on_knowledge_changed)

    if TechnologyManager:
        TechnologyManager.tech_researched.connect(_on_tech_researched)
        TechnologyManager.tech_list_updated.connect(_on_tech_list_updated)
        # Initial display of available techs (simple console print for now)
        _print_available_techs()


    era_label.text = "Current Era: Stone Age"

    if tech_tree_button:
        tech_tree_button.pressed.connect(_on_tech_tree_button_pressed)

    var timer = get_tree().create_timer(2.0)
    timer.timeout.connect(_test_resource_changes)


func _on_tech_tree_button_pressed():
    print("Tech Tree button pressed! Attempting to research 'Fire Control'.")
    if TechnologyManager:
        if TechnologyManager.research_tech("FIRE_CONTROL"):
            print("'Fire Control' research successful from button press.")
        else:
            print("'Fire Control' research failed or not possible from button press.")

        # Try to research a locked tech to test prerequisite logic
        print("\nAttempting to research 'Shelter Building' (should fail if 'Basic Tool Making' not researched)...")
        if TechnologyManager.research_tech("SHELTER_BUILDING"):
            print("'Shelter Building' research successful (unexpected without prereqs).")
        else:
            print("'Shelter Building' research failed as expected or not enough RP.");


func _on_tech_researched(tech_id: String):
    print("Signal received: Tech researched - ", tech_id, " (", TechnologyManager.technologies[tech_id].name, ")")
    # Potentially update some game state or UI here in the future
    _print_available_techs()


func _on_tech_list_updated():
    print("Signal received: Tech list updated.")
    _print_available_techs()

func _print_available_techs():
    if TechnologyManager:
        var available = TechnologyManager.get_available_technologies()
        print("Currently available techs: ", available)


func update_resource_display(resource_name: String, new_value: int):
    match resource_name:
        "Food": food_label.text = "Food: " + str(new_value)
        "Wood": wood_label.text = "Wood: " + str(new_value)
        "Stone": stone_label.text = "Stone: " + str(new_value)
        "Knowledge": knowledge_label.text = "Knowledge: " + str(new_value)

func update_era_display(new_era_name: String):
    era_label.text = "Current Era: " + new_era_name

func _on_food_changed(new_amount: int): update_resource_display("Food", new_amount)
func _on_wood_changed(new_amount: int): update_resource_display("Wood", new_amount)
func _on_stone_changed(new_amount: int): update_resource_display("Stone", new_amount)
func _on_knowledge_changed(new_amount: int): update_resource_display("Knowledge", new_amount)

func _test_resource_changes():
    print("\nTesting resource changes...")
    if ResourceManager:
        ResourceManager.add_resource(ResourceManager.ResourceType.FOOD, 25)
        ResourceManager.add_resource(ResourceManager.ResourceType.WOOD, 10)
        ResourceManager.spend_resource(ResourceManager.ResourceType.STONE, 5) # Initial stone is 20
        ResourceManager.add_resource(ResourceManager.ResourceType.KNOWLEDGE, 5) # Initial Knowledge is 0, add 5 for Fire Control (cost 10)
        #ResourceManager.add_resource(ResourceManager.ResourceType.KNOWLEDGE, 50) # For testing tech tree button

func _process(delta):
    pass

EOF
