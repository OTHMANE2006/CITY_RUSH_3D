extends Node3D

const BUILDING_COLORS := [
    Color(0.35, 0.42, 0.55),
    Color(0.30, 0.36, 0.48),
    Color(0.40, 0.44, 0.55),
    Color(0.25, 0.30, 0.40),
    Color(0.45, 0.40, 0.50),
]

var scenery: Array[Node3D] = []

func _ready() -> void:
    _build_ground()
    _build_rails()
    _build_background_buildings()
    _build_lights()
    _build_billboards()
    _build_tunnel()
    _build_bridge()
    _build_station()
    _build_trees()
    _build_environment()
    _build_ramps()
    _build_elevated_rails()

func _build_ground() -> void:
    var ground := StaticBody3D.new()
    ground.name = "Ground"
    var col := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(120.0, 1.0, 300.0)
    col.shape = box
    ground.position = Vector3(0.0, -0.5, 50.0)
    ground.add_child(col)
    var mesh := MeshInstance3D.new()
    var gmesh := BoxMesh.new()
    gmesh.size = Vector3(120.0, 1.0, 300.0)
    mesh.mesh = gmesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.12, 0.13, 0.17)
    mesh.material_override = mat
    ground.add_child(mesh)
    add_child(ground)

func _build_rails() -> void:
    for side in [-1.0, 1.0]:
        var rail := StaticBody3D.new()
        rail.name = "Rail"
        var col := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(0.25, 0.12, 120.0)
        col.shape = box
        rail.position = Vector3(side * 0.9, 0.06, 50.0)
        rail.add_child(col)
        var mesh := MeshInstance3D.new()
        var gmesh := BoxMesh.new()
        gmesh.size = Vector3(0.25, 0.12, 120.0)
        mesh.mesh = gmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.75, 0.72, 0.68)
        mesh.material_override = mat
        rail.add_child(mesh)
        add_child(rail)

func _build_background_buildings() -> void:
    for i in 14:
        var z := randf_range(30.0, 90.0)
        var x := randf_range(-14.0, 14.0)
        var w := randf_range(8.0, 18.0)
        var h := randf_range(12.0, 40.0)
        var depth := randf_range(8.0, 16.0)
        var b := StaticBody3D.new()
        b.name = "Building"
        var col := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(w, h, depth)
        col.shape = box
        b.position = Vector3(x, h * 0.5, z)
        b.add_child(col)
        var mesh := MeshInstance3D.new()
        var gmesh := BoxMesh.new()
        gmesh.size = Vector3(w, h, depth)
        mesh.mesh = gmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = BUILDING_COLORS[randi() % BUILDING_COLORS.size()]
        mat.roughness = 0.9
        mesh.material_override = mat
        b.add_child(mesh)
        add_child(b)
        scenery.append(b)

func _build_lights() -> void:
    var light := DirectionalLight3D.new()
    light.name = "Sun"
    light.set("energy", 3.0)
    light.set("color", Color(1.0, 0.95, 0.9))
    light.set("shadow_enabled", true)
    light.set("shadow_map_size", 1024)
    light.set("shadow_cascade_count", 2)
    light.position = Vector3(0.0, 10.0, 0.0)
    add_child(light)
    for i in 12:
        var pole := StaticBody3D.new()
        pole.name = "StreetLight"
        var col := CollisionShape3D.new()
        var cyl := CylinderShape3D.new()
        cyl.radius = 0.06
        cyl.height = 8.0
        col.shape = cyl
        pole.position = Vector3(randf_range(-10.0, 10.0), 4.0, randf_range(20.0, 80.0))
        pole.add_child(col)
        var pmesh := MeshInstance3D.new()
        var pole_mesh := BoxMesh.new()
        pole_mesh.size = Vector3(0.15, 8.0, 0.15)
        pmesh.mesh = pole_mesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.9, 0.85, 0.7)
        pmesh.material_override = mat
        pmesh.position = Vector3(0.0, 4.0, 0.0)
        pole.add_child(pmesh)
        add_child(pole)
        scenery.append(pole)

func _build_environment() -> void:
    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.set("background_mode", 0)
    env.set("background_color", Color(0.02, 0.03, 0.06, 1.0))
    env.set("ambient_light_energy", 0.5)
    env.set("tonemap_mode", 2)
    env.set("fog_enabled", 1)
    env.set("fog_density", 0.012)
    env_node.set("environment", env)
    add_child(env_node)

func _build_billboards() -> void:
    for i in 8:
        var board := StaticBody3D.new()
        board.name = "Billboard"
        var col := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(6.0, 3.0, 0.2)
        col.shape = box
        board.position = Vector3(randf_range(-12.0, 12.0), 5.0, randf_range(25.0, 85.0))
        board.add_child(col)
        var mesh := MeshInstance3D.new()
        var gmesh := BoxMesh.new()
        gmesh.size = Vector3(6.0, 3.0, 0.2)
        mesh.mesh = gmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.15, 0.2, 0.35)
        mesh.material_override = mat
        board.add_child(mesh)
        add_child(board)
        scenery.append(board)

