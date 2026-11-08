extends CharacterBody3D

signal jumped
signal slid
signal landed
signal crashed

const LANE_X: Array[float] = [-3.0, 0.0, 3.0]
const LANE_NAMES: Array[String] = ["LEFT", "CENTER", "RIGHT"]
const GRAVITY: float = 9.8
const JUMP_VELOCITY: float = 8.5
const RUN_SPEED: float = 14.0
const SLIDE_HEIGHT: float = 0.55
const STANDING_HEIGHT: float = 1.8
const CRASH_ROTATION: Vector3 = Vector3(0.9, 0.4, 0.0)

var lane_index: int = 1
var base_y: float = STANDING_HEIGHT * 0.5
var is_jumping: bool = false
var is_falling: bool = false
var is_sliding: bool = false
var slide_reached: bool = false
var slide_target_y: float = 0.25
var speed: float = RUN_SPEED
var visual: MeshInstance3D = null
var crashed_animated: bool = false
var facing: int = 1
var cam: Camera3D = null

func _ready() -> void:
    slide_target_y = base_y - (STANDING_HEIGHT - SLIDE_HEIGHT) * 0.5
    _setup_input_actions()
    var col := CollisionShape3D.new()
    var capsule_shape := CapsuleShape3D.new()
    capsule_shape.radius = 0.4
    capsule_shape.height = STANDING_HEIGHT
    col.shape = capsule_shape
    add_child(col)
    var visual_node := MeshInstance3D.new()
    visual_node.name = "Visual"
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.4
    capsule.height = STANDING_HEIGHT
    visual_node.mesh = capsule
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.8, 0.8, 0.85)
    visual_node.material_override = mat
    add_child(visual_node)
    visual = visual_node
    var cam_node := Camera3D.new()
    cam_node.name = "Camera3D"
    cam_node.position = Vector3(0.0, 2.2, -5.0)
    cam_node.fov = 60
    add_child(cam_node)
    cam = cam_node
    position = Vector3(0.0, base_y, 0.0)

func reset_position() -> void:
    lane_index = 1
    is_jumping = false
    is_falling = false
    is_sliding = false
    slide_reached = false
    velocity = Vector3(0.0, 0.0, 0.0)
    global_position = Vector3(0.0, base_y, 0.0)
    if visual != null:
        visual.rotation = Vector3(0.0, 0.0, 0.0)
        visual.scale = Vector3(1.0, 1.0, 1.0)
    if cam != null:
        cam.position = Vector3(0.0, 2.2, -5.0)

func _setup_input_actions() -> void:
    for action in ["lane_left", "lane_right", "jump", "slide"]:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
    _add_key_event("lane_left", KEY_LEFT)
    _add_key_event("lane_left", KEY_A)
    _add_key_event("lane_right", KEY_RIGHT)
    _add_key_event("lane_right", KEY_D)
    _add_key_event("jump", KEY_UP)
    _add_key_event("jump", KEY_SPACE)
    _add_key_event("slide", KEY_DOWN)
    _add_key_event("slide", KEY_SHIFT)

func _add_key_event(action: String, keycode: int) -> void:
    var ev := InputEventKey.new()
    ev.physical_keycode = keycode
    InputMap.action_add_event(action, ev)

func _physics_process(delta: float) -> void:
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    var target_x: float = LANE_X[lane_index]
    var diff: float = target_x - global_position.x
    velocity.x = diff * 12.0
    velocity.z = speed
    if is_jumping:
        velocity.y -= GRAVITY * delta
        if velocity.y < 0.0:
            is_falling = true
        move_and_slide()
        if velocity.y <= 0.0:
            velocity.y = 0.0
            is_jumping = false
            is_falling = false
            if visual != null:
                visual.rotation.x = 0.0
            landed.emit()
    elif is_sliding:
        if not slide_reached:
            velocity.y = -30.0
            move_and_slide()
            if global_position.y <= slide_target_y + 0.01:
                global_position.y = slide_target_y
                velocity.y = 0.0
                slide_reached = true
        else:
            velocity.y = 0.0
            move_and_slide()
    else:
        velocity.y = 0.0
        move_and_slide()
    if cam != null:
        var cam_target := Vector3(0.0, 2.2, -5.0)
        cam.position = cam.position.lerp(cam_target, 0.2)
        if visual != null and visual is MeshInstance3D:
            if is_sliding and slide_reached:
                visual.scale = Vector3(1.0, SLIDE_HEIGHT / STANDING_HEIGHT, 1.0)
            else:
                visual.scale = Vector3(1.0, 1.0, 1.0)
    if is_falling and visual != null:
        visual.rotation.x = -0.35
    check_collisions()

