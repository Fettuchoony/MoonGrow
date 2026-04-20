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
@onready var _blank_item : TextureRect = $BlankItem
@onready var _pickup_hold_location : Node3D = $PickupPivot/ItemHoverSpot
@onready var _held_item : RigidBody3D = null
@onready var _can_enter_vehicle:bool = false
@onready var _in_vehicle:bool = false
@onready var _mouse_mode:int = 2
# Vehicle entrance should be the only collision option on layer 9
@onready var _vehicle_info = null
@onready var _enter_vehicle_cooldown:float = 0
# TODO: Create item list/map of all names, items ID by exact string (lowercase)
# This is a list of all items and if they are equipped
@onready var _taskbar_items : Array[Node3D]
@onready var _taskbar_containers : Array[Node]
@onready var _taskbar_index : int = 0
@onready var _inventory : Array[Node3D]
@onready var _paused : bool
@onready var _item_timer: float = 0
@onready var _aim_ray : RayCast3D = $CameraPivot/SpringArm3D/Camera3D/PlayerRay
@onready var _item_ray : RayCast3D = $CameraPivot/SpringArm3D/Camera3D/ItemRay
@onready var _ground_ray : RayCast3D = $GroundDetect
@onready var _menu : Control = $"../Menus"
@onready var _ground_pos : Vector3 = Vector3(0, 0, 0)
@onready var _last_subscene : int = 0

# Preload all items (Might be a better way to do this)
@onready var _bomb_spawner = preload("res://SceneObjs/bomb_spawner.tscn")
@onready var _grapple_spawner = preload("res://SceneObjs/grapple_spawner.tscn")
@onready var _turret_spawner = preload("res://SceneObjs/turret_spawner.tscn")


@export var item_cooldown_time : float = 0.2
@export var debug:bool = false
@export var give_all_items : bool = false

func _ready() -> void:
	# force health to refresh
	_taskbar_items = [null,null,null,null,null,null,null,null]
	_taskbar_containers = $GUI/TaskBar/HBoxContainer.get_children()
	change_health(0)
	_spawn_with_all_items()
	_initialize_taskbar()
	return
	
func _process(delta: float) -> void:
	_item_timer += delta
	use_item()
	trigger_enemy_info()

func _physics_process(delta: float) -> void:
	_enter_vehicle_cooldown += delta
	_update_ground_pos()
	handle_pausing()
	enter_vehicle()
	exit_vehicle()
	if !_in_vehicle:
		movement_processing(delta)
	pickup_and_lockon()
	use_item()
	debug_aim()

# Displays UI for entering vehicle and handles user input and controller handover to vehicle script
func enter_vehicle() -> void:
	# TODO: UI implementation "Press F to enter vehicle"
	
	# Handles user input for transfering controls over to vehicle mode
	if _can_enter_vehicle and Input.is_action_just_pressed("Interact") and !_in_vehicle and _enter_vehicle_cooldown > INTERACT_COOLDOWN_TIME:
		print_debug("Player controller side camera transfer initiated")
		_enter_vehicle_cooldown = 0
		_in_vehicle = true
		vehicle_entered.emit(self)
		transfer_cam_to_vehicle.emit(_vehicle_info)
		
func exit_vehicle() -> void:
	if _in_vehicle and Input.is_action_just_pressed("Interact") and _enter_vehicle_cooldown > INTERACT_COOLDOWN_TIME:
		_enter_vehicle_cooldown = 0
		_in_vehicle = false
		vehicle_exited.emit()
		transfer_cam_to_player.emit(self)
		

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
		_paused = !_paused
		if _mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pause_menu.emit()
		else:
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


func _on_character_area_detect_area_exited(area: Area3D) -> void:
	_vehicle_info = null
	_can_enter_vehicle = false


#func _on_menus_gui_input(event: InputEvent) -> void:
	#print_debug(event)

