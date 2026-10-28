extends Node3D

# Space between the health and the background
@onready var _border_thickness : float = 0.01
@onready var _enemy : RigidBody3D = get_parent()

@onready var _bar : MeshInstance3D = $Bar
@onready var _hp : MeshInstance3D = $Bar/HP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hp.scale = _bar.scale - Vector3(_border_thickness*2.0, _border_thickness*2.0, _border_thickness*2.0)
	_hp.position += Vector3(-_bar.scale.x/2.0 + _border_thickness, 0.0, 0.001)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (is_instance_valid(_enemy) && is_instance_valid(_enemy.player)):
		look_at(_enemy.player.global_position)
