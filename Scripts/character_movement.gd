extends CharacterBody3D


const MAX_SPEED = 3.5
const JUMP_SPEED = 6.5
const ACCELERATION = 4
const DECELERATION = 4
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const INTERACT_COOLDOWN_TIME = 1
const QSLOT : int = 0
const ESLOT : int = 1
const RSLOT : int = 2

signal transfer_cam_to_vehicle(target:VehicleBody3D)
signal transfer_cam_to_player()
signal vehicle_entered(player:CharacterBody3D)
signal vehicle_exited()
signal pause_menu()
signal update_health_GUI(deltaH: int, deltaMax: int)

@onready var _max_health : int = 10
@onready var _health : int = 10
@onready var _target = $CameraPivot/SpringArm3D/Camera3D/PlayerRay
@onready var _debug_ball = $CameraPivot/SpringArm3D/Camera3D/PlayerRay/DebugBall
@onready var _item_spawn_location = $ItemPivot/ItemSpawnSpot
@onready var _pickup_hold_location : Node3D = $PickupPivot/ItemHoverSpot
@onready var _held_item : RigidBody3D = null
@onready var _can_enter_vehicle:bool = false
@onready var _last_vehicle_entered : Node3D = null
@onready var _in_vehicle:bool = false
@onready var _mouse_mode:int = 2
# Vehicle entrance should be the only collision option on layer 9
@onready var _vehicle_info = null
@onready var _enter_vehicle_cooldown:float = 0
# TODO: Create item list/map of all names, items ID by exact string (lowercase)
# This is a list of all items and if they are equipped [name : taskbar index]
@onready var _taskbar_items : Dictionary[String, Node3D]
@onready var _taskbar_containers : Array[Node]
@onready var _current_taskbar_index : int = 0
@onready var _taskbar_rects = $GUI/TaskBar/HBoxContainer.get_children()

@onready var _inventory : Array[Node3D]
@onready var _paused : bool
@onready var _item_timer: float = 0
@onready var _aim_ray : RayCast3D = $CameraPivot/SpringArm3D/Camera3D/PlayerRay
@onready var _item_ray : RayCast3D = $CameraPivot/SpringArm3D/Camera3D/ItemRay
@onready var _ground_ray : RayCast3D = $GroundDetect
@onready var _menu : Control = $"../Menus"
@onready var _ground_pos : Vector3 = Vector3(0, 0, 0)
@onready var _last_subscene : int = 0
# Keeps track if the turret gui is displaying or not
@onready var _displaying_turret_gui : bool = false
# Keep track of the gui being displayed
@onready var _current_turret_gui : Control
@onready var _camera : Camera3D = $CameraPivot/SpringArm3D/Camera3D

# Preload all items (Might be a better way to do this)
@onready var _turret_gui = preload("res://SceneObjs/info_upgrade_gui.tscn")
@onready var _bomb_spawner = preload("res://SceneObjs/bomb_spawner.tscn")
@onready var _grapple_spawner = preload("res://SceneObjs/grapple_spawner.tscn")
@onready var _turret_spawner = preload("res://SceneObjs/turret_spawner.tscn")


@export var item_cooldown_time : float = 0.2
@export var debug:bool = false
@export var give_all_items : bool = false

func _ready() -> void:
	# force health to refresh
	_taskbar_containers = $GUI/TaskBar/HBoxContainer.get_children()
	change_health(0)
	_spawn_with_all_items()
	_init_taskbar()
	return
	
func _process(delta: float) -> void:
	_item_timer += delta
	trigger_enemy_info()
	_taskbar_scrolling()
	_upgrade_hover_ui()

func _physics_process(delta: float) -> void:
	_enter_vehicle_cooldown += delta
	_update_ground_pos()
	handle_pausing()
	enter_vehicle()
	exit_vehicle()
	while_driving()
	if !_in_vehicle:
		movement_processing(delta)
	pickup_and_lockon(delta)
	use_item()
	debug_aim()

# Displays UI for entering vehicle and handles user input and controller handover to vehicle script
func enter_vehicle() -> void:
	# Handles user input for transfering controls over to vehicle mode
	if _can_enter_vehicle and Input.is_action_just_pressed("Interact") and !_in_vehicle and _enter_vehicle_cooldown > INTERACT_COOLDOWN_TIME:
		var vehicle_detect = $CharacterAreaDetect.get_overlapping_areas()
		if vehicle_detect.size() > 0:
			var vehicle = vehicle_detect[0].get_parent()
			_last_vehicle_entered = vehicle
			vehicle._vehicle_occupied = true
			_enter_vehicle_cooldown = 0
			_in_vehicle = true
			vehicle_entered.emit(self)
			transfer_cam_to_vehicle.emit(_vehicle_info)
		
func exit_vehicle() -> void:
	if _in_vehicle and Input.is_action_just_pressed("Interact") and _enter_vehicle_cooldown > INTERACT_COOLDOWN_TIME && _last_vehicle_entered != null:
			_last_vehicle_entered._vehicle_occupied = false
			_enter_vehicle_cooldown = 0
			_in_vehicle = false
			vehicle_exited.emit()
			transfer_cam_to_player.emit(self)
		
