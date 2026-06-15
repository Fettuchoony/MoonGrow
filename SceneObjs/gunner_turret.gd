extends RigidBody3D
class_name Turret

static var DETECT_TIME_INTERVAL : float = 0.01
static var COLLOQUIAL_NAME : String = "Gunner Turret"

@onready var _enemy_detection_area = $EnemyDetect
@onready var _enemy_detect_timer : float = 0
# [Enemy node, distance enemy is from end of path] useful for detecting front/back enemy
@onready var _current_reachable_enemies : Dictionary[Node3D, float]
# Attack mode is which enemy to attack in group: first, middle, last, strongest, weakest
@onready var _attack_mode : String = "first"
@onready var _debug_target_ball : MeshInstance3D = $DebugTargetBall
@onready var _bullet_scene = preload("res://SceneObjs/test_bullet.tscn")
@onready var _firing_point : Node3D = $TurretBase/HeadPivot/TurretHead/FiringPoint
@onready var _firing_timer : float = 0
@onready var _head_pivot : Node3D = $TurretBase/HeadPivot
@onready var _up_ref : Node3D = $TurretBase/UpRef
@onready var _current_projectile : ProjectileSpawner
@onready var target : Node3D

@onready var _menu : Control
@onready var ui : Control

# Added to by perk when clicked, used to populate upgrade gui with equip when created and avoid repeats
# Key : Slot #, Value : Upgrade
@onready var applied_upgrades : Dictionary[int, Control]


# These two variables are essential for every pickupable object
var being_held
var hold_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	being_held = false
	hold_pos = global_position
	print(get_parent())
	var ui_tscn = preload("res://SceneObjs/info_upgrade_gui.tscn")
	ui = ui_tscn.instantiate()
	add_child(ui)
	ui.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_handle_upgrade_input()
	if target != null:
		
		_head_pivot.look_at(target.global_position, _up_ref.global_position - global_position)
		#var target_rotation = (_head_pivot.global_position - target.global_position).normalized()
		#_head_pivot.global_rotation = lerp(_head_pivot.global_rotation, angle, 0.02)

func _physics_process(delta: float) -> void:
	_enemy_detect_timer += delta
	_pickup_func()
	_enemy_detection()
	_turret_attack()
	_firing_timer += delta
	

# This makes the object pickupable by the player, needs to be added to every appropriate obj
func _pickup_func() -> void:
	if being_held:
		gravity_scale = 0
		linear_velocity = global_position.distance_to(hold_pos.global_position) * global_position.direction_to(hold_pos.global_position)
	else:
		gravity_scale = 1

# Updates enemy list, adjust speed with DETECT_TIME_INTERVAL
func _enemy_detection() -> void:
	var updated_enemy_list : Dictionary[Node3D, float]
	_current_reachable_enemies.clear()
	if DETECT_TIME_INTERVAL < _enemy_detect_timer && _enemy_detection_area.has_overlapping_bodies():
		for enemy in _enemy_detection_area.get_overlapping_bodies():
			updated_enemy_list[enemy] = enemy.path_length
		_current_reachable_enemies = updated_enemy_list
		_enemy_detect_timer = 0

func _turret_attack() -> void:
	var curr_target_path_length : float
	# Must be initialized different depending on mode for sorting
	if _attack_mode == "first":
		curr_target_path_length = INF
	elif _attack_mode == "last":
		curr_target_path_length = -INF
	# attack mode determines which enemy is targeted
	for enemy in _current_reachable_enemies:
		if _attack_mode == "first":
			if _current_reachable_enemies[enemy] < curr_target_path_length:
				target = enemy
				curr_target_path_length = enemy.path_length
		if _attack_mode == "last":
			if _current_reachable_enemies[enemy] > curr_target_path_length:
				target = enemy
				curr_target_path_length = enemy.path_length
	# Actually firing
	if target != null && _current_projectile != null && _firing_timer > _current_projectile.get_firerate():
		var target_pos = target.find_child("TargetPoint").global_position
		var fire_pos = _firing_point.global_position
		_current_projectile.fire(fire_pos, target_pos)
		#bullet.global_position = _firing_point.global_position
		#bullet.look_at(target_pos)
		#var velocity = 1
		#var difference = target_pos - fire_pos
		## TODO: I think target and fire pos should be swapped but this works better idk
		#var t = (-velocity - sqrt(abs(pow(velocity, 2.0) - 4.0 * -4.8 * (target_pos.y - fire_pos.y)))) / (2.0 * -4.8)
		#var future_enemy_pos : Vector3 = target_pos + (t * target.linear_velocity)
		#_debug_target_ball.global_position = future_enemy_pos
		#var future_t = (-velocity - sqrt(abs(pow(velocity, 2.0) - 4.0 * -4.8 * (target_pos.y - fire_pos.y)))) / (2.0 * -4.8)
		#bullet.apply_impulse(Vector3(difference.x / future_t, velocity, difference.z/future_t))
		_firing_timer = 0 
		
