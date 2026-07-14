class_name Enemy extends RigidBody3D

static var HEALTH_SHOW_TIME : float = 1
static var REFRESH_FREQUENCY : float = 1

@onready var _dmg_particle_spawner : Node3D = $DmgParticleSpawner

@onready var time : float = 0
@onready var health_sprite : Sprite3D = $Sprite3D
@onready var health_sprite_timer : float = 0
@onready var heart_module_scene = preload("res://SceneObjs/UI/Scenes/HeartModule.tscn")
@onready var health_bar : HBoxContainer = $"Sprite3D/EnemyViewport/Health Bar/HBoxContainer"
@onready var time_since_target_update : float = 0
@onready var time_since_last_hop : float = 0
@onready var player : CharacterBody3D = $"../../../../MainPlayer"
@onready var player_cam : Camera3D = $"../../../../MainPlayer/CameraPivot/SpringArm3D/Camera3D"
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var castle : Node3D = $"../../../Castle"
@onready var path_length : float = 0

@export var health : int = 6
@export var max_health : int = 10
@export var movement_speed: float = 3.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get a good reference to enemy velocty?
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_init_healthbar()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:	
	_adjust_target()
	_update_healthbar()
	_update_navigation()
	time += delta
	health_sprite_timer += delta
	time_since_target_update += delta
	
func _on_velocity_computed(safe_velocity: Vector3):
	linear_velocity = safe_velocity

# Determines pathfinding behaviour of enemy
func _adjust_target() -> void :
	# Readjust path of enemies and updates length for the turrets to use to determine order
	if time_since_target_update > REFRESH_FREQUENCY:
		navigation_agent.set_target_position(castle.global_position)
		time_since_target_update = 0
		path_length = navigation_agent.get_path_length()

func _init_healthbar() -> void:
	var i : int = 0
	while i < max_health:
		var heart = heart_module_scene.instantiate()
		heart.get_child(0).visible = false
		heart.get_child(0).get_child(0).visible = false
		health_bar.add_child(heart)
		i += 2

func enable_info() -> void:
	health_sprite.visible = true
	health_sprite_timer = 0

func health_gui_update(updated_health: int, updated_max: int) -> void:
	var temp_health : int = health
	var temp_max : int = max_health
	for heart_module in health_bar.get_children():
		var half : TextureRect = heart_module.get_child(0)
		var full : TextureRect = half.get_child(0)
		if temp_max > 0:
			heart_module.visible = true
		else:
			heart_module.visible = false
		if temp_health > 1:
			half.visible = true
			full.visible = true
		elif temp_health == 1:
			half.visible = true
			full.visible = false
		else:
			half.visible = false
			full.visible = false
		temp_max -= 2
		temp_health -= 2

func change_health(delta: int) -> void:
	print(name + " took " + str(delta) + " dmg")
	_dmg_particle_spawner.trigger(delta)
	health += delta
	# Cap health
	health = min(health, max_health)
	#print(health)
	# ded
	if health <= 0:
		queue_free()
		pass
	# Send info to the health GUI
	health_gui_update(health, max_health)

func apply_knockback(origin: Vector3, knockback_strength : float = 1.0) -> void:
	apply_impulse(knockback_strength * (1 / origin.distance_to(global_position)) * origin.direction_to(global_position))

func _update_healthbar() -> void:
	if health_sprite_timer > HEALTH_SHOW_TIME:
		health_gui_update(6, 10)
		health_sprite.visible = false

func _update_navigation() -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return
