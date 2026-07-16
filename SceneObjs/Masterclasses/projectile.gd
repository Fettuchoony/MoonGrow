class_name Projectile extends RigidBody3D

# TODO: Move this to a prent class for all spawned projectiles
# THIS IS VERY IMPORTANT: holds a copy of the spawner that created it, which holds all effect data
@onready var projectile_effect : ProjectileSpawner

## How long the projectile exists in seconds
@export var lifetime : float = 3

@export var knockback_strength : float = 1
@export var throw_strength : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func flight_behaviour(target_enemy : Enemy) -> void:
	var target_pos : Vector3 = target_enemy.global_position
	look_at(target_pos)
	var velocity = 1
	var difference = target_pos - global_position
	# TODO: I think target and fire pos should be swapped but this works better idk
	var t = (-velocity - sqrt(abs(pow(velocity, 2.0) - 4.0 * -4.8 * (target_pos.y - global_position.y)))) / (2.0 * -4.8)
	var future_enemy_pos : Vector3 = target_pos + (t * target_enemy.linear_velocity)
	#_debug_target_ball.global_position = future_enemy_pos
	var future_t = (-velocity - sqrt(abs(pow(velocity, 2.0) - 4.0 * -4.8 * (target_pos.y - global_position.y)))) / (2.0 * -4.8)
	lifetime = future_t
	apply_impulse(throw_strength * Vector3(difference.x / future_t, velocity, difference.z/future_t))
