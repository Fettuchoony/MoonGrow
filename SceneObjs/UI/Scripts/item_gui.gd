extends AspectRatioContainer

@onready var _hover : TextureRect = $Hover
@onready var _texture : TextureRect = $Icon

@export var icon : Texture2D = preload("res://Textures/Extracted/PlaceholderItem.png")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var rect = get_rect()
	rect.position = global_position
	if rect.has_point(get_screen_transform() * get_local_mouse_position()):
		_hover.visible = true
	else:
		_hover.visible = false
