extends RigidBody3D

const BEAM_LENGTH : float = 200.0

@onready var _ray_origin : Node3D = $RayOrigin
@onready var _ray_mesh : MeshInstance3D = $RayOrigin/Ray
@onready var _phys_ray : RayCast3D = $RayOrigin/PhysRay
@onready var _contact_point : Vector3
@onready var _contact_object : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var endpoint : Vector3 = _calculate_ray_endpoint()
	_ray_mesh.mesh.height = endpoint.length()
	_ray_mesh.position = endpoint / 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _calculate_ray_endpoint() -> Vector3:
	if _phys_ray.is_colliding():
		return to_local(_phys_ray.get_collision_point())
		print("laser collision")
	else:
		return BEAM_LENGTH * Vector3.FORWARD

	
