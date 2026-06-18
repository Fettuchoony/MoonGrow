extends Control

@onready var _menu =  $"../../../Menus"

@onready var _cursor_slot = $"../ItemHold"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("Click"):
		#for item_slot in find_child("HBoxContainer").get_children():
			#var slot_rect = item_slot.get_rect()
			## Shift rect to position so click aligns
			#slot_rect.position =  item_slot.global_position
			#
			## Flags
			#var in_rect : bool = slot_rect.has_point(get_screen_transform() * get_local_mouse_position())
			#var holding_item_in_cursor : bool = _cursor_slot != null && _cursor_slot.get_child_count() > 0
			#var is_item : bool = false
			#if holding_item_in_cursor: is_item = _cursor_slot.get_child(0) is Item
			#var item_slot_filled : bool = item_slot.find_child("Augment").get_child_count() > 0
			#
			### Assigning item to empty slot
			#if in_rect && holding_item_in_cursor && is_item && !item_slot_filled:
				#var curr_item : Item = _cursor_slot.get_child(0)
				#curr_item.move(item_slot)
		#
		 #Grabbing item from slot
		#if clicked && in_rect && !holding_item_in_cursor && is_item && item_slot_filled:
			#var taskbar_item = item_slot.get_child(0)
			#taskbar_item.move(_cursor_slot)
		
		# Swapping item in slot
		
