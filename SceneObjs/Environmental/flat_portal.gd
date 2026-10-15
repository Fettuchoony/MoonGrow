
extends Node3D

const IN_OVERWORLD := 1
const IN_UNDERWORLD := 2

const FLAT_PORTAL_SHADER = preload(
    "res://Materials/flat_portal.tres"
)

@onready var _player: CharacterBody3D = $"../MainPlayer"
@onready var _player_cam: Camera3D = $"../MainPlayer/CameraPivot/SpringArm3D/CurrPlayerCam/Camera3D"

@export var portal_half_size := Vector2(2.5, 2.5)
@export var rearm_distance := 0.25

var _previous_local_position: Vector3
var _armed := true


func _ready() -> void:
	_previous_local_position = to_local(
		_player_cam.global_position
	)


func _physics_process(_delta: float) -> void:
	# Switch the global dimension when the camera origin crosses.
	var current_local_position: Vector3 = to_local(
		_player_cam.global_position
	)

	if not _armed:
		if abs(current_local_position.z) >= rearm_distance:
			_armed = true

		_previous_local_position = current_local_position
		return

	var previous_z := _previous_local_position.z
	var current_z := current_local_position.z

	var crossed := (
		(previous_z > 0.0 and current_z <= 0.0)
		or
		(previous_z < 0.0 and current_z >= 0.0)
	)

	if crossed:
		var denominator := previous_z - current_z

		if abs(denominator) > 0.000001:
			var t := previous_z / denominator
			var crossing_point: Vector3 = _previous_local_position.lerp(
				current_local_position,
				t
			)

			var inside_x : bool = abs(crossing_point.x) <= portal_half_size.x
			var inside_y : bool = abs(crossing_point.y) <= portal_half_size.y

			if inside_x and inside_y:
				_switch_dimension()
				_armed = false

	_previous_local_position = current_local_position


func _switch_dimension() -> void:
	_player.in_overworld = not _player.in_overworld

	var dimension := (
		IN_OVERWORLD
		if _player.in_overworld
		else IN_UNDERWORLD
	)

	FLAT_PORTAL_SHADER.set_shader_parameter(
		"player_dimension",
		dimension
	)

	print(
		"Camera origin local Z: ",
		to_local(_player_cam.global_position).z
	)
