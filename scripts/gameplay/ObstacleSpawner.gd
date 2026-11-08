extends Node3D

const LANE_X: Array[float] = [-3.0, 0.0, 3.0]

var obstacles: Array[Node3D] = []
var obstacle_pool: Array[Node3D] = []
const POOL_SIZE: int = 12
var running: bool = false
var distance_since_spawn: float = 0.0

func _ready() -> void:
    for i in POOL_SIZE:
        var o: Node3D = _create_obstacle(0, 1, false)
        o.visible = false
        obstacle_pool.append(o)

func start() -> void:
    running = true
    distance_since_spawn = 0.0
    obstacles.clear()

func stop() -> void:
    running = false
    for o in obstacles:
        o.visible = false
        obstacle_pool.append(o)
    obstacles.clear()

func get_obstacles() -> Array:
    return obstacles

func get_obstacle_count() -> int:
    return obstacles.size()

func _process(delta: float) -> void:
    if not running:
        return
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    for i in range(obstacles.size() - 1, -1, -1):
        var o: Node3D = obstacles[i]
        o.global_position.z -= o.speed * delta
        if o.global_position.z < -50.0:
            GameManager.add_obstacle_avoided()
            obstacles.remove_at(i)
            _return_to_pool(o)
    distance_since_spawn += GameManager.BASE_SPEED * delta
    var interval: float = maxf(0.55, 1.1 - (GameManager.score / 30000.0) * 0.55)
    if distance_since_spawn >= interval:
        distance_since_spawn = 0.0
        _spawn_obstacle()

func _return_to_pool(o: Node3D) -> void:
    o.visible = false
    obstacle_pool.append(o)

func _spawn_obstacle() -> void:
    var kind := _pick_kind()
    var lane := _pick_lane()
    var obstacle: Node3D
    if not obstacle_pool.is_empty():
        obstacle = obstacle_pool.pop_back()
        obstacle.visible = true
        obstacle.collision_depth = 2.2
        obstacle.collision_height = 1.2
        obstacle.speed = 8.0
        obstacle.movable = true
    else:
        obstacle = _create_obstacle(kind, lane)
    obstacle.kind = kind
    obstacle.lane = lane
    obstacle.global_position = Vector3(LANE_X[lane], 0.0, GameManager.distance + 30.0 + randf_range(0.0, 25.0))
    _rebuild_visuals(obstacle, kind)
    obstacles.append(obstacle)
    GameManager.obstacle_spawner = self

func _rebuild_visuals(obstacle: Node3D, kind: int) -> void:
    for c in obstacle.get_children():
        c.queue_free()
    obstacle.get_children().clear()
    _build_visuals(obstacle, kind)

func _pick_kind() -> int:
    var r: float = randf()
    var index: int = int(r * 8.0)
    if index < 1:
        return 0
    if index < 2:
        return 1
    if index < 3:
        return 2
    if index < 4:
        return 3
    if index < 5:
        return 4
    if index < 6:
        return 5
    if index < 7:
        return 6
    return 7

func _pick_lane() -> int:
    var roll: float = randf()
    if roll < 0.34:
        return 0
    if roll < 0.67:
        return 1
    return 2

func _create_obstacle(kind: int, lane: int, fresh_position: bool = true) -> Node3D:
    var o = Node3D.new()
    o.set_script(preload("res://scripts/gameplay/Obstacle.gd"))
    o.name = "Obstacle"
    o.lane = lane
    o.collision_depth = 2.2
    o.collision_height = 1.2
    o.speed = 8.0
    o.movable = true
    o.kind = kind
    if fresh_position:
        o.position = Vector3(LANE_X[lane], 0.0, GameManager.distance + 30.0 + randf_range(0.0, 25.0))
    else:
        o.position = Vector3(0.0, 0.0, 0.0)
    _build_visuals(o, kind)
    add_child(o)
    return o

