class_name Bullet extends Projectile

@onready var damage_hitbox = $DamageArea

var _dmg_area : Area3D
var _death_time : float
var _time_alive : float
var _dmg : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_dmg_area = $DamageArea
	_time_alive = 0
	# Set by turret, default to 5
	_death_time = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Check for entitys to damage (layer 10)
	var dmg_collisions : Array[Node3D] = damage_hitbox.get_overlapping_bodies()
	for col in dmg_collisions:
		# Apply effects of the passed spawner
		if projectile_effect != null:
			projectile_effect.apply_effects_to_enemy(col)
		# Knockback
		if col is RigidBody3D:
			col.apply_knockback(global_position, knockback_strength)
			queue_free()
	_time_alive += delta
	if _time_alive > _death_time: queue_free()
