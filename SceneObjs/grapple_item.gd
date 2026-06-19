extends Node3D



@onready var time : float = 0
@onready var player : Node3D = $"../../../../../MainPlayer"
@onready var start_pos : Vector3 = global_position
@onready var aim_cast : RayCast3D = $"../../../../../MainPlayer/CameraPivot/SpringArm3D/Camera3D/PlayerRay"
@onready var rb : RigidBody3D = $RigidBody3D
@onready var debug_ball = $StaticBody3D
@onready var aim_pos : Vector3 = aim_cast.get_collision_point()
@onready var rawdist : float = start_pos.distance_to(aim_pos)
@onready var life : float = 1
# Theres some parabola magic going on here
@onready var b : float = (aim_pos.y/rawdist) + arch_factor * rawdist
# Arc length equation
@onready var arc_length : float = 0.5 * sqrt(pow(b, 2) + 16 * pow(arch_factor, 2)) + (pow(b, 2) / (8 * arch_factor)) * log((4 * arch_factor + sqrt(pow(b, 2) + 16 * pow(arch_factor, 2))) / b)

@export var arch_factor : float = 1
@export var strength : float = 1
@export var lifetime_factor : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# lifetime exponentially scaled
	life = arc_length


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# If flying through air
	if time < life:
		var percent_complete : float = time/life
		var t_pos : float = lerpf(0, rawdist, percent_complete)
		
		#print(arc_length)
		global_position.y = -arch_factor * pow(t_pos, 2) + b * t_pos
		global_position.x = lerp(start_pos.x, aim_pos.x, percent_complete)
		global_position.z = lerp(start_pos.z, aim_pos.z, percent_complete)
		#print(global_position)
	# If landed
	time += delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	print_debug(rb.global_position)
	debug_ball.global_position = rb.global_position
