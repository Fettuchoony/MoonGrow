extends Label3D

@onready var _lifetime : float = get_parent().lifetime
@onready var _height : Curve = get_parent().height
@onready var _spread : float = get_parent().lifetime
@onready var _size_over_life : Curve = get_parent().size_over_life
@onready var _time = 0.0
@onready var _starting_pos : Vector3 = global_position
@onready var _dir : Vector3 = Vector3(randf() * _spread, 0.0, randf() * _spread)

func init(dmg_amt : float = 0.0) -> void:
	text = str(dmg_amt)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _time > _lifetime:
		queue_free()
	_fly_off(delta)
	_time += delta

func _fly_off(delta : float) -> void:
	var new_y_pos = _height.sample(_time/_lifetime) + get_parent().global_position.y
	var new_x_pos = global_position.x + delta * _dir.x
	var new_z_pos = global_position.z + delta * _dir.z
	var new_size = _size_over_life.sample(_time/_lifetime)
	global_position = Vector3(new_x_pos, new_y_pos, new_z_pos)
	scale = Vector3(new_size, new_size, new_size)
	
