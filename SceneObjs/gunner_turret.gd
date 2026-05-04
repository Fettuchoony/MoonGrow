extends RigidBody3D

static var DETECT_TIME_INTERVAL : float = 0.1

@onready var _enemy_detection_area = $EnemyDetect
@onready var _enemy_detect_timer : float = 0
# [Enemy node, distance enemy is from end of path] useful for detecting front/back enemy
@onready var _current_reachable_enemies : Dictionary[Node3D, float]
# Attack mode is which enemy to attack in group: first, middle, last, strongest, weakest
@onready var _attack_mode : String = "first"
@onready var _debug_target_ball : MeshInstance3D = $DebugTargetBall

# These two variables are essential for every pickupable object
var being_held
var hold_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("The Gunner turret has spawned")
	being_held = false
	hold_pos = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	if DETECT_TIME_INTERVAL < _enemy_detect_timer && _enemy_detection_area.has_overlapping_bodies():
		for enemy in _enemy_detection_area.get_overlapping_bodies():
			updated_enemy_list[enemy] = enemy.path_length
		_current_reachable_enemies = updated_enemy_list
		_enemy_detect_timer = 0

func _turret_attack() -> void:
	var curr_target_path_length : float = INF
	var target : Node3D
	# First
	if _attack_mode == "first":
		for enemy in _current_reachable_enemies:
			if _current_reachable_enemies[enemy] < curr_target_path_length:
				target = enemy
	if target != null:
		_debug_target_ball.global_position = target.global_position
	

func change_turret_mode(mode : String) -> void:
	_attack_mode = mode
