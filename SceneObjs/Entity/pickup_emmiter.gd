## This object is mostly for testing pickups, normally they should be instantiated by a source (enemy death, shop purchase, etc...)
extends Node3D

@onready var time : float = 0

@onready var frequency : float = 3.0

@export var target : Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time > frequency:
		var item = preload("res://SceneObjs/Modifiers/dmg_mod_tier1.tscn").instantiate()
		add_child(item)
		Pickup.new(item, global_position)
		time = 0.0
		print("spawn")
	time += delta
