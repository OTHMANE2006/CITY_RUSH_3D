extends Node3D

var lane: int = 1
var value: int = 1
var speed: float = 10.0
var collected: bool = false

signal collected_coin(coin_value: int)

func _init() -> void:
    pass
