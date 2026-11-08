extends Node

var coins: int = 150
var best_score: int = 0
var unlocked_characters: Array[String] = ["char_red"]
var selected_character: String = "char_red"
var music_enabled: bool = true
var sfx_enabled: bool = true
var missions_progress: Dictionary = {}

const SAVE_PATH: String = "user://save.cfg"

func _ready() -> void:
    load_save()

func load_save() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) == OK:
        coins = cfg.get_value("game", "coins", 150)
        best_score = cfg.get_value("game", "best_score", 0)
        var unlocked: PackedStringArray = cfg.get_value("characters", "unlocked", PackedStringArray(["char_red"]))
        unlocked_characters = []
        for id in unlocked:
            unlocked_characters.append(id)
        selected_character = str(cfg.get_value("characters", "selected", "char_red"))
        music_enabled = bool(cfg.get_value("settings", "music_enabled", true))
        sfx_enabled = bool(cfg.get_value("settings", "sfx_enabled", true))
        missions_progress = {}
        var mp = cfg.get_value("missions", "progress", {})
        if mp is Dictionary:
            missions_progress = mp
    else:
        coins = 150
        best_score = 0
        unlocked_characters = ["char_red"]
        selected_character = "char_red"
        music_enabled = true
        sfx_enabled = true
        missions_progress = {}

func save() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("game", "coins", coins)
    cfg.set_value("game", "best_score", best_score)
    cfg.set_value("characters", "unlocked", PackedStringArray(unlocked_characters))
    cfg.set_value("characters", "selected", selected_character)
    cfg.set_value("settings", "music_enabled", music_enabled)
    cfg.set_value("settings", "sfx_enabled", sfx_enabled)
    cfg.set_value("missions", "progress", missions_progress)
    cfg.save(SAVE_PATH)

func reset_save() -> void:
    coins = 150
    best_score = 0
    unlocked_characters = ["char_red"]
    selected_character = "char_red"
    music_enabled = true
    sfx_enabled = true
    missions_progress = {}
    save()
