extends Control

var score_label: Label
var coins_label: Label
var distance_label: Label
var pause_btn: Button
var magnet_indicator: Label
var sneakers_indicator: Label
var jetpack_indicator: Label
var multiplier_indicator: Label
var shield_indicator: Label
var lane_left_btn: Button
var lane_right_btn: Button
var jump_btn: Button
var slide_btn: Button

func _ready() -> void:
    visible = false
    _build_ui()
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.distance_changed.connect(_on_distance_changed)
    GameManager.coins_changed.connect(_on_coins_changed)
    GameManager.powerup_used.connect(_on_powerup_used)
    GameManager.powerup_ended.connect(_on_powerup_ended)
    GameManager.state_changed.connect(_on_state_changed)

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.02, 0.03, 0.06, 1.0)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    score_label = Label.new()
    score_label.name = "ScoreLabel"
    score_label.position = Vector2(0, 60)
    score_label.size = Vector2(720, 80)
    score_label.horizontal_alignment = 1
    score_label.add_theme_font_size_override("font_size", 56)
    score_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    add_child(score_label)
    coins_label = Label.new()
    coins_label.name = "CoinsLabel"
    coins_label.position = Vector2(20, 60)
    coins_label.size = Vector2(300, 60)
    coins_label.horizontal_alignment = 0
    coins_label.add_theme_font_size_override("font_size", 30)
    coins_label.add_theme_color_override("font_color", Color(0.98, 0.80, 0.30))
    add_child(coins_label)
    distance_label = Label.new()
    distance_label.name = "DistanceLabel"
    distance_label.position = Vector2(20, 110)
    distance_label.size = Vector2(300, 40)
    distance_label.horizontal_alignment = 0
    distance_label.add_theme_font_size_override("font_size", 20)
    distance_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
    add_child(distance_label)
    pause_btn = Button.new()
    pause_btn.name = "PauseButton"
    pause_btn.position = Vector2(20, 20)
    pause_btn.size = Vector2(90, 60)
    pause_btn.text = "Pause"
    pause_btn.add_theme_font_size_override("font_size", 22)
    pause_btn.add_theme_stylebox_override("normal", _make_btn_style())
    pause_btn.add_theme_stylebox_override("hover", _make_btn_style())
    pause_btn.add_theme_stylebox_override("pressed", _make_btn_style())
    pause_btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    pause_btn.pressed.connect(_on_pause_pressed)
    add_child(pause_btn)
    var powerup_panel := Control.new()
    powerup_panel.name = "PowerUpPanel"
    powerup_panel.position = Vector2(0, 120)
    powerup_panel.size = Vector2(720, 140)
    add_child(powerup_panel)
    magnet_indicator = _make_indicator("Magnet")
    sneakers_indicator = _make_indicator("Sneakers")
    jetpack_indicator = _make_indicator("Jetpack")
    multiplier_indicator = _make_indicator("x2")
    shield_indicator = _make_indicator("Shield")
    var hbox := HBoxContainer.new()
    hbox.position = Vector2(20, 40)
    hbox.size = Vector2(680, 60)
    hbox.add_theme_constant_override("separation", 12)
    powerup_panel.add_child(hbox)
    hbox.add_child(magnet_indicator)
    hbox.add_child(sneakers_indicator)
    hbox.add_child(jetpack_indicator)
    hbox.add_child(multiplier_indicator)
    hbox.add_child(shield_indicator)
    _build_touch_controls()

