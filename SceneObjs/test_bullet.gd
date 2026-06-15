class_name Bullet extends RigidBody3D

var _dmg_area : Area3D
var _death_time : float
var _time_alive : float
var _dmg : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_dmg_area = $DamageArea
	_time_alive = 0
	# Set by turret, default to 5
	_death_time = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	_dmg_calc()
	_time_alive += delta
	if _time_alive > _death_time: queue_free()
	
	
func _dmg_calc() -> void:
	if _dmg_area.has_overlapping_bodies():
		for col in _dmg_area.get_overlapping_bodies():
			col.recieve_dmg(_dmg)
		queue_free()
