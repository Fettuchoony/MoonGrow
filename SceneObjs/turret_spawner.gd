class_name TurretSpawner extends Item

var target_item : Resource
var level_node : Node3D

@onready var load_item : Node3D

@export var icon : TextureRect
	
	
func _ready() -> void:
	icon = find_child("Icon")
	target_item = preload("res://SceneObjs/gunner_turret.tscn")
	level_node = get_tree().get_nodes_in_group("levels")[0]
	var load_item = target_item.instantiate()
	add_child(load_item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Deletes init turret that was created to prevent lag
	if load_item != null: load_item.queue_free()
	
func trigger(_pos: Vector3) -> void:
	#print(gunner_turret_data)
	if target_item != null:
		var turret_obj = target_item.instantiate()
		level_node.add_child(turret_obj)
		turret_obj.global_position = _pos
