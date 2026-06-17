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
		
		# Flags
		var clicked : bool = Input.is_action_just_pressed("Click")
		var in_rect : bool = slot_rect.has_point(get_screen_transform() * get_local_mouse_position())
		var holding_item_in_cursor : bool = _menu._cursor_item != null && _menu._cursor_item.get_child_count() > 0
		var is_augment : bool = false
		if holding_item_in_cursor: is_augment = _menu._cursor_item.get_child(0) is Augment
		var item_slot_filled : bool = item_slot.get_child_count() > 2
		
			
		# Check if shifted rect is clicked, if so bind item
		# Dont let augments be put in task bar, they only go in turrets
		if clicked && in_rect && holding_item_in_cursor && !is_augment:
			#print(_menu._cursor_item.get_child(0))
			# if there is already something in the slot
			if item_slot_filled:
				item_slot.get_child(2).queue_free()
			_menu._cursor_item.get_child(0).reparent(item_slot)
		elif clicked && in_rect && !holding_item_in_cursor && item_slot_filled:
			item_slot.get_child(2).reparent(_menu._cursor_item)
		
