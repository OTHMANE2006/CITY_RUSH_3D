extends Control

var music_btn: Button
var sfx_btn: Button

func _ready() -> void:
    visible = false
    _build_ui()
    GameManager.state_changed.connect(_on_state_changed)
    _update_buttons()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.02, 0.03, 0.06, 1.0)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var panel := Control.new()
    panel.name = "Panel"
    panel.position = Vector2(40, 80)
    panel.size = Vector2(640, 700)
    add_child(panel)
    var panel_bg := ColorRect.new()
    panel_bg.color = Color(0.06, 0.08, 0.14, 0.92)
    panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.add_child(panel_bg)
    var vbox := VBoxContainer.new()
    vbox.position = Vector2(50, 50)
    vbox.size = Vector2(540, 600)
    vbox.add_theme_constant_override("separation", 18)
    panel.add_child(vbox)
    var title := Label.new()
    title.text = "Settings"
    title.horizontal_alignment = 1
    title.add_theme_font_size_override("font_size", 40)
    title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
    vbox.add_child(title)
    music_btn = _make_button("Music: %s" % ("ON" if SaveSystem.music_enabled else "OFF"), 28, _on_music_pressed)
    var sfx_btn_tmp := _make_button("Sound Effects: %s" % ("ON" if SaveSystem.sfx_enabled else "OFF"), 28, _on_sfx_pressed)
    sfx_btn = sfx_btn_tmp
    vbox.add_child(music_btn)
    vbox.add_child(sfx_btn)

func _make_button(text: String, font_size: int, handler: Callable) -> Button:
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
    style.border_color = Color(0.3, 0.4, 0.65, 1.0)
    btn.add_theme_stylebox_override("normal", style)
    var hover := StyleBoxFlat.new()
    hover.bg_color = Color(0.16, 0.22, 0.38, 1.0)
    btn.add_theme_stylebox_override("hover", hover)
    var pressed := StyleBoxFlat.new()
    pressed.bg_color = Color(0.2, 0.12, 0.5, 1.0)
    btn.add_theme_stylebox_override("pressed", pressed)
    btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
    btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
    btn.pressed.connect(handler)
    return btn

func _on_music_pressed() -> void:
    SaveSystem.music_enabled = not SaveSystem.music_enabled
    AudioManager.set_music_enabled(SaveSystem.music_enabled)
    music_btn.text = "Music: %s" % ("ON" if SaveSystem.music_enabled else "OFF")

func _on_sfx_pressed() -> void:
    SaveSystem.sfx_enabled = not SaveSystem.sfx_enabled
    AudioManager.set_sfx_enabled(SaveSystem.sfx_enabled)
    sfx_btn.text = "Sound Effects: %s" % ("ON" if SaveSystem.sfx_enabled else "OFF")

func _on_state_changed(new_state: int) -> void:
    visible = new_state == GameManager.STATE_MENU

func _update_buttons() -> void:
    music_btn.text = "Music: %s" % ("ON" if SaveSystem.music_enabled else "OFF")
    sfx_btn.text = "Sound Effects: %s" % ("ON" if SaveSystem.sfx_enabled else "OFF")
