class_name TurretSpawner extends Item

var target_item : Resource
var level_node : Node3D

@onready var load_item : Node3D

@export var icon : TextureRect
	
	
func _ready() -> void:
	super()
	icon = find_child("Icon")
	target_item = preload("res://SceneObjs/gunner_turret.tscn")
	level_node = get_tree().get_nodes_in_group("levels")[0]
	var load_platform = level_node.find_child("LoadPlatform")
	var load_item = target_item.instantiate()
	load_platform.add_child(load_item)
	load_item.global_position = load_platform.global_position + Vector3(0.0, 5.0, 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func trigger(_pos: Vector3) -> void:
	#print(gunner_turret_data)
	if target_item != null:
		var turret_obj = target_item.instantiate()
		level_node.add_child(turret_obj)
		turret_obj.global_position = _pos
