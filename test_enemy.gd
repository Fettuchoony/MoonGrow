# HELP: https://docs.godotengine.org/en/4.6/tutorials/navigation/navigation_using_navigationagents.html
class_name Slime extends Enemy

static var HOP_FREQUENCY : float = 2
static var HOP_INTENSITY : float = 4


@export var charge_attack_radius: float = 5
@export var chargeup_time : float = 5

# Theres some parabola magic going on here
@onready var b : float
@onready var charge : float = 0
@onready var slime_scale : Vector3 = scale
# Lets the slime do its animation even after player is flung outside its radius
@onready var temp_radius : float = charge_attack_radius
@onready var health_y : float = health_sprite.position.y

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Update timers
	time_since_last_hop += delta
	#look_at(player.global_position)
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
	var dist_to_target : float = global_position.distance_to(player.global_position)
	
	var next_path_pos = navigation_agent.get_next_path_position()
	look_at(Vector3(next_path_pos.x, global_position.y, next_path_pos.z))
	
	if time_since_last_hop > HOP_FREQUENCY:
		# Cancel any charging if player leaves radius
		charge = 0
		new_dir.y = 1
		apply_impulse(HOP_INTENSITY * new_dir)
		time_since_last_hop = 0

	# Initiate charge attack, probably will be removed idk
	if (dist_to_target < temp_radius):
		temp_radius = 99999
		time_since_last_hop = HOP_FREQUENCY - chargeup_time
		#first half of the chargeup
		if charge < chargeup_time:
			# This is a formula for a gaussian curve-like graph
			var factor : float = charge_attack_radius * exp(-30 * pow(charge - (chargeup_time/2), 2)) + 1
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
