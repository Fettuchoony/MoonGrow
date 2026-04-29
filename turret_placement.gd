## DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED
extends RigidBody3D

enum Turret_Type {gunner}

var placement_ray : RayCast3D
var turret_mesh : MeshInstance3D

@onready var turret : Node3D
@onready var place_mode : bool = true
@onready var item_spawn_node : Node3D

@export var turret_type : Turret_Type = Turret_Type.gunner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_spawn_node = $"../../MainPlayer".find_child("ItemSpawnSpot")
	if item_spawn_node == null:
		print("Could not find placement position reference for turret spawn")
	var temp_turret = load("res://SceneObjs/" + Turret_Type.keys()[turret_type] + "_turret.tscn")
	turret = temp_turret.instantiate()
	add_child(turret)
	turret_mesh = turret.find_child("TurretMesh")
	print("placed: " + turret.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	print(turret_mesh)
	if place_mode && turret_mesh != null:
		linear_velocity = Vector3(0,0,0)
		turret_mesh.global_position = item_spawn_node.global_position
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Click") && place_mode == true:
		place_mode = false
		turret.global_position = item_spawn_node.global_position
		turret_mesh.position = Vector3(0,0,0)
		# Grabs turret specific collision to use
		var col : CollisionShape3D = turret.find_child("TurretCollision")
		if col != null:
			col.reparent(self)

		
		
