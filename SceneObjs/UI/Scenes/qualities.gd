extends AspectRatioContainer

@export var animation_speed : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += animation_speed * delta
