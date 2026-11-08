extends Node

signal state_changed(new_state: int)
signal score_changed(new_score: int)
signal distance_changed(new_distance: float)
signal coins_changed(new_coins: int)
signal game_over_screen_opened
signal powerup_used(powerup_id: String)
signal powerup_ended(powerup_id: String)

const STATE_MENU: int = 0
const STATE_RUNNING: int = 1
const STATE_PAUSED: int = 2
const STATE_GAMEOVER: int = 3

const BASE_SPEED: float = 14.0
const COINS_PER_METER: int = 2
const BEST_SCORE_KEY: String = "best_score"

var state: int = STATE_MENU

var score: int = 0
var distance: float = 0.0
var best_score: int = 0
var run_coins: int = 0
var total_coins: int = 0

var multiplier: float = 1.0
var shield: bool = false
var magnet: bool = false
var sneakers: bool = false
var jetpack: bool = false
var active_powerup: String = ""
var powerup_timer: float = 0.0
var missions_progress: Dictionary = {}

var obstacle_spawner: Node3D = null
var coin_spawner: Node3D = null
var player: CharacterBody3D = null
var obstacles_avoided: int = 0

func get_player_x() -> float:
    if player != null:
        return player.global_position.x
    return 0.0

func get_player_z() -> float:
    if player != null:
        return player.global_position.z
    return 0.0

func update_powerups(delta: float) -> void:
    if active_powerup == "" or powerup_timer <= 0.0:
        return
    powerup_timer -= delta
    if powerup_timer <= 0.0:
        end_powerup(active_powerup)

func add_obstacle_avoided() -> void:
    obstacles_avoided += 1
    var avoid_progress: int = int(SaveSystem.missions_progress.get("avoid_20", 0))
    SaveSystem.missions_progress["avoid_20"] = avoid_progress + 1

func _ready() -> void:
    Engine.max_fps = 60.0
    var mem_info := OS.get_memory_info()
    var total_mb: float = mem_info.get("total", 0) / (1024.0 * 1024.0)
    if total_mb > 0.0 and total_mb < 1792.0:
        Engine.max_fps = 30.0
        push_warning("Low memory device detected (%.0fMB): running at 30 FPS" % total_mb)
    best_score = SaveSystem.best_score
    total_coins = SaveSystem.coins

func start_game() -> void:
    score = 0
    distance = 0.0
    run_coins = 0
    multiplier = 1.0
    shield = false
    magnet = false
    sneakers = false
    jetpack = false
    active_powerup = ""
    powerup_timer = 0.0
    obstacles_avoided = 0
    state = STATE_RUNNING
    state_changed.emit(state)
    if player != null:
        var p = player
        if p != null:
            p.reset_position()

func pause_game() -> void:
    if state == STATE_RUNNING:
        state = STATE_PAUSED
        state_changed.emit(state)

func resume_game() -> void:
    if state == STATE_PAUSED:
        state = STATE_RUNNING
        state_changed.emit(state)

func game_over() -> void:
    best_score = maxi(best_score, score)
    SaveSystem.best_score = best_score
    SaveSystem.save()
    state = STATE_GAMEOVER
    state_changed.emit(state)
    game_over_screen_opened.emit()

func add_score(meters: float) -> void:
    distance += meters
    score = int(distance * 10.0 * multiplier)
    score_changed.emit(score)
    distance_changed.emit(distance)
    var run_progress: int = int(SaveSystem.missions_progress.get("run_1000", 0))
    SaveSystem.missions_progress["run_1000"] = run_progress + int(meters)

func add_coins(amount: int) -> void:
    if amount <= 0:
        return
    run_coins += amount
    total_coins += amount
    SaveSystem.coins = total_coins
    coins_changed.emit(total_coins)
    var coin_progress: int = int(SaveSystem.missions_progress.get("coin_100", 0))
    SaveSystem.missions_progress["coin_100"] = coin_progress + amount

func use_powerup(powerup_id: String) -> void:
    active_powerup = powerup_id
    powerup_timer = 0.0
    powerup_used.emit(powerup_id)
    match powerup_id:
        "magnet":
            magnet = true
        "sneakers":
            sneakers = true
            powerup_timer = 15.0
        "jetpack":
            jetpack = true
            powerup_timer = 12.0
        "multiplier":
            multiplier = 2.0
            powerup_timer = 20.0
        "shield":
            shield = true
            powerup_timer = 0.0
        _:
            pass
    if powerup_id != "magnet" and powerup_id != "shield":
        var powerup_progress: int = int(SaveSystem.missions_progress.get("powerup_3", 0))
        SaveSystem.missions_progress["powerup_3"] = powerup_progress + 1

func end_powerup(powerup_id: String) -> void:
    match powerup_id:
        "magnet":
            magnet = false
        "sneakers":
            sneakers = false
        "jetpack":
            jetpack = false
        "multiplier":
            multiplier = 1.0
        "shield":
            shield = false
        _:
            pass
    active_powerup = ""
    powerup_ended.emit(powerup_id)