func while_driving() -> void:
	if _last_vehicle_entered != null && _in_vehicle:
		global_position = _last_vehicle_entered.global_position

# Handles user input and player direction / cardinal movement/jumping
func movement_processing(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.aaada
	# As good practice, you should replace UI actions with custom gameplay actions.
	var cam_right = Vector3.RIGHT
	var cam_back = Vector3.BACK
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	#var direction := (transform.basis * Vector3(input_dir.x * (cam_left + cam_right).x, 0, input_dir.y * (cam_front + cam_back).z)).normalized()
	var direction := (transform.basis * (input_dir.x) * Vector3(cam_right)).normalized()
	direction += (transform.basis * (input_dir.y) * Vector3(cam_back)).normalized()

	var hvel = velocity
	hvel.y = 0

	var target = direction * MAX_SPEED
	var acceleration
	if direction.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.lerp(target, acceleration * delta)

	# Assign hvel's values back to velocity, and then move.
	velocity.x = hvel.x
	velocity.z = hvel.z

	# Non-acceleration based controls:
	#if direction:
		#
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
#
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		#
	move_and_slide()

func handle_pausing() -> void:
	# Pausing Functionality / Free mouse
	if Input.is_action_just_pressed("Escape"):
		#_paused = !_paused
		if _mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_paused = true
			_mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pause_menu.emit()
		elif _displaying_turret_gui:
			_paused = true
			_mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pause_menu.emit()
		else:
			_paused = false
			_camera.enable_movement = true
			_mouse_mode = Input.MOUSE_MODE_CAPTURED
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pause_menu.emit()
			
func debug_aim() -> Node3D:
	if !debug:
		_debug_ball.visible = false
	else:
		_debug_ball.visible = true
		var target_point = _target.get_collision_point()
		_debug_ball.global_position = target_point
		print_debug(_target.get_collider())
	return


func _on_character_area_detect_area_entered(area: Area3D) -> void:
	var vehicle = area.get_parent()
	if vehicle != null and vehicle is VehicleBody3D:
		print("vehicle detected | id:" + vehicle.to_string())
		_vehicle_info = vehicle
		_can_enter_vehicle = true
	else:
		print_debug("Error: Cannot grab vehicle info despite colliding with entrance")


func _on_character_area_detect_area_exited(_area: Area3D) -> void:
	_vehicle_info = null
	_can_enter_vehicle = false


#func _on_menus_gui_input(event: InputEvent) -> void:
	#print_debug(event)

# Recieves equip/unequip info from menu and applies to hotbar/character
func _bind_item(item_gui: Control) -> void:
	# Search each taskbar slot for duplicates
	for slot in _taskbar_containers:
		var item_rect = slot.find_child(item_gui.name, true, false)
		if item_rect != null:
			item_rect.free()
	var new_item_icon = item_gui.duplicate()
	_taskbar_containers[_current_taskbar_index].add_child(new_item_icon)
	for item in _inventory:
		if item.name == item_gui.name:
			_taskbar_items[item_gui.name] = item
	# Check for duplicate in taskbar
	#for i in range(9):
		#if _taskbar_rects[i].find_child(item_gui.name) != null:
			#_unbind_item(i)
	#new_item_icon.find_child("Equipped").visible = false
	pass
	# Refresh Inventory

# Clears the item from the hotbar	
func _unbind_item(taskbar_index : int) -> void:
	var target_name : String
	if _taskbar_containers[taskbar_index].get_children().size() > 2: target_name = _taskbar_containers[taskbar_index].get_child(2).name
	if target_name != null:
		print("removing " + target_name)
		_taskbar_items.erase(target_name)
	for control_node in _taskbar_containers[taskbar_index].get_children():
		if control_node is AspectRatioContainer:
			control_node.free()
	var inv_icon = _menu._item_slots.find_child(_taskbar_containers[taskbar_index].name)
	if inv_icon != null && inv_icon.find_child("Equipped") != null :
		inv_icon.find_child("Equipped").visible = false
	_menu._refresh_inventory()
	pass
	
func use_item() -> void:
	if !_paused && Input.is_action_just_pressed("Click") && _taskbar_rects[_current_taskbar_index].get_children().size() > 2 && !_displaying_turret_gui:
		var curr_item_name = _taskbar_rects[_current_taskbar_index].get_child(2).name
		_taskbar_items[curr_item_name].trigger()
		
	pass
	
	
# TODO: add more params for signals from enemies for debuffs and stuff
func change_health(delta: int) -> void:
	_health += delta
	# Cap health
	_health = min(_health, _max_health)
	# ded
	if _health <= 0:
		game_over()
	# Send info to the health GUI
	update_health_GUI.emit(_health, _max_health)
	
# Health will always be filled with more max health
func change_max_health(delta: int) -> void:
	_max_health += delta
	_health = _max_health
	update_health_GUI.emit(_health, _max_health)
	
func apply_knockback(source_pos : Vector3, strength : float) -> void:
	var dir : Vector3 = source_pos.direction_to(global_position)
	velocity = strength * dir
	
func trigger_enemy_info() -> void:
	var collision = _aim_ray.get_collider()
	# Enemy layer only
	if collision != null and collision.collision_layer == 4:
		collision.enable_info()
	
func _update_ground_pos():
	_ground_pos = _ground_ray.get_collision_point()
	
func game_over() -> void:
	pass

# Actually picking up the rigidbodies and moving them
func pickup_and_lockon(delta : float) -> void:
	var col : RigidBody3D = _item_ray.get_collider()
	# pickup
	if Input.is_action_just_pressed("RClick") and _held_item == null and col != null and col.collision_layer == 8:
		# Reassign held item
		#print_debug("picked up: " + to_string(_held_item))
		_held_item = col
		_held_item.being_held = true
		_held_item.hold_pos = _pickup_hold_location
		# Right object upward when picked up
		#var y_ang_vel : float = _held_item.angular_velocity.y
		#_held_item.angular_velocity.x = -_held_item.global_rotation.x
		#_held_item.angular_velocity.z = -_held_item.global_rotation.z
		#TODO: Fix righting
		#_held_item.rotation = Vector3(0, _held_item.rotation.y, 0)
	# put down
	elif Input.is_action_just_pressed("RClick") and _held_item != null:
		#print("put down: " + to_string(_held_item))
		_held_item.being_held = false
		_held_item = null
	if _held_item != null:
		_held_item.rotation = lerp(_held_item.rotation, _held_item.rotation.y * Vector3.UP, 0.05)
		_held_item.angular_velocity.z = -_held_item.rotation.z
	
# Adds item to inventory and updates the menu accordingly
func _pickup_item(item : Node3D) -> void:
	for inv_item in _inventory:
		# If item already exists, increment it
		if inv_item.name == item.name:
			inv_item.amount += 1
			_menu._refresh_inventory()
			# No need to instantiate more spawners than 1
			item.free()
			return
	_inventory.append(item)
	_item_spawn_location.add_child(item)
	# Make the GUI elements invisible
	item.find_child("GUI").visible = false
	_menu._refresh_inventory()

func _spawn_with_all_items() -> void:
	_pickup_item(_bomb_spawner.instantiate())
	_pickup_item(_grapple_spawner.instantiate())
	_pickup_item(_turret_spawner.instantiate())

# TODO: Find a way to make this use event instead of direct input?
func _taskbar_scrolling() -> void:
	if Input.is_action_just_released("ScrollDown"):
		# Clear equip sprite from prev index
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = false
		# Move index
		_current_taskbar_index -= 1
		if _current_taskbar_index < 0:
			_current_taskbar_index = 8
		# Reveal equip sprite for curr index of taskbar
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = true
		#_currently_idleing = false
		
	if Input.is_action_just_released("ScrollUp"):
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = false
		_current_taskbar_index += 1
		if _current_taskbar_index > 8:
			_current_taskbar_index = 0
		_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = true
		#_currently_idleing = false
	#_current_hovered_item_name = _player._taskbar_items[_current_taskbar_index]

func _init_taskbar() -> void:
	_taskbar_rects[_current_taskbar_index].find_child("Equipped").visible = true

# Only to be ran at ready, preloads all starter items and assigns them to player
func _init_items() -> void:
	# Load the items
	_bomb_spawner = preload("res://SceneObjs/bomb_spawner.tscn")
	_grapple_spawner = preload("res://SceneObjs/grapple_spawner.tscn")
	_turret_spawner = preload("res://SceneObjs/turret_spawner.tscn")
	
func _upgrade_hover_ui() -> void:
	var col = _aim_ray.get_collider()
	# Trigger gui when hovering but dont free mouse
	if col != null && col.collision_layer == 8 && !_displaying_turret_gui && !_paused:
		_current_turret_gui = _turret_gui.instantiate()
		get_tree().root.add_child(_current_turret_gui)
		_current_turret_gui.init(col)
		for perk in _current_turret_gui._tree.get_children():
			perk._turret = col
		_displaying_turret_gui = true
		# Initialize the GUI
	# Delete GUI when the player has the GUI up already and the game is puased or focus lost on turret
	if (col == null || col.collision_layer != 8 || _paused) && _displaying_turret_gui:
		_current_turret_gui.queue_free()
		_displaying_turret_gui = false
		# If exited with e press, recapture mouse
		if !_paused:
			_mouse_mode = Input.MOUSE_MODE_CAPTURED
			Input.mouse_mode = _mouse_mode
			_camera.enable_movement = true
		# If exited with pause, keep mouse visible
		else: 
			_mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.mouse_mode = _mouse_mode
			_camera.enable_movement = false
	# Handle edit prompt
	if col != null && _displaying_turret_gui && Input.is_action_just_pressed("EItem"):
		if _mouse_mode == Input.MOUSE_MODE_VISIBLE:
			_mouse_mode = Input.MOUSE_MODE_CAPTURED
			_camera.enable_movement = true
		else:
			_mouse_mode = Input.MOUSE_MODE_VISIBLE
			_camera.enable_movement = false
		Input.mouse_mode = _mouse_mode
		#_current_turret_gui.mouse_filter = 1
		print("Click")
