class_name GrappleSpawner extends Item



@export var icon : TextureRect
@export var amount : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	icon = find_child("Icon")
	item_name = "grapple"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
