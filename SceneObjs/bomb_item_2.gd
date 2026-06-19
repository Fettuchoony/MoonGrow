class_name Bomb extends RigidBody3D

# This is to make the explosion a child of the global scene and be able to delete the bomb

@onready var main : Node3D = $".."
# In degrees
@onready var camera_tilt = $"../MainPlayer/CameraPivot/SpringArm3D/Camera3D"._camera_pivot.rotation.x
@onready var player : CharacterBody3D = $"../MainPlayer"
@onready var age: float = 0
@onready var wall_delete_hitbox : Area3D = $WallDeleteBox
@onready var damage_hitbox : Area3D = $DamageBox
@onready var explosion_fog  = preload("res://SceneObjs/explosion_bomb.tscn")

# THIS IS VERY IMPORTANT: holds a copy of the spawner that created it, which holds all effect data
@onready var projectile_effect : ProjectileSpawner

@export var lifetime : float = 3
@export var knockback_strength : float = 1
@export var throw_strength : float = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	age += delta
	# Blow up
	if age > lifetime:
		explode()

func explode() -> void:
	# Check for bombable walls (layer 11)
	var wall_collisions : Array[Node3D] = wall_delete_hitbox.get_overlapping_bodies()
	for col in wall_collisions:
		col.queue_free()
	# Check for entitys to damage (layer 10)
	var dmg_collisions : Array[Node3D] = damage_hitbox.get_overlapping_bodies()
	for col in dmg_collisions:
		# Apply effects of the passed spawner
		if projectile_effect != null:
			projectile_effect.apply_effects_to_enemy(col)
		# Knockback
		if col is RigidBody3D:
			col.apply_knockback(global_position, knockback_strength)
		#elif col is CharacterBody3D:
			#col.velocity += knockback_scalar * knockback_dir
	var explosion = explosion_fog.instantiate()
	explosion.position = position
	main.add_child(explosion)
	# Delete the bomb
	queue_free()

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
