class_name HealthBar extends Node3D

# Space between the health and the background (percent of full size)
@onready var _border_thickness : float = 0.95
@onready var _bar : MeshInstance3D = MeshInstance3D.new()
@onready var _hp : MeshInstance3D = MeshInstance3D.new()
@onready var _max_hp : float = 0.0

var _enemy

func _init(enemy: Enemy, max_hp : float = 1.0) -> void:
	_max_hp = max_hp
	_enemy = enemy
	if _max_hp <= 0.0:
		printerr("HealthBar: Enemy spawned without max_hp set or it is <= 0.0")
	if !is_instance_valid(_enemy):
		printerr("HealthBar: Health Bar spawned without proper enemy parent")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_bar.mesh = load("res://SceneObjs/UI/HPBarBackground.tres")
	_hp.mesh = load("res://SceneObjs/UI/HPBar.tres")
	_hp.mesh.size = _border_thickness * _bar.mesh.size
	_hp.position += Vector3(0.0, 0.0, 0.0)

# Called every frame. 'delta' is the elapsed time since the previousd frame.
func _process(delta: float) -> void:
	pass

func update_health_bar(curr: int):
	var percent_full : float = float(_enemy.health) / float(_max_hp)
	var x_pos = -(_bar.mesh.size.x) * (percent_full - 1.0)
	var x_scale = percent_full * _bar.mesh.size.x
	var y_scale = _bar.mesh.size.y
	_hp.mesh.size = _border_thickness * Vector2(x_scale, y_scale)
	_hp.mesh.center_offset = Vector3(x_pos, 0.0, 0.0)
