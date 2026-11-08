extends Control

var buttons: Array[Button] = []
var character_buttons: Dictionary = {}
var current_char_id: String = ""
var current_char_price: int = 0

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
    panel.position = Vector2(40, 100)
    panel.size = Vector2(640, 1000)
    add_child(panel)
    var panel_bg := ColorRect.new()
    panel_bg.color = Color(0.06, 0.08, 0.14, 0.92)
    panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.add_child(panel_bg)
    var vbox := VBoxContainer.new()
    vbox.position = Vector2(50, 60)
    vbox.size = Vector2(540, 880)
    vbox.add_theme_constant_override("separation", 14)
    panel.add_child(vbox)
    var title := Label.new()
    title.text = "Select Character"
    title.horizontal_alignment = 1
    title.add_theme_font_size_override("font_size", 40)
    title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
    vbox.add_child(title)
    var hbox := HBoxContainer.new()
    hbox.position = Vector2(30, 90)
    hbox.size = Vector2(580, 700)
    hbox.add_theme_constant_override("separation", 16)
    panel.add_child(hbox)
    for c in CharacterManager.get_characters():
        var char_id: String = str(c["id"])
        var char_name: String = str(c["name"])
        var price: int = int(c["price"])
        var btn := Button.new()
        btn.name = "CharButton_" + char_id
        btn.text = char_name
        btn.add_theme_font_size_override("font_size", 22)
        btn.custom_minimum_size = Vector2(180, 220)
        var style2 := StyleBoxFlat.new()
        style2.bg_color = Color(0.10, 0.14, 0.24, 1.0)
        style2.border_width_left = 3
        style2.border_width_right = 3
        style2.border_width_top = 3
        style2.border_width_bottom = 3
        style2.border_color = Color(0.3, 0.4, 0.65, 1.0)
        btn.add_theme_stylebox_override("normal", style2)
        var hover := StyleBoxFlat.new()
        hover.bg_color = Color(0.16, 0.22, 0.38, 1.0)
        btn.add_theme_stylebox_override("hover", hover)
        var pressed := StyleBoxFlat.new()
        pressed.bg_color = Color(0.2, 0.12, 0.5, 1.0)
        btn.add_theme_stylebox_override("pressed", pressed)
        btn.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
        btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
        btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
        btn.add_theme_color_override("icon_color", Color(1.0, 1.0, 1.0))
        current_char_id = char_id
        current_char_price = price
        if CharacterManager.is_unlocked(char_id):
            btn.text = char_name + "  [SELECT]"
        else:
            btn.text = "%s  [%d coins]" % [char_name, price]
        btn.pressed.connect(_on_char_button_pressed)
        hbox.add_child(btn)
        character_buttons[char_id] = btn

func _on_char_button_pressed() -> void:
    var id: String = current_char_id
    var price: int = current_char_price
    if CharacterManager.is_unlocked(id):
        CharacterManager.select_character(id)
    else:
        if SaveSystem.coins >= price:
            CharacterManager.unlock_character(id, price)

func _on_state_changed(new_state: int) -> void:
    visible = new_state == GameManager.STATE_MENU
