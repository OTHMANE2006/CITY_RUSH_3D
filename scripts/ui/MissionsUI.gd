extends Control

const MISSIONS := [
    {"id": "coin_100", "desc": "Collect 100 coins", "target": 100, "reward": 50},
    {"id": "run_1000", "desc": "Run 1000 meters", "target": 1000, "reward": 30},
    {"id": "avoid_20", "desc": "Avoid 20 obstacles", "target": 20, "reward": 40},
    {"id": "powerup_3", "desc": "Use 3 power-ups", "target": 3, "reward": 60},
]

var mission_buttons: Dictionary = {}
var current_mission_id: String = ""
var current_mission_target: int = 0
var current_mission_reward: int = 0

func _ready() -> void:
    visible = false
    _build_ui()
    GameManager.state_changed.connect(_on_state_changed)

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.02, 0.03, 0.06, 1.0)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var panel := Control.new()
    panel.name = "Panel"
    panel.position = Vector2(40, 80)
    panel.size = Vector2(640, 1000)
    add_child(panel)
    var panel_bg := ColorRect.new()
    panel_bg.color = Color(0.06, 0.08, 0.14, 0.92)
    panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.add_child(panel_bg)
    var vbox := VBoxContainer.new()
    vbox.position = Vector2(50, 50)
    vbox.size = Vector2(540, 950)
    vbox.add_theme_constant_override("separation", 14)
    panel.add_child(vbox)
    var title := Label.new()
    title.text = "Missions"
    title.horizontal_alignment = 1
    title.add_theme_font_size_override("font_size", 40)
    title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
    vbox.add_child(title)
    for m in MISSIONS:
        var id: String = str(m["id"])
        var desc: String = str(m["desc"])
        var target: int = int(m["target"])
        var reward: int = int(m["reward"])
        var btn := Button.new()
        btn.name = "MissionButton_" + id
        btn.text = "%s - Progress: %d/%d (Reward: %d)" % [desc, SaveSystem.missions_progress.get(id, 0), target, reward]
        btn.add_theme_font_size_override("font_size", 22)
        btn.custom_minimum_size = Vector2(340, 70)
        btn.add_theme_stylebox_override("normal", _make_btn_style())
        var hover := StyleBoxFlat.new()
        hover.bg_color = Color(0.16, 0.22, 0.38, 1.0)
        btn.add_theme_stylebox_override("hover", hover)
        var pressed := StyleBoxFlat.new()
        pressed.bg_color = Color(0.2, 0.12, 0.5, 1.0)
        btn.add_theme_stylebox_override("pressed", pressed)
        btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
        btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
        btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
        current_mission_id = id
        current_mission_target = target
        current_mission_reward = reward
        btn.pressed.connect(Callable(self, "_on_mission_button_pressed"))
        vbox.add_child(btn)
        mission_buttons[id] = btn

func _make_btn_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.10, 0.14, 0.24, 1.0)
    return style

func _on_mission_button_pressed() -> void:
    var id: String = current_mission_id
    var target: int = current_mission_target
    var reward: int = current_mission_reward
    var progress: int = int(SaveSystem.missions_progress.get(id, 0))
    if progress >= target:
        SaveSystem.missions_progress[id] = 0
        SaveSystem.coins = SaveSystem.coins + reward
        SaveSystem.save()
        GameManager.add_coins(reward)

func _on_state_changed(new_state: int) -> void:
    visible = new_state == GameManager.STATE_MENU

func _update_mission_texts() -> void:
    for m in MISSIONS:
        var id: String = str(m["id"])
        var btn: Button = mission_buttons.get(id, null)
        if btn == null:
            continue
        var target: int = int(m["target"])
        var reward: int = int(m["reward"])
        btn.text = "%s - Progress: %d/%d (Reward: %d)" % [str(m["desc"]), SaveSystem.missions_progress.get(id, 0), target, reward]
