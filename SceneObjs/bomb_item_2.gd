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
	print("Firing bomb")
	# 1.2 is the camera angle max rotation in x
	throw_strength *= camera_tilt + 1.2
	var dir : Vector3 = player.global_position.direction_to(global_position)
	dir = dir.normalized()
	apply_impulse(throw_strength * dir)


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
		col.change_health(-1)
		var distance : float = col.global_position.distance_to(global_position)
		var knockback_scalar : float = knockback_strength / (distance + 0.1)
		var knockback_dir : Vector3 = global_position.direction_to(col.global_position)
		if knockback_dir.y > 1:
			knockback_dir.y = 1
		# Give it some upward velocity
		
		# Knockback
		# Scale knockback relevant to how close the bomb is
		if col is RigidBody3D:
			col.apply_knockback(global_position)
		elif col is CharacterBody3D:
			col.velocity += knockback_scalar * knockback_dir
	var explosion = explosion_fog.instantiate()
	explosion.position = position
	main.add_child(explosion)
	# Delete the bomb
	queue_free()

func flight_behaviour(target_pos : Vector3) -> void:
	print("bomb projectile flight!")