func _build_trees() -> void:
    for i in 10:
        var tree := StaticBody3D.new()
        tree.name = "Tree"
        var col := CollisionShape3D.new()
        var cyl := CylinderShape3D.new()
        cyl.radius = 0.3
        cyl.height = 2.0
        col.shape = cyl
        tree.position = Vector3(randf_range(-12.0, 12.0), 1.0, randf_range(20.0, 80.0))
        tree.add_child(col)
        var tmesh := MeshInstance3D.new()
        var trunk_mesh := BoxMesh.new()
        trunk_mesh.size = Vector3(0.2, 2.0, 0.2)
        tmesh.mesh = trunk_mesh
        var tmat := StandardMaterial3D.new()
        tmat.albedo_color = Color(0.2, 0.12, 0.06)
        tmesh.material_override = tmat
        tmesh.position = Vector3(0.0, 1.0, 0.0)
        tree.add_child(tmesh)
        var crown := MeshInstance3D.new()
        var crown_mesh := BoxMesh.new()
        crown_mesh.size = Vector3(2.0, 2.0, 2.0)
        crown.mesh = crown_mesh
        crown.material_override = tmat
        crown.position = Vector3(0.0, 3.2, 0.0)
        tree.add_child(crown)
        add_child(tree)
        scenery.append(tree)

func _build_tunnel() -> void:
    var tunnel := StaticBody3D.new()
    tunnel.name = "Tunnel"
    var col := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(12.0, 12.0, 16.0)
    col.shape = box
    tunnel.position = Vector3(0.0, 6.0, 55.0)
    tunnel.add_child(col)
    var mesh := MeshInstance3D.new()
    var gmesh := BoxMesh.new()
    gmesh.size = Vector3(12.0, 12.0, 16.0)
    mesh.mesh = gmesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.05, 0.05, 0.08)
    mat.roughness = 1.0
    mesh.material_override = mat
    tunnel.add_child(mesh)
    add_child(tunnel)
    scenery.append(tunnel)

func _build_bridge() -> void:
    var bridge := StaticBody3D.new()
    bridge.name = "Bridge"
    var col := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(10.0, 2.0, 30.0)
    col.shape = box
    bridge.position = Vector3(0.0, 1.0, 80.0)
    bridge.add_child(col)
    var mesh := MeshInstance3D.new()
    var gmesh := BoxMesh.new()
    gmesh.size = Vector3(10.0, 2.0, 30.0)
    mesh.mesh = gmesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.25, 0.3, 0.4)
    mesh.material_override = mat
    bridge.add_child(mesh)
    add_child(bridge)
    scenery.append(bridge)

func _build_station() -> void:
    var station := StaticBody3D.new()
    station.name = "Station"
    var col := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(16.0, 8.0, 20.0)
    col.shape = box
    station.position = Vector3(0.0, 4.0, 100.0)
    station.add_child(col)
    var mesh := MeshInstance3D.new()
    var gmesh := BoxMesh.new()
    gmesh.size = Vector3(16.0, 8.0, 20.0)
    mesh.mesh = gmesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.3, 0.35, 0.45)
    mesh.material_override = mat
    station.add_child(mesh)
    var roof := StaticBody3D.new()
    roof.name = "StationRoof"
    var rcol := CollisionShape3D.new()
    var rbox := BoxShape3D.new()
    rbox.size = Vector3(18.0, 1.0, 22.0)
    rcol.shape = rbox
    roof.position = Vector3(0.0, 8.5, 100.0)
    roof.add_child(rcol)
    var rmesh := MeshInstance3D.new()
    var rgmesh := BoxMesh.new()
    rgmesh.size = Vector3(18.0, 1.0, 22.0)
    rmesh.mesh = rgmesh
    rmesh.material_override = mat
    roof.add_child(rmesh)
    add_child(station)
    add_child(roof)
    scenery.append(station)
    scenery.append(roof)

func _build_ramps() -> void:
    for i in 4:
        var ramp := StaticBody3D.new()
        ramp.name = "Ramp"
        var col := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(6.0, 1.0, 10.0)
        col.shape = box
        ramp.position = Vector3(randf_range(-8.0, 8.0), 0.5, randf_range(30.0, 90.0))
        ramp.add_child(col)
        var mesh := MeshInstance3D.new()
        var gmesh := BoxMesh.new()
        gmesh.size = Vector3(6.0, 1.0, 10.0)
        mesh.mesh = gmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.2, 0.35, 0.55)
        mesh.material_override = mat
        ramp.add_child(mesh)
        add_child(ramp)
        scenery.append(ramp)

func _build_elevated_rails() -> void:
    for side in [-1.0, 1.0]:
        var rail := StaticBody3D.new()
        rail.name = "RailElev"
        var col := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(0.25, 0.12, 120.0)
        col.shape = box
        rail.position = Vector3(side * 0.9, 2.0, 120.0)
        rail.add_child(col)
        var mesh := MeshInstance3D.new()
        var gmesh := BoxMesh.new()
        gmesh.size = Vector3(0.25, 0.12, 120.0)
        mesh.mesh = gmesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.75, 0.72, 0.68)
        mesh.material_override = mat
        rail.add_child(mesh)
        add_child(rail)
        scenery.append(rail)

func move_scenery(delta: float) -> void:
    var world_speed: float = 14.0
    if GameManager != null and GameManager.BASE_SPEED > 0.0:
        world_speed = GameManager.BASE_SPEED
    for s in scenery:
        if is_instance_valid(s):
            s.global_position.z -= world_speed * delta
