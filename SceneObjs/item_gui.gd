extends AspectRatioContainer

@onready var hover : TextureRect = $Hover

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rect = get_rect()
	rect.position = global_position
	if rect.has_point(get_screen_transform() * get_local_mouse_position()):
		hover.visible = true
	else:
		hover.visible = false
