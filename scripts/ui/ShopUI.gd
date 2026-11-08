extends Control

var buttons: Array[Button] = []

const POWERUPS := [
    {"id": "magnet", "name": "Coin Magnet", "price": 150, "desc": "Coins within 8m are collected automatically."},
    {"id": "sneakers", "name": "Super Sneakers", "price": 200, "desc": "Double run speed for 15 seconds."},
    {"id": "jetpack", "name": "Jetpack", "price": 300, "desc": "Fly forward for 12 seconds."},
    {"id": "multiplier", "name": "Score x2", "price": 250, "desc": "Double score for 20 seconds."},
    {"id": "shield", "name": "Shield", "price": 120, "desc": "Survive one crash."},
]

const COIN_PACKAGES := [
    {"id": "pkg_small", "coins": 50, "price": 30},
    {"id": "pkg_medium", "coins": 150, "price": 80},
    {"id": "pkg_large", "coins": 400, "price": 180},
]

var current_powerup_id: String = ""
var current_powerup_price: int = 0
var current_package_id: String = ""
var current_package_coins: int = 0
var current_package_price: int = 0

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
    panel.size = Vector2(640, 1100)
    add_child(panel)
    var panel_bg := ColorRect.new()
    panel_bg.color = Color(0.06, 0.08, 0.14, 0.92)
    panel_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.add_child(panel_bg)
    var vbox := VBoxContainer.new()
    vbox.position = Vector2(50, 50)
    vbox.size = Vector2(540, 1000)
    vbox.add_theme_constant_override("separation", 14)
    panel.add_child(vbox)
    var title := Label.new()
    title.text = "Shop"
    title.horizontal_alignment = 1
    title.add_theme_font_size_override("font_size", 40)
    title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
    vbox.add_child(title)
    var coins_label := Label.new()
    coins_label.text = "Coins: %d" % SaveSystem.coins
    coins_label.horizontal_alignment = 1
    coins_label.add_theme_font_size_override("font_size", 26)
    coins_label.add_theme_color_override("font_color", Color(0.98, 0.80, 0.30))
    vbox.add_child(coins_label)
    for p in POWERUPS:
        var id: String = str(p["id"])
        var name: String = str(p["name"])
        var price: int = int(p["price"])
        var desc: String = str(p["desc"])
        current_powerup_id = id
        current_powerup_price = price
        var btn := _make_button(name, 24, "_on_powerup_button")
        btn.tooltip_text = desc
        vbox.add_child(btn)
        buttons.append(btn)
    var packages_header := Label.new()
    packages_header.text = "Coin Packages"
    packages_header.add_theme_font_size_override("font_size", 30)
    packages_header.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
    vbox.add_child(packages_header)
    for p in COIN_PACKAGES:
        var id: String = str(p["id"])
        var coins_amount: int = int(p["coins"])
        var price2: int = int(p["price"])
        current_package_id = id
        current_package_coins = coins_amount
        current_package_price = price2
        var btn2 := _make_button("%d Coins (+%d)" % [coins_amount, coins_amount], 24, "_on_package_button")
        vbox.add_child(btn2)
        buttons.append(btn2)

func _make_button(text: String, font_size: int, handler: StringName) -> Button:
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
    btn.pressed.connect(Callable(self, handler))
    return btn

func _on_powerup_button() -> void:
    var id: String = current_powerup_id
    var price: int = current_powerup_price
    if SaveSystem.coins < price:
        return
    SaveSystem.coins = SaveSystem.coins - price
    SaveSystem.save()
    GameManager.use_powerup(id)
    var lbl := _get_coins_label()
    if lbl != null:
        lbl.text = "Coins: %d" % SaveSystem.coins

func _on_package_button() -> void:
    var amount: int = current_package_coins
    var price: int = current_package_price
    if SaveSystem.coins < price:
        return
    SaveSystem.coins = SaveSystem.coins - price + amount
    SaveSystem.save()

func _get_coins_label() -> Label:
    for c in get_children():
        if c is Label:
            return c
    return null

func _on_state_changed(new_state: int) -> void:
    visible = new_state == GameManager.STATE_MENU