func _build_touch_controls() -> void:
    lane_left_btn = Button.new()
    lane_left_btn.name = "LaneLeftButton"
    lane_left_btn.position = Vector2(25, 280)
    lane_left_btn.size = Vector2(150, 150)
    lane_left_btn.text = "<"
    lane_left_btn.add_theme_font_size_override("font_size", 44)
    lane_left_btn.add_theme_stylebox_override("normal", _make_btn_style())
    lane_left_btn.add_theme_stylebox_override("hover", _make_btn_style())
    lane_left_btn.add_theme_stylebox_override("pressed", _make_btn_style())
    lane_left_btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    lane_left_btn.pressed.connect(_on_lane_left_pressed)
    add_child(lane_left_btn)
    lane_right_btn = Button.new()
    lane_right_btn.name = "LaneRightButton"
    lane_right_btn.position = Vector2(545, 280)
    lane_right_btn.size = Vector2(150, 150)
    lane_right_btn.text = ">"
    lane_right_btn.add_theme_font_size_override("font_size", 44)
    lane_right_btn.add_theme_stylebox_override("normal", _make_btn_style())
    lane_right_btn.add_theme_stylebox_override("hover", _make_btn_style())
    lane_right_btn.add_theme_stylebox_override("pressed", _make_btn_style())
    lane_right_btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    lane_right_btn.pressed.connect(_on_lane_right_pressed)
    add_child(lane_right_btn)
    jump_btn = Button.new()
    jump_btn.name = "JumpButton"
    jump_btn.position = Vector2(230, 530)
    jump_btn.size = Vector2(200, 140)
    jump_btn.text = "JUMP"
    jump_btn.add_theme_font_size_override("font_size", 30)
    jump_btn.add_theme_stylebox_override("normal", _make_btn_style())
    jump_btn.add_theme_stylebox_override("hover", _make_btn_style())
    jump_btn.add_theme_stylebox_override("pressed", _make_btn_style())
    jump_btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    jump_btn.pressed.connect(_on_jump_pressed)
    add_child(jump_btn)
    slide_btn = Button.new()
    slide_btn.name = "SlideButton"
    slide_btn.position = Vector2(230, 680)
    slide_btn.size = Vector2(200, 140)
    slide_btn.text = "SLIDE"
    slide_btn.add_theme_font_size_override("font_size", 30)
    slide_btn.add_theme_stylebox_override("normal", _make_btn_style())
    slide_btn.add_theme_stylebox_override("hover", _make_btn_style())
    slide_btn.add_theme_stylebox_override("pressed", _make_btn_style())
    slide_btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    slide_btn.pressed.connect(_on_slide_pressed)
    add_child(slide_btn)
    lane_left_btn.visible = false
    lane_right_btn.visible = false
    jump_btn.visible = false
    slide_btn.visible = false

func _on_lane_left_pressed() -> void:
    if GameManager.player != null:
        GameManager.player.request_lane_change(0)

func _on_lane_right_pressed() -> void:
    if GameManager.player != null:
        GameManager.player.request_lane_change(2)

func _on_jump_pressed() -> void:
    if GameManager.player != null:
        GameManager.player.request_jump()

func _on_slide_pressed() -> void:
    if GameManager.player != null:
        GameManager.player.request_slide()

func _make_btn_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.10, 0.14, 0.24, 1.0)
    return style

func _make_indicator(text: String) -> Label:
    var label := Label.new()
    label.name = text + "Indicator"
    label.text = text
    label.horizontal_alignment = 1
    label.add_theme_font_size_override("font_size", 20)
    label.add_theme_color_override("font_color", Color(0.4, 0.45, 0.6, 1.0))
    label.visible = false
    return label

func _on_state_changed(new_state: int) -> void:
    visible = new_state == GameManager.STATE_RUNNING
    var show_controls: bool = new_state == GameManager.STATE_RUNNING
    if lane_left_btn != null:
        lane_left_btn.visible = show_controls
    if lane_right_btn != null:
        lane_right_btn.visible = show_controls
    if jump_btn != null:
        jump_btn.visible = show_controls
    if slide_btn != null:
        slide_btn.visible = show_controls

func _on_pause_pressed() -> void:
    if GameManager.state == GameManager.STATE_RUNNING:
        GameManager.pause_game()
    elif GameManager.state == GameManager.STATE_PAUSED:
        GameManager.resume_game()

func _on_score_changed(s: int) -> void:
    score_label.text = str(s)

func _on_distance_changed(d: float) -> void:
    distance_label.text = "Distance: %d m" % int(d)

func _on_coins_changed(c: int) -> void:
    coins_label.text = "Coins: %d" % c

func _on_powerup_used(powerup_id: String) -> void:
    match powerup_id:
        "magnet":
            magnet_indicator.visible = true
        "sneakers":
            sneakers_indicator.visible = true
        "jetpack":
            jetpack_indicator.visible = true
        "multiplier":
            multiplier_indicator.visible = true
        "shield":
            shield_indicator.visible = true

func _on_powerup_ended(powerup_id: String) -> void:
    match powerup_id:
        "magnet":
            magnet_indicator.visible = false
        "sneakers":
            sneakers_indicator.visible = false
        "jetpack":
            jetpack_indicator.visible = false
        "multiplier":
            multiplier_indicator.visible = false
        "shield":
            shield_indicator.visible = false
