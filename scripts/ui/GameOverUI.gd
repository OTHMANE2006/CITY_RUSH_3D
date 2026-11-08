extends Control

var final_score_label: Label
var best_score_label: Label
var coins_label: Label
var restart_btn: Button
var menu_btn: Button

func _ready() -> void:
    visible = false
    _build_ui()
    GameManager.game_over_screen_opened.connect(_on_game_over)
    GameManager.state_changed.connect(_on_state_changed)

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color(0.02, 0.03, 0.06, 1.0)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var panel := Control.new()
    panel.name = "Panel"
    panel.position = Vector2(60, 140)
    panel.size = Vector2(600, 860)
    add_child(panel)
    var panel_bg := ColorRect.new()
    panel_bg.color = Color(0.06, 0.08, 0.14, 0.92)
    panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.add_child(panel_bg)
    var vbox := VBoxContainer.new()
    vbox.position = Vector2(40, 60)
    vbox.size = Vector2(520, 760)
    vbox.add_theme_constant_override("separation", 14)
    panel.add_child(vbox)
    final_score_label = Label.new()
    final_score_label.name = "FinalScoreLabel"
    final_score_label.text = "Final Score: 0"
    final_score_label.horizontal_alignment = 1
    final_score_label.add_theme_font_size_override("font_size", 40)
    final_score_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
    vbox.add_child(final_score_label)
    best_score_label = Label.new()
    best_score_label.name = "BestScoreLabel"
    best_score_label.text = "Best: 0"
    best_score_label.horizontal_alignment = 1
    best_score_label.add_theme_font_size_override("font_size", 26)
    best_score_label.add_theme_color_override("font_color", Color(0.98, 0.80, 0.30))
    vbox.add_child(best_score_label)
    coins_label = Label.new()
    coins_label.name = "GameOverCoinsLabel"
    coins_label.text = "Coins: 0"
    coins_label.horizontal_alignment = 1
    coins_label.add_theme_font_size_override("font_size", 26)
    coins_label.add_theme_color_override("font_color", Color(0.6, 0.85, 0.6))
    vbox.add_child(coins_label)
    restart_btn = _make_button("Restart", 30, _on_restart_pressed)
    var menu_btn := _make_button("Main Menu", 30, _on_menu_pressed)
    vbox.add_child(restart_btn)
    vbox.add_child(menu_btn)

func _make_button(text: String, font_size: int, handler: Callable) -> Button:
    var btn := Button.new()
    btn.text = text
    btn.add_theme_font_size_override("font_size", font_size)
    btn.custom_minimum_size = Vector2(320, 64)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.10, 0.14, 0.24, 1.0)
    style.border_width_left = 2
    style.border_width_right = 2
    style.border_width_top = 2
    style.border_width_bottom = 2
    style.border_color = Color(0.30, 0.40, 0.65, 1.0)
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

func _on_game_over() -> void:
    final_score_label.text = "Final Score: %d" % GameManager.score
    best_score_label.text = "Best: %d" % SaveSystem.best_score
    coins_label.text = "Coins: %d" % SaveSystem.coins
    visible = true

func _on_state_changed(new_state: int) -> void:
    visible = new_state == GameManager.STATE_GAMEOVER

func _on_restart_pressed() -> void:
    visible = false
    GameManager.start_game()

func _on_menu_pressed() -> void:
    visible = false
    GameManager.state = GameManager.STATE_MENU
    GameManager.state_changed.emit(GameManager.STATE_MENU)
