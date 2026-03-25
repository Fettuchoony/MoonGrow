extends Camera3D

#@onready var _camera := $"." as Camera3D
@onready var _camera_pivot := $"../.." as Node3D
@onready var _player := $"../../.." as CharacterBody3D
@onready var _vehicle_cam := $"../../../../MainTestScene/VehicleBody3D/Pivot/SpringArm3D/VehicleCam"

# TODO: make sensitivity adjustable
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Camera tilt, max tilt set above as global
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Clamps tilt within params
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		# Camera orbit around player
		_player.rotation.y += -event.relative.x * mouse_sensitivity

func _ready() -> void:
	# Suck player mouse in
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_main_player_transfer_cam_to_vehicle(target: VehicleBody3D) -> void:
	if target == null:
		print_debug("Lost reference to vehicle when passing to camera")
	else: 
		print_debug("Camera Transfered to vehicle")
		clear_current()
		_vehicle_cam.make_current()


func _on_main_player_transfer_cam_to_player(player: CharacterBody3D) -> void:
	print_debug("Camera Transfered to player | id:" + player.to_string())
	_vehicle_cam.clear_current()
	make_current()
