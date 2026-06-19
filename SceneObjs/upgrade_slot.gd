class_name ItemSlot extends AspectRatioContainer

@onready var _cursor_slot = get_tree().root.get_child(0).find_child("ItemHold")
@onready var _augment_slot = $Augment


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var slot_rect = get_rect()
	slot_rect.position = global_position
	if event.is_action_pressed("Click") && _cursor_slot.get_child_count() > 0 && slot_rect.has_point(get_screen_transform() * get_local_mouse_position()):
		print("sending signal to all items")
		get_tree().call_group("items", "_request_item_for_slot", _augment_slot)
