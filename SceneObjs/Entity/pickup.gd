class_name Pickup extends Sprite3D

const GRAV : float = -9.8
const AMPLITUDE : float = 5.0
const FREQ : float = 2.0

var dmg_mod : Item = preload("res://SceneObjs/Modifiers/dmg_mod_tier1.tscn").instantiate()

# init
var _item : Item

# ready
var _name : String
var _vel : Vector3
var _pickup_area : Area3D
# if object is landed, item no longer scans for collision, is only capturable
var _landed : bool
var _time : float = 0

# TODO: Change this to a custom default item, not just the dmg modifier
func _init(item : Item = dmg_mod) -> void:
	_item = item 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_name = _item.item_name
	texture = _item.slot_icon
	_pickup_area = $PickupArea
	_landed = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_fall_and_pickup(delta)
	
func _fall_and_pickup(delta: float) -> void:
	# Falling and rotation
	if !_landed && _pickup_area.get_overlapping_areas().size() == 0 && _pickup_area.get_overlapping_bodies().size() == 0:
		_vel.y += GRAV * delta
		global_position += delta * _vel
	else:
		_landed = true
		offset.y = AMPLITUDE * -cos(FREQ * _time) + ((pixel_size / 0.01) * AMPLITUDE)
		rotation.y += delta
	
	# IMPORTANT: Player pickup is handled in player movement script
	
	_time += delta
