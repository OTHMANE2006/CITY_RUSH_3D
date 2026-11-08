extends Node3D

const KIND_TRAIN: int = 0
const KIND_STATIONARY_TRAIN: int = 1
const KIND_BARRIER: int = 2
const KIND_CONE: int = 3
const KIND_VEHICLE: int = 4
const KIND_WOODEN_BOX: int = 5
const KIND_LOW_OBSTACLE: int = 6
const KIND_HIGH_OBSTACLE: int = 7

var kind: int = KIND_BARRIER
var lane: int = 1
var collision_depth: float = 2.2
var collision_height: float = 1.2
var speed: float = 8.0
var movable: bool = true

func _init() -> void:
    pass
