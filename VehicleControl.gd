# Much of this is taken from https://github.com/godotengine/godot-demo-projects/blob/4.2-31d1c0c/3d/truck_town/vehicles/vehicle.gd
extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4
const BRAKE_STRENGTH = 2.0

@export var engine_force_value := 40.0

var previous_speed := linear_velocity.length()
var _steer_target := 0.0

@onready var _driver_pos : Vector3 = $DrivingPos.global_position
@onready var _vehicle_occupied: bool = false
@onready var desired_engine_pitch: float = $EngineSound.pitch_scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_vehicle_occupied = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if _vehicle_occupied:
		vehicle_controls(delta)

# All player controls are removed asid from the interact key
func vehicle_controls(delta: float) -> void:
	var fwd_mps := (linear_velocity * transform.basis).x

	_steer_target = Input.get_axis(&"turn_right", &"turn_left")
	_steer_target *= STEER_LIMIT

	# Engine sound simulation (not realistic, as this car script has no notion of gear or engine RPM).
	desired_engine_pitch = 0.05 + linear_velocity.length() / (engine_force_value * 0.5)
	# Change pitch smoothly to avoid abrupt change on collision.
	# TODO: Add driving sound
	$EngineSound.pitch_scale = lerpf($EngineSound.pitch_scale, desired_engine_pitch, 0.2)

	if abs(linear_velocity.length() - previous_speed) > 1.0:
		# Sudden velocity change, likely due to a collision. Play an impact sound to give audible feedback,
		# and vibrate for haptic feedback.
		# TODO: Add crashing sound 
		$ImpactSound.play()
		Input.vibrate_handheld(100)
		for joypad in Input.get_connected_joypads():
			Input.start_joy_vibration(joypad, 0.0, 0.5, 0.1)

	# Automatically accelerate when using touch controls (reversing overrides acceleration).
	if Input.is_action_pressed(&"accelerate"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		print("accelerate")
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = engine_force_value

		if not DisplayServer.is_touchscreen_available():
			# Apply analog throttle factor for more subtle acceleration if not fully holding down the trigger.
			engine_force *= Input.get_action_strength(&"accelerate")
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"reverse"):
		# Increase engine force at low speeds to make the initial reversing faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * BRAKE_STRENGTH * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = -engine_force_value * BRAKE_STRENGTH

		# Apply analog brake factor for more subtle braking if not fully holding down the trigger.
		engine_force *= Input.get_action_strength(&"reverse")

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_speed = linear_velocity.length()
