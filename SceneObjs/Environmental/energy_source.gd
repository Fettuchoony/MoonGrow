extends RigidBody3D

@onready var laser : Laser = null
@onready var test_item : Item = Item.new()
@onready var _emit_point : Node3D = $EmissionPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	laser = Laser.new([test_item])
	_emit_point.add_child(laser)
	
