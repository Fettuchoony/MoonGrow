extends Camera3D

#@onready var _camera := $"." as Camera3D
@onready var _camera_pivot := $"../../CameraPivot" as Node3D
@onready var _player := $"../.." as CharacterBody3D
@onready var _overworld_cam : Camera3D = _player.find_child("Camera3D")
@onready var is_player_cam : bool = false

# TODO: make sensitivity adjustable
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@export var enable_movement : bool = true


func _unhandled_input(event: InputEvent) -> void:
	if !is_player_cam:
		transform = _overworld_cam.transform
	elif enable_movement && event is InputEventMouseMotion:
		# Camera tilt, max tilt set above as global
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Clamps tilt within params
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		# Camera orbit around player
		_player.rotation.y += -event.relative.x * mouse_sensitivity

func _ready() -> void:
	# Suck player mouse in
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var main_viewport : Viewport = get_tree().root
	var portal_viewport : SubViewport = get_parent()
	portal_viewport.size = main_viewport.size
	
	


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
