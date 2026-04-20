extends Node3D


@export var icon : TextureRect
@export var amount : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon = find_child("Icon")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
