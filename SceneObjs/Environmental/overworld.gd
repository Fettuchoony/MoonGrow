extends Node3D

@onready var _root = get_parent()
@onready var _player = $"../MainPlayer"
@onready var _menus = $"../Menus"
@onready var _map_cam = $MapCam
@onready var _map = $World
@onready var _anchor_point : Vector2 = Vector2.ZERO
@onready var _dragging : bool = false
@onready var _last_frame_mouse_pos : Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _dragging:
		_map_drag()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Map"):
		_dragging = false
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			print("showing mouse")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			print("capturing mouse")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_map_cam.current = !_map_cam.current
		_menus.visible = !_menus.visible
		_player.visible = !_player.visible
		_player.toggleHUD()
		_root.curr_level.visible = !_root.curr_level.visible
		visible = !visible
	if _map_cam.current && event.is_action_released("ScrollDown"):
		_map.global_position -= Vector3(0.0, 320/90, 5.0)
	if _map_cam.current && event.is_action_released("ScrollUp"):
		_map.global_position += Vector3(0.0, 320/90, 5.0)
	if _map_cam.current && event.is_action_pressed("Click"):
		_last_frame_mouse_pos = get_viewport().get_mouse_position()
		_dragging = true
		_anchor_point = get_viewport().get_mouse_position()
	if _map_cam.current && event.is_action_released("Click"):
		_dragging = false
		_anchor_point = Vector2.ZERO
	#_map.global_position += Vector3(0.0, (320/90) * _zoom_level, _zoom_level)

func _map_drag() -> void:
	var drag : Vector2 = _last_frame_mouse_pos - get_viewport().get_mouse_position()
	_map.global_position -= Vector3(drag.x, 0.0, drag.y)
	print(drag)
	_last_frame_mouse_pos = get_viewport().get_mouse_position()
	
