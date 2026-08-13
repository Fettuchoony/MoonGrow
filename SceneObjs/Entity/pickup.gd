class_name Pickup extends Sprite3D

const GRAV : float = -9.8
const AMPLITUDE : float = 5.0
const FREQ : float = 2.0
const MAG_POWER : float = 10.0


var dmg_mod : Item = preload("res://SceneObjs/Modifiers/dmg_mod_tier1.tscn").instantiate()

# init
var _item : Item

# ready
var _vel : Vector3
var _name : String
var _pickup_area : Area3D
# if object is landed, item no longer scans for collision, is only capturable
var _landed : bool
var _time : float = 0
var _expiring : bool = false
var _magnetized : bool = false
var _mag_target : Player
var _percent_to_player : float = 0.0

@export var mag_strength : Curve

# TODO: Change this to a custom default item, not just the dmg modifier
func _init(item : Item = dmg_mod, spawn_pos : Vector3 = Vector3.ZERO) -> void:
	_item = item 
	global_position = spawn_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_name = _item.item_name
	texture = _item.slot_icon
	_pickup_area = $PickupArea
	_landed = false

func _physics_process(delta: float) -> void:
	_fall_and_pickup(delta)
	if _expiring: queue_free()
	
	
func _fall_and_pickup(delta: float) -> void:
	rotation.y += delta
	# Falling and rotation
	if !_landed && _pickup_area.get_overlapping_bodies().size() == 0:
		_vel.y += GRAV * delta
		global_position += delta * _vel
	elif _magnetized && _landed:
		var curve_offset = global_position.distance_to(_mag_target.global_position) / _mag_target.pickup_radius
		global_position = global_position.move_toward(_mag_target.global_position, MAG_POWER * mag_strength.sample(curve_offset) * delta)
		print(curve_offset)
	else:
		_vel = Vector3.ZERO
		_landed = true
		offset.y = AMPLITUDE * -cos(FREQ * _time) + ((pixel_size / 0.01) * AMPLITUDE)
	
	# IMPORTANT: Player pickup is handled in player movement script
	
	_time += delta

## Returns pickup as item and destroys the pickup
func pickup_and_kill() -> Item:
	_expiring = true
	print("kill")
	return _item

func magnetize(player : Player) -> void:
	_magnetized = true
	_percent_to_player = 0.0
	_mag_target = player
