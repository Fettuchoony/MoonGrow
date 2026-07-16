extends Node3D

@onready var _root = get_parent()
@onready var _player = $"../MainPlayer"
@onready var _menus = $"../Menus"
@onready var _curr_level = _root.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Map"):
		print("map")
