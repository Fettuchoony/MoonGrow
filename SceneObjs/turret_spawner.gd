extends Node3D

var gunner_turret_data : Resource
var level_node : Node3D

@export var icon : TextureRect
@export var amount : int = 5

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	icon = find_child("Icon")
	gunner_turret_data = preload("res://SceneObjs/gunner_turret.tscn")
	print("Created spawner for: " + str(gunner_turret_data))
	
func _ready() -> void:
	level_node = get_tree().get_nodes_in_group("levels")[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func trigger() -> void:
	#print(gunner_turret_data)
	if gunner_turret_data != null:
		var turret_obj = gunner_turret_data.instantiate()
		level_node.add_child(turret_obj)
		turret_obj.global_position = get_parent().global_position
