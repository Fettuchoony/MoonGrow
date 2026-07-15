#class_name DamageText extends Label3D
#
#@onready var _time : float = 0.0
#@onready var _starting_pos : Vector3 = global_position 
#@onready var _velocity : Vector3 = Vector3.ZERO
#
### How fast the label flys out of the enemy, there is gravity.
#@export var launch_strength : float = 1.0
### The randomness to the angles of emission, 0.0 = no spread, 0.5 = 45 degree spread, and so on...
#@export var spread_percent : float = 0.1
### How long the particle lasts
#@export var lifetime : float = 1.0
#
#
#func _init(init_pos : Vector3 = Vector3.ZERO) -> void:
	#_starting_pos = init_pos
	#print(_starting_pos)
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var x_spread = randf_range(-spread_percent, spread_percent)
	#var z_spread = randf_range(-spread_percent, spread_percent)
	#_velocity = Vector3(x_spread, launch_strength, z_spread) 
	#print(_velocity)
#
#func _enter_tree() -> void:
	#_time = 0
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if _time > lifetime: queue_free()
	#var grav = Vector3(0.0, 0.5 * -9.8 * pow(_time, 2), 0.0)
	#global_position = _starting_pos + _velocity * _time - grav
	#print(global_position)
	#_time += delta
