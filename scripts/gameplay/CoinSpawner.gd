extends Node3D

var coins: Array[Node3D] = []
var coin_pool: Array[Node3D] = []
const POOL_SIZE: int = 12
var running: bool = false
var magnet_active: bool = false
var distance_since_spawn: float = 0.0

const LANE_X: Array[float] = [-3.0, 0.0, 3.0]

func _ready() -> void:
    for i in POOL_SIZE:
        var c = Node3D.new()
        c.set_script(preload("res://scripts/gameplay/Coin.gd"))
        c.name = "Coin"
        c.visible = false
        c.collected = false
        add_child(c)
        coin_pool.append(c)

func start() -> void:
    running = true
    coins.clear()
    for c in coin_pool:
        c.visible = false
        c.collected = false
    distance_since_spawn = 0.0

func stop() -> void:
    running = false
    for c in coins:
        c.visible = false
        c.collected = false
        coin_pool.append(c)
    coins.clear()

func get_coins() -> Array:
    return coins

func _process(delta: float) -> void:
    if not running:
        return
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    for i in range(coins.size() - 1, -1, -1):
        var c: Node3D = coins[i]
        c.global_position.z -= c.speed * delta
        if c.collected:
            continue
        if c.global_position.z < -50.0:
            coins.remove_at(i)
            _return_coin_to_pool(c)
            continue
        _check_collection(c)
    distance_since_spawn += GameManager.BASE_SPEED * delta
    var interval: float = maxf(10.0, 28.0 - (GameManager.score / 50000.0) * 14.0)
    if distance_since_spawn >= interval:
        distance_since_spawn = 0.0
        _spawn_coin(randi() % 3, GameManager.distance + 30.0 + randf_range(0.0, 20.0), 1)

func _return_coin_to_pool(c: Node3D) -> void:
    c.visible = false
    c.collected = false
    coin_pool.append(c)

func _spawn_coin(lane: int, z: float, value: int = 1) -> void:
    var c: Node3D
    if not coin_pool.is_empty():
        c = coin_pool.pop_back()
        c.visible = true
        c.collected = false
    else:
        c = Node3D.new()
        c.set_script(preload("res://scripts/gameplay/Coin.gd"))
        c.name = "Coin"
    c.lane = lane
    c.value = value
    c.speed = 10.0
    c.global_position = Vector3(LANE_X[lane], 1.0, z)
    if not coin_pool_owner_has_parent(c):
        add_child(c)
    coins.append(c)
    GameManager.coin_spawner = self

func coin_pool_owner_has_parent(c: Node3D) -> bool:
    return c.get_parent() != null

func _check_collection(c: Node3D) -> void:
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    if c.collected:
        return
    var player_x: float = GameManager.get_player_x()
    var player_z: float = GameManager.get_player_z()
    var dx: float = absf(c.global_position.x - player_x)
    var dz: float = absf(c.global_position.z - player_z)
    if dx > 3.6 or dz > 1.6:
        if not GameManager.magnet:
            return
        if (dx * dx) + (dz * dz) > (8.0 * 8.0):
            return
    c.collected = true
    c.visible = false
    var value: int = 1
    if GameManager.magnet:
        value = 3
    GameManager.add_coins(value)
    AudioManager.play_coin()
    var tw := c.create_tween()
    tw.tween_property(c, "scale", Vector3(1.8, 1.8, 1.8), 0.18)
    tw.tween_property(c, "scale", Vector3(0.0, 0.0, 0.0), 0.18).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func spawn_coin(lane: int, z: float, value: int = 1) -> void:
    _spawn_coin(lane, z, value)
