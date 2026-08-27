extends Area3D

var master_level : Node3D
var global_shift : Vector3

@export var target_level : PackedScene



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_level = find_parent("CurrentLevel")
	global_shift = $GlobalShift.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for player in get_overlapping_areas():
		master_level.load_level(target_level, global_shift)
