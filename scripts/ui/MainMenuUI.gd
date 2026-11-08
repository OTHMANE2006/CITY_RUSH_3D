extends Control

signal play_requested
signal shop_requested
signal characters_requested
signal missions_requested
signal settings_requested

var panel: Control
var play_btn: Button
var shop_btn: Button
var characters_btn: Button
var missions_btn: Button
var settings_btn: Button
var coins_label: Label
var title_label: Label

func _ready() -> void:
    visible = false
    _build_ui()
    GameManager.state_changed.connect(_on_state_changed)
    _refresh_coins()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.02, 0.03, 0.06, 1.0)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    panel = Control.new()
    panel.name = "Panel"
    panel.position = Vector2(40, 120)
    panel.size = Vector2(640, 980)
    add_child(panel)
    var panel_bg := ColorRect.new()
    panel_bg.color = Color(0.06, 0.08, 0.14, 0.88)
    panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.add_child(panel_bg)
    var vbox := VBoxContainer.new()
    vbox.position = Vector2(60, 200)
    vbox.size = Vector2(600, 820)
    vbox.add_theme_constant_override("separation", 16)
    panel.add_child(vbox)
    title_label = Label.new()
    title_label.text = "CITY RUSH 3D"
    title_label.horizontal_alignment = 1
    title_label.add_theme_font_size_override("font_size", 56)
    title_label.add_theme_color_override("font_color", Color(0.90, 0.95, 1.0))
    vbox.add_child(title_label)
    var subtitle := Label.new()
    subtitle.text = "Run. Jump. Slide. Collect."
    subtitle.horizontal_alignment = 1
    subtitle.add_theme_font_size_override("font_size", 22)
    subtitle.add_theme_color_override("font_color", Color(0.55, 0.65, 0.85))
    vbox.add_child(subtitle)
    coins_label = Label.new()
    coins_label.name = "CoinsLabel"
    coins_label.text = "Coins: %d" % SaveSystem.coins
    coins_label.horizontal_alignment = 1
    coins_label.add_theme_font_size_override("font_size", 26)
    coins_label.add_theme_color_override("font_color", Color(0.98, 0.80, 0.30))
    vbox.add_child(coins_label)
    play_btn = _make_button("Play", 34, _on_play_pressed, true)
    shop_btn = _make_button("Shop", 30, _on_shop_requested)
    characters_btn = _make_button("Characters", 28, _on_characters_requested)
    missions_btn = _make_button("Missions", 28, _on_missions_requested)
    settings_btn = _make_button("Settings", 28, _on_settings_requested)
    for b in [play_btn, shop_btn, characters_btn, missions_btn, settings_btn]:
        vbox.add_child(b)

func _make_button(text: String, font_size: int, handler: Callable, primary: bool = false) -> Button:
    var btn := Button.new()
    btn.text = text
    btn.add_theme_font_size_override("font_size", font_size)
    btn.custom_minimum_size = Vector2(340, 64)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.10, 0.14, 0.24, 1.0)
    style.border_width_left = 2
    style.border_width_right = 2
    style.border_width_top = 2
    style.border_width_bottom = 2
    style.border_color = Color(0.30, 0.40, 0.65, 1.0)
    if primary:
        style.bg_color = Color(0.35, 0.25, 0.75, 1.0)
        style.border_color = Color(0.60, 0.45, 0.95, 1.0)
    btn.add_theme_stylebox_override("normal", style)
    var hover := StyleBoxFlat.new()
    hover.bg_color = style.bg_color + Color(0.1, 0.1, 0.1, 0.0)
    btn.add_theme_stylebox_override("hover", hover)
    var pressed := StyleBoxFlat.new()
    pressed.bg_color = Color(0.2, 0.12, 0.5, 1.0)
    btn.add_theme_stylebox_override("pressed", pressed)
    btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
    btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
    btn.pressed.connect(handler)
    return btn

func _on_play_pressed() -> void:
    play_requested.emit()

func _on_shop_requested() -> void:
    shop_requested.emit()

func _on_characters_requested() -> void:
    characters_requested.emit()

func _on_missions_requested() -> void:
    missions_requested.emit()

func _on_settings_requested() -> void:
    settings_requested.emit()

func _on_state_changed(new_state: int) -> void:
    visible = new_state == GameManager.STATE_MENU

func _refresh_coins() -> void:
    if coins_label != null:
        coins_label.text = "Coins: %d" % SaveSystem.coins
