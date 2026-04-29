extends Control

const DEFAULT_ICON_SIZE = 32.0


@onready var _item_slots : Control = $TabContainer/Inventory/HFlowContainer
@onready var current_focus_item : TextureRect
## The rects that contain the item icon
@onready var _taskbar_rects = $"../MainPlayer/GUI/TaskBar/HBoxContainer".get_children()
@onready var _equip_texture = preload("res://SceneObjs/equipped.tscn")
@onready var _player : CharacterBody3D = $"../MainPlayer"
@onready var _current_hovered_item_name : String = ""
@onready var turret_scene = preload("res://SceneObjs/turret_placement.tscn")
@onready var placement_ray : RayCast3D = $"../MainPlayer/CameraPivot/SpringArm3D/Camera3D/PlacementRay"
@onready var _currently_idleing : bool = false
@onready var _current_idle_obj = null



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_execute_idles()
	_item_hovering_and_selection_func()
	

# Player Controller sends a signal to toggle visibility
# Player controller handles mouse unlocking 
func _on_main_player_pause_menu() -> void:
	if visible:
		visible = false
	else:
		visible = true


## Executes all idle anims TODO: might replace with animgraph at some point?
func _execute_idles() -> void:
	# Turrets idle is the mesh floating infront of the player, specifics managed by turret placement tscn
	if _current_hovered_item_name.ends_with("turret"):
		if _currently_idleing && _current_idle_obj == null:
			var placement_location = placement_ray.get_collision_point()
			_current_idle_obj = turret_scene.instantiate()
			_current_idle_obj.position = placement_location
			# Find current level to place turret
			var curr_level = get_tree().get_nodes_in_group("levels")
			if curr_level == null:
				print("Cannot find current level for turret placement")
			else:
				curr_level = curr_level[0]
			# This way, turrets are saved on changing level
			curr_level.add_child(_current_idle_obj)
	elif (_current_idle_obj != null && _current_idle_obj.place_mode == true):
		_current_idle_obj.free()


func _refresh_inventory() -> void:
	# These are reasserted here because sometimes refresh is called before this script readies
	_item_slots = $TabContainer/Inventory/HFlowContainer
	_player = $"../MainPlayer"
	if _item_slots.get_children() == null:
		return
	# Add new icons
	var inv = _player._inventory
	assert(inv != null, "Fatal error: inventory not refreshable")
	for item in inv:
		var item_gui : Control = item.find_child("GUI", true, false).duplicate()
		var amount_label : Label = item_gui.get_node("Amount")
		var item_icon : TextureRect = item_gui.get_node("Icon")
		item_gui.name = item.name
		item_gui.visible = true
		#print("item name = " + item_gui.name)
		# Update item count
		if amount_label != null:
			amount_label.text = str(item.amount)
		var already_in_menu = false
		for icon in _item_slots.get_children():
			if icon.name == item.name: 
				already_in_menu = true
		# If the item is already in the inventory, just update it
		## TODO: increment item count when picking up duplicates
		if already_in_menu:
			pass
		# If the item is new to the inventory, add it
		else:
			_item_slots.add_child(item_gui)
		# Do not scale taskbar rects

func _item_hovering_and_selection_func() -> void:
	# Make sure player connection good
	if _item_slots != null && _player != null && visible:
		# Go through each item slot, these are generated on pickup_item in player script
		for slot in _item_slots.get_children():
			# Get the rect of the actual item
			var slot_icon : TextureRect =  slot.find_child("Icon")
			assert(slot_icon != null)
			var slot_rect = slot_icon.get_rect()
			# Shift rect to position so click aligns
			slot_rect.position = slot.global_position
			# Check if shifted rect is clicked, if so bind item
			if Input.is_action_just_pressed("Click") and slot_rect.has_point(get_screen_transform() * get_local_mouse_position()):
				var equip_tex : TextureRect = slot.find_child("Equipped")
				# If item isnt equipped already:
				slot.find_child("Equipped").visible = true
				_player._unbind_item(_player._current_taskbar_index)
				_player._bind_item(slot)
			var is_in_taskbar = false
			for item in _player._taskbar_items:
				if item == slot.name:
					is_in_taskbar = true
			if !is_in_taskbar:
				slot.find_child("Equipped").visible = false
			else:
				slot.find_child("Equipped").visible = true

# When GUI icons size change from the slider
func _on_h_slider_value_changed(value: float) -> void:
	# 32 is the default pixel art texture res
	var new_size : float = DEFAULT_ICON_SIZE * value
	for item in _item_slots.get_children():
		item.custom_minimum_size = Vector2(new_size, new_size)
		for child in item.get_children():
			child.custom_minimum_size = Vector2(new_size, new_size)
			if child.name == "Amount":
				# divide by two because we dont want it to be too big
				child.label_settings.font_size = new_size / 2
	for taskbar_rect in _taskbar_rects:
		taskbar_rect.custom_minimum_size = Vector2(DEFAULT_ICON_SIZE, DEFAULT_ICON_SIZE)
		for child_rect in taskbar_rect.get_children():
			child_rect.custom_minimum_size = Vector2(DEFAULT_ICON_SIZE, DEFAULT_ICON_SIZE)
		
