## DEPRECATED
extends Area3D

## Set this loaders subscene so scene manager can grab it on load
@onready var subscene : int = 0
@onready var scene_target_index : int = 0
@onready var subscene_target_index : int = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
## This must be called by parent object to make loader work
func init_loader(scene_target : int, subscene_target : int, this_subscene : int) -> void:
	scene_target_index = scene_target
	subscene_target_index = subscene_target
	subscene = this_subscene
