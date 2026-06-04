extends Control

@onready var _menu =  $"../../../Menus"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for item_slot in find_child("HBoxContainer").get_children():
		var slot_rect = item_slot.get_rect()
		# Shift rect to position so click aligns
		slot_rect.position =  item_slot.global_position
		# Check if shifted rect is clicked, if so bind item
		if Input.is_action_just_pressed("Click") and slot_rect.has_point(get_screen_transform() * get_local_mouse_position()) && _menu._cursor_item != null:
			item_slot.add_child(_menu._cursor_item.get_child(0).duplicate())
			print(_menu._cursor_item)