func _unhandled_input(event: InputEvent) -> void:
    if GameManager.state == GameManager.STATE_RUNNING or GameManager.state == GameManager.STATE_PAUSED:
        if event is InputEventKey:
            if event.pressed and not event.echo:
                var keycode: int = event.keycode
                if keycode == KEY_LEFT or keycode == KEY_A:
                    request_lane_change(0)
                elif keycode == KEY_RIGHT or keycode == KEY_D:
                    request_lane_change(2)
                elif keycode == KEY_UP or keycode == KEY_SPACE:
                    request_jump()
                elif keycode == KEY_DOWN or keycode == KEY_SHIFT:
                    request_slide()
        elif event is InputEventScreenTouch:
            if event.pressed:
                _touch_start(event.index, event.position)
            else:
                _touch_end(event.index, event.position)

func _touch_start(index: int, pos: Vector2) -> void:
    _active_touches[index] = {"start_pos": pos, "start_time": Time.get_ticks_msec() / 1000.0}

var _active_touches: Dictionary = {}

func _touch_end(index: int, pos: Vector2) -> void:
    var t = _active_touches.get(index)
    if t == null:
        return
    _active_touches.erase(index)
    var start_pos: Vector2 = t["start_pos"]
    var start_time: float = t["start_time"]
    var end_pos: Vector2 = pos
    var elapsed: float = Time.get_ticks_msec() / 1000.0 - start_time
    if elapsed > 0.3:
        return
    var dx: float = end_pos.x - start_pos.x
    var dy: float = end_pos.y - start_pos.y
    if abs(dx) > abs(dy) and abs(dx) > 24.0:
        if dx > 0:
            request_lane_change(2)
        else:
            request_lane_change(0)
    elif abs(dy) > abs(dx) and abs(dy) > 24.0:
        if dy < 0.0:
            request_jump()
        else:
            request_slide()

func request_lane_change(index: int) -> void:
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    if index < 0 or index > 2:
        return
    if index == lane_index:
        return
    lane_index = index
    if visual != null:
        var tw := visual.create_tween()
        tw.tween_property(visual, "rotation", Vector3(0.2, 0.0, 0.0), 0.12)
        tw.tween_property(visual, "rotation", Vector3(0.0, 0.0, 0.0), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    velocity.x = (LANE_X[index] - global_position.x) * 12.0

func request_jump() -> void:
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    if is_sliding or is_jumping:
        return
    if not is_on_floor:
        return
    velocity.y = JUMP_VELOCITY
    is_jumping = true
    jumped.emit()

func request_slide() -> void:
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    if is_jumping:
        return
    if not is_sliding:
        is_sliding = true
        slide_reached = false
        velocity.y = -30.0
        slid.emit()

func end_slide() -> void:
    if not is_sliding:
        return
    is_sliding = false
    if not is_jumping:
        global_position.y = base_y
        velocity.y = 0.0
        slide_reached = false
    if visual != null:
        visual.scale = Vector3(1.0, 1.0, 1.0)

func check_collisions() -> void:
    if GameManager.state != GameManager.STATE_RUNNING or GameManager.obstacle_spawner == null:
        return
    var spawner = GameManager.obstacle_spawner
    for o in spawner.get_obstacles():
        if o.lane != lane_index:
            continue
        if o.global_position.z < global_position.z:
            continue
        var dz: float = global_position.z - o.global_position.z
        if dz > o.collision_depth + 0.6:
            continue
        var player_bottom: float = global_position.y - STANDING_HEIGHT * 0.5
        var player_top: float = global_position.y + STANDING_HEIGHT * 0.5
        if is_sliding:
            player_top = global_position.y + SLIDE_HEIGHT * 0.5
        var obstacle_bottom: float = o.global_position.y
        var obstacle_top: float = o.global_position.y + o.collision_height * 0.5
        if player_top > obstacle_bottom - 0.05 and player_bottom < obstacle_top + 0.05:
            _crash()
            break

func _crash() -> void:
    if GameManager.shield:
        GameManager.end_powerup("shield")
        reset_position()
        return
    GameManager.game_over()
    AudioManager.play_crash()
    var tw := create_tween()
    tw.tween_property(self, "rotation", CRASH_ROTATION, 0.5)
    tw.tween_property(self, "rotation", Vector3(0.0, 0.0, 0.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
