class_name GrappleSpawner extends PanelContainer

@export var item_name = "grapple"

@export var icon : TextureRect
@export var amount : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon = find_child("Icon")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