func _build_visuals(o: Node3D, kind: int) -> void:
    var root: Node3D = o
    if kind == 0 or kind == 1:
        root.collision_height = 2.2
        var train := Node3D.new()
        train.name = "Train"
        var car_proto := BoxMesh.new()
        car_proto.size = Vector3(2.0, 2.2, 5.0)
        for c in 3:
            var car := MeshInstance3D.new()
            car.mesh = car_proto
            var mat := StandardMaterial3D.new()
            mat.albedo_color = Color(0.2, 0.25, 0.35)
            mat.roughness = 0.6
            car.material_override = mat
            car.position = Vector3(0.0, 1.1, -5.0 * (c + 1))
            train.add_child(car)
        root.add_child(train)
        root.speed = 9.0
    elif kind == 2:
        root.collision_height = 0.9
        var bar := MeshInstance3D.new()
        bar.name = "Barrier"
        var bmesh := BoxMesh.new()
        bmesh.size = Vector3(7.0, 0.9, 0.25)
        bar.mesh = bmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.7, 0.1, 0.1)
        mat.roughness = 0.6
        bar.material_override = mat
        bar.position = Vector3(0.0, 0.45, 0.0)
        bar.collision_depth = 7.0
        root.add_child(bar)
        root.collision_height = 0.9
    elif kind == 3:
        root.collision_height = 0.9
        var cone := MeshInstance3D.new()
        cone.name = "Cone"
        var cone_mesh := BoxMesh.new()
        cone_mesh.size = Vector3(0.7, 1.0, 0.7)
        cone.mesh = cone_mesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.95, 0.6, 0.05)
        cone.material_override = mat
        cone.position = Vector3(0.0, 0.5, 0.0)
        root.add_child(cone)
        root.collision_depth = 1.2
    elif kind == 4:
        root.collision_height = 1.8
        var vehicle := MeshInstance3D.new()
        vehicle.name = "Vehicle"
        var vmesh := BoxMesh.new()
        vmesh.size = Vector3(4.0, 1.8, 2.0)
        vehicle.mesh = vmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.5, 0.55, 0.65)
        mat.roughness = 0.6
        vehicle.material_override = mat
        vehicle.position = Vector3(0.0, 0.9, -2.0)
        var vmesh2 := BoxMesh.new()
        vmesh2.size = Vector3(4.0, 1.5, 2.0)
        var vehicle2 := MeshInstance3D.new()
        vehicle2.mesh = vmesh2
        vehicle2.material_override = mat
        vehicle2.position = Vector3(0.0, 1.0, 2.0)
        vehicle.add_child(vehicle2)
        root.add_child(vehicle)
        root.collision_depth = 4.0
    elif kind == 5:
        root.collision_height = 1.2
        var crate := MeshInstance3D.new()
        crate.name = "WoodenBox"
        var cmesh := BoxMesh.new()
        cmesh.size = Vector3(1.6, 1.2, 1.6)
        crate.mesh = cmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.55, 0.35, 0.2)
        crate.material_override = mat
        crate.position = Vector3(0.0, 0.6, 0.0)
        root.add_child(crate)
        root.collision_depth = 1.6
    elif kind == 6:
        root.collision_height = 1.4
        var low := MeshInstance3D.new()
        low.name = "LowObstacle"
        var lmesh := BoxMesh.new()
        lmesh.size = Vector3(2.0, 1.4, 1.0)
        low.mesh = lmesh
        var lmat := StandardMaterial3D.new()
        lmat.albedo_color = Color(0.85, 0.85, 0.9)
        low.material_override = lmat
        low.position = Vector3(0.0, 0.7, 0.0)
        root.add_child(low)
        root.collision_depth = 2.0
        root.collision_height = 1.4
    elif kind == 7:
        root.collision_height = 2.8
        var high := MeshInstance3D.new()
        high.name = "HighObstacle"
        var hmesh := BoxMesh.new()
        hmesh.size = Vector3(2.0, 2.8, 1.0)
        high.mesh = hmesh
        var hmat := StandardMaterial3D.new()
        hmat.albedo_color = Color(0.85, 0.2, 0.2)
        high.material_override = hmat
        high.position = Vector3(0.0, 1.4, 0.0)
        root.add_child(high)
        root.collision_depth = 2.0
        root.collision_height = 2.8

func _process_spawn_logic(delta: float) -> void:
    pass