# Recieves equip/unequip info from menu and applies to hotbar/character
func _bind_item(item_gui: Control) -> void:
	# Load textures onto hotbar
	# Make sure our references are not lost
	#if _taskbar_containers != null and target != null and target.is_passive == false:
		#_taskbar_items[slot_num] = target.name
		## Pass slot info to object script
		#target.equipped_on_slot_num = slot_num
		## Texture inventory slot
		#var item_tex = _taskbar_containers[slot_num].find_child("ItemTexture")
		#if item_tex != null:
			#item_tex.texture = target.texture
		#else:
			#print("Error: item with no texture was added to taskbar?")
		## Set item status to active, checked on refresh
		#_items_equipped[target.name] = true
		## Set texture filter to nearest to avoid blur
		#_taskbar_containers[slot_num].find_child("TextureRect").set_texture_filter(1) 
	## for primary and non QER items
	#elif slot_num == -1 and not target.is_primary:
		#target.equipped_on_slot_num = -1
		#_items_equipped[target.name] = true
		#print(target.name)
	#elif target.is_primary == true:
		#_primary = target.name
		#target.equipped_on_slot_num = -1
		#_items_equipped[target.name] = true
	#_taskbar_items[_taskbar_index] = item
	#_taskbar_containers[_taskbar_index] = item.find_child("Icon")
	#_taskbar_items[_taskbar_index].add_child(item_gui)
	_taskbar_containers[_taskbar_index].add_child(item_gui.duplicate())
	pass
	# Refresh Inventory

# Clears the item from the hotbar	
func _unbind_item(target: TextureRect) -> void:
	#if target.equipped_on_slot_num != -1:
		## Clear GUI of sprite
		#_taskbar_containers[target.equipped_on_slot_num].find_child("ItemTexture").texture = _blank_item
		## Clear from internal checker
		#_taskbar_items[target.equipped_on_slot_num] = ""
		## Clear from equip list
		#_items_equipped[target.name] = false
		## Clear item's tracking of its slot number
		#target.equipped_on_slot_num = -1
	#elif target.equipped_on_slot_num == -1:
		## Clear from equip list
		#_items_equipped[target.name] = false
	pass
	
func use_item() -> void:
	#var indx = _menu._current_taskbar_index
	#if _taskbar_items[indx] != "":
		#trigger_item_idle.emit(_taskbar_items[indx])
	#if (Input.is_action_just_pressed("Click")) and not _paused and _item_timer > item_cooldown_time:
		## Checks which item is selected in the taskbar
		#var curr_item : ItemSlot = _menu.find_child(_taskbar_items[indx])
		#if curr_item == null:
			#print("No item selected")
		#else :
			#curr_item.use_item(_taskbar_items[indx], _item_spawn_location)
		#_item_timer = 0
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
	
func pickup_and_lockon() -> void:
	var col : RigidBody3D = _item_ray.get_collider()
	# pickup
	if Input.is_action_just_pressed("RClick") and _held_item == null and col != null and col.collision_layer == 8:
		# Reassign held item
		#print_debug("picked up: " + to_string(_held_item))
		_held_item = col
		_held_item.being_held = true
		_held_item.hold_pos = _pickup_hold_location
	# put down
	elif Input.is_action_just_pressed("RClick") and _held_item != null:
		#print("put down: " + to_string(_held_item))
		_held_item.being_held = false
		_held_item = null

func _initialize_taskbar() -> void:
	pass

# Adds item to inventory and updates the menu accordingly
func _pickup_item(item : Node3D) -> void:
	for inv_item in _inventory:
		# If item already exists, increment it
		if inv_item.name == item.name:
			inv_item.amount += 1
			_menu._refresh_inventory()
			return
	_inventory.append(item)
	_menu._refresh_inventory()

func _spawn_with_all_items() -> void:
	_pickup_item(_bomb_spawner.instantiate())
	_pickup_item(_grapple_spawner.instantiate())
	_pickup_item(_turret_spawner.instantiate())
