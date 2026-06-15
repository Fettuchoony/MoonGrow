class_name ProjectileSpawner extends Augment
# Determines the projectile of the turret, TODO: only one allowed?

# Base: Projectile's base stats with no augmentation, NEVER MUTATED
@export var base_dmg : int = 1
@export var base_firerate : float = 1.0

# These are added to corresponding bases and passed to every initialized projectile
@onready var added_dmg : int = 0
@onready var added_firerate : float = 0.0

# Default projectile is bullet TODO: For now?
@export var projectile : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)

func apply_effects_to_enemy(enemy : Enemy) -> void:
	enemy.change_health(-base_dmg - added_dmg)

func get_dmg() -> int:
	return base_dmg + added_firerate

func get_firerate() -> float:
	return base_firerate + added_firerate

func fire(fire_pos : Vector3, target_pos : Vector3) -> void:
	var proj_obj : RigidBody3D = projectile.instantiate()
	# Add copy of spawner just for the stats to carry into projectile
	var self_duplicate : ProjectileSpawner = self.duplicate()
	self_duplicate.visible = false
	proj_obj.add_child(self_duplicate)
	print(get_tree().root)
	get_tree().root.get_child(0).add_child(proj_obj)
	proj_obj.global_position = fire_pos
	proj_obj.flight_behaviour(target_pos)

# This exists to be overriden by specific projectile
func flight_behaviour(target_pos : Vector3) -> void:
	print("Cannot find prjectile " + name + " flight behaviour, falling back to default")
