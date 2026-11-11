extends Node3D

# Space between the health and the background (percent of full size)
@onready var _border_thickness : float = 0.95
@onready var _enemy : Enemy = get_parent()

@onready var _bar : MeshInstance3D = $Bar
@onready var _hp : MeshInstance3D = $Bar/HP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hp.mesh.size = _border_thickness * _bar.mesh.size
	_hp.position += Vector3(0.0, 0.0, 0.0)

# Called every frame. 'delta' is the elapsed time since the previousd frame.
func _process(delta: float) -> void:
	pass

func update_health_bar(curr: int):
	if (is_instance_valid(_enemy) && is_instance_valid(_enemy.player)):
		look_at(_enemy.player.global_position)
	var percent_full : float = float(_enemy.health) / float(_enemy.max_health)
	var x_pos = -(_bar.mesh.size.x) * (percent_full - 1.0)
	var x_scale = percent_full * _bar.mesh.size.x
	var y_scale = _bar.mesh.size.y
	_hp.mesh.size = _border_thickness * Vector2(x_scale, y_scale)
	_hp.mesh.center_offset = Vector3(x_pos, 0.0, 0.0)
