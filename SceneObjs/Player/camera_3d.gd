extends Camera3D

#@onready var _camera := $"." as Camera3D
@onready var _camera_pivot := get_tree().root.get_child(0).find_child("CameraPivot") as Node3D
@onready var _player : CharacterBody3D = get_tree().root.get_child(0).find_child("MainPlayer")
@onready var _curr_cam : Camera3D

# TODO: make sensitivity adjustable
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var is_player_cam : bool = false
@export var tilt_limit = deg_to_rad(75)
@export var enable_movement : bool = true


func _unhandled_input(event: InputEvent) -> void:
	if is_player_cam && enable_movement && event is InputEventMouseMotion:
		# Camera tilt, max tilt set above as global
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Clamps tilt within params
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		# Camera orbit around player
		_player.rotation.y += -event.relative.x * mouse_sensitivity

func _ready() -> void:
	# Suck player mouse in
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("cameras")
	if is_player_cam:
		update_curr_cam(self, _player.in_overworld)
	else:
		update_curr_cam(_player.find_child("Camera3D"), _player.in_overworld)


func _process(delta: float) -> void:
	if _curr_cam == null:
		push_error("Current player camera not set!")
	if !is_player_cam && _curr_cam != null:
		global_transform = _curr_cam.global_transform

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_main_player_transfer_cam_to_vehicle(target: VehicleBody3D) -> void:
	if target == null:
		print_debug("Lost reference to vehicle when passing to camera")
	else: 
		print_debug("Camera Transfered to vehicle")
		clear_current()
		#_vehicle_cam.make_current()


func _on_main_player_transfer_cam_to_player(player: CharacterBody3D) -> void:
	print_debug("Camera Transfered to player | id:" + player.to_string())
	#_vehicle_cam.clear_current()
	make_current()

# Meant for camera group call
func update_curr_cam(cam : Camera3D, curr_cam_in_overworld : bool) -> void:
	print("updating cameras")
	_curr_cam = cam
	if cam == self:
		set_cull_mask_value(1, curr_cam_in_overworld)
		set_cull_mask_value(2, !curr_cam_in_overworld)
		is_player_cam = true
	else:
		set_cull_mask_value(1, !curr_cam_in_overworld)
		set_cull_mask_value(2, curr_cam_in_overworld)
		is_player_cam = false
