extends Node3D

@onready var _curr_level : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_curr_level = get_child(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_child_count() == 1:
		_curr_level = get_child(0)

func load_level(level : PackedScene, global_shift : Vector3):
	if level == null:
		push_error("Load zone has unnasigned target level")
	if _curr_level != null:
		print("new_level")
		var prev_level = _curr_level
		_curr_level = level.instantiate()
		add_child(_curr_level)
		_curr_level.global_position = global_shift
		prev_level.queue_free()
