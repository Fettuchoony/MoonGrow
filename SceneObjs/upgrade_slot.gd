class_name ItemSlot extends AspectRatioContainer

@onready var _cursor_slot = get_tree().root.get_child(0).find_child("ItemHold")
@onready var _augment_slot = $Augment

@export var _is_cursor_slot = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_cursor_slot:
		global_position = get_screen_transform() * get_local_mouse_position()
		if _augment_slot.get_child_count() > 0:
			visible = true
		else:
			visible = false

func _input(event: InputEvent) -> void:
	if !_is_cursor_slot:
		var slot_rect = get_rect()
		slot_rect.position = global_position
		if event.is_action_pressed("Click") && _cursor_slot.get_child_count() > 0 && slot_rect.has_point(get_screen_transform() * get_local_mouse_position()) && _augment_slot.get_child_count() == 0:
			print("sending signal to all items")
			get_tree().call_group("items", "_request_item_for_slot", _augment_slot)
