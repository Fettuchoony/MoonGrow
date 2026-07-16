class_name Bomb extends Projectile

# This is to make the explosion a child of the global scene and be able to delete the bomb

@onready var main : Node3D = $".."
# In degrees
@onready var camera_tilt = $"../MainPlayer/CameraPivot/SpringArm3D/Camera3D"._camera_pivot.rotation.x
@onready var player : CharacterBody3D = $"../MainPlayer"
@onready var age: float = 0
@onready var wall_delete_hitbox : Area3D = $WallDeleteBox
@onready var damage_hitbox : Area3D = $DamageBox
@onready var explosion_fog  = preload("res://SceneObjs/Bomb/explosion_bomb.tscn")


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
