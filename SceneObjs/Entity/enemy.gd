class_name Enemy extends RigidBody3D

static var HEALTH_SHOW_TIME : float = 1
static var REFRESH_FREQUENCY : float = 1


var _dmg_particle_spawner : Node3D
var _navigation_agent: NavigationAgent3D
var _health_bar : HealthBar

@onready var time : float = 0
@onready var health_sprite_timer : float = 0
@onready var heart_module_scene = preload("res://SceneObjs/UI/Scenes/HeartModule.tscn")
@onready var _enemy_phys_mat : PhysicsMaterial = preload("res://SceneObjs/Entity/Enemies/enemy_phys_mat.tres")
@onready var time_since_target_update : float = 0
@onready var time_since_last_hop : float = 0
@onready var player : CharacterBody3D = get_tree().root.get_child(0).find_child("MainPlayer")
@onready var player_cam : Camera3D = get_tree().root.get_child(0).find_child("Camera3D")
@onready var castle : Node3D = get_parent().find_child("Castle")
@onready var path_length : float = 0

# Set by the enemy
@onready var loot_table : Dictionary[Item, float]

@export var health : int = 6
@export var max_health : int = 10
@export var movement_speed: float = 3.0
@export var health_bar_y_pos : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_init_healthbar()
	physics_material_override = _enemy_phys_mat
	collision_layer = 4
	_setup_healthbar()
	_setup_dmg_particles()
	_setup_navigation()


func _physics_process(delta: float) -> void:	
	if _dmg_particle_spawner == null || _navigation_agent == null || _health_bar == null:
		printerr("Enemy: " + name + " is missing vital nav/health properties. Forgot to call super() in enemy's _ready func? 
		DMG Particle status: " + str(_dmg_particle_spawner) +
		"\nNAV Agent status: " + str(_navigation_agent) +
		"\nHealth Bar status: " + str(_health_bar))
	_adjust_target()
	#_update_healthbar()
	_update_navigation()
	time += delta
	health_sprite_timer += delta
	time_since_target_update += delta
	
#func _on_velocity_computed(safe_velocity: Vector3):
	#linear_velocity = safe_velocity

# Determines pathfinding behaviour of enemy
func _adjust_target() -> void :
	# Readjust path of enemies and updates length for the turrets to use to determine order
	if _navigation_agent != null && time_since_target_update > REFRESH_FREQUENCY:
		_navigation_agent.set_target_position(castle.global_position)
		time_since_target_update = 0
		path_length = _navigation_agent.get_path_length()



func enable_info() -> void:
	_health_bar.visible = true
	health_sprite_timer = 0


func change_health(delta: int) -> void:
	print(name + " took " + str(delta) + " dmg")
	_dmg_particle_spawner.trigger(delta)
	health += delta
	# Cap health
	health = min(health, max_health)
	#print(health)
	# ded
	if health <= 0:
		_drop_loot()
		queue_free()
		pass
	_health_bar.update_health_bar(health)


func apply_knockback(origin: Vector3, knockback_strength : float = 1.0) -> void:
	apply_impulse(knockback_strength * (1 / origin.distance_to(global_position)) * origin.direction_to(global_position))


func _update_navigation() -> void:
	if !is_instance_valid(_navigation_agent):
		return
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(_navigation_agent.get_navigation_map()) == 0:
		return
	if _navigation_agent.is_navigation_finished():
		return

func _drop_loot() -> void:
	for item in loot_table:
		var chance = loot_table[item]
		if chance <= randf():
			var loot = Pickup.new(item)
			loot.global_position = global_position + Vector3(0.0, 0.5, 0.0)
			
func _setup_healthbar() -> void:
	if health_bar_y_pos == 0:
		push_warning("Enemy: " + name + " health bar pos is 0.0, probably clipping in enemy")
	_health_bar = HealthBar.new(max_health)
	add_child(_health_bar)
	_health_bar.position.y = health_bar_y_pos

func _setup_dmg_particles() -> void:
	_dmg_particle_spawner = DmgParticleSpawner.new()
	add_child(_dmg_particle_spawner)
	

func _setup_navigation() -> void:
	_navigation_agent = NavigationAgent3D.new()
	add_child(_navigation_agent)
	#_navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
