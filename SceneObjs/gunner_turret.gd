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
@onready var _head_pivot : Node3D = $TurretBase/HeadPivot
@onready var _up_ref : Node3D = $TurretBase/UpRef
@onready var _current_projectiles : Array[ProjectileSpawner]
@onready var target : Node3D

@onready var _menu : Control
@onready var ui : Control

# Probably change how this works eventually
@onready var turret_value : float = 1.0


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
	var ui_tscn = load("res://SceneObjs/info_upgrade_gui.tscn")
	ui = ui_tscn.instantiate()
	add_child(ui)
	ui.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if target != null:
		
		_head_pivot.look_at(target.global_position, _up_ref.global_position - global_position)
		#var target_rotation = (_head_pivot.global_position - target.global_position).normalized()
		#_head_pivot.global_rotation = lerp(_head_pivot.global_rotation, angle, 0.02)

func _physics_process(delta: float) -> void:
	_enemy_detect_timer += delta
	_pickup_func()
	_enemy_detection()
	_turret_attack()
	

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
	for proj in _current_projectiles:
		if target != null && proj != null && !proj.invalid.visible:
			var fire_pos = _firing_point.global_position
			proj.fire(fire_pos, target)
		

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
	applied_upgrades.clear()
	_current_projectiles.clear()
	#_current_projectile = null
	var i : int = 0
	# iterate through the slots in the turret grabbing projectiles and normal modifiers
	for slot in ui.perk_slot_matrix.get_children():
		var curr_item : Item = slot.get_item_in_slot()
		if curr_item is ProjectileSpawner:
			applied_upgrades[i] = curr_item
			_current_projectiles.append(curr_item)
		
		if curr_item is ProjectileModifier:
			applied_upgrades[i] = curr_item
		i += 1
	
	# Disable all projectiles if theres more than one, can only be undone by special modifiers
	if _current_projectiles.size() > 1:
		for projectile in _current_projectiles:
			projectile.invalid.visible = true
	
	i = 0
	# Meta modifier loop, performed after because it mods the mods
	for slot in ui.perk_slot_matrix.get_children():
		var curr_item : Item = slot.get_item_in_slot()
		if curr_item is SpecialModifier:
			curr_item.trigger_special_effect(ui, i)
		i += 1
	
	
	# Visually updates ui with new stats and applys the upgrades to projectiles
	if _current_projectiles.size() > 0:
		print("Applying augments")
		for proj in _current_projectiles:
			proj.reset()
			# TODO: this only works under projectiles condition ie: This projectile only upgrades items in same row
			apply_augments_to_projectile(proj)
			ui.update_info(proj)
	else:
		ui.update_info(null)

func apply_augments_to_projectile(proj : ProjectileSpawner) -> void:
	# TODO: loop through dictionary with int i so you can pass slot number and grid height to projectile
	# Projectile can then calculate if it should modify the object or not
	for augment in applied_upgrades.values():
		if augment is ProjectileModifier:
			augment.modify_proj(proj)
