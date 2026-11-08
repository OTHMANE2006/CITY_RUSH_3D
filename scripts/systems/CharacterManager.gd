extends Node

const CHARACTERS := [
    {"id": "char_red", "name": "Red Dash", "price": 0, "body": Color(0.85, 0.08, 0.08), "accent": Color(0.98, 0.75, 0.15)},
    {"id": "char_blue", "name": "Blue Bolt", "price": 150, "body": Color(0.08, 0.25, 0.85), "accent": Color(0.20, 0.80, 0.95)},
    {"id": "char_green", "name": "Green Racer", "price": 300, "body": Color(0.05, 0.60, 0.25), "accent": Color(0.60, 0.95, 0.30)},
    {"id": "char_yellow", "name": "Yellow Blaze", "price": 500, "body": Color(0.95, 0.65, 0.05), "accent": Color(0.98, 0.95, 0.20)},
    {"id": "char_purple", "name": "Purple Storm", "price": 800, "body": Color(0.45, 0.15, 0.75), "accent": Color(0.75, 0.45, 0.95)},
    {"id": "char_silver", "name": "Silver Striker", "price": 1100, "body": Color(0.75, 0.78, 0.82), "accent": Color(0.98, 0.98, 0.98)},
    {"id": "char_cyan", "name": "Cyan Comet", "price": 1300, "body": Color(0.05, 0.70, 0.80), "accent": Color(0.40, 0.90, 1.0)},
    {"id": "char_crimson", "name": "Crimson Cyclone", "price": 1500, "body": Color(0.80, 0.10, 0.20), "accent": Color(1.0, 0.45, 0.30)},
    {"id": "char_emerald", "name": "Emerald Racer", "price": 1700, "body": Color(0.05, 0.55, 0.35), "accent": Color(0.40, 0.90, 0.55)},
    {"id": "char_white", "name": "White Phantom", "price": 2000, "body": Color(0.85, 0.85, 0.88), "accent": Color(0.70, 0.75, 1.0)},
]

func get_characters() -> Array:
    return CHARACTERS

func get_character(character_id: String) -> Dictionary:
    for c in CHARACTERS:
        if str(c["id"]) == character_id:
            return c
    return {}

func is_unlocked(character_id: String) -> bool:
    if character_id == "char_red":
        return true
    return SaveSystem.unlocked_characters.has(character_id)

func unlock_character(character_id: String, price: int) -> void:
    SaveSystem.unlocked_characters.append(character_id)
    SaveSystem.coins = maxi(SaveSystem.coins - price, 0)
    SaveSystem.save()

func select_character(character_id: String) -> void:
    SaveSystem.selected_character = character_id
    SaveSystem.save()
    var chars := get_character(character_id)
    var body_color: Color = chars["body"]
    var accent: Color = chars["accent"]
    var player_node = GameManager.player
    if player_node != null:
        var visual = player_node.get_node_or_null("Visual")
        if visual != null:
            var mat = StandardMaterial3D.new()
            mat.albedo_color = body_color
            visual.material_override = mat
