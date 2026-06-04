extends Control

var target_item : Resource
var level_node : Node3D

@export var icon : TextureRect
@export var amount : int = 5

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	icon = find_child("Icon")
	target_item = preload("res://SceneObjs/gunner_turret.tscn")
	
	
func _ready() -> void:
	level_node = get_tree().get_nodes_in_group("levels")[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func trigger() -> void:
	#print(gunner_turret_data)
	if target_item != null:
		var turret_obj = target_item.instantiate()
		level_node.add_child(turret_obj)
		turret_obj.global_position = get_parent().global_position
