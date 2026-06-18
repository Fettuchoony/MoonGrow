extends AspectRatioContainer

@onready var _cursor_slot = get_tree().root.get_child(0).find_child("ItemHold")
@onready var _augment_slot = $Augment


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Click") && _cursor_slot.get_child_count() > 0:
		var slot_rect = get_rect()
		# Shift rect to position so click aligns
		slot_rect.position = global_position
		if slot_rect.has_point(get_screen_transform() * get_local_mouse_position()):
			_cursor_slot.get_child(0).reparent(_augment_slot)
			_augment_slot.get_child(0).position = Vector2.ZERO