func _handle_upgrade_input() -> void:
	if _menu != null:
		var slot_num = 0
		for slot in ui._perk_slots:
			# Where all the augments sit in each slot so theyre easily referenced as child 0
			var slot_augment_spot = slot.find_child("Augment")
			var slot_rect = slot.get_rect()
			slot_rect.position = slot.global_position
			var cursor_item = _menu._cursor_item
			# Hovering func
			if slot_rect.has_point(_menu.get_screen_transform() * _menu.get_local_mouse_position()):
				slot.find_child("Hover").visible = true
			else: 
				slot.find_child("Hover").visible = false
			var already_toggled : bool = false
			
			# Flags
			var clicked : bool = Input.is_action_just_pressed("Click")
			var within_rect : bool = slot_rect.has_point(_menu.get_screen_transform() * _menu.get_local_mouse_position())
			var cursor_holding_item : bool = cursor_item.get_child_count() != 0
			var held_item_is_augment : bool = false
			var held_item_is_projectile : bool = false
			if cursor_holding_item: 
				held_item_is_augment = cursor_item.get_child(0) is Augment
				cursor_item.get_child(0).set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_FULL_RECT)
				held_item_is_projectile = cursor_item.get_child(0) is ProjectileSpawner
			var slot_occupied : bool = slot.get_child(2).get_child_count() != 0
			
			# ADD CASE
			# Cursor item set, put on empty space
			if clicked && within_rect && cursor_holding_item && held_item_is_augment && !slot_occupied:
				print_debug("Adding augment: " + cursor_item.get_child(0).name + " to " + ui._turret_name.text)
				var grab_item = cursor_item.get_child(0)
				applied_upgrades[slot_num] = grab_item
				grab_item.reparent(slot_augment_spot)
				grab_item.global_position = slot.global_position
				already_toggled = true
				if held_item_is_projectile: _current_projectile = grab_item
				update_turret_stats()
						
			# REMOVE CASE
			# No cursor item, but augment clicked and slot isnt empty
			if clicked && within_rect && !cursor_holding_item && slot_occupied:
				var grab_item = slot.get_child(2).get_child(0)
				applied_upgrades.erase(slot_num)
				grab_item.reparent(cursor_item)
				grab_item.global_position = cursor_item.global_position
				if grab_item is ProjectileSpawner: _current_projectile = null
				update_turret_stats()
			
			# SWAP CASE
			# Cursor item set, put on occupied space
			if clicked && within_rect && cursor_holding_item && slot_occupied:
				var cursor_augment = cursor_item.get_child(0)
				var slot_augment = slot.get_child(2).get_child(0)
				_current_projectile = null
				if cursor_augment is ProjectileSpawner: _current_projectile = cursor_augment
				applied_upgrades[slot_num] = cursor_augment
				slot_augment.global_position = cursor_item.global_position
				cursor_item.global_position = slot_augment_spot.global_position
				cursor_augment.reparent(slot_augment_spot)
				slot_augment.reparent(cursor_item)
				update_turret_stats()
			
			slot_num += 1

func change_turret_mode(mode : String) -> void:
	_attack_mode = mode

# On augment change, update turret with new stats
func update_turret_stats() -> void:
	#print("updating turret gui to reflect stat change")
	#if _current_projectile != null:
		## Modify the projectile
		#for augment in applied_upgrades.values():
			#if augment is ProjectileModifier:
				#dmg += augment.delta_dmg
				#print(dmg)
			#if augment is ProjectileSpawner:
				#_current_projectile = augment
				
	# Visually updates ui with new stats
	if _current_projectile != null:
		ui.update_info(_current_projectile)

func apply_augments_to_projectile(proj : ProjectileSpawner) -> void:
	for augment in applied_upgrades.values():
		if augment is ProjectileModifier:
			augment.modify_proj(proj)
