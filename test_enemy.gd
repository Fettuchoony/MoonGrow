# https://docs.godotengine.org/en/4.6/tutorials/navigation/navigation_using_navigationagents.html
extends RigidBody3D


static var REFRESH_FREQUENCY : float = 1
static var HOP_FREQUENCY : float = 2
static var HOP_INTENSITY : float = 4
static var HEALTH_SHOW_TIME : float = 1

@export var movement_speed: float = 3.0
@export var charge_attack_radius: float = 5
@export var chargeup_time : float = 5

# Theres some parabola magic going on here
@onready var time : float = 0
@onready var health : int = 6
@onready var max_health : int = 10
@onready var health_sprite : Sprite3D = $Sprite3D
@onready var health_sprite_timer : float = 0
@onready var heart_module_scene = preload("res://SceneObjs/heart_module.tscn")
@onready var health_bar : HBoxContainer = $"Sprite3D/EnemyViewport/Health Bar/HBoxContainer"
@onready var hurt_zone : Area3D = $Area3D
@onready var time_since_target_update : float = 0
@onready var time_since_last_hop : float = 0
@onready var player : CharacterBody3D = $"../../../../MainPlayer"
@onready var player_cam : Camera3D = $"../../../../MainPlayer/CameraPivot/SpringArm3D/Camera3D"
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var b : float
@onready var charge : float = 0
@onready var slime_scale : Vector3 = scale
# Lets the slime do its animation even after player is flung outside its radius
@onready var temp_radius : float = charge_attack_radius
@onready var health_y : float = health_sprite.position.y

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	var i : int = 0
	while i < max_health:
		var heart = heart_module_scene.instantiate()
		heart.get_child(0).visible = false
		heart.get_child(0).get_child(0).visible = false
		health_bar.add_child(heart)
		i += 2

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Update timers
	time += delta
	health_sprite_timer += delta
	time_since_target_update += delta
	time_since_last_hop += delta
	_adjust_target()
	look_at(player.global_position)
	rotation.x = 0
	rotation.z = 0
	if health_sprite_timer > HEALTH_SHOW_TIME:
		health_gui_update(6, 10)
		health_sprite.visible = false
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return
	
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_dir: Vector3 = (global_position.direction_to(next_path_position)).normalized()
	var dist_to_player : float = global_position.distance_to(player.global_position)
	
	if time_since_last_hop > HOP_FREQUENCY:
		# Cancel any charging if player leaves radius
		charge = 0
		new_dir.y = 1
		apply_impulse(HOP_INTENSITY * new_dir)
		time_since_last_hop = 0

	# Initiate charge attack
	if (dist_to_player < temp_radius):
		temp_radius = 99999
		time_since_last_hop = HOP_FREQUENCY - chargeup_time
		#first half of the chargeup
		if charge < chargeup_time:
			# This is a formula for a gaussian curve-like graph
			var factor : float = charge_attack_radius * exp(-30 * pow(charge - (chargeup_time/2), 2)) + 1
			print(charge)
			# Scale slime
			scale = factor * slime_scale
			charge += delta
			# Shift health bar, undo scaling
			health_sprite.position.y = health_y * factor
		else:
			charge = 0
			# Reset health y pos
			health_sprite.global_position.y = health_y
			# Reset activation radius of slime charge
			temp_radius = charge_attack_radius
			slime_scale = Vector3(1, 1, 1)
			scale = Vector3(1,1,1)
	
	# Enemy dmg and knockback
	var cols = hurt_zone.get_overlapping_areas()
	for col in cols:
		var parent = col.get_parent()
		# targets in enemy and player layers must have area3d as child right under their root or this errors
		parent.apply_knockback(global_position, 100)
		parent.change_health(-1)
	
	
	#if navigation_agent.avoidance_enabled:
		#navigation_agent.set_velocity(new_velocity)
	#else:
		#_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	linear_velocity = safe_velocity

func _adjust_target() -> void :
	if time_since_target_update > REFRESH_FREQUENCY:
		navigation_agent.set_target_position(player._ground_pos)
		time_since_target_update = 0

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
	health += delta
	# Cap health
	health = min(health, max_health)
	# ded
	if health <= 0:
		queue_free()
	# Send info to the health GUI
	health_gui_update(health, max_health)

func apply_knockback(origin: Vector3) -> void:
	apply_impulse(10 * origin.direction_to(global_position) / (origin.distance_to(global_position) + 0.01))
