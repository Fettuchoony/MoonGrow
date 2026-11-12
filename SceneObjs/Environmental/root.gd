class_name Root extends Node3D

# QUICK REFERENCE
# USE: get_tree().root.get_child(0).VARIBLE_NAME
# This will allow easy access to frequently accessed variables

@onready var entities = $CurrentLevel/MainTestScene/Objects/Entities


@onready var curr_level = $CurrentLevel/MainTestScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
