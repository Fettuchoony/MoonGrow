extends RigidBody3D

@onready var enemy_detection = $EnemyDetect

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
	if enemy_detection.has_overlapping_bodies(): print("enemy detected")
	if being_held:
		gravity_scale = 0
		linear_velocity = global_position.distance_to(hold_pos.global_position) * global_position.direction_to(hold_pos.global_position)
	else:
		gravity_scale = 1
