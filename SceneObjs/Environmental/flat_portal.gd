extends Node3D

@onready var norm: Node3D = $Norm
@onready var _player: CharacterBody3D = $"../MainPlayer"

@export var portal_half_size := Vector2(2.5, 2.5)
@export var crossing_cooldown := 0.25

var _last_pos: Vector3
var _last_crossing_time := -1000.0

func _ready() -> void:
	_last_pos = _player.global_position

func _process(_delta: float) -> void:
	var previous := norm.to_local(_last_pos)
	var current := norm.to_local(_player.global_position)

	# Save the position for the next frame.
	_last_pos = _player.global_position

	# Only react when the player crosses the plane.
	if previous.z * current.z >= 0.0:
		return

	# Find where the movement segment crosses local Z = 0.
	var t := previous.z / (previous.z - current.z)
	var crossing_point := previous.lerp(current, t)

	# Require the crossing to be inside the aperture.
	if abs(crossing_point.x) > portal_half_size.x:
		return
	if abs(crossing_point.y) > portal_half_size.y:
		return

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_crossing_time < crossing_cooldown:
		return

	_last_crossing_time = now
	_player.in_overworld = not _player.in_overworld
