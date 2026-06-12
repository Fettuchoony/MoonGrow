class_name TurretSpawner extends PanelContainer

var target_item : Resource
var level_node : Node3D

@onready var amount_label : Label = $GUI/Amount

@export var item_name = "base_turret"
@export var icon : TextureRect
@export var amount : int = 5
	
	
func _ready() -> void:
	icon = find_child("Icon")
	target_item = preload("res://SceneObjs/gunner_turret.tscn")
	level_node = get_tree().get_nodes_in_group("levels")[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func trigger(_pos: Vector3) -> void:
	#print(gunner_turret_data)
	if target_item != null && amount > 0:
		var turret_obj = target_item.instantiate()
		level_node.add_child(turret_obj)
		turret_obj.global_position = _pos
		amount -= 1
		amount_label.text = str(amount)
