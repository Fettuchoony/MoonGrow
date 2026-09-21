class_name Laser extends Node3D

const BEAM_LENGTH : float = 200.0

@onready var _ray_mesh : MeshInstance3D = MeshInstance3D.new()
@onready var _phys_ray : RayCast3D = RayCast3D.new()

func _init(transmited_items : Array[Item] = Array()) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_beam()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	call_deferred("_pos_and_size")

func _calculate_ray_endpoint() -> Vector3:
	if _phys_ray.is_colliding():
		return to_local(_phys_ray.get_collision_point())
	else:
		return BEAM_LENGTH * Vector3.FORWARD

func _pos_and_size() -> void:
	var endpoint : Vector3 = _calculate_ray_endpoint()
	_ray_mesh.mesh.height = endpoint.length()
	_ray_mesh.position = endpoint / 2.0
	
func _init_beam() -> void:
	add_child(_ray_mesh)
	add_child(_phys_ray)
	_ray_mesh.mesh = preload("res://Materials/laser_ray_mesh.tres")
	_ray_mesh.rotate_x(PI/2.0)
	_phys_ray.target_position = Vector3(0.0, 0.0, -BEAM_LENGTH)
