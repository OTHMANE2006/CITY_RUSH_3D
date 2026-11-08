extends Node

const SFX_PATHS := {
    "jump": "res://assets/audio/sfx/jump.wav",
    "coin": "res://assets/audio/sfx/coin.wav",
    "crash": "res://assets/audio/sfx/crash.wav",
    "powerup": "res://assets/audio/sfx/powerup.wav",
    "click": "res://assets/audio/sfx/click.wav",
    "slide": "res://assets/audio/sfx/slide.wav",
    "land": "res://assets/audio/sfx/land.wav",
}

const MUSIC_PATH: String = "res://assets/audio/music/city_rush_bgm.wav"

var sfx_players: Dictionary = {}
var music_player: AudioStreamPlayer = null
var music_playing: bool = false

func _ready() -> void:
    _create_sfx_players()
    start_music()

func _create_sfx_players() -> void:
    for key in SFX_PATHS.keys():
        var player := AudioStreamPlayer.new()
        var wav := AudioStreamWAV.new()
        wav.load_from_file(SFX_PATHS[key])
        player.set("loop", false)
        player.stream = wav
        player.volume_db = -10.0
        add_child(player)
        sfx_players[key] = player

func play(key: String) -> void:
    if not SaveSystem.sfx_enabled:
        return
    var player = sfx_players.get(key)
    if player == null:
        return
    if player.playing:
        player.stop()
    player.play()

func play_jump() -> void:
    play("jump")

func play_coin() -> void:
    play("coin")

func play_crash() -> void:
    play("crash")

func play_powerup() -> void:
    play("powerup")

func play_click() -> void:
    play("click")

func play_slide() -> void:
    play("slide")

func play_land() -> void:
    play("land")

func start_music() -> void:
    if music_player == null:
        music_player = AudioStreamPlayer.new()
        add_child(music_player)
        var music_wav := AudioStreamWAV.new()
        music_wav.load_from_file(MUSIC_PATH)
        music_player.stream = music_wav
        music_player.set("loop", true)
        music_player.volume_db = -14.0
    if not music_playing:
        music_player.play()
        music_playing = true

func stop_music() -> void:
    if music_player != null and music_player.playing:
        music_player.stop()
    music_playing = false

func set_music_enabled(enabled: bool) -> void:
    SaveSystem.music_enabled = enabled
    if enabled:
        start_music()
    else:
        stop_music()

func set_sfx_enabled(enabled: bool) -> void:
    SaveSystem.sfx_enabled = enabled
