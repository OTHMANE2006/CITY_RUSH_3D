extends Node3D

var player: CharacterBody3D
var world_builder: Node3D
var obstacle_spawner: Node3D
var coin_spawner: Node3D
var main_menu: Control
var hud: Control
var game_over_ui: Control
var character_select: Control
var shop: Control
var missions: Control
var settings: Control

func _ready() -> void:
    _build_world()
    _build_player()
    _build_ui()
    GameManager.player = player
    GameManager.obstacle_spawner = obstacle_spawner
    GameManager.coin_spawner = coin_spawner
    GameManager.state = GameManager.STATE_MENU

func _build_world() -> void:
    world_builder = Node3D.new()
    world_builder.name = "WorldBuilder"
    world_builder.set_script(preload("res://scripts/gameplay/WorldBuilder.gd"))
    add_child(world_builder)
    obstacle_spawner = Node3D.new()
    obstacle_spawner.name = "ObstacleSpawner"
    obstacle_spawner.set_script(preload("res://scripts/gameplay/ObstacleSpawner.gd"))
    add_child(obstacle_spawner)
    coin_spawner = Node3D.new()
    coin_spawner.name = "CoinSpawner"
    coin_spawner.set_script(preload("res://scripts/gameplay/CoinSpawner.gd"))
    add_child(coin_spawner)

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(preload("res://scripts/player/PlayerController.gd"))
    add_child(player)
    GameManager.player = player

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    layer.name = "UILayer"
    add_child(layer)
    main_menu = Control.new()
    main_menu.name = "MainMenu"
    main_menu.set_script(preload("res://scripts/ui/MainMenuUI.gd"))
    layer.add_child(main_menu)
    hud = Control.new()
    hud.name = "Hud"
    hud.set_script(preload("res://scripts/ui/HudUI.gd"))
    layer.add_child(hud)
    game_over_ui = Control.new()
    game_over_ui.name = "GameOverUI"
    game_over_ui.set_script(preload("res://scripts/ui/GameOverUI.gd"))
    layer.add_child(game_over_ui)
    character_select = Control.new()
    character_select.name = "CharacterSelect"
    character_select.set_script(preload("res://scripts/ui/CharacterSelectUI.gd"))
    layer.add_child(character_select)
    shop = Control.new()
    shop.name = "Shop"
    shop.set_script(preload("res://scripts/ui/ShopUI.gd"))
    layer.add_child(shop)
    missions = Control.new()
    missions.name = "Missions"
    missions.set_script(preload("res://scripts/ui/MissionsUI.gd"))
    layer.add_child(missions)
    settings = Control.new()
    settings.name = "Settings"
    settings.set_script(preload("res://scripts/ui/SettingsUI.gd"))
    layer.add_child(settings)
    main_menu.play_requested.connect(_on_play_requested)
    main_menu.shop_requested.connect(_on_shop_requested)
    main_menu.characters_requested.connect(_on_characters_requested)
    main_menu.missions_requested.connect(_on_missions_requested)
    main_menu.settings_requested.connect(_on_settings_requested)

func _on_play_requested() -> void:
    GameManager.start_game()

func _on_shop_requested() -> void:
    shop.visible = true
    character_select.visible = false
    missions.visible = false
    settings.visible = false
    main_menu.visible = false

func _on_characters_requested() -> void:
    character_select.visible = true
    shop.visible = false
    missions.visible = false
    settings.visible = false
    main_menu.visible = false

func _on_missions_requested() -> void:
    missions.visible = true
    shop.visible = false
    character_select.visible = false
    settings.visible = false
    main_menu.visible = false

func _on_settings_requested() -> void:
    settings.visible = true
    shop.visible = false
    character_select.visible = false
    missions.visible = false
    main_menu.visible = false

func _process(delta: float) -> void:
    GameManager.update_powerups(delta)
    if GameManager.state != GameManager.STATE_RUNNING:
        return
    if GameManager.player != null:
        GameManager.player.speed = GameManager.BASE_SPEED * (2.0 if GameManager.sneakers else 1.0)
        if GameManager.jetpack and GameManager.player.is_on_floor and not GameManager.player.is_jumping and not GameManager.player.is_sliding:
            GameManager.player.request_jump()
    GameManager.add_score(GameManager.BASE_SPEED * delta)
    if world_builder != null:
        world_builder.move_scenery(delta)

func _on_state_changed(new_state: int) -> void:
    if new_state == GameManager.STATE_RUNNING:
        if obstacle_spawner != null:
            obstacle_spawner.start()
        if coin_spawner != null:
            coin_spawner.start()
        if hud != null:
            hud.visible = true
        if main_menu != null:
            main_menu.visible = false
        if game_over_ui != null:
            game_over_ui.visible = false
    elif new_state == GameManager.STATE_MENU:
        if obstacle_spawner != null:
            obstacle_spawner.stop()
        if coin_spawner != null:
            coin_spawner.stop()
        if hud != null:
            hud.visible = false
        if main_menu != null:
            main_menu.visible = true
        if game_over_ui != null:
            game_over_ui.visible = false
    elif new_state == GameManager.STATE_GAMEOVER:
        if obstacle_spawner != null:
            obstacle_spawner.stop()
        if coin_spawner != null:
            coin_spawner.stop()
        if hud != null:
            hud.visible = false
        if main_menu != null:
            main_menu.visible = false
        if game_over_ui != null:
            game_over_ui.visible = true
