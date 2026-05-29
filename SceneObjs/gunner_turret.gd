extends RigidBody3D

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
@onready var target : Node3D

@export var dmg : int = 1
@export var firing_rate : float = 0.5


# These two variables are essential for every pickupable object
var being_held
var hold_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	being_held = false
	hold_pos = global_position


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
	if target != null && _firing_timer > firing_rate:
		var target_pos = target.find_child("TargetPoint").global_position
		var bullet = _bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		# Set projectile damage
		bullet._dmg = dmg
		var fire_pos = _firing_point.global_position
		bullet.global_position = _firing_point.global_position
		bullet.look_at(target_pos)
		var velocity = 1
		var difference = target_pos - fire_pos
		# TODO: I think target and fire pos should be swapped but this works better idk
		var t = (-velocity - sqrt(abs(pow(velocity, 2.0) - 4.0 * -4.8 * (target_pos.y - fire_pos.y)))) / (2.0 * -4.8)
		var future_enemy_pos : Vector3 = target_pos + (t * target.linear_velocity)
		_debug_target_ball.global_position = future_enemy_pos
		var future_t = (-velocity - sqrt(abs(pow(velocity, 2.0) - 4.0 * -4.8 * (target_pos.y - fire_pos.y)))) / (2.0 * -4.8)
		bullet.apply_impulse(Vector3(difference.x / future_t, velocity, difference.z/future_t))
		_firing_timer = 0 
		
		
	

func change_turret_mode(mode : String) -> void:
	_attack_mode = mode
